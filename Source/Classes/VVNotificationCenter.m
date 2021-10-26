//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//


#import "VVNotificationCenter.h"

#import <objc/runtime.h>

#import "VVModuleProtocol.h"

@interface VVNotificationCenter ()

@property(unsafe_unretained, nonatomic) Class moduleClazz;

@end

@interface TPNotificationMaker ()

@property(copy, nonatomic) NSString *m_name;
@property(strong, nonatomic) id m_object;
@property(strong, nonatomic) id m_userInfo;

@end

@interface TPNotificationObserver : NSObject

@property(weak, nonatomic) id target;

@end

@implementation VVNotificationCenter

+ (instancetype)centerWithModule:(Class)module {
    NSAssert([module conformsToProtocol:@protocol(VVModuleProtocol)], @"Module class don't conform to 'VVModuleProtocol'");
    if (![module conformsToProtocol:@protocol(VVModuleProtocol)]) {
        return nil;
    }

    VVNotificationCenter *instance = [[VVNotificationCenter alloc] init];
    instance.moduleClazz = module;
    return instance;
}

+ (instancetype)defaultCenter {
    static VVNotificationCenter *TPNotificationCenterInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TPNotificationCenterInstance = [[VVNotificationCenter alloc] init];
    });
    return TPNotificationCenterInstance;
}

- (void)broadcastNotification:(void (^)(TPNotificationMaker *))makerHandler {
    TPNotificationMaker *maker = [[TPNotificationMaker alloc] init];
    makerHandler(maker);
    NSAssert(maker.m_name, @"Broadcast-notification's name cannot be nil!");
    if (!maker.m_name) {
        return;
    }

    NSString *name = [VVNotificationCenter broadcastNotificationName:maker.m_name moduleLevel:[self moduleLevel]];
    NSNotification *notification = [[NSNotification alloc] initWithName:name object:maker.m_object userInfo:maker.m_userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)reportNotification:(void (^)(TPNotificationMaker *))makerHandler targetModule:(NSString *)moduleName {
    TPNotificationMaker *maker = [[TPNotificationMaker alloc] init];
    makerHandler(maker);
    NSAssert(maker.m_name, @"Report-notification's name cannot be nil!");
    if (!maker.m_name) {
        return;
    }

    VVModuleLevel moduleLevel = [self moduleLevel];
    VVModuleLevel targetModuleLevel = VVModuleLevelBasic;
    Class targetModule = NSClassFromString(moduleName);
    if ([targetModule respondsToSelector:@selector(moduleLevel)]) {
        targetModuleLevel = [targetModule moduleLevel];
    }

    NSAssert(targetModuleLevel <= moduleLevel, @"High-level module report to basic-level module");
    if (targetModuleLevel > moduleLevel) {
        return;
    }

    NSString *name = [VVNotificationCenter reportNotificationName:maker.m_name targetModuleName:moduleName];
    NSNotification *notification = [[NSNotification alloc] initWithName:name object:maker.m_object userInfo:maker.m_userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

static char const *const TPNotificationObserverKey = "TPNotificationObserverKey";

- (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName object:(id)anObject {
    NSParameterAssert(observer);
    if (!observer) {
        return;
    }

    TPNotificationObserver *obsv;
    @synchronized (observer) {
        obsv = objc_getAssociatedObject(observer, TPNotificationObserverKey);
        if (!obsv) {
            obsv = [[TPNotificationObserver alloc] init];
            objc_setAssociatedObject(observer, TPNotificationObserverKey, obsv, OBJC_ASSOCIATION_RETAIN);
        }
        obsv.target = observer;
    }

    for (int i = [self moduleLevel] - 1; i >= 0; i--) {
        NSString *name = [VVNotificationCenter broadcastNotificationName:aName moduleLevel:i];
        [[NSNotificationCenter defaultCenter] addObserver:obsv selector:aSelector name:name object:anObject];
    }

    NSString *name = [VVNotificationCenter reportNotificationName:aName targetModuleName:NSStringFromClass(self.moduleClazz)];
    [[NSNotificationCenter defaultCenter] addObserver:obsv selector:aSelector name:name object:anObject];
}

#pragma mark - private

- (VVModuleLevel)moduleLevel {
    VVModuleLevel moduleLevel = VVModuleLevelBasic;
    if ([self.moduleClazz respondsToSelector:@selector(moduleLevel)]) {
        moduleLevel = [self.moduleClazz moduleLevel];
    }
    return moduleLevel;
}

static NSString *const BroadcastNotificationNameSuffix = @"broadcast";
static NSString *const ReportNotificationNameSuffix = @"report";

+ (NSString *)broadcastNotificationName:(NSString *)name moduleLevel:(VVModuleLevel)level {
    NSString *levelName = [self levelNameWithModuleLevel:level];
    return [NSString stringWithFormat:@"%@#%@_%@", name, levelName, BroadcastNotificationNameSuffix];
}

+ (NSString *)reportNotificationName:(NSString *)name targetModuleName:(NSString *)targetModuleName {
    return [NSString stringWithFormat:@"%@#%@_%@", name, targetModuleName, ReportNotificationNameSuffix];
}

+ (NSString *)levelNameWithModuleLevel:(VVModuleLevel)level {
    NSString *result;
    switch (level) {
        case VVModuleLevelBasic: {
            result = @"TPModuleLevelBasic";
            break;
        }
        case VVModuleLevelMiddle: {
            result = @"TPModuleLevelMiddle";
            break;
        }
        case VVModuleLevelTopout: {
            result = @"TPModuleLevelTopout";
            break;
        }
    }
    return result;
}

@end

@implementation TPNotificationMaker

- (TPNotificationMaker *(^)(NSString *))name {
    return ^TPNotificationMaker *(NSString *name) {
        self.m_name = name;
        return self;
    };
}

- (TPNotificationMaker *(^)(id))object {
    return ^TPNotificationMaker *(id object) {
        self.m_object = object;
        return self;
    };
}

- (TPNotificationMaker *(^)(id))userInfo {
    return ^TPNotificationMaker *(id userInfo) {
        self.m_userInfo = userInfo;
        return self;
    };
}

@end

@implementation TPNotificationObserver

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    if ([self.target respondsToSelector:aSelector]) {
        return [[self.target class] instanceMethodSignatureForSelector:aSelector];
    }
    return [super methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if ([self.target respondsToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:self.target];
        return;
    }
    [super forwardInvocation:anInvocation];
}

@end

@interface NSObject (TPNotificationCenter) <VVModuleProtocol>

+ (VVNotificationCenter *)tp_notificationCenter;

@end

@implementation NSObject (TPNotificationCenter)

+ (VVNotificationCenter *)tp_notificationCenter {
    return [VVNotificationCenter centerWithModule:self];
}

@end
