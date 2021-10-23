//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "VVRouter.h"

@class VVMediator;

extern NSString *const IsCheckRouter;

#define VVURLHostForRouter(host, routerClass) \
[[VVMediator sharedInstance] addURLHost:host forRouter:[routerClass class]];

#define ClangPush _Pragma("clang diagnostic push")
#define ClangPop _Pragma("clang diagnostic pop")
#define ClangDiagnosticUndeclaredSelector _Pragma("clang diagnostic ignored \"-Wundeclared-selector\"")

#define VVURLPathForActionForRouter(path, action, routerClass) \
ClangPush \
ClangDiagnosticUndeclaredSelector \
[[VVMediator sharedInstance] addURLPath:path forAction:NSStringFromSelector(@selector(action)) forRouter:[routerClass class]]; \
ClangPop

@protocol VVMediatorDelegate <NSObject>

@optional

- (BOOL)mediator:(VVMediator *)mediator params:(NSDictionary *)params checkAuthRetryPerformActionHandler:(void (^)(void))retryHandler;

@end

@interface VVMediator : NSObject

@property(strong, nonatomic) NSArray *appURLSchemes;
@property(weak, nonatomic) id <VVMediatorDelegate> deleagate;

+ (instancetype)sharedInstance;

- (void)addRouter:(Class)routerClass;

- (void)addURLHost:(NSString *)host forRouter:(Class)routerClass;

- (void)addURLPath:(NSString *)path forAction:(NSString *)action forRouter:(Class)routerClass;

- (id)performAction:(NSString *)action router:(NSString *)router params:(NSDictionary *)params;

- (BOOL)openURL:(NSString *)urlPath;

- (BOOL)openURL:(NSString *)urlPath params:(NSDictionary *)params;

- (BOOL)openURL:(NSString *)urlPath params:(NSDictionary *)params mode:(VVRouterNavigationMode)mode;

- (BOOL)canOpenURL:(NSString *)urlPath;

@end
