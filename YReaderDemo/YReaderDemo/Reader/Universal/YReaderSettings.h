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

@property (strong, nonatomic, readonly) UIColor *textColor;
@property (strong, nonatomic, readonly) UIImage *pageImage;     //根据 YReaderTheme 来定
@property (strong, nonatomic, readonly) NSDictionary *readerAttributes;

@end
