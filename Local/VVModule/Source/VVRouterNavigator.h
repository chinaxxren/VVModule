//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VVRouter.h"

NS_ASSUME_NONNULL_BEGIN

@interface VVRouterNavigator : NSObject

+ (instancetype)sharedNavigator;

- (void)showController:(UIViewController *)controller withNavigationMode:(VVRouterNavigationMode)mode;

- (void)pushViewController:(UIViewController *)controller;

- (void)presentViewController:(UIViewController *)controller;

@end

NS_ASSUME_NONNULL_END
