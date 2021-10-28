//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//


#import <Foundation/Foundation.h>

@protocol VVServiceProtocol <NSObject>

@optional

+ (BOOL)singleton;

+ (instancetype)sharedInstance;

@end
