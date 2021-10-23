//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>

#pragma mark - 存储的结构体

struct VV_Function {
    char *stage;
    long priority;

    void (*function)(void);
};

#define kVVLauncherStagePreMain @"Pre_main"
#define kVVLauncherStageA @"Stage_A"
#define kVVLauncherStageB @"Stage_B"

#define kVVLauncherPriorityHigh LONG_MAX
#define kVVLauncherPriorityDefault 0
#define kVVLauncherPriorityLow LONG_MIN

#define VV_FUNCTION_EXPORT(key, _priority_) \
static void _VV##key(void); \
__attribute__((used, section("__DATA,__launch"))) \
static const struct VV_Function __F##key = (struct VV_Function){(char *)(&#key), _priority_, (void *)(&_VV##key)}; \
static void _VV##key \


@interface VVLaunchManager : NSObject

@property(nonatomic, strong) NSMutableDictionary *moduleDic;

+ (instancetype)sharedInstance;

- (void)executeArrayForKey:(NSString *)key;

@end

