//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//

#import "VVRouter.h"

//NSString *VVRouterNameFromString(NSString *str) {
//    NSString *routerName = str;
//    if (![[routerName lowercaseString] hasSuffix:@"router"]) {
//        routerName = [routerName stringByAppendingString:@"Router"];
//    }
//    return routerName;
//}
//

SEL VVRouterActionSelectorFromString(NSString *str) {
    NSString *actionName = str;
    if (![actionName hasPrefix:@"vv_router_"]) {
        actionName = [NSString stringWithFormat:@"vv_router_%@:", str];
    }
    return NSSelectorFromString(actionName);
}

//@implementation VVRouter
//
//+ (NSString *)routerName {
//    NSString *routerName = NSStringFromClass(self);
//    if (![[routerName lowercaseString] hasSuffix:@"router"]) {
//        routerName = [routerName stringByAppendingString:@"Router"];
//    }
//    return routerName;
//}

//@end
