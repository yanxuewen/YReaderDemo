//
//  YChapterContentModel.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/12.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YChapterContentModel.h"
#import "YReaderSettings.h"
#import <CoreText/CoreText.h>

#define kiOS10_3Later ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 10.3)

@interface YChapterContentModel ()


@property (strong, nonatomic) NSMutableAttributedString *attributedString;


@end

@implementation YChapterContentModel

+ (NSArray *)modelPropertyWhitelist {
    return @[@"title",@"body"];
}

- (void)updateContentPaging {
    [self pagingWithBounds:CGRectMake(kYReaderLeftSpace, kYReaderTopSpace, kScreenWidth - kYReaderLeftSpace - kYReaderRightSpace, kScreenHeight - kYReaderTopSpace - kYReaderBottomSpace)];
}

- (void)pagingWithBounds:(CGRect)bounds {
    NSMutableArray *rangeArr = @[].mutableCopy;
    YReaderSettings *settings = [YReaderSettings shareReaderSettings];
    NSString *content = settings.isTraditional ? self.traditionalStr : self.body;
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString  alloc] initWithString:content attributes:settings.readerAttributes];
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) attr);
    CGPathRef path = CGPathCreateWithRect(bounds, NULL);
    CFRange range = CFRangeMake(0, 0);
    NSUInteger rangeOffset = 0;
    
    do {
        CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(rangeOffset, 0), path, NULL);
        range = CTFrameGetVisibleStringRange(frame);
        [rangeArr addObject:[NSValue valueWithRange:NSMakeRange(rangeOffset, range.length)]];
        rangeOffset += range.length;
        if (frame) {
            CFRelease(frame);
        }
    } while (range.location + range.length < attr.length);
    
    if (path) {
        CFRelease(path);
    }
    
    if (frameSetter) {
        CFRelease(frameSetter);
    }
    
    _pageArr = rangeArr;
    _pageCount = _pageArr.count;
    _attributedString = attr;
}

- (NSAttributedString *)getStringWith:(NSUInteger)page {
    NSRange range = [self getRangeWith:page];
    if (range.length > 0) {
        return [_attributedString attributedSubstringFromRange:range];
    }
    return nil;
}

- (NSRange)getRangeWith:(NSUInteger)page {
    if (page < _pageArr.count) {
        return [_pageArr[page] rangeValue];
    }
    return NSMakeRange(NSNotFound, 0);
}

+ (instancetype)chapterModelWith:(NSString *)title link:(NSString *)link load:(BOOL)isLoadCache{
    YChapterContentModel *chapterM = [[YChapterContentModel alloc] init];
    chapterM.title = title;
    chapterM.link = link;
    chapterM.isLoadCache = isLoadCache;
    chapterM.body = @"\t正在为您加载...";
    chapterM.isLoad = NO;
    return chapterM;
}

+ (NSString *)adjustParagraphFormat:(NSString *)string {
    if (!string) {
        return nil;
    }
    NSString *repStr = kiOS10_3Later ? @"      " : @"\t";
    string = [repStr stringByAppendingString:string];
    repStr = [NSString stringWithFormat:@"\n%@",repStr];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:repStr];
    return string;
}

- (void)releaseChapter {
    _isLoad = false;
    _body = @"\t正在为您加载...";
    _attributedString = nil;
    _pageArr = nil;
}

- (NSString *)traditionalStr {
    if (!_traditionalStr) {
        _traditionalStr = [[YReaderSettings shareReaderSettings] transformToTraditionalWith:_body];
    }
    return _traditionalStr;
}

- (NSString *)body {
    if (_body) {
        if (kiOS10_3Later && [_body hasPrefix:@"\t"]) {
            _body = [_body stringByReplacingOccurrencesOfString:@"\t" withString:@"      "];
        }
    }
    return _body;
}

@end
