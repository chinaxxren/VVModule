//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//


#import "TestModuleService.h"
#import "VVModuleRegister.h"

@implementation TestModuleService1Imp

VVSERVICE_AUTO_REGISTER(TestModuleService1, TestModuleService1Imp) // 自动注册服务

- (void)function1 {
    NSLog(@"%@", @"TestModuleService1 function1");
}

@end

@implementation TestModuleService2Imp

VVSERVICE_AUTO_REGISTER(TestModuleService2, TestModuleService2Imp)

+ (BOOL)singleton {
    return YES;
}

+ (instancetype)sharedInstance {
    static TestModuleService2Imp *TestModuleService2ImpInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TestModuleService2ImpInstance = [[TestModuleService2Imp alloc] init];
    });
    return TestModuleService2ImpInstance;
}

- (void)function2 {
    NSLog(@"%@", @"TestModuleService2 function2");
}

@end

@implementation TestModuleService3Imp

- (void)function3 {
    NSLog(@"%@", @"TestModuleService3 function3");
}

@end
