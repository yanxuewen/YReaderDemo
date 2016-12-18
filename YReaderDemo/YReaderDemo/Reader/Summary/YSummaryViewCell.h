//
//  YSummaryViewCell.h
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/18.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YBookSummaryModel;
@interface YSummaryViewCell : UITableViewCell

@property (assign, nonatomic) BOOL isSelectSummary;
@property (strong, nonatomic) YBookSummaryModel *summaryM;

@end
