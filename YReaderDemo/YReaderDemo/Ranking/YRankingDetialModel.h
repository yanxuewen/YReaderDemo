//
//  YRankingDetialModel.h
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/19.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YBaseModel.h"

@interface YRankingDetialModel : YBaseModel

@property (nonatomic, strong) NSString * author;
@property (nonatomic, assign) NSInteger banned;
@property (nonatomic, strong) NSString * cat;
@property (nonatomic, assign) NSInteger latelyFollower;
@property (nonatomic, assign) NSInteger latelyFollowerBase;
@property (nonatomic, assign) NSInteger minRetentionRatio;
@property (nonatomic, strong) NSString * retentionRatio;
@property (nonatomic, strong) NSString * shortIntro;
@property (nonatomic, strong) NSString * site;
@property (nonatomic, strong) NSString * title;

@end
