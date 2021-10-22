//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//


#import "VVModuleRegister.h"

#include <dlfcn.h>
#include <mach-o/getsect.h>
#include <mach-o/dyld.h>

#import "VVContext.h"

static NSString *const VV_PLIST_APPURLSCHEME_KEY = @"AppURLSchemes";
static NSString *const VV_PLIST_MODULE_KEY = @"ModuleClasses";
static NSString *const VV_PLIST_SERVICE_KEY = @"ServicesTable";
static NSString *const VV_PLIST_ROUTER_KEY = @"RouterClasses";

@interface VVModuleRegister ()

@property(strong, nonatomic,readwrite) VVContext *context;

@end

@implementation VVModuleRegister

+ (instancetype)sharedInstance {
    static VVModuleRegister *TPInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TPInstance = [[VVModuleRegister alloc] init];
    });
    return TPInstance;
}

- (VVContext *)context {
    if (_context) {
        _context = [[VVContext alloc] init];
    }
    return _context;
}

- (void)registerModule:(Class)clz {
    [[VVModuleManager sharedInstance] registerModule:clz];
}

- (void)registerService:(Protocol *)proto impClass:(Class)impClass {
    [[VVServiceManager sharedInstance] registerService:proto impClass:impClass];
}

- (void)addRouter:(Class)routerClass {
    [[VVMediator sharedInstance] addRouter:routerClass];
}

- (void)loadConfig {
    NSBundle *bundle =[NSBundle mainBundle];

    if (self.schemePlistFileName) {
        NSString *schemePlistFilePath = [bundle pathForResource:self.schemePlistFileName ofType:@"plist"];
        if (schemePlistFilePath) {
            NSDictionary *schemeDict = [NSDictionary dictionaryWithContentsOfFile:schemePlistFilePath];
            NSArray *schemes = schemeDict[VV_PLIST_APPURLSCHEME_KEY];
            [[VVMediator sharedInstance] setAppURLSchemes:schemes];
        }
    }
    
    if (self.modulePlistFileName) {
        NSString *modulePlistFilePath = [bundle pathForResource:self.modulePlistFileName ofType:@"plist"];
        if (modulePlistFilePath) {
            NSDictionary *moduleDict = [NSDictionary dictionaryWithContentsOfFile:modulePlistFilePath];
            NSArray *moduleArray = moduleDict[VV_PLIST_MODULE_KEY];
            [moduleArray enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                [self registerModule:NSClassFromString(obj)];
            }];
        }
    }
    
    if (self.servicePlistFileName) {
        NSString *servicePlistFilePath = [bundle pathForResource:self.servicePlistFileName ofType:@"plist"];
        if (servicePlistFilePath) {
            NSDictionary *serviceDict = [NSDictionary dictionaryWithContentsOfFile:servicePlistFilePath];
            NSDictionary *serviceTable = serviceDict[VV_PLIST_SERVICE_KEY];
            [serviceTable enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
                [self registerService:NSProtocolFromString(key) impClass:NSClassFromString(obj)];
            }];
        }
    }

    if (self.routerPlistFileName) {
        NSString *routerPlistFilePath = [bundle pathForResource:self.routerPlistFileName ofType:@"plist"];
        if (routerPlistFilePath) {
            NSDictionary *routerDict = [NSDictionary dictionaryWithContentsOfFile:routerPlistFilePath];
            NSArray *routerArray = routerDict[VV_PLIST_ROUTER_KEY];
            [routerArray enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                [self addRouter:NSClassFromString(obj)];
            }];
        }
    }
}

@end

NSArray<NSString *> *VVReadConfiguration(char *sectionName, const struct mach_header *mhp);

static void dyld_callback(const struct mach_header *mhp, intptr_t vmaddr_slide) {
    
    // register module
    NSArray *mods = VVReadConfiguration("VVModuleModule", mhp);
    for (NSString *modName in mods) {
        if (modName) {
            Class cls = NSClassFromString(modName);
            if (cls) {
                [[VVModuleRegister sharedInstance] registerModule:cls];
            }
        }
    }

    // register services
    NSArray<NSString *> *services = VVReadConfiguration("VVModuleService", mhp);
    for (NSString *map in services) {
        NSData *jsonData = [map dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        id json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        if (!error) {
            if ([json isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dict = (NSDictionary *) json;
                if ([[dict allKeys] count] > 0) {
                    NSString *proto = [[dict allKeys] firstObject];
                    NSString *clsName = [[dict allValues] firstObject];
                    if (proto && clsName) {
                        [[VVModuleRegister sharedInstance] registerService:NSProtocolFromString(proto) impClass:NSClassFromString(clsName)];
                    }
                }
            }
        }
    }

    // register router
    NSArray *routers = VVReadConfiguration("VVModuleRouter", mhp);
    for (NSString *routerName in routers) {
        if (routerName) {
            Class cls = NSClassFromString(routerName);
            if (cls) {
                [[VVModuleRegister sharedInstance] addRouter:cls];
            }
        }
    }
}

__attribute__((constructor))
void initProphet() {
    _dyld_register_func_for_add_image(dyld_callback);
}

NSArray<NSString *> *VVReadConfiguration(char *sectionName, const struct mach_header *mhp) {
    NSMutableArray *configs = [NSMutableArray array];
    unsigned long size = 0;
#ifndef __LP64__
    uintptr_t *memory = (uintptr_t*)getsectiondata(mhp, SEG_DATA, sectionName, &size);
#else
    const struct mach_header_64 *mhp64 = (const struct mach_header_64 *) mhp;
    uintptr_t *memory = (uintptr_t *) getsectiondata(mhp64, SEG_DATA, sectionName, &size);
#endif

    unsigned long counter = size / sizeof(void *);
    for (int idx = 0; idx < counter; ++idx) {
        char *string = (char *) memory[idx];
        NSString *str = [NSString stringWithUTF8String:string];
        if (!str)continue;
        if (str) [configs addObject:str];
    }
    
    if ([configs count] > 0) {
        NSLog(@"config===>%@",configs);
    }
    
    return configs;
}
