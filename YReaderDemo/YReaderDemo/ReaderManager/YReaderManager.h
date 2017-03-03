//
//  YReaderManager.h
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/13.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YBookSummaryModel.h"
#import "YChapterContentModel.h"
#import "YChaptersLinkModel.h"
#import "YBookDetailModel.h"
#import "YReaderRecord.h"

@interface YReaderManager : NSObject

@property (strong, nonatomic, readonly) NSMutableArray *chaptersArr;
@property (strong, nonatomic, readonly) YBookDetailModel *readingBook;
@property (strong, nonatomic, readonly) YBookSummaryModel *selectSummary;
@property (strong, nonatomic, readonly) YReaderRecord *record;
@property (assign, nonatomic, readonly) NSUInteger chaptersCount;
@property (copy, nonatomic) void(^cancelLoadingCompletion)();
@property (copy, nonatomic) void(^cancelGetChapterCompletion)();

+ (instancetype)shareReaderManager;
- (void)updateReadingBook:(YBookDetailModel *)bookM completion:(void(^)())completion failure:(void (^)(NSString *msg))failure;
- (void)updateBookSummary:(YBookSummaryModel *)summaryM completion:(void(^)())completion failure:(void (^)(NSString *msg))failure;
- (void)updateReadingBookChaptersContent;
- (void)updateBookChaptersLink;
- (void)autoLoadNextChapters:(NSUInteger)index;
- (void)updateReadingChapter:(NSUInteger)chapter page:(NSUInteger)page;
- (void)closeReadingBook;
- (void)cancelLoadReadingBook;
- (void)getChapterContentWith:(NSUInteger)chapter completion:(void(^)())completion failure:(void (^)(NSString *msg))failure;
- (void)cancelGetChapterContent;
@end



