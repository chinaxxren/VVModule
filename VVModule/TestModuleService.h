//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "VVServiceProtocol.h"

@protocol TestModuleService1 <VVServiceProtocol>

- (void)function1;

@end

@interface TestModuleService1Imp : NSObject <TestModuleService1>

@end

@protocol TestModuleService2 <VVServiceProtocol>

- (void)function2;

@end

@interface TestModuleService2Imp : NSObject <TestModuleService2>

@end

@protocol TestModuleService3 <VVServiceProtocol>

- (void)function3;

@end

@interface TestModuleService3Imp : NSObject <TestModuleService3>

@end
