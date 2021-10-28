//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVEventTypes.h"

@class VVEventBus;
@class VVParamEvent;

@interface NSObject (VVEventBus)

/**
 在EventBus单例shared上监听指定类型的事件，并且跟随self一起取消监听
 */
- (VVEventSubscriberMaker *)subscribeSharedBusOfClass:(Class)eventClass;

/**
 在EventBus单例子监听指定字符串事件
 */
- (VVEventSubscriberMaker<NSString *> *)subscribeSharedBusOfString:(NSString *)eventName;

/**
 在bus上监听指定类型的事件，并且跟随self一起取消监听
 */
- (VVEventSubscriberMaker *)subscribe:(Class)eventClass on:(VVEventBus *)bus;

/**
 在bus上监听指定字符串时间
 */
- (VVEventSubscriberMaker<NSString *> *)subscribeName:(NSString *)eventName on:(VVEventBus *)bus;

@end

@interface NSObject (EventBus_ParamEvent)

/**
 监听一个JSONEvent，并且self释放的时候自动取消订阅
 */
- (VVEventSubscriberMaker<VVParamEvent *> *)subscribeSharedBusOfParam:(NSString *)name;

@end

@interface NSObject (EventBus_Notification)

/**
 监听通知
 */
- (VVEventSubscriberMaker<NSNotification *> *)subscribeNotification:(NSString *)name;

- (VVEventSubscriberMaker<NSNotification *> *)subscribeAppDidBecomeActive;

- (VVEventSubscriberMaker<NSNotification *> *)subscribeAppDidEnterBackground;

- (VVEventSubscriberMaker<NSNotification *> *)subscribeAppDidReceiveMemoryWarning;

- (VVEventSubscriberMaker<NSNotification *> *)subscribeUserDidTakeScreenshot;

- (VVEventSubscriberMaker<NSNotification *> *)subscribeAppWillEnterForground;

- (VVEventSubscriberMaker<NSNotification *> *)subscribeAppWillResignActive;

- (VVEventSubscriberMaker<NSNotification *> *)subscribeAppWillTerminate;

@end
