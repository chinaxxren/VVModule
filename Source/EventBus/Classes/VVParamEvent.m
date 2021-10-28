//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//


#import "VVParamEvent.h"

@interface VVParamEvent ()

@property(nonatomic, copy) NSString *uniqueId;

@property(nonatomic, strong) id data;

@end

@implementation VVParamEvent

- (instancetype)initWithId:(NSString *)unqiueId data:(id)data {
    if (self = [super init]) {
        self.data = data;
        self.uniqueId = unqiueId;
    }
    return self;
}

+ (instancetype)eventWithId:(NSString *)uniqueId jsonArray:(NSArray *)data {
    NSAssert([data isKindOfClass:[NSArray class]], @"Data must be NSArray");
    return [[self alloc] initWithId:uniqueId data:data];
}

+ (instancetype)eventWithId:(NSString *)uniqueId jsonObject:(NSDictionary *)data {
    NSAssert([data isKindOfClass:[NSDictionary class]], @"Data must be NSDictionary");
    return [[self alloc] initWithId:uniqueId data:data];
}

- (NSString *)eventSubType {
    return self.uniqueId;
}

@end
