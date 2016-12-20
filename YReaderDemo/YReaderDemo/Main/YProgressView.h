//
//  YProgressView.h
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/20.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YReaderUniversal.h"

@interface YProgressView : UIView

@property (assign, nonatomic) YDownloadStatus loadStatus;
@property (assign, nonatomic) double progress;

@end
