//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "VVEventTypes.h"
#import "VVParamEvent.h"
#import "NSNotification+VVEvent.h"
#import "NSObject+VVEventBus.h"
#import "NSString+VVEvent.h"

//监听全局总线，监听的生命周期和object一样
#define VVSubClass(_object_,_class_) ([_object_ subscribeSharedBusOfClass:_class_])
#define VVSubString(_object_,_name_) ([_object_ subscribeSharedBusOfString:_name_])

//监听全局总线，异步在主线程监听
#define VVSubClassMain(_object_,_class_) ([VVSubClass(_object_, _class_) atQueue:dispatch_get_main_queue()])

//全局总线监听NSNotification
#define VVSubNotification(_object_,_name_) ([_object_ subscribeNotification:_name_])

//全局总线监听VVParamEvent
#define VVSubParam(_object_,_name_) ([_object_ subscribeSharedBusOfParam:_name_])

@class VVEventSubscriberMaker;

/**
 事件总线，负责转发事件，
 支持同步/异步派发，同步/异步监听
 */
@interface VVEventBus<EventType> : NSObject

/**
 单例
 */
@property (class,readonly) VVEventBus * shared;

/**
 注册监听事件,点语法
 
 如果需要监听系统的通知，请监听NSNotification这个类，如果要监听通用的事件，请监听VVJsonEvent
 */
@property (readonly, nonatomic) VVEventSubscriberMaker<EventType> *(^on)(Class eventClass);

/**
 注册监听事件
 
 如果需要监听系统的通知，请监听NSNotification这个类，如果要监听通用的事件，请监听VVJsonEvent
 */
- (VVEventSubscriberMaker<EventType> *)on:(Class)eventClass;

/**
 发布Event,等待event执行结束
 */
- (void)dispatch:(id<VVIEvent>)event;

/**
 异步到eventbus内部queue上dispath
 */
- (void)dispatchOnBusQueue:(id<VVIEvent>)event;

/**
 异步到主线程dispatch
 */
- (void)dispatchOnMain:(id<VVIEvent>)event;

@end


