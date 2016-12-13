//
//  YReaderManager.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/13.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YReaderManager.h"
#import "YSQLiteManager.h"

@interface YReaderManager ()

@property (strong, nonatomic) YSQLiteManager *sqliteM;

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
        self.sqliteM = [YSQLiteManager shareManager];
    }
    return self;
}

- (void)updateReadingBook:(YBookDetailModel *)bookM {
//    if ([bookM isEqual:_readingBook]) {
//        return;
//    }
    _readingBook = bookM;
    _record = [YReaderRecord recordModelWith:bookM];
    if (_record.chaptersLink.count > 0) {
        for (YChaptersLinkModel *linkM in _record.chaptersLink) {
            YChapterContentModel *chapterM = [YChapterContentModel chapterModelWith:linkM.title link:linkM.link];
            [_chaptersArr addObject:chapterM];
        }
    }
    if (_record.readingChapter < _chaptersArr.count) {
        _chapterModel = _chaptersArr[_record.readingChapter];
        [_chapterModel pagingWithBounds:CGRectMake(20, 30, kScreenWidth-40, kScreenHeight - 60)];
    } else {
        DDLogError(@"%@ %@ _record.readingChapter >= _chaptersArr.count error",bookM,_record);
    }
    
}

@end
