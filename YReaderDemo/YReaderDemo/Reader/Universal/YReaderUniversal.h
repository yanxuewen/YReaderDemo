//
//  YReaderUniversal.h
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/13.
//  Copyright © 2016年 yxw. All rights reserved.
//

#ifndef YReaderUniversal_h
#define YReaderUniversal_h


typedef NS_ENUM(NSInteger,YReaderTheme) {
    YReaderThemeOne,
    YReaderThemeTwo
};

typedef NS_ENUM(NSInteger,YTurnPageStyle) {
    YTurnPageStyleSimulated,
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

#define kYReaderLeftSpace 20.0
#define kYReaderRightSpace 20.0
#define kYReaderTopSpace 40.0
#define kYReaderBottomSpace 40.0

#endif /* YReaderUniversal_h */
