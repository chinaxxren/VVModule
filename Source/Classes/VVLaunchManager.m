//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//

#import "VVLaunchManager.h"

#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <mach-o/getsect.h>

#ifdef __LP64__
typedef uint64_t VVExportValue;
typedef struct section_64 VVExportSection;
#define VVGetSectByNameFromHeader getsectbynamefromheader_64
#else
typedef uint32_t VVExportValue;
typedef struct section VVExportSection;
#define VVGetSectByNameFromHeader getsectbynamefromheader
#endif

#pragma mark -

@interface VVModuleMetaDataModel : NSObject

@property(nonatomic, assign) NSInteger priority;
@property(nonatomic, strong) NSString *stage;
@property(nonatomic, assign) IMP imp;

@end

@implementation VVModuleMetaDataModel

@end

static NSMutableArray<VVModuleMetaDataModel *> *modulesInDyld() {
    NSString *appName = [[NSBundle mainBundle] infoDictionary][(NSString *) kCFBundleExecutableKey];
    NSString *fullAppName = [NSString stringWithFormat:@"/%@.app/", appName];
    char *fullAppNameC = (char *) [fullAppName UTF8String];

    NSMutableArray<VVModuleMetaDataModel *> *result = [[NSMutableArray alloc] init];

    int num = _dyld_image_count();
    for (int i = 0; i < num; i++) {
        const char *name = _dyld_get_image_name(i);
        if (strstr(name, fullAppNameC) == NULL) {
            continue;
        }

        const struct mach_header *header = _dyld_get_image_header(i);
        //        printf("%d name: %s\n", i, name);

        Dl_info info;
        dladdr(header, &info);

        const VVExportValue dliFbase = (VVExportValue) info.dli_fbase;
        const VVExportSection *section = VVGetSectByNameFromHeader(header, "__DATA", "__launch");
        if (section == NULL) continue;
        int addrOffset = sizeof(struct VV_Function);
        for (VVExportValue addr = section->offset;
             addr < section->offset + section->size;
             addr += addrOffset) {

            struct VV_Function entry = *(struct VV_Function *) (dliFbase + addr);
            VVModuleMetaDataModel *metaData = [[VVModuleMetaDataModel alloc] init];
            metaData.priority = entry.priority;
            metaData.imp = entry.function;
            metaData.stage = [NSString stringWithCString:entry.stage encoding:NSUTF8StringEncoding];
            [result addObject:metaData];
        }
    }
    return result;
}

static void dyld_callback(const struct mach_header *mhp, intptr_t slide) {
}

__attribute__((constructor))
void premain() {
    [[VVLaunchManager sharedInstance] executeArrayForKey:kVVLauncherStagePreMain];

    //读出的时候还可以这样，这个函数是用来注册回调，当dyld链接符号时，调用此回调函数。在dyld加载镜像时，会执行注册过的回调函数
//    _dyld_register_func_for_add_image(dyld_callback);
}

@interface VVLaunchManager ()

@end

@implementation VVLaunchManager

+ (instancetype)sharedInstance {
    static VVLaunchManager *singleTon;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleTon = VVLaunchManager.new;
    });
    return singleTon;
}

- (void)executeArrayForKey:(NSString *)key {
    NSLog(@"\n\n------------------------  %@ start ------------------------\n\n",key);

    NSMutableArray *arrayModule;
    if (![self.moduleDic count]) {
        arrayModule = modulesInDyld();
        if (!arrayModule.count) {
            return;
        }
        [arrayModule sortUsingComparator:^NSComparisonResult(VVModuleMetaDataModel *_Nonnull obj1, VVModuleMetaDataModel *_Nonnull obj2) {
            return obj1.priority < obj2.priority;
        }];
        for (NSInteger i = 0; i < [arrayModule count]; i++) {
            VVModuleMetaDataModel *model = arrayModule[i];
            if (self.moduleDic[model.stage]) {
                NSMutableArray *stageArray = self.moduleDic[model.stage];
                [stageArray addObject:model];
            } else {
                NSMutableArray *stageArray = [NSMutableArray array];
                [stageArray addObject:model];
                self.moduleDic[model.stage] = stageArray;
            }
        }
    }
    arrayModule = self.moduleDic[key];

    for (NSInteger i = 0; i < [arrayModule count]; i++) {
        VVModuleMetaDataModel *model = arrayModule[i];
        IMP imp = model.imp;
        void (*func)(void) = (void *) imp;
        func();
    }
}

- (NSMutableDictionary *)moduleDic {
    if (!_moduleDic) {
        _moduleDic = [[NSMutableDictionary alloc] init];
    }
    return _moduleDic;
}

@end

