//
//  YMenuViewController.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/13.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YMenuViewController.h"
#import "YBottomButton.h"

@interface YMenuViewController ()
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIView *topView;

@end

@implementation YMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    
    __weak typeof(self) wself = self;
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        [wself hideMenuView];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }]];
    
}

- (void)setupUI {
    NSArray *imgArr = @[@"night_mode",@"feedback",@"directory",@"preview_btn",@"reading_setting"];
    NSArray *titleArr = @[@"夜间",@"反馈",@"目录",@"缓存",@"设置"];
    for (NSInteger i = 0; i < imgArr.count; i++) {
        YBottomButton *btn = [YBottomButton bottonWith:titleArr[i] imageName:imgArr[i] tag:i];
        [self.bottomView addSubview:btn];
    }
}

- (IBAction)handleButton:(id)sender {
    UIButton *btn = sender;
    if (self.menuTapAction) {
        self.menuTapAction(btn.tag);
    }
}


- (void)showMenuView {
    [UIView animateWithDuration:0.25 animations:^{
        self.topView.top = 0;
        self.bottomView.top = kScreenHeight - self.bottomView.height;
    } completion:^(BOOL finished) {
        self.topView.top = 0;
        self.bottomView.top = kScreenHeight - self.bottomView.height;
    }];;
}

- (void)hideMenuView {
    [UIView animateWithDuration:0.25 animations:^{
        self.topView.top = -self.topView.height;
        self.bottomView.top = kScreenHeight ;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];;
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
