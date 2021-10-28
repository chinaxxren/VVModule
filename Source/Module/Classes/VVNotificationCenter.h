//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//


#import <Foundation/Foundation.h>

@class TPNotificationMaker;
@protocol VVModuleProtocol;

@interface VVNotificationCenter : NSObject

+ (instancetype)centerWithModule:(Class)module;

- (void)broadcastNotification:(void (^)(TPNotificationMaker *make))makerHandler;

- (void)reportNotification:(void (^)(TPNotificationMaker *make))makerHandler targetModule:(NSString *)moduleName;

- (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName object:(id)anObject;

@end

// 链式调用
@interface TPNotificationMaker : NSObject

- (TPNotificationMaker *(^)(NSString *name))name;

- (TPNotificationMaker *(^)(id object))object;

- (TPNotificationMaker *(^)(id userInfo))userInfo;

@end
