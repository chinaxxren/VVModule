//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//


#import "NSObject+VVEventBus.h"

#import <UIKit/UIKit.h>

#import "VVEventBus.h"
#import "NSString+VVEvent.h"
#import "NSObject+VVEventBusPrivate.h"

@implementation NSObject (VVEventBus)

- (VVEventSubscriberMaker *)subscribeSharedBusOfClass:(Class)eventClass {
    return [VVEventBus shared].on(eventClass).freeWith(self);
}

- (VVEventSubscriberMaker *)subscribeSharedBusOfString:(NSString *)eventName {
    NSParameterAssert(eventName != nil);
    return [VVEventBus shared].on(NSString.class).ofSubType(eventName).freeWith(self);
}

- (VVEventSubscriberMaker *)subscribeName:(NSString *)eventName on:(VVEventBus *)bus {
    NSParameterAssert(eventName != nil);
    return bus.on(NSString.class).ofSubType(eventName).freeWith(self);
}

- (VVEventSubscriberMaker *)subscribe:(Class)eventClass on:(VVEventBus *)bus {
    return bus.on(eventClass).freeWith(self);
}

@end

@implementation NSObject (EventBus_ParamEvent)

- (VVEventSubscriberMaker *)subscribeSharedBusOfParam:(NSString *)name {
    return [VVEventBus shared].on(VVParamEvent.class).freeWith(self).ofSubType(name);
}

@end

@implementation NSObject (EventBus_Notification)
/**
 监听通知
 */
- (VVEventSubscriberMaker<NSNotification *> *)subscribeNotification:(NSString *)name {
    return [VVEventBus shared].on(NSNotification.class).ofSubType(name).freeWith(self);
}

- (VVEventSubscriberMaker *)subscribeAppDidBecomeActive {
    return [self subscribeNotification:UIApplicationDidBecomeActiveNotification];
}

- (VVEventSubscriberMaker *)subscribeAppDidEnterBackground {
    return [self subscribeNotification:UIApplicationDidEnterBackgroundNotification];
}

- (VVEventSubscriberMaker *)subscribeAppDidReceiveMemoryWarning {
    return [self subscribeNotification:UIApplicationDidReceiveMemoryWarningNotification];
}

- (VVEventSubscriberMaker *)subscribeUserDidTakeScreenshot {
    return [self subscribeNotification:UIApplicationUserDidTakeScreenshotNotification];
}

- (VVEventSubscriberMaker *)subscribeAppWillEnterForground {
    return [self subscribeNotification:UIApplicationWillEnterForegroundNotification];
}

- (VVEventSubscriberMaker *)subscribeAppWillResignActive {
    return [self subscribeNotification:UIApplicationWillResignActiveNotification];
}

- (VVEventSubscriberMaker *)subscribeAppWillTerminate {
    return [self subscribeNotification:UIApplicationWillTerminateNotification];
}

@end

