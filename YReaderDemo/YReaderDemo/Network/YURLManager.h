//
//  YURLManager.h
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/9.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,YAPIType) {
    YAPITypeFuzzySearch,
    YAPITypeAutoCompletion,
    YAPITypeBookCover,
    YAPITypeBookDetail,
    YAPITypeRecommendBook,
    YAPITypeRecommendBookList,
    YAPITypeBookReview,
    YAPITypeAuthorAvatar,
    YAPITypeBookSummary,
    YAPITypeChaptersLink,
    YAPITypeChapterContent,
    YAPITypeBookUpdate,
    YAPITypeRanking,
    YAPITypeRankingDetial,
};

@interface YURLManager : NSObject

+ (NSURL *)getURLWith:(YAPIType)type parameter:(id)parameter;

@end
