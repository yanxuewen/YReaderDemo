//
//  YReadPageViewController.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/12.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YReadPageViewController.h"
#import "YBatteryView.h"
#import "YDateModel.h"
#import "YReaderView.h"
#import "YReaderUniversal.h"

@interface YReadPageViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *pageNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet YBatteryView *batteryView;
@property (strong, nonatomic) YReaderView *readerView;

@end

@implementation YReadPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _readerView = [[YReaderView alloc] initWithFrame:CGRectMake(kYReaderLeftSpace, kYReaderTopSpace, kScreenWidth - kYReaderLeftSpace - kYReaderRightSpace, kScreenHeight - kYReaderTopSpace - kYReaderBottomSpace)];
    _readerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_readerView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.titleLabel.text = self.booktitle;
    self.pageNumberLabel.text = [NSString stringWithFormat:@"第%zi/%zi页",self.page+1,self.totalPage];
    self.timeLabel.text = [[YDateModel shareDateModel] getTimeString];
    [self.batteryView setNeedsDisplay];
    self.readerView.content = self.pageContent;
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
