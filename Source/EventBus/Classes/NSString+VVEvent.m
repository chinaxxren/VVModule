//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//

#import "NSString+VVEvent.h"

@implementation NSString (VVEvent)

- (NSString *)eventSubType{
    return [self copy];
}

+ (Class)eventClass{
    return [NSString class];
}

@end
