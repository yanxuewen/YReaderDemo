//
//  YJLocalCountryData.h
//  SMS_SDKDemo
//
//  Created by 李愿生 on 15/12/21.
//  Copyright © 2015年 All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMS_MBProgressHUD.h"

@interface YJLocalCountryData : NSObject

/**
 *  @param             初始化YJLocalCountryData对象
 */
+ (YJLocalCountryData *)shareInstance;

/**
 *  @param             返回本地的国家列表数据
 */
+ (NSMutableArray *)localCountryDataArray;

/**
 *  @param dateString  待比较的日期字符串
 *  @param             返回比较的结果
 */

+ (NSDateComponents*)compareTwoDays:(NSString *)dateString;

/**
 *  @param keysInfo    传入数据
 *  @param             返回数据
 */
+ (NSMutableDictionary *)mutableDeepCopy:(NSDictionary *)keysInfo;

/**
 *  @param message     传入标识信息
 *  @param view        progressHUD展示的View
 */
+ (SMS_MBProgressHUD *)showMessag:(NSString *)message toView:(UIView *)view;

@end
