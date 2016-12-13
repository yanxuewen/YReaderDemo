//
//  YURLManager.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/9.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YURLManager.h"
#import <CoreFoundation/CoreFoundation.h>

#define kAPIBaseUrl @"http://api.zhuishushenqi.com/"

@implementation YURLManager

+ (NSURL *)getURLWith:(YAPIType)type parameter:(id)parameter {
    NSString *urlStr = nil;
    switch (type) {
        case YAPITypeFuzzySearch:
            urlStr = [NSString stringWithFormat:@"%@book/fuzzy-search?query=%@&start=0&limit=100",kAPIBaseUrl,parameter];
            break;
        case YAPITypeAutoCompletion:
            urlStr = [NSString stringWithFormat:@"%@book/auto-complete?query=%@",kAPIBaseUrl,parameter];
            break;
        case YAPITypeBookCover: {
            if ([parameter hasPrefix:@"/cover/"]) {
                urlStr = [NSString stringWithFormat:@"http://statics.zhuishushenqi.com%@",parameter];
                NSLog(@"urlStr cover   %@",urlStr);
            } else {
                parameter = [self encodeToPercentEscapeString:parameter];
                urlStr = [NSString stringWithFormat:@"http://statics.zhuishushenqi.com/agent/%@-covers",parameter];
            }
        }
            break;
        case YAPITypeAuthorAvatar:
            urlStr = [NSString stringWithFormat:@"http://statics.zhuishushenqi.com%@",parameter];
            break;
        case YAPITypeBookDetail:
            urlStr = [NSString stringWithFormat:@"%@book/%@",kAPIBaseUrl,parameter];
            break;
        case YAPITypeBookReview:
            urlStr = [NSString stringWithFormat:@"%@post/review/best-by-book?book=%@",kAPIBaseUrl,parameter];
            break;
        case YAPITypeRecommendBook:
            urlStr = [NSString stringWithFormat:@"%@book/%@/recommend",kAPIBaseUrl,parameter];
            break;
        case YAPITypeRecommendBookList:
            urlStr = [NSString stringWithFormat:@"%@book-list/%@/recommend?limit=3",kAPIBaseUrl,parameter];
            break;
        case YAPITypeBookSummary:
            urlStr = [NSString stringWithFormat:@"%@atoc?view=summary&book=%@",kAPIBaseUrl,parameter];
            break;
        case YAPITypeChaptersLink:
            urlStr = [NSString stringWithFormat:@"%@atoc/%@?view=chapters",kAPIBaseUrl,parameter];
            break;
        case YAPITypeChapterContent: {
            parameter = [self encodeToPercentEscapeString:parameter];
            urlStr = [NSString stringWithFormat:@"http://chapter2.zhuishushenqi.com/chapter/%@",parameter];
            break;
        }
        default:
            break;
    }
    
    if (type == YAPITypeAutoCompletion || type == YAPITypeFuzzySearch) {
        urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    return [NSURL URLWithString:urlStr];
}

+ (NSString *)encodeToPercentEscapeString:(NSString *)input {
    NSString *outputStr = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(__bridge CFStringRef)input, NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
    return outputStr;
}


@end
