//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "VVEventBus.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIResponder (VVEventBus)

/**
 沿着响应链，找到第一个isDispatcherProvider提供的EventBus
 */
@property(readonly, nullable, nonatomic) VVEventBus *eventDispatcher;

/**
 是否作为响应链上一个EventBust的提供者
 
 @note UIViewController这个值默认为YES，其他为NO
 */
@property(nonatomic, assign, getter=isDispatcherProvider) BOOL dispatcherProvider;

@end

NS_ASSUME_NONNULL_END
