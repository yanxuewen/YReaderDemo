//
//  YReaderUniversal.h
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/13.
//  Copyright © 2016年 yxw. All rights reserved.
//

#ifndef YReaderUniversal_h
#define YReaderUniversal_h

#pragma mark - 实在不想起名字了
typedef NS_ENUM(NSInteger,YReaderTheme) {
    YReaderThemeOne,
    YReaderThemeTwo,
    YReaderThemeThree,
    YReaderThemeFour,
    YReaderThemeFive,
    YReaderThemeSix,
    YReaderThemeSeven,
    YReaderThemeEight,
    YReaderThemeNine,
    YReaderThemeTen
};

typedef NS_ENUM(NSInteger,YTurnPageStyle) {
    YTurnPageStylePageCurl,
    YTurnPageStyleScroll
};

typedef NS_ENUM(NSInteger,YDownloadType) {
    YDownloadTypeAllLoad,
    YDownloadTypeBehindAll,
    YDownloadTypeBehindSome
};

typedef NS_ENUM(NSInteger,YDownloadStatus) {
    YDownloadStatusNone,
    YDownloadStatusWait,
    YDownloadStatusLoading,
    YDownloadStatusCancel
};

#define kYFontSizeMax 25
#define kYFontSizeMin 13

#define kYLineSpacingSparse 12.0
#define kYLineSpacingNormal 8.0
#define kYLineSpacingCompact 4.0

#define kYReaderLeftSpace 20.0
#define kYReaderRightSpace 20.0
#define kYReaderTopSpace 40.0
#define kYReaderBottomSpace 40.0

#endif /* YReaderUniversal_h */
