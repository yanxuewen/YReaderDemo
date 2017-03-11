//
//  YSpeechManager.h
//  YAVSpeechSynthesizerDemo
//
//  Created by yanxuewen on 2017/3/2.
//  Copyright © 2017年 YXW. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,YSpeechState) {
    YSpeechStateNone,
    YSpeechStateStart,
    YSpeechStatePause,
    YSpeechStateContinue,
    YSpeechStateCancel,
    YSpeechStateFinish,
};

@protocol YSpeechManagerDelegate <NSObject>
@optional;
- (void)speechManagerUpdateState:(YSpeechState)state;
- (void)speechManagerWillSpeakRange:(NSRange)range;
- (void)speechManagerWillChangeSection:(NSUInteger)section string:(NSString *)string;

@end

@interface YSpeechManager : NSObject

@property (weak, nonatomic) id<YSpeechManagerDelegate> delegate;
@property (assign, nonatomic, readonly) YSpeechState state;
@property (copy, nonatomic, readonly) NSString *speakingString;
@property (assign, nonatomic, readonly) NSUInteger sectionStringCount;//正在读的该段,在整个string中位置

+ (instancetype)shareSpeechManager;
- (void)startSpeechWith:(NSString *)string;
- (void)continueSpeech;
- (void)pauseSpeech;
- (void)exitSpeech;
- (void)changeSpeechRate:(double)rate;

@end
