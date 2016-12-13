//
//  YCenterViewController.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/8.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YCenterViewController.h"
#import "YReaderViewController.h"
#import "YReadPageViewController.h"

@interface YCenterViewController ()

@end

@implementation YCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (IBAction)tapAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    YShowState state = button.tag == 100 ? YShowStateLeft : YShowStateRight;
    if (self.tapBarButton) {
        self.tapBarButton(state);
    }
}

- (IBAction)tapTest:(id)sender {
    YReaderViewController *reader = [[YReaderViewController alloc] init];
    [self presentViewController:reader animated:YES completion:nil];
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
