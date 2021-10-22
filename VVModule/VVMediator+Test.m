//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//

#import "VVMediator+Test.h"
#import "VVModuleRegister.h"
#import "TestRouter.h"

@implementation VVMediator (Test)

+ (void)load {
    // 声明TestRouter对应的Host
    VVURLHostForRouter(@"com.waqu.test", TestRouter) // china://com.waqu.test

    // 声明TestRouter中action1对应的Path
    VVURLPathForActionForRouter(@"/action_test", action1, TestRouter);  // china://com.waqu.test/action_test
}

@end
