//
//  YRankingModel.h
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/19.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YBaseModel.h"

@interface YRankingModel : YBaseModel

@property (nonatomic, assign) BOOL collapse;
@property (nonatomic, strong) NSString * monthRank;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * totalRank;

+ (instancetype)modelWithTitle:(NSString *)title;

@end
