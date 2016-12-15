//
//  YDownloadManager.h
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/15.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YReaderUniversal.h"
#import "YBookDetailModel.h"
#import "YBookSummaryModel.h"
#import "YChaptersLinkModel.h"
#import "YChapterContentModel.h"
#import "YReaderRecord.h"

@class YDownloadModel;

@interface YDownloadManager : NSObject

@property (strong, nonatomic) YDownloadModel *downloadReading;

+ (instancetype)shareManager;
- (void)downloadReadingBookWith:(YDownloadType)loadType progress:(void(^)(NSUInteger chapter,NSUInteger totalChapters))progress completion:(void(^)())completion failure:(void(^)(NSString *msg))failure;

@end



@interface YDownloadModel : NSObject

@property (strong, nonatomic) YBookDetailModel *downloadBook;
@property (strong, nonatomic) YBookSummaryModel *summaryM;
@property (strong, nonatomic) YReaderRecord *record;
@property (strong, nonatomic) YYDiskCache *cache;
@property (strong, nonatomic) NSArray *chaptersLink;
@property (strong, nonatomic) NSArray *chaptersArr;
@property (assign, nonatomic) NSUInteger startChapter;
@property (assign, nonatomic) NSUInteger chapter;
@property (assign, nonatomic) NSUInteger endChapter;
@property (assign, nonatomic) NSUInteger totalChapter;
@property (strong, nonatomic) NSString *recordKey;
@property (strong, nonatomic) NSURLSessionTask *lastTask;
@property (assign, atomic) BOOL iaCancelled;
@property (copy, nonatomic) void (^cancelCompletion)();

@property (copy, nonatomic) void (^progress)(NSUInteger, NSUInteger);
@property (copy, nonatomic) void (^completion)();
@property (copy, nonatomic) void (^failure)(NSString *);

@end
