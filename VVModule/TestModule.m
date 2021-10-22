//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//


#import "TestModule.h"
#import "VVContext.h"

@implementation TestModule1

VVMODULE_AUTO_REGISTER(TestModule1) // 自动注册模块，动态注册模块

VV_MODULE_ASYNC         // 异步启动模块，优化开屏性能

VV_MODULE_PRIORITY(3)   // 模块启动优先级，优先级高的先启动

VV_MODULE_LEVEL(VVModuleLevelBasic)     // 模块级别：基础模块

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

- (void)moduleDidLoad:(VVContext *)context {
    switch (context.env) {
        case VVRunningEnviromentTypeDebug: {
            NSLog(@"%@", @"TestModule1 moduleDidLoad: debug");
            break;
        }
        case VVRunningEnviromentTypeRelease: {
            NSLog(@"%@", @"TestModule1 moduleDidLoad: release");
            break;
        }
    }
}

@end


@implementation TestModule2

VVMODULE_AUTO_REGISTER(TestModule2)

VV_MODULE_ASYNC

VV_MODULE_PRIORITY(5)

VV_MODULE_LEVEL(VVModuleLevelBasic)

- (void)moduleDidLoad:(VVContext *)context {
    switch (context.env) {
        case VVRunningEnviromentTypeDebug: {
            NSLog(@"%@", @"TestModule2 moduleDidLoad: debug");
            break;
        }
        case VVRunningEnviromentTypeRelease: {
            NSLog(@"%@", @"TestModule2 moduleDidLoad: release");
            break;
        }
    }
}
@end


@implementation TestModule3

VV_MODULE_PRIORITY(1)

VV_MODULE_LEVEL(VVModuleLevelTopout)

- (void)moduleDidLoad:(VVContext *)context {
    switch (context.env) {
        case VVRunningEnviromentTypeDebug: {
            NSLog(@"%@", @"TestModule3 moduleDidLoad: debug");
            break;
        }
        case VVRunningEnviromentTypeRelease: {
            NSLog(@"%@", @"TestModule3 moduleDidLoad: release");
            break;
        }
    }
}

@end
