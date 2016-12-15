//
//  YMenuViewController.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/13.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YMenuViewController.h"
#import "YBottomButton.h"
#import "YReaderManager.h"
#import "YDownloadManager.h"

@interface YMenuViewController ()

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *downloadView;
@property (weak, nonatomic) IBOutlet UILabel *downloadLabel;

@property (strong, nonatomic) YDownloadManager *downloadManager;

@end

@implementation YMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    
    self.downloadView.top = kScreenHeight;
    
    __weak typeof(self) wself = self;
    [self.bgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        [wself hideMenuView];
    }]];
    
}

- (void)setupUI {
    NSArray *imgArr = @[@"night_mode",@"feedback",@"directory",@"preview_btn",@"reading_setting"];
    NSArray *titleArr = @[@"夜间",@"反馈",@"目录",@"缓存",@"设置"];
    void (^tapAction)(NSInteger) = ^(NSInteger tag){
        NSLog(@"tapAction %zi",tag);
        switch (tag) {
            case 200:           //日/夜间模式切换
                
                break;
            case 201:           //反馈
                
                break;
            case 202:           //目录
                
                break;
            case 203: {          //下载
//                [[YReaderManager shareReaderManager] ]
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"选择缓存章节方式" message:@"meg" preferredStyle:UIAlertControllerStyleActionSheet];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                UIAlertAction *someAction = [UIAlertAction actionWithTitle:@"后面50章" style:UIAlertActionStyleDefault handler:nil];
                UIAlertAction *behindAction = [UIAlertAction actionWithTitle:@"后面全部" style:UIAlertActionStyleDefault handler:nil];
                UIAlertAction *allAction = [UIAlertAction actionWithTitle:@"全部章节" style:UIAlertActionStyleDefault handler:nil];
                [alertVC addAction:cancelAction];
                [alertVC addAction:someAction];
                [alertVC addAction:behindAction];
                [alertVC addAction:allAction];
                [self presentViewController:alertVC animated:YES completion:nil];
            }
                break;
            case 204:           //设置
                
                break;
            default:
                break;
        }
    };
    for (NSInteger i = 0; i < imgArr.count; i++) {
        YBottomButton *btn = [YBottomButton bottonWith:titleArr[i] imageName:imgArr[i] tag:i];
        btn.tapAction = tapAction;
        [self.bottomView addSubview:btn];
    }
}

- (void)downloadChpatersWith:(YDownloadType)type {
    [self showDownloadView];
    self.downloadManager = [YDownloadManager shareManager];
    
    __weak typeof(self) wself = self;
    [self.downloadManager downloadReadingBookWith:type progress:^(NSUInteger chapter, NSUInteger totalChapters) {
        wself.downloadLabel.text = [NSString stringWithFormat:@"正在缓存中 (%zi/%zi) ...",chapter,totalChapters];
    } completion:^{
        wself.downloadLabel.text = @"缓存完成";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [wself hideMenuView];
        });
    } failure:^(NSString *msg) {
        wself.downloadLabel.text = [NSString stringWithFormat:@"缓存失败: %@",msg];

    }];
    
}

- (void)showDownloadView {
    if (self.downloadView.top != kScreenHeight - self.bottomView.height - self.downloadView.height) {
        [UIView animateWithDuration:0.25 animations:^{
            self.downloadView.top = kScreenHeight - self.bottomView.height - self.downloadView.height;
        }];
    }
}

- (void)hideDownloadView {
    if (self.downloadView.top != kScreenHeight) {
        [UIView animateWithDuration:0.25 animations:^{
            self.downloadView.top = kScreenHeight;
        }];
    }
}

- (IBAction)handleButton:(id)sender {
    UIButton *btn = sender;
    if (self.menuTapAction) {
        self.menuTapAction(btn.tag);
    }
}


- (void)showMenuView {
    self.view.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^{
        self.topView.top = 0;
        self.bottomView.top = kScreenHeight - self.bottomView.height;
    } completion:^(BOOL finished) {
        if (finished) {
//            self.topView.top = 0;
//            self.bottomView.top = kScreenHeight - self.bottomView.height;
        }
    }];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)hideMenuView {
    [UIView animateWithDuration:0.25 animations:^{
        self.topView.top = -self.topView.height;
        self.bottomView.top = kScreenHeight ;
    } completion:^(BOOL finished) {
        if (finished) {
//            self.topView.top = -self.topView.height;
//            self.bottomView.top = kScreenHeight ;
//            [self.view removeFromSuperview];
            self.view.hidden = YES;
        }
    }];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
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
