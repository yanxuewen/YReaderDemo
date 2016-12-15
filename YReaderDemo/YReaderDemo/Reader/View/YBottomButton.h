//
//  YBottomButton.h
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/12.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YBottomButton : UIView

@property (copy, nonatomic) void(^tapAction)(NSInteger);
+ (instancetype)bottonWith:(NSString *)title imageName:(NSString *)imageName tag:(NSInteger)tag;

@end
