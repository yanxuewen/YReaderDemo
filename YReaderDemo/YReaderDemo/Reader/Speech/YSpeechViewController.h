//
//  YSpeechViewController.h
//  YReaderDemo
//
//  Created by yanxuewen on 2017/3/4.
//  Copyright © 2017年 yxw. All rights reserved.
//

#import "YBaseViewController.h"

@interface YSpeechViewController : YBaseViewController

@property (assign, nonatomic) NSUInteger page;
@property (assign, nonatomic) NSUInteger chapter;
- (void)showSpeechView;

@end
