//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//

#import "UIResponder+VVEventBus.h"
#import <objc/runtime.h>

const char _VVResponserPrivateBusKey;
const char _VVResponserProviderKey;

@interface UIResponder (VVEventBus_Private)

@property(strong, nonatomic) VVEventBus *qt_privateBus;

@end


@implementation UIResponder (VVEventBus)

- (VVEventBus *)qt_privateBus {
    VVEventBus *bus = objc_getAssociatedObject(self, &_VVResponserPrivateBusKey);
    if (!bus) {
        bus = [[VVEventBus alloc] init];
        objc_setAssociatedObject(self, &_VVResponserPrivateBusKey, bus, OBJC_ASSOCIATION_RETAIN);
    }
    return bus;
}

- (VVEventBus *)eventDispatcher {
    UIResponder *resp = self;
    do {
        if ([resp isDispatcherProvider]) {
            return resp.qt_privateBus;
        }
        resp = resp.nextResponder;
    } while (resp != nil);
    return nil;
}

- (BOOL)isDispatcherProvider {
    NSNumber *value = objc_getAssociatedObject(self, &_VVResponserProviderKey);
    if (value) {
        return value.boolValue;
    }
    if ([self isKindOfClass:[UIViewController class]]) {
        return YES;
    }
    return NO;
}

- (void)setDispatcherProvider:(BOOL)dispatcherProvider {
    objc_setAssociatedObject(self, &_VVResponserProviderKey, @(dispatcherProvider), OBJC_ASSOCIATION_RETAIN);
}

@end
