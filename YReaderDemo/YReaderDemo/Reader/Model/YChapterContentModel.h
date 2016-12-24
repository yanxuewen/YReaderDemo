//
//  YChapterContentModel.h
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/12.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YBaseModel.h"

@interface YChapterContentModel : YBaseModel

@property (nonatomic, strong) NSString * body;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString *link;
@property (nonatomic, assign) BOOL isLoad;          //从本地加载到内存,为了速度,内存等
@property (nonatomic, assign) BOOL isLoadCache;        //从网络下载到本地
@property (nonatomic, assign) NSUInteger pageCount;

@property (strong, nonatomic) NSString *traditionalStr;//body对于繁体

- (void)updateContentPaging;
- (NSAttributedString *)getStringWith:(NSUInteger)page;
+ (instancetype)chapterModelWith:(NSString *)title link:(NSString *)link load:(BOOL)isLoadCache;
+ (NSString *)adjustParagraphFormat:(NSString *)string;
@end
