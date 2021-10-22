//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//


#import "TestRouter.h"

#import "VVModuleRegister.h"
#import "ViewController2.h"

@implementation TestRouter

VVROUTER_AUTO_REGISTER(TestRouter)  // 自动注册路由

VVROUTER_METHOD_EXPORT(action1, {
    NSLog(@"TestRouter action1 params=%@", params);
    ViewController2 *vc = [ViewController2 new];
    return vc;
});

VVROUTER_METHOD_EXPORT(action2, {
    NSLog(@"TestRouter action2 params=%@", params);
    return nil;
});

@end
