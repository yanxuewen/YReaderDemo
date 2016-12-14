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
#import <UIKit/UIKit.h>

#define kYReaderAutoLoadNumber 10

@interface YReaderManager ()

@property (strong, nonatomic) YSQLiteManager *sqliteM;
@property (strong, nonatomic) YReaderRecord *record;
@property (strong, nonatomic) YBookSummaryModel *selectSummary;
@property (assign, nonatomic) NSUInteger chaptersCount;
@property (strong, nonatomic) YYDiskCache *cache;
@property (strong, nonatomic) NSString *documentPath;
@property (strong, nonatomic) YNetworkManager *netManager;
@property (copy, nonatomic) void(^updateCompletion)();
@property (copy, nonatomic) void(^updateFailure)(NSString *);
@property (assign, nonatomic) NSUInteger endLoadIndex;
@property (strong, nonatomic, readonly) NSString *cachePath;
@property (strong, nonatomic, readonly) NSString *summarykey;
@property (strong, nonatomic, readonly) NSString *recordKey;
@property (assign, atomic) BOOL isAutoLoading;


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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminateNotification:) name:UIApplicationWillTerminateNotification object:nil];
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
        self.selectSummary = (YBookSummaryModel *)[self.sqliteM.cache objectForKey:self.summarykey];
        if (self.selectSummary) {
            [self getBookChaptersLink];
        } else {
            [self getBookSummary];
        }
    });
}

- (void)getBookSummary {
    __weak typeof(self) wself = self;
    [_netManager getWithAPIType:YAPITypeBookSummary parameter:_readingBook.idField success:^(id response) {
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
        DDLogWarn(@"get Book Summary failure %@",wself.readingBook);
        [wself updateReadingCompletionWith:error.localizedFailureReason];
    }];
    
}

- (void)getBookChaptersLink {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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
        [_netManager getWithAPIType:YAPITypeChaptersLink parameter:_selectSummary.idField success:^(id response) {
            NSArray *arr = (NSArray *)response;
            if (arr.count > 0) {
                wself.record.chaptersLink = arr;
                [wself updateReadingBookChaptersContent];
                [wself getChapterContentWith:wself.record.readingChapter autoLoad:NO];
            } else {
                DDLogWarn(@"本书该来源没有下载地址 %@",wself.selectSummary);
                [wself updateReadingCompletionWith:@"该来源没有下载地址"];
            }
        } failure:^(NSError *error) {
            DDLogWarn(@"get Book Chapters Link failure %@",wself.selectSummary);
            [wself updateReadingCompletionWith:error.localizedFailureReason];
        }];
    });
}

- (void)getChapterContentWith:(NSUInteger)chapter autoLoad:(BOOL)isAutoLoad{
    __weak typeof(self) wself = self;
    YChapterContentModel *chapterM = nil;
    if (chapter < self.chaptersArr.count) {
        chapterM = self.chaptersArr[chapter];
    } else {
        DDLogWarn(@"get Chapter Content  chapter(%zi) < self.chaptersArr.count(%zi)",chapter,self.chaptersArr.count);
        [wself updateReadingCompletionWith:@"书籍历史章节记录错误"];
        return;
    }
    
    if (chapterM.isLoadCache) {
        chapterM.body = (NSString *)[self.cache objectForKey:chapterM.link];;
        chapterM.isLoad = YES;
        if (isAutoLoad) {
            if (chapter < self.endLoadIndex) {
                [self getChapterContentWith:chapter+1 autoLoad:YES];
            } else {
                self.isAutoLoading = NO;;
                DDLogInfo(@"AutoLoad 完成 endLoadIndex:%zi",self.endLoadIndex);
            }
        } else {
            [chapterM updateContentPaging];
            [wself updateReadingCompletionWith:nil];
        }
        if (!chapterM.body) {
            DDLogError(@"error isLoadCache YES BUT body==nil;chapterM:%@  selectSummary:%@",chapterM,self.selectSummary);
        }
        return;
    }
    [_netManager getWithAPIType:YAPITypeChapterContent parameter:chapterM.link success:^(id response) {
        chapterM.body = ((YChapterContentModel *)response).body;
        chapterM.isLoad = YES;
        [wself.cache setObject:chapterM.body forKey:chapterM.link withBlock:^{
            chapterM.isLoadCache = YES;
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
        DDLogWarn(@"get Chapter Content failure %@",chapterM);
        [wself updateReadingCompletionWith:error.localizedFailureReason];
    }];
}

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

- (void)appDidEnterBackgroundNotification:(NSNotification *)noti {
    NSLog(@"%s",__func__);
    if (self.selectSummary) {
        [self.cache setObject:self.selectSummary forKey:self.summarykey];
    }
    if (self.record) {
        [self.cache setObject:self.record forKey:self.recordKey];
    }
}

- (void)appWillTerminateNotification:(NSNotification *)noti {
    NSLog(@"%s",__func__);
    if (self.selectSummary) {
        [self.cache setObject:self.selectSummary forKey:self.summarykey];
    }
    if (self.record) {
        [self.cache setObject:self.record forKey:self.recordKey];
    }
}

- (NSString *)cachePath {
    return [self.documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_cache",self.selectSummary.idField]];
}

- (NSString *)summarykey {
    return [NSString stringWithFormat:@"%@_summary",self.readingBook.idField];
}

- (NSString *)recordKey {
    return [NSString stringWithFormat:@"%@_record",self.selectSummary.idField];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
