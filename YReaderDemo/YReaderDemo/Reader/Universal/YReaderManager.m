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
        NSString *summaryKey = [NSString stringWithFormat:@"%@_selectSummary",bookM.idField];
        self.selectSummary = (YBookSummaryModel *)[self.sqliteM.cache objectForKey:summaryKey];
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
        self.cache = [[YYDiskCache alloc] initWithPath:[NSString stringWithFormat:@"%@_bookCache",self.selectSummary]];
        self.record = (YReaderRecord *)[self.cache objectForKey:[NSString stringWithFormat:@"%@_recore",self.selectSummary.idField]];
        if (self.record && self.record.chaptersLink.count > 0) {
            [self updateReadingBookChaptersContent];
            [self getChapterContentWith:self.record.readingChapter];
            return;
        } else {
            self.record = [[YReaderRecord alloc] init];
            self.record.chaptersLink = @[];
            self.record.readingPage = 0;
            self.record.readingChapter = 0;
        }
        __weak typeof(self) wself = self;
        [_netManager getWithAPIType:YAPITypeChaptersLink parameter:_selectSummary.idField success:^(id response) {
            NSArray *arr = (NSArray *)response;
            if (arr.count > 0) {
                wself.record.chaptersLink = arr;
                [wself updateReadingBookChaptersContent];
                [wself getChapterContentWith:0];
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

- (void)getChapterContentWith:(NSUInteger)chapter {
    __weak typeof(self) wself = self;
    YChapterContentModel *chapterM = nil;
    if (chapter < self.chaptersArr.count) {
        chapterM = self.chaptersArr[chapter];
    } else {
        DDLogWarn(@"get Chapter Content  chapter(%zi) < self.chaptersArr.count(%zi)",chapter,self.chaptersArr.count);
        [wself updateReadingCompletionWith:@"书籍历史章节记录错误"];
        return;
    }
    NSString *body = (NSString *)[self.cache objectForKey:chapterM.link];
    if (body) {
        chapterM.body = body;
        [chapterM updateContentPaging];
        [wself updateReadingCompletionWith:nil];
        return;
    }
    [_netManager getWithAPIType:YAPITypeChapterContent parameter:chapterM.link success:^(id response) {
        chapterM.body = ((YChapterContentModel *)response).body;
        [chapterM updateContentPaging];
        [wself updateReadingCompletionWith:nil];
        
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
            YChapterContentModel *chapterM = [YChapterContentModel chapterModelWith:linkM.title link:linkM.link];
            [_chaptersArr addObject:chapterM];
        }
    } else {
        DDLogError(@"chaptersLink nil or empty %@",_record);
    }   
}

@end
