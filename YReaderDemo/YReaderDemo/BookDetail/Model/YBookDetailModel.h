//
//  YBookDetailModel.h
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/10.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YBaseModel.h"
#import "YReaderUniversal.h"
@class YDownloadModel;

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

@property (assign, nonatomic) BOOL hasSticky;       //置顶
@property (assign, nonatomic) BOOL hasUpdated;      //有更新
/**
 已经下载完,这个状态现在有误,比如换了书籍的下载来源,但是现在不改了,然后现在Xcode 8 插件比较麻烦,不好写注释了,就没写了...
 反正这也是写给女朋友看的...
 **/
@property (assign, nonatomic) BOOL hasLoadCompletion;
@property (weak, nonatomic) YDownloadModel *downloadM;
@property (assign, atomic) YDownloadStatus loadStatus;
@property (copy, nonatomic) void (^loadProgress)(NSUInteger, NSUInteger);
@property (copy, nonatomic) void (^loadCompletion)();
@property (copy, nonatomic) void (^loadFailure)(NSString *);
@property (copy, nonatomic) void (^loadCancel)();

- (NSString *)getBookWordCount;

@end
