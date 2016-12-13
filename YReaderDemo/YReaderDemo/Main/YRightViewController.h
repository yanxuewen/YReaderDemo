//
//  YRightViewController.h
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/8.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YRightViewController : YBaseViewController

@property (copy, nonatomic) void(^selectCell)(NSInteger);

@end
