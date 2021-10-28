//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "VVDisposeBag.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (VVEventBusPrivate)

/**
 释放池
 */
@property(strong, nonatomic, readonly) VVDisposeBag *eb_disposeBag;

@end

NS_ASSUME_NONNULL_END
