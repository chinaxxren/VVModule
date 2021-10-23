//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//


#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, VVRunningEnviromentType) {
    VVRunningEnviromentTypeRelease = 0,
    VVRunningEnviromentTypeDebug,
};

@interface VVContext : NSObject

@property(assign, nonatomic) VVRunningEnviromentType env;

@end
