//
//  YSpeechManager.m
//  YAVSpeechSynthesizerDemo
//
//  Created by yanxuewen on 2017/3/2.
//  Copyright © 2017年 YXW. All rights reserved.
//

#import "YSpeechManager.h"
#import <AVFoundation/AVFoundation.h>

@interface YSpeechManager ()<AVSpeechSynthesizerDelegate>

@property (strong, nonatomic) AVSpeechSynthesizer *speechSynthesizer;
@property (strong, nonatomic) NSArray *speechArray;
@property (assign, nonatomic) NSUInteger speechCount;
@property (assign, nonatomic) double speechRate;    // Values are pinned between AVSpeechUtteranceMinimumSpeechRate and AVSpeechUtteranceMaximumSpeechRate.
@property (assign, nonatomic) double speechVolume;  // [0-1] Default = 1
@property (strong, nonatomic) AVSpeechSynthesisVoice *voiceType;//zh-CN
@property (strong, nonatomic) NSString *speechString;
@property (assign, nonatomic) NSRange speechRange;

@end

@implementation YSpeechManager

+ (instancetype)shareSpeechManager {
    static YSpeechManager *speechManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        speechManager = [[YSpeechManager alloc] init];
    });
    return speechManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _speechCount = 0;
        _speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
        _speechSynthesizer.delegate = self;
        _speechRate = AVSpeechUtteranceDefaultSpeechRate;
        _speechVolume = 1;
        _voiceType = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    }
    return self;
}

- (void)startSpeechWith:(NSString *)string {
    _speechString = string;
    _speechArray = [string componentsSeparatedByString:@"\n"];
    _speechCount = 0;
    if (!_speechArray) {
        _speechArray = @[string];
    }
    NSError *error = NULL;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    if(error) {
        // Do some error handling
    }
    [session setActive:YES error:&error];
    if (error) {
        // Do some error handling
    }
    
    _speechRange = NSMakeRange(0, 0);
    [self p_startSpeechWith:_speechArray[_speechCount]];
}

- (void)p_startSpeechWith:(NSString *)string {
    AVSpeechUtterance *speechUtterance = [[AVSpeechUtterance alloc] initWithString:string];
    speechUtterance.voice = _voiceType;
    speechUtterance.volume = _speechVolume;
    speechUtterance.rate = _speechRate;
    [_speechSynthesizer speakUtterance:speechUtterance];
    
}

- (void)continueSpeech {
    [_speechSynthesizer continueSpeaking];
}

- (void)pauseSpeech {
    [_speechSynthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
}

- (void)exitSpeech {
    [_speechSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance {
    NSLog(@"%s",__func__);
    [self p_speechUpdateState:YSpeechStateStart];
    if (self.delegate && [self.delegate respondsToSelector:@selector(speechManagerWillChangeSection:string:)]) {
        [self.delegate speechManagerWillChangeSection:_speechCount string:_speechArray[_speechCount]];
    }
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance {
    NSLog(@"%s",__func__);
    _speechCount++;
    if (_speechCount < _speechArray.count) {
        NSRange range = [_speechString rangeOfString:_speechArray[_speechCount]];
        if (range.location != NSNotFound && range.length > 0) {
            _speechRange.location = range.location - 1;
        }
        [self p_startSpeechWith:_speechArray[_speechCount]];
    } else {
        
        [self p_speechUpdateState:YSpeechStateFinish];
    }
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didPauseSpeechUtterance:(AVSpeechUtterance *)utterance {
    NSLog(@"%s",__func__);
    [self p_speechUpdateState:YSpeechStatePause];
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didContinueSpeechUtterance:(AVSpeechUtterance *)utterance {
    NSLog(@"%s",__func__);
    [self p_speechUpdateState:YSpeechStateContinue];
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance {
    NSLog(@"%s",__func__);
    [self p_speechUpdateState:YSpeechStateCancel];
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance {
    //    NSLog(@"%s",__func__);
        NSLog(@"characterRange:%@",NSStringFromRange(characterRange));
    _speechRange = NSMakeRange(_speechRange.location+characterRange.length, characterRange.length);
    if (self.delegate && [self.delegate respondsToSelector:@selector(speechManagerWillSpeakRange:)]) {
        [self.delegate speechManagerWillSpeakRange:_speechRange];
    }
}

- (void)p_speechUpdateState:(YSpeechState)state {
    if (self.delegate && [self.delegate respondsToSelector:@selector(speechManagerUpdateState:)]) {
        [self.delegate speechManagerUpdateState:state];
    }
}

@end
