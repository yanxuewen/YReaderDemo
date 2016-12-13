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

@interface YChapterContentModel ()

@property (strong, nonatomic) NSMutableArray *pageArr;

@end

@implementation YChapterContentModel

+ (NSArray *)modelPropertyWhitelist {
    return @[@"title",@"body"];
}

- (void)pagingWithBounds:(CGRect)bounds {
    _pageArr = @[].mutableCopy;
    NSMutableAttributedString *attr = [[NSMutableAttributedString  alloc] initWithString:self.body attributes:[YReaderSettings shareReaderSettings].readerAttributes];
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) attr);
    CGPathRef path = CGPathCreateWithRect(bounds, NULL);
    CFRange range = CFRangeMake(0, 0);
    NSUInteger rangeOffset = 0;
    do {
        CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(rangeOffset, 0), path, NULL);
        range = CTFrameGetVisibleStringRange(frame);
        rangeOffset += range.length;
        [_pageArr addObject:@(range.location)];
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
    _pageCount = _pageArr.count;
    NSLog(@"_pageArr %@ %zi",_pageArr,attr.length);
}

+ (instancetype)chapterModelWith:(NSString *)title link:(NSString *)link {
    YChapterContentModel *chapterM = [[YChapterContentModel alloc] init];
    chapterM.title = title;
    chapterM.link = link;
    chapterM.body = @"正在为您加载...";
    chapterM.isDownload = NO;
    return chapterM;
}

@end
