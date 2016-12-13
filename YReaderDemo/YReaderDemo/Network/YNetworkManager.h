//
//  YNetworkManager.h
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/9.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YURLManager.h"

@interface YNetworkManager : NSObject

+ (instancetype)shareManager;

- (NSURLSessionTask *)getWithAPIType:(YAPIType)type parameter:(id)parameter success:(void (^)(id response))success failure:(void (^)(NSError *error))failure;

@end
