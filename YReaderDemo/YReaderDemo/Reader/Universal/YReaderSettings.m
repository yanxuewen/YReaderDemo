//
//  YReaderSettings.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/12.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YReaderSettings.h"
#import "YSQLiteManager.h"

#define kYReaderSettings @"kYReaderSettings"

@interface YReaderSettings ()

@property (assign, nonatomic) BOOL needUpdateAttributes;
@property (strong, nonatomic) NSDictionary *readerAttributes;

@end

@implementation YReaderSettings

+ (NSArray *)modelPropertyBlacklist {
    return @[@"textColor",@"pageImage",@"readerAttributes",@"needUpdateAttributes",@"cover",@"idField"];
}

+ (instancetype)shareReaderSettings {
    static YReaderSettings *setting = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        YYCache *cache = [YSQLiteManager shareManager].cache;
        if ([cache containsObjectForKey:kYReaderSettings]) {
            setting = (YReaderSettings *)[cache objectForKey:kYReaderSettings];
        } else {
            setting = [[self alloc] init];
            [cache setObject:setting forKey:kYReaderSettings];
        }
    });
    return setting;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _brightness = 0.7;
        _lineSpacing = 5.0;
        _isTraditional = NO;
        _fontSize = 14.0;
        _font = [UIFont systemFontOfSize:_fontSize];
        _theme = YReaderThemeOne;
        _pageStyle = YTurnPageStyleSimulated;
        _isNightMode = NO;
    }
    return self;
}


- (NSDictionary *)readerAttributes {
    if (!_needUpdateAttributes && _readerAttributes) {
        return _readerAttributes;
    }
    NSMutableDictionary *dic = @{}.mutableCopy;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = self.lineSpacing;
    paragraphStyle.firstLineHeadIndent = [@"汉字" boundingRectWithSize:CGSizeMake(200, 200) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.font} context:NULL].size.width;
    dic[NSForegroundColorAttributeName] = self.textColor;
    dic[NSFontAttributeName] = self.font;
    dic[NSParagraphStyleAttributeName] = paragraphStyle;
    _readerAttributes = dic.copy;
    return _readerAttributes;
}

- (UIColor *)textColor {
    UIColor *color = [UIColor blackColor];
    switch (self.theme) {
        case YReaderThemeOne:
        case YReaderThemeTwo:
            color = YRGBColor(33, 33, 33);
            break;
            
        default:
            break;
    }
    return color;
}

- (UIImage *)pageImage {
    UIImage *image = [UIImage new];
    switch (self.theme) {
        case YReaderThemeOne:
        case YReaderThemeTwo:
            image = [UIImage imageWithColor:YRGBColor(200, 200, 200) size:kScreenSize];
            break;
            
        default:
            break;
    }
    return image;
}

@end
