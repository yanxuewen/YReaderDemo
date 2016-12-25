//
//  YMoreSettingsViewController.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/25.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YMoreSettingsViewController.h"
#import "YMoreSettingsCell.h"
#import "YReaderSettings.h"

@interface YMoreSettingsViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) YReaderSettings *settings;

@end

@implementation YMoreSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.settings = [YReaderSettings shareReaderSettings];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([YMoreSettingsCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([YMoreSettingsCell class])];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YMoreSettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YMoreSettingsCell class]) forIndexPath:indexPath];
    cell.titleLabel.text = @"翻页方式";
    if (self.settings.pageStyle == YTurnPageStylePageCurl) {
        cell.styleLabel.text = @"拟真";
    } else if (self.settings.pageStyle == YTurnPageStyleScroll) {
        cell.styleLabel.text = @"滑动";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [self showSelectTurnPageStyle];
    }
}

- (void)showSelectTurnPageStyle {
    __weak typeof(self) wself = self;
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"选择翻页方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    void (^turnPageStyle)(NSInteger) = ^(NSInteger style) {
        wself.settings.pageStyle = style;
        [wself.tableView reloadData];
    };
    UIAlertAction *curlAction = [UIAlertAction actionWithTitle:@"拟真" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        turnPageStyle(YTurnPageStylePageCurl);
    }];
    UIAlertAction *scrollAction = [UIAlertAction actionWithTitle:@"滑动" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        turnPageStyle(YTurnPageStyleScroll);
    }];
    [alertVC addAction:cancelAction];
    [alertVC addAction:curlAction];
    [alertVC addAction:scrollAction];
    [wself presentViewController:alertVC animated:YES completion:nil];
}

- (IBAction)backBtnAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
