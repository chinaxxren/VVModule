//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//


#import "VVRouterNavigator.h"

@implementation VVRouterNavigator

#pragma mark - sharedNavigator

+ (instancetype)sharedNavigator {
    static dispatch_once_t onceToken;
    static VVRouterNavigator *sharedNavigator = nil;
    dispatch_once(&onceToken, ^{
        sharedNavigator = [[VVRouterNavigator alloc] init];
    });
    return sharedNavigator;
}

#pragma mark - showVC

- (void)showController:(UIViewController *)controller withNavigationMode:(VVRouterNavigationMode)mode {
    switch (mode) {
        case VVRouterNavigationPush:
            [self pushViewController:controller];
            break;
        case VVRouterNavigationPresent:
            [self presentViewController:controller];
            break;
        case VVRouterNavigationNone:
            NSLog(@"Internal error.");
            break;
        default:
            break;
    }
}

- (void)pushViewController:(UIViewController *)controller {
    UIViewController *topViewController = [self topMostViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
    
    if ([topViewController isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController *)topViewController pushViewController:controller animated:YES];
    } else if (topViewController.navigationController) {
        [topViewController.navigationController pushViewController:controller animated:YES];
    } else {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        [topViewController presentViewController:navController animated:YES completion:nil];
    }
}

- (void)presentViewController:(UIViewController *)controller {
    UIViewController *topViewController = [self topMostViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
    
    if ([topViewController isKindOfClass:[UITabBarController class]] || [topViewController isKindOfClass:[UINavigationController class]]) {
        return ;
    }
    
    if (topViewController.presentedViewController) {
        [topViewController dismissViewControllerAnimated:NO completion:nil];
    }
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    [topViewController presentViewController:navController animated:YES completion:nil];
}

- (UIViewController *)topMostViewControllerWithRootViewController:(UIViewController *)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController;
        return [self topMostViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController *)rootViewController;
        return [self topMostViewControllerWithRootViewController:navController.topViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController *presentedController = rootViewController.presentedViewController;
        return [self topMostViewControllerWithRootViewController:presentedController];
    } else {
        return rootViewController;
    }
}


@end
