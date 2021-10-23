//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//


#import "VVMediator.h"

#import "VVModuleConst.h"
#import "VVRouter.h"
#import "VVModuleRegister.h"
#import "VVRouterNavigator.h"

NSString *const IsCheckRouter = @"IsCheckRouter";

static inline NSMutableDictionary *VVDictionaryFromURLQueryString(NSString *query) {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *param in [query componentsSeparatedByString:@"&"]) {
        NSArray *elts = [param componentsSeparatedByString:@"="];
        if ([elts count] < 2) continue;
        params[[[elts firstObject] stringByRemovingPercentEncoding]] = [[elts lastObject] stringByRemovingPercentEncoding];
    }
    return params;
}

@interface VVMediator ()

@property(strong, nonatomic) NSMutableDictionary *nativeRouterHostDict;        // {host: routerName}
@property(strong, nonatomic) NSMutableDictionary *nativeRouterActionPathDict;  // {routerName:{path:actionName}}

@end

@implementation VVMediator

+ (instancetype)sharedInstance {
    static VVMediator *mediator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mediator = [[VVMediator alloc] init];
    });
    return mediator;
}

- (void)addRouter:(Class)routerClass {
    NSParameterAssert(routerClass);
    NSString *routerName = NSStringFromClass(routerClass);
    if (!routerName) {
        return;
    }
    [[VVServiceManager sharedInstance] registerServiceWithName:routerName impClass:routerClass];
}

- (void)addURLHost:(NSString *)host forRouter:(Class)routerClass {
    NSParameterAssert(host);
    NSParameterAssert(routerClass);
    if (!host || !routerClass) {
        return;
    }
    NSString *routerName = NSStringFromClass(routerClass);
    if (!routerName) {
        return;
    }
    self.nativeRouterHostDict[host] = routerName;
}

- (void)addURLPath:(NSString *)path forAction:(NSString *)action forRouter:(Class)routerClass {
    NSParameterAssert(path);
    NSParameterAssert(action);
    NSParameterAssert(routerClass);
    if (!path || !action || !routerClass) {
        return;
    }
    NSString *routerName = NSStringFromClass(routerClass);
    if (!routerName) {
        return;
    }
    if (self.nativeRouterActionPathDict[routerName]) {
        self.nativeRouterActionPathDict[routerName][path] = action;
    } else {
        self.nativeRouterActionPathDict[routerName] = [@{path: action} mutableCopy];
    }
}

- (id)performAction:(NSString *)action router:(NSString *)router params:(NSDictionary *)params {
    return [self performAction:action router:router params:params mode:VVRouterNavigationNone];
}

- (id)performAction:(NSString *)action router:(NSString *)router params:(NSDictionary *)params mode:(VVRouterNavigationMode)mode {
    id service = [[VVServiceManager sharedInstance] serviceWithName:router];
    if (!service) {
        return nil;
    }

    BOOL isAuthCheck = [params[IsCheckRouter] boolValue];
    if (isAuthCheck) {
        VV_Module_Log(@"%@", @"Authorization required");
        __weak typeof(self) weakSelf = self;
        if ([self.deleagate respondsToSelector:@selector(mediator:params:checkAuthRetryPerformActionHandler:)]) {
            if (![self.deleagate mediator:self params:params checkAuthRetryPerformActionHandler:^{
                [weakSelf performAction:action router:router params:params mode:mode];
            }]) {
                return nil;
            }
        }
    }

    SEL selector = VVRouterActionSelectorFromString(action);
    if ([service respondsToSelector:selector]) {
        id result = [self safePerformAction:selector target:service params:params];
        if (result && mode != VVRouterNavigationNone && [result isKindOfClass:[UIViewController class]]) {
            UIViewController *showingVC = (UIViewController *) result;
            [[VVRouterNavigator sharedNavigator] showController:showingVC withNavigationMode:mode];
        }
        return result;
    }

    return nil;
}

- (BOOL)openURL:(NSString *)urlPath {
    return [self openURL:urlPath params:nil];
}

- (BOOL)openURL:(NSString *)urlPath params:(NSDictionary *)params {
    return [self openURL:urlPath params:params mode:VVRouterNavigationPush];
}

- (BOOL)openURL:(NSString *)urlPath params:(NSDictionary *)params mode:(VVRouterNavigationMode)mode {
    if (![self canOpenURL:urlPath]) {
        return NO;
    }

    NSURL *URL = [NSURL URLWithString:urlPath];

    NSString *host = URL.host;
    NSString *path = URL.path.length > 0 ? URL.path : @"/";

    NSString *router = self.nativeRouterHostDict[host];
    NSString *action = self.nativeRouterActionPathDict[router][path];

    NSMutableDictionary *queryDict = VVDictionaryFromURLQueryString(URL.query);
    if (params) {
        [queryDict addEntriesFromDictionary:params];
    }

    [self performAction:action router:router params:queryDict mode:mode];

    return YES;
}

- (BOOL)canOpenURL:(NSString *)urlPath {
    if ([urlPath length] == 0) {
        return NO;
    }

    NSURL *URL = [NSURL URLWithString:urlPath];
    if (![self.appURLSchemes containsObject:URL.scheme]) {
        return NO;
    }

    NSString *host = URL.host;
    NSString *path = URL.path.length > 0 ? URL.path : @"/";

    NSString *router = self.nativeRouterHostDict[host];
    NSString *action = self.nativeRouterActionPathDict[router][path];

    if (!router || !action) {
        return NO;
    }

    return YES;
}

- (NSMutableDictionary *)nativeRouterHostDict {
    if (!_nativeRouterHostDict) {
        _nativeRouterHostDict = [NSMutableDictionary dictionary];
    }
    return _nativeRouterHostDict;
}

- (NSMutableDictionary *)nativeRouterActionPathDict {
    if (!_nativeRouterActionPathDict) {
        _nativeRouterActionPathDict = [NSMutableDictionary dictionary];
    }
    return _nativeRouterActionPathDict;
}


- (id)safePerformAction:(SEL)action target:(NSObject *)target params:(NSDictionary *)params {
    NSMethodSignature *methodSig = [target methodSignatureForSelector:action];
    if (methodSig == nil) {
        return nil;
    }
    const char *retType = [methodSig methodReturnType];

    if (strcmp(retType, @encode(void)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        return nil;
    }

    if (strcmp(retType, @encode(NSInteger)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        NSInteger result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }

    if (strcmp(retType, @encode(BOOL)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        BOOL result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }

    if (strcmp(retType, @encode(CGFloat)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        CGFloat result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }

    if (strcmp(retType, @encode(NSUInteger)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        NSUInteger result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return [target performSelector:action withObject:params];
#pragma clang diagnostic pop
}

@end
