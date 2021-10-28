//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//


#import <Foundation/Foundation.h>

@protocol VVIEvent <NSObject>

@optional


/**
 事件的名称
 
 @note: 有些类在运行时是子类，用这个强制返回父类
 */
+ (Class)eventClass;

/**
 事件的二级类型
 */
- (NSString *)eventSubType;

@end

@protocol VVIEventToken <NSObject>

/**
 释放当前的监听
 */
- (void)dispose;

@end

/**
 提供一套DSL监听
 */
@interface VVEventSubscriberMaker<Value> : NSObject

typedef void (^VVEventNextBlock)(Value event) NS_SWIFT_UNAVAILABLE("");

/**
 事件触发的回调
 */
- (id <VVIEventToken>)doNext:(VVEventNextBlock)hander;

/**
 监听的队列，设置了监听队列后，副作用事件的监听会变成异步
 */
- (VVEventSubscriberMaker<Value> *)atQueue:(dispatch_queue_t)queue;

/**
 在对象释放的时候，释放监听
 */
- (VVEventSubscriberMaker<Value> *)freeWith:(id)object;

/**
 二级事件，这个操作符可以多次使用
 
 举个例子：[VVEventBus shared].on(VVParamEvent.class).subType(@"Login").subType(@"Logout")
 
 表示同时监听QTJsonEvent下面的id为Login和Logout事件
 */
- (VVEventSubscriberMaker<Value> *)ofSubType:(NSString *)subType;


#pragma mark - 点语法扩展

@property(readonly, nonatomic) VVEventSubscriberMaker<Value> *(^atQueue)(dispatch_queue_t);

@property(readonly, nonatomic) VVEventSubscriberMaker<Value> *(^ofSubType)(NSString *);

@property(readonly, nonatomic) VVEventSubscriberMaker<Value> *(^freeWith)(id);

//@property (readonly, nonatomic) id<VVIEventToken>(^next)(VVEventNextBlock block);

@end

