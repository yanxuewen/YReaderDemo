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


@interface YDownloadManager : NSObject

+ (instancetype)shareManager;

- (void)downloadReadingBookWith:(YDownloadType)loadType progress:(void(^)(NSUInteger chapter,NSUInteger totalChapters))progress completion:(void(^)())completion failure:(void(^)(NSString *msg))failure;

@end



@interface YDownloadModel : NSObject

@property (strong, nonatomic) YBookDetailModel *downloadBook;
@property (strong, nonatomic) NSArray *chaptersLink;
@property (strong, nonatomic) NSArray *chaptersArr;
@property (assign, nonatomic) NSUInteger startChapter;
@property (assign, nonatomic) NSUInteger endChapter;
@property (assign, nonatomic) NSUInteger totalChapter;

@end
