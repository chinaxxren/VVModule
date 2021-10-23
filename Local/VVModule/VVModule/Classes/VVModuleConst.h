//
//  VVModuleConst.h
//  Pods
//
//  Created by 赵江明 on 2021/10/23.
//

#ifndef VVModuleConst_h
#define VVModuleConst_h

#ifdef DEBUG
#define VV_Module_Log(...) NSLog(@"%s 第%d行 \n %@\n\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])
#else
#define VV_Module_Log(...)
#endif

#endif /* VVModuleConst_h */
