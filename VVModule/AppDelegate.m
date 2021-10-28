//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//

#import "AppDelegate.h"

#import <VVModule/VVModule.h>

#import "MainController.h"
#import "TestModule.h"
#import "TestModuleService.h"
#import "TestRouter.h"

@interface AppDelegate () <VVMediatorDelegate>

@end

@implementation AppDelegate

@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [VVMediator sharedInstance].deleagate = self;

    VVModuleRegister *mr = [VVModuleRegister sharedInstance];
    mr.schemePlistFileName = @"VVModule";
    mr.modulePlistFileName = @"VVModule";
    mr.servicePlistFileName = @"VVModule";
    mr.routerPlistFileName = @"VVModule";
    [mr loadConfig];

    NSString *string = @"waqu//object/action/primaryKey?name=haha&age=18";
    [[VVMediator sharedInstance] openURL:string];

    BOOL result = [super application:application didFinishLaunchingWithOptions:launchOptions];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[MainController new]];
    [self.window makeKeyAndVisible];
    
    NSLog(@"%s",__func__);
    [[VVLaunchManager sharedInstance] executeArrayForKey:kVVLauncherStage(@"A")];

    return result;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"%s",__func__);
    [[VVLaunchManager sharedInstance] executeArrayForKey:kVVLauncherStage(@"B")];
}

static BOOL login = NO;

- (BOOL)mediator:(VVMediator *)mediator params:(NSDictionary *)params checkAuthRetryPerformActionHandler:(void (^)(void))retryHandler {
    BOOL isLogin = login;
    [self checkLogin:^{
        if (!isLogin) {
            retryHandler();
        }
    }];
    return login;
}

- (BOOL)checkLogin:(void (^)(void))compeltionHandler {
    if (login) {
        compeltionHandler();
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"%@", @"登录成功");
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                login = YES;
            });
            compeltionHandler();
        });
    }
    return login;
}

@end
