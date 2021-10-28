//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//

#import "VVEventBus.h"

#import <pthread.h>
#import <objc/runtime.h>

#import "NSObject+VVEventBus.h"
#import "VVEventBusCollection.h"
#import "NSNotification+VVEvent.h"
#import "NSObject+VVEventBusPrivate.h"

static inline NSString *__generateUnqiueKey(Class <VVIEvent> cls, NSString *eventType) {
    Class targetClass = [cls respondsToSelector:@selector(eventClass)] ? [cls eventClass] : cls;
    if (eventType) {
        return [NSString stringWithFormat:@"%@_of_%@", eventType, NSStringFromClass(targetClass)];
    } else {
        return NSStringFromClass(targetClass);
    }
}

/**
 内存中保存的监听者
 */
@interface VVEventSubscriberMaker ()

- (instancetype)initWithEventBus:(VVEventBus *)eventBus
                      eventClass:(Class)eventClass;

@property(strong, nonatomic) Class eventClass;

@property(strong, nonatomic) NSObject *lifeTimeTracker;

@property(strong, nonatomic) dispatch_queue_t queue;

@property(strong, nonatomic) NSMutableArray *eventSubTypes;

@property(strong, nonatomic) VVEventBus *eventBus;

@property(copy, nonatomic) void (^hander)(__kindof NSObject *);

@end


/**
 保存的监听者信息
 */
@interface _VVEventSubscriber : NSObject <QTEventBusContainerValue>

@property(strong, nonatomic) Class eventClass;

@property(copy, nonatomic) void (^handler)(__kindof NSObject *);

@property(strong, nonatomic) dispatch_queue_t queue;

@property(copy, nonatomic) NSString *uniqueId;

@end

@implementation _VVEventSubscriber

- (NSString *)valueUniqueId {
    return self.uniqueId;
}

@end

/**
 返回可以取消的token
 */
@interface _VVEventToken : NSObject <VVIEventToken>

@property(copy, nonatomic) NSString *uniqueId;

@property(copy, nonatomic) void (^onDispose)(NSString *uniqueId);

@property(assign, nonatomic) BOOL isDisposed;

@end

@implementation _VVEventToken

- (instancetype)initWithKey:(NSString *)uniqueId {
    if (self = [super init]) {
        _uniqueId = uniqueId;
        _isDisposed = NO;
    }
    return self;
}

- (void)dispose {
    @synchronized (self) {
        if (_isDisposed) {
            return;
        }
        _isDisposed = YES;
    }
    if (self.onDispose) {
        self.onDispose(self.uniqueId);
    }
}
@end

/**
 组合token
 */
@interface _VVComposeToken : NSObject <VVIEventToken>

- (instancetype)initWithTokens:(NSArray<_VVEventToken *> *)tokens;

@property(assign, nonatomic) BOOL isDisposed;

@property(strong, nonatomic) NSArray<_VVEventToken *> *tokens;

@end

@implementation _VVComposeToken

- (instancetype)initWithTokens:(NSArray<_VVEventToken *> *)tokens {
    if (self = [super init]) {
        _tokens = tokens;
        _isDisposed = NO;
    }
    return self;
}

- (void)dispose {
    @synchronized (self) {
        if (_isDisposed) {
            return;
        }
        _isDisposed = YES;
    }
    for (_VVEventToken *token in self.tokens) {
        [token dispose];
    }
}

@end


@interface VVEventBus () {
    pthread_mutex_t _accessLock;
}

@property(copy, nonatomic) NSString *prefix;

@property(strong, nonatomic) VVEventBusCollection *collection;

@property(strong, nonatomic) dispatch_queue_t publishQueue;

@property(strong, nonatomic) NSMutableDictionary *notificationTracker;

@end

@implementation VVEventBus

+ (instancetype)shared {
    static VVEventBus *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[VVEventBus alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _prefix = @([[NSDate date] timeIntervalSince1970]).stringValue;
        _collection = [[VVEventBusCollection alloc] init];
        _publishQueue = dispatch_queue_create("com.eventbus.publish.atQueue", DISPATCH_QUEUE_SERIAL);
        _notificationTracker = [[NSMutableDictionary alloc] init];
        pthread_mutex_init(&_accessLock, NULL);
    }
    return self;
}

- (void)lockAndDo:(void (^)(void))block {
    @try {
        pthread_mutex_lock(&_accessLock);
        block();
    } @finally {
        pthread_mutex_unlock(&_accessLock);
    }
}

#pragma mark - Normal Event


- (id <VVIEventToken>)_createNewSubscriber:(VVEventSubscriberMaker *)maker {
    if (!maker.hander) {
        return nil;
    }
    if (maker.eventSubTypes.count == 0) {//一级事件
        _VVEventToken *token = [self _addSubscriberWithMaker:maker eventType:nil];
        return token;
    }
    NSMutableArray *tokens = [[NSMutableArray alloc] init];
    for (NSString *eventType in maker.eventSubTypes) {
        _VVEventToken *token = [self _addSubscriberWithMaker:maker eventType:eventType];
        [tokens addObject:token];
    }
    _VVComposeToken *token = [[_VVComposeToken alloc] initWithTokens:tokens];
    return token;
}

- (void)_addNotificationObserverIfNeeded:(NSString *)name {
    if (!name) {return;}
    [self lockAndDo:^{
        if (self.notificationTracker[name]) {
            return;
        }
        self.notificationTracker[name] = @(1);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:name object:nil];
    }];
}

- (void)_removeNotificationObserver:(NSString *)name {
    if (!name) {return;}
    [self lockAndDo:^{
        [self.notificationTracker removeObjectForKey:name];
        @try {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:name object:nil];
        } @catch (NSException *exception) {
        }
    }];
}

- (_VVEventToken *)_addSubscriberWithMaker:(VVEventSubscriberMaker *)maker eventType:(NSString *)eventType {
    __weak typeof(self) weakSelf = self;
    NSString *eventKey = __generateUnqiueKey(maker.eventClass, eventType);
    NSString *groupId = [self.prefix stringByAppendingString:eventKey];
    NSString *uniqueId = [groupId stringByAppendingString:@([NSDate date].timeIntervalSince1970).stringValue];
    _VVEventToken *token = [[_VVEventToken alloc] initWithKey:uniqueId];
    BOOL isCFNotifiction = (maker.eventClass == [NSNotification class]);
    if (eventType && isCFNotifiction) {
        [self _addNotificationObserverIfNeeded:eventType];
    }
    token.onDispose = ^(NSString *uniqueId) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        BOOL empty = [strongSelf.collection removeUniqueId:uniqueId ofKey:groupId];
        if (empty && isCFNotifiction) {
            [strongSelf _removeNotificationObserver:eventType];
        }
    };
    //创建监听者
    _VVEventSubscriber *subscriber = [[_VVEventSubscriber alloc] init];
    subscriber.queue = maker.queue;
    subscriber.handler = maker.hander;
    subscriber.uniqueId = uniqueId;
    if (maker.lifeTimeTracker) {
        [maker.lifeTimeTracker.eb_disposeBag addToken:token];
    }
    [self.collection addObject:subscriber forKey:groupId];
    return token;
}

- (VVEventSubscriberMaker<id> *(^)(Class eventClass))on {
    return ^VVEventSubscriberMaker *(Class eventClass) {
        return [[VVEventSubscriberMaker alloc] initWithEventBus:self
                                                     eventClass:eventClass];
    };
}

- (VVEventSubscriberMaker<id> *)on:(Class)eventClass {
    return [[VVEventSubscriberMaker alloc] initWithEventBus:self eventClass:eventClass];
}

- (void)receiveNotification:(NSNotification *)notificaion {
    [self dispatch:notificaion];
}

- (void)dispatch:(id <VVIEvent>)event {
    if (!event) {
        return;
    }
    NSString *eventSubType = [event respondsToSelector:@selector(eventSubType)] ? [event eventSubType] : nil;
    if (eventSubType) {
        //二级事件
        NSString *key = __generateUnqiueKey(event.class, eventSubType);
        [self _publishKey:key event:event];
    }
    //一级事件
    NSString *key = __generateUnqiueKey(event.class, nil);
    [self _publishKey:key event:event];
}

- (void)dispatchOnBusQueue:(id <VVIEvent>)event {
    dispatch_async(self.publishQueue, ^{
        [self dispatch:event];
    });
}

- (void)dispatchOnMain:(id <VVIEvent>)event {
    if ([NSThread isMainThread]) {
        [self dispatch:event];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dispatch:event];
        });
    }
}

- (void)_publishKey:(NSString *)eventKey event:(NSObject *)event {
    NSString *groupId = [self.prefix stringByAppendingString:eventKey];
    NSArray *subscribers = [self.collection objectsForKey:groupId];
    if (!subscribers || subscribers.count == 0) {
        return;
    }
    for (_VVEventSubscriber *subscriber in subscribers) {
        if (subscriber.queue) { //异步分发
            dispatch_async(subscriber.queue, ^{
                if (subscriber.handler) {
                    subscriber.handler(event);
                }
            });
        } else { //同步分发
            if (subscriber.handler) {
                subscriber.handler(event);
            }
        }

    }
}

@end

@implementation VVEventSubscriberMaker

- (NSMutableArray *)eventSubTypes {
    if (!_eventSubTypes) {
        _eventSubTypes = [[NSMutableArray alloc] init];
    }
    return _eventSubTypes;
}

- (instancetype)initWithEventBus:(VVEventBus *)eventBus
                      eventClass:(Class)eventClass {
    if (self = [super init]) {
        _eventBus = eventBus;
        _eventClass = eventClass;
        _queue = nil;
    }
    return self;
}

- (id <VVIEventToken>)doNext:(VVEventNextBlock)hander {
    return self.doNext(hander);
}

- (VVEventSubscriberMaker *)atQueue:(dispatch_queue_t)queue {
    return self.atQueue(queue);
}

- (VVEventSubscriberMaker *)freeWith:(id)object {
    return self.freeWith(object);
}

- (VVEventSubscriberMaker *)ofSubType:(NSString *)subType {
    return self.ofSubType(subType);
}

#pragma mark - 点语法

- (VVEventSubscriberMaker<id> *(^)(dispatch_queue_t))atQueue {
    return ^VVEventSubscriberMaker *(dispatch_queue_t queue) {
        self.queue = queue;
        return self;
    };
}

- (VVEventSubscriberMaker<id> *(^)(NSString *))ofSubType {
    return ^VVEventSubscriberMaker *(NSString *eventType) {
        if (!eventType) {
            return self;
        }
        @synchronized (self) {
            [self.eventSubTypes addObject:eventType];
        }
        return self;
    };
}

- (VVEventSubscriberMaker<id> *(^)(id))freeWith {
    return ^VVEventSubscriberMaker *(id lifeTimeTracker) {
        self.lifeTimeTracker = lifeTimeTracker;
        return self;
    };
}

- (id <VVIEventToken>(^)(void(^)(id event)))doNext {
    return ^id <VVIEventToken>(void(^hander)(__kindof id event)) {
        self.hander = hander;
        return [self.eventBus _createNewSubscriber:self];
    };
}

@end


