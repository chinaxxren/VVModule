//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VVModuleProtocol.h"

@class VVContext;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000

#import <UserNotifications/UserNotifications.h>

@interface VVModuleManager : NSObject <UIApplicationDelegate, UNUserNotificationCenterDelegate>
#else
@interface VVModuleManager : NSObject <UIApplicationDelegate>
#endif

@property(copy, nonatomic, readonly) NSArray<id <VVModuleProtocol>> *allModules;

+ (instancetype)sharedInstance;

- (void)registerModule:(Class)clz;

@end
