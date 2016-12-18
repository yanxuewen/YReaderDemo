//
//  YCenterViewController.h
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/8.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,YShowState) {
    YShowStateLeft,
    YShowStateRight
};

@interface YCenterViewController : YBaseViewController

@property (copy, nonatomic) void(^tapBarButton)(YShowState);
-(void)autoRefreshbooks;

@end
