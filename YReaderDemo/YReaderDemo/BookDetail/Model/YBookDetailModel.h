//
//  YBookDetailModel.h
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/10.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YBaseModel.h"

@interface YBookDetailModel : YBaseModel

@property (nonatomic, assign) BOOL le;
@property (nonatomic, assign) BOOL allowBeanVoucher;
@property (nonatomic, assign) BOOL allowMonthly;
@property (nonatomic, assign) BOOL allowVoucher;
@property (nonatomic, strong) NSString * author;
@property (nonatomic, strong) NSString * cat;
@property (nonatomic, assign) NSInteger chaptersCount;
@property (nonatomic, strong) NSString * copyright;
@property (nonatomic, strong) NSString * creater;
@property (nonatomic, assign) BOOL donate;
@property (nonatomic, assign) NSInteger followerCount;
@property (nonatomic, strong) NSArray * gender;
@property (nonatomic, assign) BOOL hasCp;
@property (nonatomic, assign) BOOL isSerial;
@property (nonatomic, strong) NSString * lastChapter;
@property (nonatomic, assign) NSInteger latelyFollower;
@property (nonatomic, assign) NSInteger latelyFollowerBase;
@property (nonatomic, strong) NSString * longIntro;
@property (nonatomic, strong) NSString * majorCate;
@property (nonatomic, assign) NSInteger minRetentionRatio;
@property (nonatomic, strong) NSString * minorCate;
@property (nonatomic, assign) NSInteger postCount;
@property (nonatomic, assign) double retentionRatio;
@property (nonatomic, assign) NSInteger serializeWordCount;
@property (nonatomic, strong) NSArray * tags;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSDate * updated;
@property (nonatomic, assign) NSInteger wordCount;

- (NSString *)getBookWordCount;

@end
