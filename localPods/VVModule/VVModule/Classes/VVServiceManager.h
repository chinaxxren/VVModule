//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVServiceProtocol.h"

@interface VVServiceManager : NSObject

+ (instancetype)sharedInstance;

- (void)registerService:(Protocol *)proto impClass:(Class)impClass;

- (void)registerServiceWithName:(NSString *)name impClass:(Class)impClass;

- (id)serviceWithName:(NSString *)name;

@end
