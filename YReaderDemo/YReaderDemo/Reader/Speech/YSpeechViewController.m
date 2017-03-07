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
}

- (IBAction)timerBtnAction:(UIButton *)sender {
    NSLog(@"%s tag:%zi",__func__,sender.tag);
}

- (IBAction)playBtnAction:(UIButton *)sender {
    NSLog(@"%s tag:%zi",__func__,sender.tag);
    if (sender.tag == 200) {        ///exit
        [self hideSpeechView];
        [self.speechManager exitSpeech];
        if (self.delegate && [self.delegate respondsToSelector:@selector(speechViewExitSpeak)]) {
            [self.delegate speechViewExitSpeak];
        }
        self.view.hidden = YES;
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
    NSLog(@"%s val:%.2f",__func__,sender.value);
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
        NSRange range = [chapterM getRangeWith:_page];
        if (range.location != NSNotFound && range.length > 0) {
            range.length = chapterM.body.length  - range.location;
            NSString *str = [chapterM.body substringWithRange:range];
            
            [self.speechManager startSpeechWith:str];
        }
    }
    
}

- (void)updateSpeakChapter:(NSUInteger)chapter page:(NSUInteger)page {
    _chapter = chapter;
    _page = page;
    [self startSpeechCurrentPageContent];
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
        [self.delegate speechViewWillSpeakString:string pageFinished:NO];
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
