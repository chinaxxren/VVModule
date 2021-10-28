//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//


#import "NSObject+VVEventBusPrivate.h"
#import <objc/runtime.h>

static const char event_bus_disposeContext;

@implementation NSObject (VVEventBusPrivate)

- (VVDisposeBag *)eb_disposeBag {
    VVDisposeBag *bag = objc_getAssociatedObject(self, &event_bus_disposeContext);
    if (!bag) {
        bag = [[VVDisposeBag alloc] init];
        objc_setAssociatedObject(self, &event_bus_disposeContext, bag, OBJC_ASSOCIATION_RETAIN);
    }
    return bag;
}

@end
