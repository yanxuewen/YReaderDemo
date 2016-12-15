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
#import "YNetworkManager.h"

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

@property (strong, nonatomic) YNetworkManager *netManager;

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

- (instancetype)init {
    self = [super init];
    if (self) {
        self.netManager = [YNetworkManager shareManager];
    }
    return self;
}

- (void)downloadReadingBookWith:(YDownloadType)loadType progress:(void (^)(NSUInteger, NSUInteger))progress completion:(void (^)())completion failure:(void (^)(NSString *))failure {
    YReaderManager *readerM = [YReaderManager shareReaderManager];
    YDownloadModel *downloadM = [[YDownloadModel alloc] init];
    downloadM.downloadBook = readerM.readingBook;
    downloadM.summaryM = readerM.selectSummary;
    downloadM.chaptersLink = readerM.record.chaptersLink;
    downloadM.chaptersArr = readerM.chaptersArr;
    if (loadType == YDownloadTypeAllLoad) {
        downloadM.startChapter = 0;
        downloadM.endChapter = readerM.chaptersArr.count;
    } else if (loadType == YDownloadTypeBehindAll) {
        downloadM.startChapter = readerM.record.readingChapter;
        downloadM.endChapter = readerM.chaptersArr.count;
    } else if (loadType == YDownloadTypeBehindSome) {
        downloadM.startChapter = readerM.record.readingChapter;
        downloadM.endChapter = downloadM.startChapter + 50 < readerM.chaptersArr.count ?  downloadM.startChapter + 50 : readerM.chaptersArr.count;
    }
    downloadM.totalChapter = downloadM.endChapter - downloadM.startChapter;
    
    downloadM.progress = progress;
    downloadM.completion = completion;
    downloadM.failure = failure;
    
    self.downloadReading = downloadM;
    
}

- (void)downloadChapterWith:(YDownloadModel *)downloadM {
    YChapterContentModel *chapterM = nil;
    if (downloadM.chapter < downloadM.chaptersArr.count) {
        chapterM = downloadM.chaptersArr[downloadM.chapter];
    } else {
        DDLogWarn(@"downloadChapter  chapter(%zi) < self.chaptersArr.count(%zi)",downloadM.chapter,downloadM.chaptersArr.count);
        return;
    }
    
    if (chapterM.isLoadCache) {
        DDLogInfo(@"Cache book:%@  chapter:%zi",downloadM.downloadBook.title,downloadM.chapter);
        dispatch_async(dispatch_get_main_queue(), ^{
            downloadM.chapter ++;
            if (![self checkDownloadStatusWith:downloadM]) {
                dispatch_async(YDownloadManagerGetQueue(), ^{
                    [self downloadChapterWith:downloadM];
                });
            }
        });
        return;
    }

    __weak typeof(downloadM) weakDownLoad = downloadM;
    [_netManager getWithAPIType:YAPITypeChapterContent parameter:chapterM.link success:^(id response) {
        
        DDLogInfo(@"Load book:%@  chapter:%zi",downloadM.downloadBook.title,downloadM.chapter);
        [weakDownLoad.cache setObject:chapterM.body forKey:chapterM.link withBlock:^{
            chapterM.isLoadCache = YES;
            DDLogInfo(@"Load Cache chapter %zi",weakDownLoad.chapter);
            if (weakDownLoad.chapter < weakDownLoad.chaptersLink.count) {
                YChaptersLinkModel *linkM = weakDownLoad.chaptersLink[weakDownLoad.chapter];
                linkM.isLoadCache = YES;
                [weakDownLoad.cache setObject:weakDownLoad.record forKey:weakDownLoad.recordKey];
            } else {
                DDLogError(@"downloadChapter error cache chapterM.body success but chapterz:%zi < wself.record.chaptersLink.count:%zi",weakDownLoad.chapter,weakDownLoad.chaptersLink.count);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                downloadM.chapter ++;
                if (![self checkDownloadStatusWith:downloadM]) {
                    dispatch_async(YDownloadManagerGetQueue(), ^{
                        [self downloadChapterWith:downloadM];
                    });
                }
            });
        }];
        
    } failure:^(NSError *error) {
        
    }];
}

- (BOOL)checkDownloadStatusWith:(YDownloadModel *)downloadM {
    if (downloadM.progress) {
        downloadM.progress(downloadM.chapter - downloadM.startChapter,downloadM.totalChapter);
    }
    if (downloadM.chapter == downloadM.endChapter) {
        if (downloadM.completion) {
            downloadM.completion();
        }
        if ([downloadM.downloadBook isEqual:self.downloadReading.downloadBook]) {
            self.downloadReading = nil;
        }
        return YES;
    }
    return NO;
}

@end



#pragma mark - YDownloadModel
@implementation YDownloadModel

- (void)setSummaryM:(YBookSummaryModel *)summaryM {
    _summaryM = summaryM;
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *cachePath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_cache",summaryM.idField]];
    self.cache = [[YYDiskCache alloc] initWithPath:cachePath];
    
}

- (NSString *)recordKey {
    if (!_recordKey) {
        _recordKey = [NSString stringWithFormat:@"%@_record",self.summaryM.idField];
    }
    return _recordKey;
}

@end



