//
//  YReaderManager.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/13.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YReaderManager.h"
#import "YSQLiteManager.h"
#import "YReaderUniversal.h"
#import "YNetworkManager.h"
#import "YDownloadManager.h"
#import "YReaderSettings.h"
#import <UIKit/UIKit.h>

#define kYReaderAutoLoadNumber 10

@interface YReaderManager ()

@property (strong, nonatomic) YSQLiteManager *sqliteM;
@property (strong, nonatomic) YReaderRecord *record;
@property (strong, nonatomic) YBookSummaryModel *selectSummary;
@property (strong, nonatomic) NSMutableArray *chaptersArr;
@property (assign, nonatomic) NSUInteger chaptersCount;
@property (strong, nonatomic) YYDiskCache *cache;
@property (strong, nonatomic) NSString *documentPath;
@property (strong, nonatomic) YNetworkManager *netManager;
@property (copy, nonatomic) void(^updateCompletion)();
@property (copy, nonatomic) void(^updateFailure)(NSString *);
@property (assign, nonatomic) NSUInteger endLoadIndex;
@property (strong, nonatomic, readonly) NSString *cachePath;
@property (strong, nonatomic, readonly) NSString *recordKey;
@property (strong, nonatomic) NSURLSessionTask *summaryTask;
@property (strong, nonatomic) NSURLSessionTask *chaptersLinkTask;
@property (strong, nonatomic) NSURLSessionTask *chapterTask;
@property (assign, atomic) BOOL isAutoLoading;
@property (assign, atomic) BOOL cancelLoading;
@property (assign, nonatomic) BOOL cancelGetChapter;
@property (strong, nonatomic) NSURLSessionTask *getChapterTask;
@property (strong, nonatomic) YReaderSettings *settings;

@end

@implementation YReaderManager

+ (instancetype)shareReaderManager {
    static YReaderManager *readerM = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        readerM = [[self alloc] init];
    });
    return readerM;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        self.netManager = [YNetworkManager shareManager];
        self.sqliteM = [YSQLiteManager shareManager];
        self.settings = [YReaderSettings shareReaderSettings];
    }
    return self;
}

- (void)updateReadingBook:(YBookDetailModel *)bookM completion:(void (^)())completion failure:(void (^)(NSString *))failure{
//    if ([bookM isEqual:_readingBook]) {
//        return;
//    }
    if (self.updateCompletion || self.updateFailure) {
        self.updateFailure(@"更新书籍错误");
        return;
    }
    self.updateCompletion = completion;
    self.updateFailure = failure;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _readingBook = bookM;
        if (bookM.downloadM) {
            if (bookM.downloadM.summaryM && bookM.downloadM.record && bookM.downloadM.chaptersArr.count > 0) {
                self.selectSummary = bookM.downloadM.summaryM;
                self.record = bookM.downloadM.record;
                self.chaptersArr = (NSMutableArray *)bookM.downloadM.chaptersArr;
                self.chaptersCount = self.chaptersArr.count;
                self.cache = [[YYDiskCache alloc] initWithPath:self.cachePath];
                [self getChapterContentWith:self.record.readingChapter autoLoad:NO];
            } else {
                [self updateReadingCompletionWith:@"书籍错误,请重试"];
            }
        } else {
            self.selectSummary = [self.sqliteM getBookSummaryWith:bookM];
            if (self.selectSummary) {
                [self getBookChaptersLink];
            } else {
                [self getBookSummary];
            }
        }
        
    });
}

- (void)updateBookSummary:(YBookSummaryModel *)summaryM completion:(void (^)())completion failure:(void (^)(NSString *))failure {
    if (self.updateCompletion || self.updateFailure) {
        self.updateFailure(@"更新书籍错误");
        return;
    }
    self.updateCompletion = completion;
    self.updateFailure = failure;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (_readingBook.downloadM && _readingBook.loadStatus != YDownloadStatusCancel) {
            _readingBook.loadStatus = YDownloadStatusCancel;
        }
        [self.sqliteM updateBookSummaryWith:self.readingBook summaryM:self.selectSummary];
        if (self.readingBook.hasLoadCompletion) {
            self.readingBook.hasLoadCompletion = NO;
            [self.sqliteM updateUserBooksStatus];
        }
        self.record = nil;
        self.chaptersArr = nil;
        self.chaptersCount = 0;
        self.selectSummary = summaryM;
        [self getBookChaptersLink];

    });
}

- (void)getBookSummary {
    __weak typeof(self) wself = self;
    _summaryTask = [_netManager getWithAPIType:YAPITypeBookSummary parameter:_readingBook.idField success:^(id response) {
        if (wself.cancelLoading) {
            [wself cancelLoadCompletion];
            return ;
        }
        NSArray *arr = (NSArray *)response;
        if (arr.count > 0) {
            YBookSummaryModel *selectSummary = nil;
            for (YBookSummaryModel *summary in arr) {
                if (![summary.source isEqualToString:@"zhuishuvip"]) {
                    selectSummary = summary;
                    break;
                }
            }
            if (selectSummary) {
                wself.selectSummary = selectSummary;
                [wself.sqliteM updateBookSummaryWith:wself.readingBook summaryM:selectSummary];
                [wself getBookChaptersLink];
            } else {
                DDLogWarn(@"本书没有免费来源 %@",wself.readingBook);
                [wself updateReadingCompletionWith:@"请购买正版阅读"];
            }
        } else {
            DDLogWarn(@"本书没有来源 %@",wself.readingBook);
            [wself updateReadingCompletionWith:@"书籍来源返回错误"];
        }
    } failure:^(NSError *error) {
        if (wself.cancelLoading) {
            DDLogInfo(@"getBookSummary summaryTask cancel");
            if (wself.cancelLoading) {
                [wself cancelLoadCompletion];
                return ;
            }
        } else {
            DDLogWarn(@"get Book Summary failure %@",wself.readingBook);
            [wself updateReadingCompletionWith:error.localizedFailureReason];
        }
        
    }];
    
}

- (void)getBookChaptersLink {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.cancelLoading) {
            [self cancelLoadCompletion];
            return ;
        }
        self.cache = [[YYDiskCache alloc] initWithPath:self.cachePath];
        self.record = (YReaderRecord *)[self.cache objectForKey:self.recordKey];
        if (self.record && self.record.chaptersLink.count > 0) {
            [self updateReadingBookChaptersContent];
            [self getChapterContentWith:self.record.readingChapter autoLoad:NO];
            return;
        } else {
            self.record = [[YReaderRecord alloc] init];
        }
        __weak typeof(self) wself = self;
        _chaptersLinkTask = [_netManager getWithAPIType:YAPITypeChaptersLink parameter:_selectSummary.idField success:^(id response) {
            NSArray *arr = (NSArray *)response;
            if (arr.count > 0) {
                wself.record.chaptersLink = arr;
                [wself updateReadingBookChaptersContent];
                if (wself.record.readingChapter >= wself.record.chaptersLink.count) {
                    wself.record.readingChapter = wself.record.chaptersLink.count - 1;//换源的时候可能发生
                }
                [wself getChapterContentWith:wself.record.readingChapter autoLoad:NO];
            } else {
                DDLogWarn(@"本书该来源没有下载地址 %@",wself.selectSummary);
                [wself updateReadingCompletionWith:@"该来源没有下载地址"];
            }
        } failure:^(NSError *error) {
            if (wself.cancelLoading) {
                DDLogInfo(@"getBookChaptersLink chaptersLinkTask cancel");
                if (wself.cancelLoading) {
                    [wself cancelLoadCompletion];
                    return ;
                }
            } else {
                DDLogWarn(@"get Book Chapters Link failure %@",wself.selectSummary);
                [wself updateReadingCompletionWith:error.localizedFailureReason];
            }
            
        }];
    });
}

#pragma mark - 更新章节下载地址
- (void)updateBookChaptersLink {
    //现在每次只会更新一次，没有处理如果这里失败，下次怎么加载
    __weak typeof(self) wself = self;
    _chaptersLinkTask = [_netManager getWithAPIType:YAPITypeChaptersLink parameter:_selectSummary.idField success:^(id response) {
        NSArray *arr = (NSArray *)response;
        if (arr.count > wself.record.chaptersLink.count) {
            
            NSArray *moreLinkArr = [arr subarrayWithRange:NSMakeRange(wself.record.chaptersLink.count, arr.count - wself.record.chaptersLink.count)];
            NSMutableArray *moreChapterArr = @[].mutableCopy;
            for (YChaptersLinkModel *linkM in moreLinkArr) {
                YChapterContentModel *chapterM = [YChapterContentModel chapterModelWith:linkM.title link:linkM.link load:linkM.isLoadCache];
                [moreChapterArr addObject:chapterM];
            }
            wself.record.chaptersLink = [wself.record.chaptersLink arrayByAddingObjectsFromArray:moreLinkArr];
            [wself.chaptersArr addObjectsFromArray:moreChapterArr];
            wself.chaptersCount = wself.chaptersArr.count;
        } else {
            DDLogWarn(@"没有更新章节 %@",wself.selectSummary);
        }
    } failure:^(NSError *error) {
        
        DDLogWarn(@"get Book Chapters Link failure %@",wself.selectSummary);
        
    }];
}

- (void)getChapterContentWith:(NSUInteger)chapter autoLoad:(BOOL)isAutoLoad{
    if (self.cancelLoading) {
        [self cancelLoadCompletion];
        return ;
    }
    YChapterContentModel *chapterM = nil;
    if (chapter < self.chaptersArr.count) {
        chapterM = self.chaptersArr[chapter];
    } else {
        DDLogWarn(@"get Chapter Content  chapter(%zi) < self.chaptersArr.count(%zi)",chapter,self.chaptersArr.count);
        if (!isAutoLoad) {
            [self updateReadingCompletionWith:@"书籍历史章节记录错误"];
        }
        return;
    }
    
    if (chapterM.isLoadCache) {
        if (!chapterM.isLoad) {
            chapterM.body = (NSString *)[self.cache objectForKey:chapterM.link];
        }
        chapterM.isLoad = YES;
        if (isAutoLoad) {
            if (self.settings.isTraditional) {
                [chapterM.traditionalStr class];//check traditionalStr
            }
            if (chapter < self.endLoadIndex) {
                [self getChapterContentWith:chapter+1 autoLoad:YES];
            } else {
                self.isAutoLoading = NO;;
                DDLogInfo(@"AutoLoad 完成 endLoadIndex:%zi",self.endLoadIndex);
            }
        } else {
            [chapterM updateContentPaging];
            [self updateReadingCompletionWith:nil];
        }
        if (!chapterM.body) {
            DDLogError(@"error isLoadCache YES BUT body==nil;chapterM:%@  selectSummary:%@",chapterM,self.selectSummary);
        }
        return;
    }
    __weak typeof(self) wself = self;
    _chapterTask = [_netManager getWithAPIType:YAPITypeChapterContent parameter:chapterM.link success:^(id response) {
        chapterM.body = [YChapterContentModel adjustParagraphFormat:((YChapterContentModel *)response).body];
        chapterM.isLoad = YES;
        if (wself.settings.isTraditional) {
            [chapterM.traditionalStr class];//check traditionalStr
        }
        DDLogInfo(@"Load chapter %zi",chapter);
        [wself.cache setObject:chapterM.body forKey:chapterM.link withBlock:^{
            chapterM.isLoadCache = YES;
            DDLogInfo(@"Load Cache chapter %zi",chapter);
            if (chapter < wself.record.chaptersLink.count) {
                YChaptersLinkModel *linkM = wself.record.chaptersLink[chapter];
                linkM.isLoadCache = YES;
            } else {
                DDLogError(@"error cache chapterM.body success but chapterz:%zi < wself.record.chaptersLink.count:%zi",chapter,wself.record.chaptersLink.count);
            }
        }];
        if (isAutoLoad) {
            if (chapter < self.endLoadIndex) {
                [wself getChapterContentWith:chapter+1 autoLoad:YES];
            } else {
                wself.isAutoLoading = NO;
                DDLogInfo(@"AutoLoad 完成 endLoadIndex:%zi",self.endLoadIndex);
            }
        } else {
            [chapterM updateContentPaging];
            [wself updateReadingCompletionWith:nil];
        }
    } failure:^(NSError *error) {
        if (wself.cancelLoading) {
            DDLogInfo(@"getChapterContentWith chapterTask cancel");
            if (wself.cancelLoading) {
                [wself cancelLoadCompletion];
                return ;
            }
        } else {
            if (isAutoLoad) {
                if (chapter < self.endLoadIndex) {
                    [wself getChapterContentWith:chapter+1 autoLoad:YES];
                } else {
                    wself.isAutoLoading = NO;
                    DDLogInfo(@"AutoLoad 完成 endLoadIndex:%zi",self.endLoadIndex);
                }
            } else {
                DDLogWarn(@"get Chapter Content failure %@",chapterM);
                [wself updateReadingCompletionWith:error.localizedFailureReason];
            }
        }
        
    }];
}

#pragma mark - Completion
- (void)updateReadingCompletionWith:(NSString *)errorMsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (errorMsg) {
            if (self.updateFailure) {
                self.updateFailure(errorMsg);
            }
        } else {
            if (self.updateCompletion) {
                self.updateCompletion();
            }
        }
        self.updateCompletion = nil;
        self.updateFailure = nil;
    });
}


- (void)updateReadingBookChaptersContent {
    if (_record.chaptersLink.count > 0) {
        _chaptersArr = @[].mutableCopy;
        for (YChaptersLinkModel *linkM in _record.chaptersLink) {
            YChapterContentModel *chapterM = [YChapterContentModel chapterModelWith:linkM.title link:linkM.link load:linkM.isLoadCache];
            [_chaptersArr addObject:chapterM];
        }
    } else {
        DDLogError(@"chaptersLink nil or empty %@",_record);
    }   
}

- (void)autoLoadNextChapters:(NSUInteger)index {
    if (self.isAutoLoading) {
        return;
    }
    self.isAutoLoading = YES;
    if (index < self.chaptersArr.count) {
        self.endLoadIndex = index + kYReaderAutoLoadNumber < self.chaptersArr.count ? index + kYReaderAutoLoadNumber : self.chaptersArr.count - 1;
        [self getChapterContentWith:index autoLoad:YES];
    } else {
        DDLogInfo(@"加载完成 ? autoLoadNextChapters   index:%zi >= self.chaptersArr.count:%zi",index,self.chaptersArr.count);
    }
    
}

#pragma mark - Cancel load
- (void)cancelLoadReadingBook {
    if (!self.updateCompletion || !self.updateFailure) {
        DDLogWarn(@"cancelLoadReadingBook updateCompletion == nil || updateFailure == nil");
        return;
    }
    self.cancelLoading = YES;
    if (self.summaryTask.state == NSURLSessionTaskStateRunning) {
        [self.summaryTask cancel];
    }
    if (self.chaptersLinkTask.state == NSURLSessionTaskStateRunning) {
        [self.chaptersLinkTask cancel];
    }
    if (self.chapterTask.state == NSURLSessionTaskStateRunning) {
        [self.chapterTask cancel];
    }
}

- (void)cancelLoadCompletion {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.cancelLoadingCompletion) {
            self.cancelLoadingCompletion();
        }
        self.updateCompletion = nil;
        self.updateFailure = nil;
        self.cancelLoadingCompletion = nil;
        self.cancelLoading = NO;
    });
}

#pragma mark - cancel ChapterContent
- (void)cancelGetChapterContent {
    self.cancelGetChapter = YES;
    if (self.getChapterTask.state == NSURLSessionTaskStateRunning) {
        [self.getChapterTask cancel];
    }
}

- (void)getChapterContentWith:(NSUInteger)chapter completion:(void (^)())completion failure:(void (^)(NSString *))failure {
    if (chapter >= self.chaptersArr.count) {
        failure(@"章节错误");
        return;
    }
    YChapterContentModel *chapterM = self.chaptersArr[chapter];
    self.updateCompletion = completion;
    self.updateFailure = failure;
    if (chapterM.isLoadCache) {
        chapterM.body = (NSString *)[self.cache objectForKey:chapterM.link];
        chapterM.isLoad = YES;
        [chapterM updateContentPaging];
        [self updateReadingCompletionWith:nil];
        return;
    }
    __weak typeof(self) wself = self;
    _getChapterTask = [_netManager getWithAPIType:YAPITypeChapterContent parameter:chapterM.link success:^(id response) {
        chapterM.body = [YChapterContentModel adjustParagraphFormat:((YChapterContentModel *)response).body];
        chapterM.isLoad = YES;
        if (wself.settings.isTraditional) {
            [chapterM.traditionalStr class];//check traditionalStr
        }
        DDLogInfo(@"getChapterContent %@",chapterM);
        [wself.cache setObject:chapterM.body forKey:chapterM.link withBlock:^{
            chapterM.isLoadCache = YES;
            DDLogInfo(@"Load Cache chapter %zi",chapter);
            if (chapter < wself.record.chaptersLink.count) {
                YChaptersLinkModel *linkM = wself.record.chaptersLink[chapter];
                linkM.isLoadCache = YES;
            } else {
                DDLogError(@"error cache chapterM.body success but chapterz:%zi < wself.record.chaptersLink.count:%zi",chapter,wself.record.chaptersLink.count);
            }
        }];
        
        [chapterM updateContentPaging];
        [wself updateReadingCompletionWith:nil];
        wself.getChapterTask = nil;
    } failure:^(NSError *error) {
        if (wself.cancelGetChapter) {
            DDLogInfo(@"getChapterContentWith getChapterTask cancel");
            if (wself.cancelLoadingCompletion) {
                wself.cancelLoadingCompletion();
            }
            wself.updateCompletion = nil;
            wself.updateFailure = nil;
            wself.cancelGetChapter = NO;
            ;
        } else {
            DDLogWarn(@"get Chapter Content failure %@",chapterM);
            [wself updateReadingCompletionWith:error.localizedFailureReason];
        }
        wself.getChapterTask = nil;
    }];
    
}

- (void)updateReadingChapter:(NSUInteger)chapter page:(NSUInteger)page {
    self.record.readingChapter = chapter;
    self.record.readingPage = page;
    [self.sqliteM updateBookSummaryWith:self.readingBook summaryM:self.selectSummary];
    [self.cache setObject:self.record forKey:self.recordKey];
}

- (void)closeReadingBook {
    _readingBook = nil;
    _record = nil;
    _chaptersArr = nil;
    _selectSummary = nil;
    _summaryTask = nil;
    _chaptersLinkTask = nil;
    _chapterTask = nil;
    _chaptersCount = 0;
    _isAutoLoading = NO;
}

- (NSString *)cachePath {
    return [self.documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_cache",self.selectSummary.idField]];
}

- (NSString *)recordKey {
    return [NSString stringWithFormat:@"%@_record",self.selectSummary.idField];
}


@end
