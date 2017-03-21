//
//  YSpeechViewController.m
//  YReaderDemo
//
//  Created by yanxuewen on 2017/3/4.
//  Copyright © 2017年 yxw. All rights reserved.
//

#import "YSpeechViewController.h"
#import "YSpeechManager.h"
#import "YReaderManager.h"

@interface YSpeechViewController ()<YSpeechManagerDelegate>

@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backViewBottom;
@property (weak, nonatomic) IBOutlet UIButton *exitBtn;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIView *tapView;
@property (strong, nonatomic) YSpeechManager *speechManager;
@property (strong, nonatomic) YReaderManager *readerManager;
@property (strong, nonatomic) YChapterContentModel *speechChapterM;
@property (assign, nonatomic) NSUInteger startSpeechCount;//开始阅读的位置
@property (strong, nonatomic) NSTimer *changeRateTimer;

@property (weak, nonatomic) IBOutlet UIButton *timerBtn5;
@property (weak, nonatomic) IBOutlet UIButton *timerBtn15;
@property (weak, nonatomic) IBOutlet UIButton *timerBtn30;
@property (weak, nonatomic) IBOutlet UIButton *timerBtn60;
@property (strong, nonatomic) NSArray *timerBtnArray;
@property (strong, nonatomic) NSTimer *closeTimer;

@end

@implementation YSpeechViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.exitBtn.layer.borderWidth = 1;
    self.exitBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.exitBtn.layer.cornerRadius = 6;
    
    self.playBtn.layer.borderWidth = 1;
    self.playBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.playBtn.layer.cornerRadius = 6;
    
    __weak typeof(self) wself = self;
    [self.tapView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        if (wself.backViewBottom.constant == 0) {
            [wself hideSpeechView];
        } else {
            [wself showSpeechView];
        }
        
    }]];
    
    [self.backView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        
    }]];
    
    _timerBtnArray = @[_timerBtn5,_timerBtn15,_timerBtn30,_timerBtn60];
//    for (UIButton *btn in _timerBtnArray) {
//        [btn setBackgroundImage:[UIImage imageWithColor:YRGBColor(234, 55, 0)] forState:UIControlStateSelected];
//        btn.layer.cornerRadius = 6;
//        btn.layer.masksToBounds = true;
//    }
    
}

- (IBAction)timerBtnAction:(UIButton *)sender {
    NSLog(@"%s tag:%zi",__func__,sender.tag);
    
    if (_closeTimer) {
        [_closeTimer invalidate];
        _closeTimer = nil;
    }
    
    if (sender.isSelected) {
        sender.selected = false;
        [sender setBackgroundColor:[UIColor clearColor]];
        return;
    }
    
    for (UIButton *btn in _timerBtnArray) {
        btn.selected = false;
        [btn setBackgroundColor:[UIColor clearColor]];
    }
    sender.selected = true;
    [sender setBackgroundColor:YRGBColor(234, 55, 0)];
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    sender.layer.cornerRadius = 6;
    sender.layer.masksToBounds = true;
    
    __weak typeof(self) wself = self;
    _closeTimer = [NSTimer timerWithTimeInterval:[sender.currentTitle integerValue] * 60 block:^(NSTimer * _Nonnull timer) {
        __strong typeof(wself) strongSelf = wself;
        [strongSelf exitSpeechString];
    } repeats:false];
    [[NSRunLoop mainRunLoop] addTimer:_closeTimer forMode:NSRunLoopCommonModes];
}

- (IBAction)playBtnAction:(UIButton *)sender {
    NSLog(@"%s tag:%zi",__func__,sender.tag);
    if (sender.tag == 200) {        ///exit
        [self exitSpeechString];
    } else if (sender.tag == 201) { /// play/pause
        if ([sender.currentTitle isEqualToString:@"开始"]) {
            [sender setTitle:@"暂停" forState:UIControlStateNormal];
            [sender setImage:[UIImage imageNamed:@"readAloud_pause"] forState:UIControlStateNormal];
            [self.speechManager continueSpeech];
        } else if ([sender.currentTitle isEqualToString:@"暂停"]) {
            [sender setTitle:@"开始" forState:UIControlStateNormal];
            [sender setImage:[UIImage imageNamed:@"readAloud_play"] forState:UIControlStateNormal];
            [self.speechManager pauseSpeech];
        }
    }
}

- (IBAction)speechRateSliderValueChanged:(UISlider *)sender {
//    NSLog(@"%s val:%.2f",__func__,sender.value);
    if (_changeRateTimer) {
        [_changeRateTimer invalidate];
        _changeRateTimer = nil;
    }
    NSInteger value = sender.value * 100;
    __weak typeof(self) wself = self;
    _changeRateTimer = [NSTimer timerWithTimeInterval:0.5 block:^(NSTimer * _Nonnull timer) {
        __strong typeof(wself) strongSelf = wself;
        [strongSelf.speechManager changeSpeechRate:value / 100.0];
    } repeats:false];
    [[NSRunLoop mainRunLoop] addTimer:_changeRateTimer forMode:NSRunLoopCommonModes];
    
}

- (void)showSpeechView {
    self.view.hidden = false;
    [UIView animateWithDuration:0.25 animations:^{
        self.backViewBottom.constant = 0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (self.speechManager.state == YSpeechStateNone) {
            [self startSpeechCurrentPageContent];
        }
    }];
}

- (void)hideSpeechView {
    
    [UIView animateWithDuration:0.25 animations:^{
        self.backViewBottom.constant = -self.backView.height;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)startSpeechCurrentPageContent {
    
    if (_chapter < self.readerManager.chaptersArr.count) {
        YChapterContentModel *chapterM = self.readerManager.chaptersArr[_chapter];
        _speechChapterM = chapterM;
        NSRange range = [chapterM getRangeWith:_page];
        if (range.location != NSNotFound && range.length > 0) {
            range.length = chapterM.body.length  - range.location;
            NSString *str = [chapterM.body substringWithRange:range];
            _startSpeechCount = range.location;
            [self.speechManager startSpeechWith:str];
        }
    }
    
}

- (void)updateSpeakChapter:(NSUInteger)chapter page:(NSUInteger)page {
    if (chapter != _chapter) {
        _chapter = chapter;
        _page = page;
        [self startSpeechCurrentPageContent];
    } else {
        _chapter = chapter;
        _page = page;
    }
}

#pragma mark - speech manager delegate
- (void)speechManagerUpdateState:(YSpeechState)state {
    if (state == YSpeechStateFinish) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(speechViewWillSpeakString:pageFinished:)]) {
            [self.delegate speechViewWillSpeakString:nil pageFinished:YES];
        }
    }
}

- (void)speechManagerWillChangeSection:(NSUInteger)section string:(NSString *)string {
    if (self.delegate && [self.delegate respondsToSelector:@selector(speechViewWillSpeakString:pageFinished:)]) {
        NSRange range = [_speechChapterM.body rangeOfString:string];
        if (range.location != NSNotFound && range.length > 0) {
            NSRange pageRange = [_speechChapterM getRangeWith:_page];
            if (range.location < pageRange.location + pageRange.length) {
                if (range.location + range.length > pageRange.location + pageRange.length) {
                    string = [string substringToIndex:pageRange.location + pageRange.length- range.location];
                }
                [self.delegate speechViewWillSpeakString:string pageFinished:NO];
            } else {
                NSLog(@"分段是正好分页,这里不返回了");
            }
            
        }
    }
}

- (void)speechManagerWillSpeakRange:(NSRange)range {
    NSUInteger speechCount = _startSpeechCount + range.location + (range.length - 1);
    NSRange pageRange = [_speechChapterM getRangeWith:_page];
    if (speechCount >= pageRange.location + pageRange.length) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(speechViewWillSpeakString:pageFinished:)]) {

            NSUInteger count = _speechManager.sectionStringCount + _startSpeechCount + _speechManager.speakingString.length - pageRange.location - pageRange.length;
            if (_speechManager.sectionStringCount + _startSpeechCount > pageRange.location + pageRange.length) {
                count = _speechManager.speakingString.length;
            }
            
            if (_speechManager.speakingString.length >= count) {
                NSString *string = [_speechManager.speakingString substringWithRange:NSMakeRange(_speechManager.speakingString.length - count, count)];
                [self.delegate speechViewWillSpeakString:string pageFinished:YES];
            } else {
                DDLogError(@"speechManagerWillSpeakRange error _speechManager.speakingString.length:%zi < count:%zi   speakingString:%@",_speechManager.speakingString.length,count,_speechManager.speakingString);
                [self exitSpeechString];
            }
        }
    }
}


- (void)exitSpeechString {
    [self hideSpeechView];
    [self.speechManager exitSpeech];
    _chapter = NSUIntegerMax;
    _page = NSUIntegerMax;
    if (self.delegate && [self.delegate respondsToSelector:@selector(speechViewExitSpeak)]) {
        [self.delegate speechViewExitSpeak];
    }
    self.view.hidden = YES;
    
    if (_changeRateTimer) {
        [_changeRateTimer invalidate];
        _changeRateTimer = nil;
    }
    
    if (_closeTimer) {
        [_closeTimer invalidate];
        _closeTimer = nil;
    }
    for (UIButton *btn in _timerBtnArray) {
        btn.selected = false;
        [btn setBackgroundColor:[UIColor clearColor]];
    }
}

- (YSpeechManager *)speechManager {
    if (!_speechManager) {
        _speechManager = [YSpeechManager shareSpeechManager];
        _speechManager.delegate = self;
    }
    return _speechManager;
}

- (YReaderManager *)readerManager {
    if (!_readerManager) {
        _readerManager = [YReaderManager shareReaderManager];
    }
    return _readerManager;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
