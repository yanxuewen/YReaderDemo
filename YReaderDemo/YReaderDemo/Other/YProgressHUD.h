//
//  YProgressHUD.h
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/18.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YProgressHUD : NSObject

@property (copy, nonatomic) void(^cancelAction)();
+ (instancetype)shareProgressHUD;
+ (void)showLoadingHUD;
+ (void)hideLoadingHUD;
+ (void)showErrorHUDWith:(NSString *)msg;

@end
