//
//  YMenuViewController.h
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/13.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YBaseViewController.h"

@interface YMenuViewController : YBaseViewController

@property (copy, nonatomic) void(^menuTapAction)(NSInteger);
- (void)showMenuView;

@end
