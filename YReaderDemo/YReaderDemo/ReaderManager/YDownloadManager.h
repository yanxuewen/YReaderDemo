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
- (void)downloadReaderBookWith:(YBookDetailModel *)bookM type:(YDownloadType)loadType;
- (void)cancelDownloadBookWith:(YBookDetailModel *)bookM;

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
@property (assign, nonatomic) YDownloadType loadType;
@property (strong, nonatomic) NSString *recordKey;
@property (strong, nonatomic) NSURLSessionTask *lastTask;

+ (instancetype)downloadModelWith:(YBookDetailModel *)bookM loadType:(YDownloadType)loadType;
- (BOOL)checkDownloadStatus;
- (BOOL)checkCancelStatus;

@end





