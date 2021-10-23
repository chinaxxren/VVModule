//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VVContext;
@class VVNotificationCenter;

#define VV_MODULE_ASYNC \
+ (BOOL)isAsync { \
    return YES;}

#define VV_MODULE_PRIORITY(priority) \
+ (NSInteger)modulePriority { \
    return priority;}

#define VV_MODULE_LEVEL(ModuleLevel) \
+ (VVModuleLevel)moduleLevel {\
    return ModuleLevel;}


typedef NS_ENUM(NSUInteger, VVModuleLevel) {
    VVModuleLevelBasic = 0,
    VVModuleLevelMiddle,
    VVModuleLevelTopout,
};

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
#import <UserNotifications/UserNotifications.h>
@protocol VVModuleProtocol <NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate>
#else
@protocol VVModuleProtocol <NSObject, UIApplicationDelegate>
#endif

@optional

+ (BOOL)isAsync;

+ (NSInteger)modulePriority;

+ (VVModuleLevel)moduleLevel;

- (void)moduleDidLoad:(VVContext *)context;

+ (VVNotificationCenter *)tp_notificationCenter;

@end
