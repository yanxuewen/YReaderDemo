//
//  YBookModel.h
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/9.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YBaseModel.h"

@interface YBookModel : YBaseModel

@property (nonatomic, strong) NSString * author;
@property (nonatomic, strong) NSString * cat;
@property (nonatomic, assign) BOOL hasCp;
@property (nonatomic, strong) NSString * lastChapter;
@property (nonatomic, assign) NSInteger latelyFollower;
@property (nonatomic, assign) double retentionRatio;
@property (nonatomic, strong) NSString * shortIntro;
@property (nonatomic, strong) NSString * site;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, assign) NSInteger wordCount;

@end
