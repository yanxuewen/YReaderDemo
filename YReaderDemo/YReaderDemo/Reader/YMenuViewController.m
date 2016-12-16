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
@property (strong, nonatomic) YBookDetailModel *downloadBook;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewTop;

@end

@implementation YMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];

    __weak typeof(self) wself = self;
    [self.bgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        [wself hideMenuView];
    }]];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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
            case 202: {          //目录
                if (self.menuTapAction) {
                    self.menuTapAction(tag);
                }
            }
                break;
            case 203: {          //下载
//                [[YReaderManager shareReaderManager] ]
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"选择缓存章节方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                UIAlertAction *someAction = [UIAlertAction actionWithTitle:@"后面50章" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self downloadChpatersWith:YDownloadTypeBehindSome];
                }];
                UIAlertAction *behindAction = [UIAlertAction actionWithTitle:@"后面全部" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self downloadChpatersWith:YDownloadTypeBehindAll];
                }];
                UIAlertAction *allAction = [UIAlertAction actionWithTitle:@"全部章节" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self downloadChpatersWith:YDownloadTypeAllLoad];
                }];
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
    self.downloadView.hidden = NO;
    self.downloadManager = [YDownloadManager shareManager];
    [self.downloadManager downloadReaderBookWith:self.downloadBook type:type];
    [self setDownloadBookCallback];
}

- (void)setDownloadBookCallback {
    __weak typeof(self) wself = self;
    self.downloadBook.loadProgress = ^(NSUInteger chapter, NSUInteger totalChapters) {
        wself.downloadLabel.text = [NSString stringWithFormat:@"正在缓存中 (%zi/%zi) ...",chapter,totalChapters];
    };
    
    self.downloadBook.loadCompletion = ^ {
        wself.downloadLabel.text = @"缓存完成";
        //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //            [wself hideMenuView];
        //        });
    };
    
    self.downloadBook.loadFailure = ^(NSString *msg) {
        wself.downloadLabel.text = [NSString stringWithFormat:@"缓存失败: %@",msg];
    };
    
    self.downloadBook.loadCancel = ^ {
        wself.downloadLabel.text = [NSString stringWithFormat:@"缓存取消"];
    };
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
//        self.topView.top = 0;
//        self.bottomView.top = kScreenHeight - self.bottomView.height;
        self.topViewTop.constant = 0;
        self.bottomViewBottom.constant = 0;
    } completion:^(BOOL finished) {
        
    }];
    if (self.downloadBook.loadStatus != YDownloadStatusNone) {
        self.downloadView.hidden = NO;
        [self setDownloadBookCallback];
    }
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)hideMenuView {
    [UIView animateWithDuration:0.25 animations:^{
//        self.topView.top = -self.topView.height;
//        self.bottomView.top = kScreenHeight + self.downloadView.height;
        self.topViewTop.constant = -self.topView.height;
        self.bottomViewBottom.constant = -self.bottomView.height - self.downloadView.height;
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

- (YBookDetailModel *)downloadBook {
    if (!_downloadBook) {
        _downloadBook = [YReaderManager shareReaderManager].readingBook;
    }
    return _downloadBook;
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
