//
//  YBookDetailCell.h
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/9.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YBookModel.h"
#import "YRecommendBookListModel.h"

@interface YBookDetailCell : UITableViewCell

@property (strong, nonatomic) YBookModel *bookModel;
@property (strong, nonatomic) YRecommendBookListModel *recommendListModel;

@end
