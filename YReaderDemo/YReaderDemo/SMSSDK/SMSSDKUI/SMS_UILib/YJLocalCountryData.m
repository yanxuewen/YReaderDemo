//
//  YJLocalCountryData.m
//  SMS_SDKDemo
//
//  Created by 李愿生 on 15/12/21.
//  Copyright © 2015年. All rights reserved.
//

#import "YJLocalCountryData.h"

@interface YJLocalCountryData ()

@property (nonatomic, strong) NSMutableArray *keys;

@property (nonatomic, strong) NSDictionary *allNames;

@end

@implementation YJLocalCountryData


static YJLocalCountryData *localCountryData = nil;

+ (YJLocalCountryData *)shareInstance
{
    @synchronized (self)
    {
        if (localCountryData == nil)
        {
            localCountryData = [[YJLocalCountryData alloc] init];
        }
        return localCountryData;
    }
}

+ (NSMutableArray *)localCountryDataArray
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"SMSSDKUI" ofType:@"bundle"];
    NSBundle *bundle = [[NSBundle alloc] initWithPath:filePath];
    NSString *dataString = [bundle pathForResource:@"country" ofType:@"plist"];
    NSDictionary *dataDic = [[NSDictionary alloc] initWithContentsOfFile:dataString];
    
    NSMutableArray *keyArray = [[NSMutableArray alloc] init];

    [keyArray addObjectsFromArray:[[dataDic allKeys]
                                   sortedArrayUsingSelector:@selector(compare:)]];
    [YJLocalCountryData shareInstance].keys = keyArray;
    
    NSMutableArray *dataArray = [[YJLocalCountryData shareInstance] readCountryCode:dataDic];
    
    return dataArray;
}

- (NSMutableArray *)readCountryCode:(NSDictionary *)countryData
{
    NSMutableArray *zoneArray = [NSMutableArray array];
    
    NSDictionary *codeDic = nil;
    
    for (NSString *key in self.keys) {
        
        for (NSString *countryNameAndCode in [countryData objectForKey:key]) {
            
            NSRange range = [countryNameAndCode rangeOfString:@"+"];
            NSString* str2 = [countryNameAndCode substringFromIndex:range.location];
            NSString* areaCode = [str2 stringByReplacingOccurrencesOfString:@"+" withString:@""];
            
            if ([areaCode isEqualToString:@"86"]) {
                
                codeDic = [NSDictionary dictionaryWithObjectsAndKeys:areaCode,@"zone",@"^1(3|5|7|8|4)\\d{9}",@"rule", nil];
            }
            else
            {
            
                codeDic = [NSDictionary dictionaryWithObjectsAndKeys:areaCode,@"zone",@"^\\d+",@"rule", nil];
            }
            
            [zoneArray addObject:codeDic];
        }
    }
    
    return zoneArray;
    
}

+ (NSMutableDictionary *)mutableDeepCopy:(NSDictionary *)keysInfo
{
    if (![YJLocalCountryData shareInstance].allNames) {
        
        [YJLocalCountryData shareInstance].allNames = [NSDictionary dictionary];
    }
    [YJLocalCountryData shareInstance].allNames = keysInfo;
    
    return [[YJLocalCountryData shareInstance] mutableDeepCopy];
}

-(NSMutableDictionary *)mutableDeepCopy
{
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] initWithCapacity:[self.allNames count]];
    NSArray *keysArray = [self.allNames allKeys];
    for (id key in keysArray)
    {
        id oneValue = [self.allNames valueForKey:key];
        id oneCopy = nil;
        
        if ([oneValue respondsToSelector:@selector(mutableDeepCopy)])
            oneCopy = [oneValue mutableDeepCopy];
        else if ([oneValue respondsToSelector:@selector(mutableCopy)])
            oneCopy = [oneValue mutableCopy];
        if (oneCopy == nil)
            oneCopy = [oneValue copy];
        [ret setValue:oneCopy forKey:key];
    }
    return ret;
}

/**
 *  计算两个日期的天数差
 *
 *  @param dateString 待计算日期
 *
 *  @return 返回NSDateComponents,通过属性day,可以判断待计算日期和当前日期的天数差
 */
+ (NSDateComponents*)compareTwoDays:(NSString *)dateString
{
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorian setFirstWeekday:2];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *fromDate;
    NSDate *toDate;
    [gregorian rangeOfUnit:NSCalendarUnitDay startDate:&fromDate interval:NULL forDate:[dateFormatter dateFromString:dateString]];
    [gregorian rangeOfUnit:NSCalendarUnitDay startDate:&toDate interval:NULL forDate:[NSDate date]];
    NSDateComponents *dayComponents = [gregorian components:NSCalendarUnitDay | NSWeekdayCalendarUnit fromDate:fromDate toDate:toDate options:0];
    
    return dayComponents;
}

#pragma mark 显示一些信息
+ (SMS_MBProgressHUD *)showMessag:(NSString *)message toView:(UIView *)view {
    // 快速显示一个提示信息
    SMS_MBProgressHUD *hud = [SMS_MBProgressHUD showHUDAddedTo:view animated:YES];
//    hud.labelText = message;//添加message造成了提示图失真
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // YES代表需要蒙版效果
    //hud.dimBackground = YES;
    
    // 3秒之后再消失
    [hud hide:YES afterDelay:3];
    
    return hud;
}

@end
