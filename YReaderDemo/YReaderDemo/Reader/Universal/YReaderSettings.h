//
//  YReaderSettings.h
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/12.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YBaseModel.h"
#import "YReaderUniversal.h"

@interface YReaderSettings : YBaseModel

+ (instancetype)shareReaderSettings;

@property (assign, nonatomic) double brightness;
@property (strong, nonatomic) UIFont *font;
@property (assign, nonatomic) BOOL isTraditional;
@property (assign, nonatomic) CGFloat lineSpacing;
@property (assign, nonatomic) YReaderTheme theme;
@property (assign, nonatomic) YTurnPageStyle pageStyle;
@property (assign, nonatomic) BOOL isNightMode;
@property (assign, nonatomic) CGFloat fontSize;

@property (copy, nonatomic) void(^refreshReaderView)();
@property (copy, nonatomic) void(^refreshPageStyle)();

@property (strong, nonatomic, readonly) UIColor *textColor;
@property (strong, nonatomic, readonly) UIColor *otherTextColor;//其他如标题,电池,时间等
@property (strong, nonatomic, readonly) NSDictionary *readerAttributes;
@property (strong, nonatomic, readonly) UIImage *themeImage;
@property (strong, nonatomic, readonly) NSArray *themeImageArr;

- (NSString *)transformToTraditionalWith:(NSString *)string;

@end
