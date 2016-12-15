//
//  YDownloadManager.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/15.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YDownloadManager.h"
#import <libkern/OSAtomic.h>
#import "YReaderManager.h"

static dispatch_queue_t YDownloadManagerGetQueue() {
#define MAX_QUEUE_COUNT 16
    static int queueCount;
    static dispatch_queue_t queues[MAX_QUEUE_COUNT];
    static int32_t counter = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queueCount = (int)[NSProcessInfo processInfo].activeProcessorCount;
        queueCount = queueCount < 1 ? 1 : queueCount;
        if ( [[UIDevice currentDevice].systemVersion floatValue] >= 8.0 ) {
            for (NSUInteger i = 0 ; i < queueCount; i++) {
                dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0);
                queues[i] = dispatch_queue_create("com.yxw.download", attr);
            }
        } else {
            for (NSUInteger i= 0; i < queueCount; i++) {
                queues[i] = dispatch_queue_create("com.yxw.download", DISPATCH_QUEUE_SERIAL);
                dispatch_set_target_queue(queues[i], dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
            }
        }
    });
    int32_t cur = OSAtomicIncrement32(&counter);
    if (cur < 0) {
        cur = -cur;
    }
    return queues[cur%queueCount];
}

@interface YDownloadManager ()

@end

@implementation YDownloadManager

+ (instancetype)shareManager {
    static YDownloadManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (void)downloadReadingBookWith:(YDownloadType)loadType progress:(void (^)(NSUInteger, NSUInteger))progress completion:(void (^)())completion failure:(void (^)(NSString *))failure {
    YReaderManager *readerM = [YReaderManager shareReaderManager];
    
}

@end
