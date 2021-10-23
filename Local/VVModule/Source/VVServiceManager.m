//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//


#import "VVServiceManager.h"

@interface VVServiceManager ()

@property(strong, nonatomic) NSMutableDictionary *servicesDict;

@end

@implementation VVServiceManager

+ (instancetype)sharedInstance {
    static VVServiceManager *serviceManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serviceManager = [[VVServiceManager alloc] init];
    });
    return serviceManager;
}

- (void)registerService:(Protocol *)proto impClass:(Class)impClass {
    NSAssert([impClass conformsToProtocol:proto], @"ImpClass must conform to proto!");
    if (![impClass conformsToProtocol:proto]) {
        return;
    }
    [self registerServiceWithName:NSStringFromProtocol(proto) impClass:impClass];
}

- (void)registerServiceWithName:(NSString *)name impClass:(Class)impClass {
    NSParameterAssert(name);
    if (!name) {
        return;
    }
    [self.servicesDict setObject:impClass forKey:name];
}

- (id)serviceWithName:(NSString *)name {
    if (!name) {
        return nil;
    }

    Class clz = self.servicesDict[name];
    if (!clz) {
        return nil;
    }
    BOOL singleton = NO;
    if ([clz respondsToSelector:@selector(singleton)]) {
        singleton = [clz singleton];
    }
    if (!singleton) {
        return [[clz alloc] init];
    } else {
        return [clz sharedInstance];
    }
    return nil;
}

#pragma mark - getter

- (NSMutableDictionary *)servicesDict {
    if (!_servicesDict) {
        _servicesDict = [NSMutableDictionary dictionary];
    }
    return _servicesDict;
}

@end
