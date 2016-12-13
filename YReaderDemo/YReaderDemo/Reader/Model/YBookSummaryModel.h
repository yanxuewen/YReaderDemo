//
//  YBookSummaryModel.h
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/12.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YBaseModel.h"

@interface YBookSummaryModel : YBaseModel

@property (nonatomic, assign) NSInteger chaptersCount;
@property (nonatomic, strong) NSString * host;
@property (nonatomic, assign) BOOL isCharge;
@property (nonatomic, strong) NSString * lastChapter;
@property (nonatomic, strong) NSString * link;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * source;
@property (nonatomic, assign) BOOL starting;
@property (nonatomic, strong) NSDate * updated;

@end
