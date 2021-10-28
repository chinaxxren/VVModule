//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVEventTypes.h"

/**
 通用的JSON Event，用于松耦合事件传递。
 */
@interface VVParamEvent : NSObject <VVIEvent>

- (instancetype)init NS_UNAVAILABLE;

/**
 事件的唯一id
 */
@property(nonatomic, copy, readonly) NSString *uniqueId;

/**
 事件的数据，只可能为NSDictionary或者NSArray
 */
@property(nonatomic, strong, readonly) id data;

/**
 字典初始化
*/
+ (instancetype)eventWithId:(NSString *)uniqueId jsonObject:(NSDictionary *)data;

/**
 数组初始化
 */
+ (instancetype)eventWithId:(NSString *)uniqueId jsonArray:(NSArray *)data;


@end
