//
//  YDateModel.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/10.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YDateModel.h"

#define kYCustomDateFormat @"yyyy-MM-dd'T'HH:mm:ss.SSSZ"

@interface YDateModel ()

@property (strong, nonatomic) NSDateFormatter *dateFormat;

@end

@implementation YDateModel

+ (instancetype)shareDateModel {
    static YDateModel *dateM = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateM = [[self alloc] init];
    });
    return dateM;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dateFormat = [[NSDateFormatter alloc] init];
        self.dateFormat.dateFormat = kYCustomDateFormat;
    }
    return self;
}

- (NSDate *)dateWithCustomDateFormat:(NSString *)dateStr {
    self.dateFormat.dateFormat = kYCustomDateFormat;
    return [self.dateFormat dateFromString:dateStr];
}

- (NSString *)getUpdateStringWith:(NSDate *)date {
    if (!date || ![date isKindOfClass:[NSDate class]]) {
        return @"long long ago";
    } else {
        NSString *unit = nil;
        NSInteger number = 0;
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:date];
        if (interval > 365 * 24 * 60 * 60) {
            number = interval / (365 * 24 * 60 * 60);
            unit = @"年";
        } else if (interval > 30 * 24 * 60 * 60) {
            number = interval / (30 * 24 * 60 * 60);
            unit = @"月";
        } else if (interval > 24 * 60 * 60) {
            number = interval / (24 * 60 * 60);
            unit = @"天";
        } else if (interval > 60 * 60) {
            number = interval / (60 * 60);
            unit = @"小时";
        } else if (interval > 60) {
            number = interval / 60;
            unit = @"分钟";
        } else {
            return @"刚刚";
        }
        return [NSString stringWithFormat:@"%zi%@前",number,unit];
    }
}

- (NSString *)getTimeString {
    self.dateFormat.dateFormat = @"HH:mm";
    return [self.dateFormat stringFromDate:[NSDate date]];
}

@end
