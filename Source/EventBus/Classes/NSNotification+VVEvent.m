//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//


#import "NSNotification+VVEvent.h"

@implementation NSNotification (VVEvent)

+ (Class)eventClass{
    return [NSNotification class];
}

- (NSString *)eventSubType{
    return self.name;
}


@end
