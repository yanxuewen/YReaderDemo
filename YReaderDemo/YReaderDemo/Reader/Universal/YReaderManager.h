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

@property (strong, nonatomic, readonly) NSArray *summarysArr;
@property (strong, nonatomic, readonly) NSMutableArray *chaptersArr;
@property (strong, nonatomic, readonly) YBookDetailModel *readingBook;
@property (strong, nonatomic) YChapterContentModel *chapterModel;
@property (strong, nonatomic) YReaderRecord *record;
@property (assign, nonatomic) NSUInteger chaptersCount;


+ (instancetype)shareReaderManager;
- (void)updateReadingBook:(YBookDetailModel *)bookM;

@end
