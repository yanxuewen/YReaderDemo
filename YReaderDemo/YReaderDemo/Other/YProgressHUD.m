//
//  YProgressHUD.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/18.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YProgressHUD.h"
#import <MBProgressHUD.h>

//先这样写了
@interface YProgressHUD ()<MBProgressHUDDelegate>

@property (strong, nonatomic) MBProgressHUD *hud;
@property (assign, nonatomic) BOOL hudWasShow;

@end

@implementation YProgressHUD

+ (instancetype)shareProgressHUD {
    static YProgressHUD *progress = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        progress = [[self alloc] init];
    });
    return progress;
}

+ (void)showLoadingHUD {
    YProgressHUD *progress = [YProgressHUD shareProgressHUD];
    if (!progress.hudWasShow) {
        progress.hudWasShow = YES;
        [progress.hud showAnimated:YES];
    }
    
}

+ (void)hideLoadingHUD {
    YProgressHUD *progress = [YProgressHUD shareProgressHUD];
    if (progress.hudWasShow) {
        progress.hudWasShow = NO;
        [progress.hud hideAnimated:YES];
        progress.hud = nil;
    }
}

+ (void)showErrorHUDWith:(NSString *)msg {
    if (!msg) {
        return;
    }
    [YProgressHUD hideLoadingHUD];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = msg;
    hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
    [hud hideAnimated:YES afterDelay:3.f];
}

- (MBProgressHUD *)hud {
    if (!_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
        _hud.mode = MBProgressHUDModeIndeterminate;
        _hud.label.text = @"Loading";
        [_hud.button setTitle:@"Cancel" forState:UIControlStateNormal];
        [_hud.button addTarget:self action:@selector(cancelWork:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hud;
}

- (void)cancelWork:(UIButton *)btn {
    [YProgressHUD hideLoadingHUD];
    if (self.cancelAction) {
        self.cancelAction();
    }
    self.cancelAction = nil;
}



@end

