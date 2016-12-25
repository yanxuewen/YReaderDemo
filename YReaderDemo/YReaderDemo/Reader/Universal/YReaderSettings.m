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
@property (strong, nonatomic) UIImage *themeImage;
@property (strong, nonatomic) NSArray *themeImageArr;

@property (strong, nonatomic) NSString *simplifiedStr;
@property (strong, nonatomic) NSString *traditionalStr;

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
        _lineSpacing = kYLineSpacingNormal;
        _isTraditional = NO;
        _fontSize = 16.0;
        _font = [UIFont systemFontOfSize:_fontSize];
        _theme = YReaderThemeOne;
        _pageStyle = YTurnPageStylePageCurl;
        _isNightMode = NO;
    }
    return self;
}

#pragma mark - set
- (void)setTheme:(YReaderTheme)theme {
    _theme = theme;
    _needUpdateAttributes = YES;
    _themeImage = [self getThemeImageWith:self.theme];
    [self updateReaderSettings];
}

- (void)setFontSize:(CGFloat)fontSize {
    if (fontSize >= kYFontSizeMin && fontSize <= kYFontSizeMax) {
        _fontSize = fontSize;
        _font = [UIFont systemFontOfSize:fontSize];
        _needUpdateAttributes = YES;
        [self updateReaderSettings];
    }
}

- (void)setLineSpacing:(CGFloat)lineSpacing {
    _lineSpacing = lineSpacing;
    _needUpdateAttributes = YES;
    [self updateReaderSettings];
}

- (void)setIsTraditional:(BOOL)isTraditional {
    _isTraditional = isTraditional;
    [self updateReaderSettings];
}

- (void)updateReaderSettings {
    [[YSQLiteManager shareManager].cache setObject:self forKey:kYReaderSettings];
    
    if (self.refreshReaderView) {
        self.refreshReaderView();
    }
}

- (void)setPageStyle:(YTurnPageStyle)pageStyle {
    if (pageStyle != _pageStyle) {
        _pageStyle = pageStyle;
        [[YSQLiteManager shareManager].cache setObject:self forKey:kYReaderSettings];
        if (self.refreshPageStyle) {
            self.refreshPageStyle();
        }
    }
}

#pragma mark - get

- (NSDictionary *)readerAttributes {
    if (!_needUpdateAttributes && _readerAttributes) {
        return _readerAttributes;
    }
    _needUpdateAttributes = NO;
    NSMutableDictionary *dic = @{}.mutableCopy;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = self.lineSpacing;
    //这种方式两个字符位置更加准确,但是每一页的开始也会空格,但是这不一定是段落的开始
//    paragraphStyle.firstLineHeadIndent = [@"汉字" boundingRectWithSize:CGSizeMake(200, 200) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.font} context:NULL].size.width;
    dic[NSForegroundColorAttributeName] = self.textColor;
    dic[NSFontAttributeName] = self.font;
    dic[NSParagraphStyleAttributeName] = paragraphStyle;
    _readerAttributes = dic.copy;
    return _readerAttributes;
}

- (UIColor *)textColor {
    UIColor *color = [UIColor blackColor];//YRGBColor(33, 33, 33);
    switch (self.theme) {
        case YReaderThemeNine:
            color = YRGBColor(149, 147, 143);
            break;
        case YReaderThemeTen:
            color = YRGBColor(98, 112, 121);
            break;
        default:
            break;
    }
    return color;
}

- (UIColor *)otherTextColor {
    UIColor *color = [UIColor blackColor];
    switch (self.theme) {
        case YReaderThemeOne:
            color = YRGBColor(115, 111, 131);
            break;
        case YReaderThemeTwo:
            color = YRGBColor(121, 104, 74);
            break;
        case YReaderThemeThree:
            color = YRGBColor(129, 147, 129);
            break;
        case YReaderThemeFour:
            color = YRGBColor(145, 132, 106);
            break;
        case YReaderThemeFive:
            color = YRGBColor(145, 132, 106);
            break;
        case YReaderThemeSix:
            color = YRGBColor(138, 133, 146);
            break;
        case YReaderThemeSeven:
            color = YRGBColor(146, 139, 152);
            break;
        case YReaderThemeEight:
            color = YRGBColor(128, 135, 107);
            break;
        case YReaderThemeNine:
            color = YRGBColor(111, 108, 104);
            break;
        case YReaderThemeTen:
            color = YRGBColor(59, 78, 87);
            break;
        default:
            break;
    }
    return color;
}

- (UIImage *)themeImage {
    if (!_themeImage) {
        _themeImage = [self getThemeImageWith:self.theme];
    }
    return _themeImage;
}

- (UIImage *)getThemeImageWith:(YReaderTheme)theme {
    if (self.isNightMode) {
        
    }
    static NSArray *imageArr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imageArr = @[@"water_mode_bg",@"yellow_mode_bg",@"green_mode_bg",@"sheepskin_mode_bg",@"violet_mode_bg",@"pink_mode_bg",@"weekGreen_mode_bg",@"weekPink_mode_bg",@"coffee_mode_bg",@"blackGreen_mode_bg"];
    });
    return [UIImage imageNamed:imageArr[theme%imageArr.count]];
}

- (NSArray *)themeImageArr {
    if (!_themeImageArr) {
        NSMutableArray *arr = @[].mutableCopy;
        for (NSUInteger i = 0; i < 10; i++) {
            [arr addObject:[self getThemeImageWith:i]];
        }
        _themeImageArr = arr;
    }
    return _themeImageArr;
}

- (NSString *)transformToTraditionalWith:(NSString *)string {
    NSMutableString *mutableStr = string.mutableCopy;
    NSInteger length = [string length];
    for (NSInteger i = 0; i< length; i++) {
        NSString *str = [string substringWithRange:NSMakeRange(i, 1)];
        NSRange gbRange = [self.simplifiedStr rangeOfString:str];
        if(gbRange.location != NSNotFound) {
            NSString *tString = [self.traditionalStr substringWithRange:gbRange];
            [mutableStr replaceCharactersInRange:NSMakeRange(i, 1) withString:tString];
        }
    }
    return mutableStr.copy;
}

- (NSString *)simplifiedStr {
    if (!_simplifiedStr) {
        _simplifiedStr = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"simplified" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
    }
    return _simplifiedStr;
}

- (NSString *)traditionalStr {
    if (!_traditionalStr) {
        _traditionalStr = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"traditional" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
    }
    return _traditionalStr;
}

@end
