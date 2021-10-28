//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVEventTypes.h"

@interface VVDisposeBag : NSObject

/**
 增加一个需要释放的token
 */
- (void)addToken:(id<VVIEventToken>)token;

@end
