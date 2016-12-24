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
#import "YSQLiteManager.h"

#define kYMaxSyncDownloadTask 2
#define Lock() dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER)
#define Unlock() dispatch_semaphore_signal(self->_lock)

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
@property (strong, nonatomic) NSMutableArray *taskArray;

@end

@implementation YDownloadManager{
    dispatch_semaphore_t _lock;
}

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
        _taskArray = @[].mutableCopy;
        _lock = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)downloadReaderBookWith:(YBookDetailModel *)bookM type:(YDownloadType)loadType{
    if (bookM.hasLoadCompletion) {
        [YProgressHUD showErrorHUDWith:@"已经缓存完成"];
        return;
    }
    if (bookM.loadStatus != YDownloadStatusNone) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bookM.loadFailure) {
                bookM.loadFailure(@"正在下载中...");
            }
            DDLogWarn(@"downloadReaderBook:%@ bookM.loadStatus:(%zi) != YDownloadStatusNone",bookM,bookM.loadStatus);
        });
        return;
    }
    bookM.loadStatus = YDownloadStatusWait;
    
    dispatch_async(YDownloadManagerGetQueue(), ^{
        YDownloadModel *downloadM = [YDownloadModel downloadModelWith:bookM loadType:loadType];
        [self addDownloadTaskWith:downloadM];
        [self startNextTask];
    });
    
}

- (void)downloadChapterWith:(YDownloadModel *)downloadM {
    
    if (!downloadM) {
        DDLogError(@"downloadChapterWith: nil");
        return;
    }
    
    if ([downloadM checkCancelStatus]) {
        [self finishTaskWith:downloadM];
        return;
    }
    YChapterContentModel *chapterM = nil;
    if (downloadM.chapter < downloadM.chaptersArr.count) {
        chapterM = downloadM.chaptersArr[downloadM.chapter];
    } else {
        [self downloadNextChapterWith:downloadM];
        DDLogWarn(@"downloadChapter  chapter(%zi) < self.chaptersArr.count(%zi)",downloadM.chapter,downloadM.chaptersArr.count);
        return;
    }
    
    if (chapterM.isLoadCache) {
        downloadM.lastTask = nil;
        [self downloadNextChapterWith:downloadM];
        DDLogInfo(@"Cache book:%@  chapter:%zi",downloadM.downloadBook.title,downloadM.chapter);
        return;
    }
    __weak typeof(self) wself = self;
    __weak typeof(downloadM) weakDownLoad = downloadM;
    downloadM.lastTask = [_netManager getWithAPIType:YAPITypeChapterContent parameter:chapterM.link success:^(id response) {
        NSString *body = [YChapterContentModel adjustParagraphFormat:((YChapterContentModel *)response).body];
        DDLogInfo(@"Load book:%@  chapter:%zi",downloadM.downloadBook.title,downloadM.chapter);
        [weakDownLoad.cache setObject:body forKey:chapterM.link withBlock:^{
            chapterM.isLoadCache = YES;
            DDLogInfo(@"Load Cache chapter %zi",weakDownLoad.chapter);
            if (weakDownLoad.chapter < weakDownLoad.chaptersLink.count) {
                YChaptersLinkModel *linkM = weakDownLoad.chaptersLink[weakDownLoad.chapter];
                linkM.isLoadCache = YES;
                [weakDownLoad.cache setObject:weakDownLoad.record forKey:weakDownLoad.recordKey];
            } else {
                DDLogError(@"downloadChapter error cache chapterM.body success but chapterz:%zi < wself.record.chaptersLink.count:%zi",weakDownLoad.chapter,weakDownLoad.chaptersLink.count);
            }
            [wself downloadNextChapterWith:downloadM];
        }];
        
    } failure:^(NSError *error) {
        if (![downloadM checkCancelStatus]) {
            [wself downloadNextChapterWith:downloadM];//先这样处理
            DDLogInfo(@"download Chapter error:%@",error);
        } else {
            [self finishTaskWith:downloadM];
        }
    }];
}

- (void)downloadNextChapterWith:(YDownloadModel *)downloadM {
    dispatch_async(dispatch_get_main_queue(), ^{
        downloadM.chapter ++;
        if (![downloadM checkDownloadStatus]) {
            dispatch_async(YDownloadManagerGetQueue(), ^{
                [self downloadChapterWith:downloadM];
            });
        } else {
            [self finishTaskWith:downloadM];
        }
    });
}

- (void)finishTaskWith:(YDownloadModel *)downloadM {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeDownloadTaskWith:downloadM];
        [self startNextTask];
    });
}

- (void)addDownloadTaskWith:(YDownloadModel *)downloadM {
    if (!downloadM) {
        return;
    }
    Lock();
    if (![self.taskArray containsObject:downloadM]) {
        [self.taskArray addObject:downloadM];
    } else {
        DDLogWarn(@"addDownloadTaskWith:%@ 但是taskArray containsObject",downloadM.downloadBook.title);
    }
    Unlock();
}

- (void)removeDownloadTaskWith:(YDownloadModel *)downloadM {
    if (!downloadM) {
        return;
    }
    Lock();
    if ([self.taskArray containsObject:downloadM]) {
        [self.taskArray removeObject:downloadM];
    } else {
        DDLogWarn(@"removeDownloadTaskWith:%@ 但是taskArray containsObject == NO",downloadM.downloadBook.title);
    }
    Unlock();
}

- (void)startNextTask {
    
    Lock();
    if (self.taskArray.count > 0) {
        YDownloadModel *readingLoad = nil;
        YDownloadModel *firstWaitTask = nil;
        YReaderManager *readerM = [YReaderManager shareReaderManager];
        NSUInteger loadingTaskCount = 0;
        for (YDownloadModel *model in self.taskArray) {
            if ([model.downloadBook isEqual:readerM.readingBook]) {
                readingLoad = model;
            } else {
                if (model.downloadBook.loadStatus == YDownloadStatusWait) {
                    firstWaitTask = model;
                }
            }
            if (model.downloadBook.loadStatus == YDownloadStatusLoading) {
                loadingTaskCount++;
            }
        }
        if (readingLoad) {
            readingLoad.downloadBook.loadStatus = YDownloadStatusLoading;
            [self downloadChapterWith:readingLoad];
        }
        if (loadingTaskCount < kYMaxSyncDownloadTask) {
            if (firstWaitTask) {
                firstWaitTask.downloadBook.loadStatus = YDownloadStatusLoading;
                [self downloadChapterWith:firstWaitTask];
            }
        }
    }
    Unlock();
}


#pragma mark - cancel task
- (void)cancelDownloadBookWith:(YBookDetailModel *)bookM {
    dispatch_async(YDownloadManagerGetQueue(), ^{
        if (bookM.downloadM.lastTask && bookM.downloadM.lastTask.state == NSURLSessionTaskStateRunning) {
            [bookM.downloadM.lastTask cancel];
        }
        if (bookM.loadStatus == YDownloadStatusWait) {
            bookM.loadStatus = YDownloadStatusCancel;
            [bookM.downloadM checkCancelStatus];
        } else {
            bookM.loadStatus = YDownloadStatusCancel;
        }
        
        
    });
}

@end



#pragma mark - YDownloadModel
@implementation YDownloadModel

-(NSString *)description {
    return [NSString stringWithFormat:@"<YDownloadModel: summaryM:%@ record:%@ downloadBook:%@>",self.summaryM,self.record,self.downloadBook];
}

+ (instancetype)downloadModelWith:(YBookDetailModel *)bookM loadType:(YDownloadType)loadType {
    YDownloadModel *downloadM = [[YDownloadModel alloc] init];
    YReaderManager *readerM = [YReaderManager shareReaderManager];
    NSUInteger chaptersCount = 0;
    if ([bookM isEqual:readerM.readingBook]) {
        downloadM.downloadBook = readerM.readingBook;
        downloadM.summaryM = readerM.selectSummary;
        downloadM.record = readerM.record;
        downloadM.chaptersLink = readerM.record.chaptersLink;
        downloadM.chaptersArr = readerM.chaptersArr;
        chaptersCount = readerM.chaptersArr.count;
    } else {
        downloadM.downloadBook = bookM;
        downloadM.summaryM = (YBookSummaryModel *)[[YSQLiteManager shareManager] getBookSummaryWith:bookM];
        if (!downloadM.summaryM) {
            [downloadM downloadBookFailureWith:@"本书没有下载源"];
            return nil;
        }
        
        YReaderRecord *record = (YReaderRecord *)[downloadM.cache objectForKey:downloadM.recordKey];
        if (!record || record.chaptersLink.count == 0) {
            [downloadM downloadBookFailureWith:@"本书没有下载地址"];
            return nil;
        }
        downloadM.record = record;
        downloadM.chaptersLink = record.chaptersLink;
        NSMutableArray *chaptersArr = @[].mutableCopy;
        for (YChaptersLinkModel *linkM in record.chaptersLink) {
            YChapterContentModel *chapterM = [YChapterContentModel chapterModelWith:linkM.title link:linkM.link load:linkM.isLoadCache];
            [chaptersArr addObject:chapterM];
        }
        downloadM.chaptersArr = chaptersArr;
        chaptersCount = chaptersArr.count;
    }
    
    if (loadType == YDownloadTypeAllLoad) {
        downloadM.startChapter = 0;
        downloadM.endChapter = chaptersCount;
    } else if (loadType == YDownloadTypeBehindAll) {
        downloadM.startChapter = readerM.record.readingChapter;
        downloadM.endChapter = chaptersCount;
    } else if (loadType == YDownloadTypeBehindSome) {
        downloadM.startChapter = readerM.record.readingChapter;
        downloadM.endChapter = downloadM.startChapter + 50 < chaptersCount ?  downloadM.startChapter + 50 : chaptersCount;
    }
    downloadM.chapter = downloadM.startChapter;
    downloadM.loadType = loadType;
    bookM.downloadM = downloadM;
    return downloadM;
}

- (BOOL)checkDownloadStatus {
    if (self.downloadBook.loadProgress) {
        self.downloadBook.loadProgress(self.chapter,self.endChapter);
    }
    if (self.chapter >= self.endChapter) {
        self.downloadBook.loadStatus = YDownloadStatusNone;
        if (self.loadType == YDownloadTypeAllLoad) {
            self.downloadBook.hasLoadCompletion = YES;
            [[YSQLiteManager shareManager] updateUserBooksStatus];
        }
        if (self.downloadBook.loadCompletion) {
            self.downloadBook.loadCompletion();
        }
        return YES;
    }
    return NO;
}

- (BOOL)checkCancelStatus {
    if (self.downloadBook.loadStatus == YDownloadStatusCancel) {
        DDLogInfo(@"Download task Cancel book:%@",self.downloadBook.title);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.downloadBook.loadCancel) {
                self.downloadBook.loadCancel();
            }
            self.downloadBook.loadStatus = YDownloadStatusNone;
        });
        return YES;
    }
    return NO;
}


- (void)downloadBookFailureWith:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.downloadBook.loadStatus = YDownloadStatusNone;
        if (self.downloadBook.loadFailure) {
            self.downloadBook.loadFailure(msg);
        }
        DDLogWarn(@"downloadReaderBook:%@ msg",self.downloadBook);
    });
}

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

- (BOOL)isEqual:(id)object {
    if (!object || ![object isKindOfClass:[self class]]) {
        return NO;
    }
    YDownloadModel *model = (YDownloadModel *)object;
    if ([self.downloadBook isEqual:model.downloadBook]) {
        return YES;
    }
    return NO;
}

@end



