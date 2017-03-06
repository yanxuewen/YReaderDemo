//
//  ViewController.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/7.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "ViewController.h"
#import "YLeftViewController.h"
#import "YRightViewController.h"
#import "YCenterViewController.h"
#import "YSearchViewController.h"
#import "YRankingViewController.h"

#define kLeftAnimationDuration 0.25
#define kRightAnimationDuration 0.5
#define kLeftViewWidth 80
#define kRightViewWidth kScreenWidth*0.6

@interface ViewController ()

@property (strong, nonatomic) YCenterViewController *centerVC;
@property (strong, nonatomic) YLeftViewController *leftVC;
@property (strong, nonatomic) YRightViewController *rightVC;
@property (strong, nonatomic) UIView *centerView;
@property (strong, nonatomic) UIView *leftView;
@property (strong, nonatomic) UIView *rightView;
@property (strong, nonatomic) UIView *closeView;
@property (assign, nonatomic) YShowState currentShow;
@property (assign, nonatomic) BOOL hasLoad;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = true;
    [self setupUI];
    
    __weak typeof(self) wself = self;
    self.centerVC.tapBarButton = ^(YShowState state) {
        [wself moveToVCWith:state];
    };
    
    self.rightVC.selectCell = ^(NSInteger index) {
        if (index == 0) {
            YSearchViewController *searchVC = [[YSearchViewController alloc] init];
            [wself.navigationController pushViewController:searchVC animated:YES];
        } else if (index == 1) {
            YRankingViewController *rankingVC = [[YRankingViewController alloc] init];
            [wself.navigationController pushViewController:rankingVC animated:YES];
        }
    };
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!_hasLoad) {
        _hasLoad = YES;
        [self.centerVC autoRefreshbooks];
    }
}

- (void)setupUI {
    self.centerVC = [[YCenterViewController alloc] init];
    self.leftVC = [[YLeftViewController alloc] init];
    self.rightVC = [[YRightViewController alloc] init];
    self.centerVC.view.frame = self.view.bounds;
    self.leftVC.view.frame = self.view.bounds;
    self.rightVC.view.frame = self.view.bounds;
    [self.centerView addSubview:self.centerVC.view];
    [self.view addSubview:self.centerView];
}

- (void)moveToVCWith:(YShowState)state {
    [self prepareViewWith:state];
    NSTimeInterval duration = state == YShowStateLeft ? kLeftAnimationDuration : kRightAnimationDuration;
    CGFloat left = state == YShowStateLeft ? kLeftViewWidth : -kRightViewWidth;
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:10 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveLinear animations:^{
        self.centerView.left = left;
        
    } completion:^(BOOL finished) {
        [self.centerView addSubview:self.closeView];
        self.currentShow = state;
    }];
}





- (void)prepareViewWith:(YShowState)state {
    if (state == YShowStateLeft) {
        [self.leftView addSubview:self.leftVC.view];
        [self.view insertSubview:self.leftView belowSubview:self.centerView];
    } else {
        [self.rightView addSubview:self.rightVC.view];
        [self.view insertSubview:self.rightView belowSubview:self.centerView];
    }
    
}

- (UIView *)centerView {
    if (_centerView == nil) {
        _centerView = [[UIView alloc] initWithFrame:self.view.bounds];
    }
    return _centerView;
}

- (UIView *)leftView {
    if (_leftView == nil) {
        _leftView = [[UIView alloc] initWithFrame:self.view.bounds];
    }
    return _leftView;
}

- (UIView *)rightView {
    if (_rightView == nil) {
        _rightView = [[UIView alloc] initWithFrame:self.view.bounds];
    }
    return _rightView;
}

- (UIView *)closeView {
    if (_closeView == nil) {
        _closeView = [[UIView alloc] initWithFrame:self.view.bounds];
        [_closeView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCloseView)]];
        [_closeView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)]];
    }
    return _closeView;
}

- (void)handleCloseView {
    [UIView animateWithDuration:kLeftAnimationDuration animations:^{
        self.centerView.left = 0;
    } completion:^(BOOL finished) {
        [self.closeView removeFromSuperview];
        [self.leftView removeFromSuperview];
        [self.rightView removeFromSuperview];
    }];
}

- (void)handlePanGesture:(UIPanGestureRecognizer*)panGesture
{
    UIGestureRecognizerState state = panGesture.state;
    CGPoint translation = [panGesture translationInView:self.view];
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            self.currentShow = self.centerView.left > 0 ? YShowStateLeft : YShowStateRight;
        }
            break;
        case UIGestureRecognizerStateChanged: {
            CGRect centerFrame = self.centerView.frame;
            centerFrame.origin.x += translation.x;
            BOOL shouldClose = NO;
            if (self.currentShow == YShowStateRight) {
                if (centerFrame.origin.x >= 0) {
                    centerFrame.origin.x = 0;
                    shouldClose = YES;
                }
            } else {
                if (centerFrame.origin.x <= 0) {
                    centerFrame.origin.x = 0;
                    shouldClose = YES;
                }
            }
            self.centerView.frame = centerFrame;
            if (shouldClose) {
                [self handleCloseView];
            }
        }
            break;
        default: {
            BOOL shouldClose = YES;
            CGFloat left = 0.0;
            if (self.currentShow == YShowStateLeft) {
                if (self.centerView.left > kLeftViewWidth/2) {
                    shouldClose = NO;
                    left = kLeftViewWidth;
                }
            } else {
                if (self.centerView.left < -kRightViewWidth/2) {
                    shouldClose = NO;
                    left = -kRightViewWidth;
                }
            }
            if (shouldClose) {
                [self handleCloseView];
            } else {
                [UIView animateWithDuration:self.currentShow == YShowStateLeft ? kLeftAnimationDuration / 2.0 : kRightAnimationDuration / 2.0 animations:^{
                    self.centerView.left = left;
                }];
            }
        }
            break;
    }
    [panGesture setTranslation:CGPointZero inView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
