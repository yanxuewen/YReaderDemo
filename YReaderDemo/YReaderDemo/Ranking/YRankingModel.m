//
//  YRankingModel.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/19.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YRankingModel.h"

@implementation YRankingModel

+ (instancetype)modelWithTitle:(NSString *)title {
    YRankingModel *model = [[YRankingModel alloc] init];
    model.title = title;
    return model;
}

@end
