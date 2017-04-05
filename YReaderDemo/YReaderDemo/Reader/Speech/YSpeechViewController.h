//
//  YSpeechViewController.h
//  YReaderDemo
//
//  Created by yanxuewen on 2017/3/4.
//  Copyright © 2017年 yxw. All rights reserved.
//

#import "YBaseViewController.h"

@protocol YSpeechViewDelegate <NSObject>

@optional;
- (BOOL)speechViewWillSpeakString:(NSString *)string pageFinished:(BOOL)isPageFinished chapterFinish:(BOOL)isChapterFinish;
- (void)speechViewExitSpeak;

@end

@interface YSpeechViewController : YBaseViewController

@property (weak, nonatomic) id<YSpeechViewDelegate> delegate;
@property (assign, nonatomic) NSUInteger page;
@property (assign, nonatomic) NSUInteger chapter;
- (void)showSpeechView;
- (void)updateSpeakChapter:(NSUInteger)chapter page:(NSUInteger)page;

@end
