//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VVRouterNavigationMode) {
    VVRouterNavigationNone = 0,
    VVRouterNavigationPush = 1,
    VVRouterNavigationPresent = 2
};

#define VVROUTER_METHOD_EXPORT(action, method, ...) \
- (id)vv_router_##action:(NSDictionary *)params method, ##__VA_ARGS__

SEL VVRouterActionSelectorFromString(NSString *str);

