//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VVModuleManager.h"
#import "VVServiceManager.h"
#import "VVMediator.h"
#import "VVAppDelegate.h"
#import "VVModuleProtocol.h"
#import "VVServiceProtocol.h"
#import "VVNotificationCenter.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000

#import <UserNotifications/UserNotifications.h>

#endif

#define VVModularizationDATA(sectname) __attribute((used, section("__DATA,"#sectname" ")))

#define VVMODULE_AUTO_REGISTER(name) \
char * k##name##_mod VVModularizationDATA(VVModuleModule) = ""#name"";

#define VVSERVICE_AUTO_REGISTER(servicename, impl) \
char * k##servicename##_service VVModularizationDATA(VVModuleService) = "{ \""#servicename"\" : \""#impl"\"}";

#define VVROUTER_AUTO_REGISTER(name) \
char * k##name##_router VVModularizationDATA(VVModuleRouter) = ""#name"";

@class VVContext;

@interface VVModuleRegister : NSObject

+ (instancetype)sharedInstance;

@property(strong, nonatomic,readonly) VVContext *context;

@property(copy, nonatomic) NSString *schemePlistFileName;
@property(copy, nonatomic) NSString *modulePlistFileName;
@property(copy, nonatomic) NSString *servicePlistFileName;
@property(copy, nonatomic) NSString *routerPlistFileName;

- (void)loadConfig;

- (void)registerModule:(Class)clz;

- (void)registerService:(Protocol *)proto impClass:(Class)impClass;

- (void)addRouter:(Class)routerClass;

@end

