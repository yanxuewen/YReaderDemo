//
//  YPageBackViewController.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/19.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YPageBackViewController.h"

@interface YPageBackViewController ()

@property (strong, nonatomic) UIImageView *backImageView;

@end

@implementation YPageBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.backImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.backImageView];
    self.backImageView.alpha = 0.5;
}

- (void)updateBackViewWith:(UIView *)view {
    self.backImageView.image = [self captureView:view];
}


- (UIImage *)captureView:(UIView *)view {
    CGRect rect = view.bounds;
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
//    CGAffineTransform transform = CGAffineTransformMake(-1.0, 0.0, 0.0, 1.0, rect.size.width, 0.0);
//    CGContextConcatCTM(context,transform);
    [view.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
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
