//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//


#import "VVDisposeBag.h"

@interface VVDisposeBag()

@property (strong, nonatomic) NSMutableArray<id<VVIEventToken>> * tokens;

@end

@implementation VVDisposeBag

- (NSMutableArray<id<VVIEventToken>> *)tokens{
    if (!_tokens) {
        _tokens = [[NSMutableArray alloc] init];
    }
    return _tokens;
}

- (void)addToken:(id<VVIEventToken>)token{
    @synchronized(self) {
        [self.tokens addObject:token];
    }
}

- (void)dealloc{
    @synchronized(self) {
        for (id<VVIEventToken> token in self.tokens) {
            if ([token respondsToSelector:@selector(dispose)]) {
                [token dispose];
            }
        }
    }
}

@end
