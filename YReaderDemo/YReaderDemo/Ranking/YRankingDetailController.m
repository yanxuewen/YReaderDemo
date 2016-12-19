//
//  YRankingDetailController.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/19.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YRankingDetailController.h"
#import "YBookDetailViewController.h"
#import "YBookModel.h"
#import "YNetworkManager.h"
#import "YRankingModel.h"
#import "YBookDetailCell.h"

typedef NS_ENUM(NSInteger,YRankingType) {
    YRankingTypeWeek = 100,
    YRankingTypeMonth,
    YRankingTypeTotal,
};

@interface YRankingDetailController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnBGViewHeight;
@property (weak, nonatomic) IBOutlet UIView *btnBGView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineViewLeading;
@property (assign, nonatomic) BOOL hasLoad;

@property (copy, nonatomic) NSArray *weekArr;
@property (copy, nonatomic) NSArray *monthArr;
@property (copy, nonatomic) NSArray *totalArr;
@property (strong, nonatomic) NSArray *sourceArr;

@property (assign, nonatomic) YRankingType rankingType;

@end

@implementation YRankingDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _rankingType = YRankingTypeWeek;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([YBookDetailCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([YBookDetailCell class])];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    if (_rankingM.collapse) {
        self.btnBGViewHeight.constant = 0;
        self.btnBGView.hidden = YES;
        [self.view layoutIfNeeded];
    }
    _titleLabel.text = _rankingM.title;
    if (!_hasLoad) {
        _hasLoad = YES;
        [self getRankingDetailSource];
    }
    
}

- (void)getRankingDetailSource {
    __weak typeof(self) wself = self;
    YNetworkManager *netManager = [YNetworkManager shareManager];
    [netManager getWithAPIType:YAPITypeRankingDetial parameter:_rankingM.idField success:^(id response) {
        wself.weekArr = response;
        wself.sourceArr = wself.weekArr;
        [wself.tableView reloadData];
    } failure:^(NSError *error) {
        [YProgressHUD showErrorHUDWith:error.localizedFailureReason];
    }];
    
    if (!_rankingM.collapse && _rankingM.monthRank && _rankingM.totalRank) {
        [netManager getWithAPIType:YAPITypeRankingDetial parameter:_rankingM.monthRank success:^(id response) {
            wself.monthArr = response;
            
        } failure:^(NSError *error) {
            [YProgressHUD showErrorHUDWith:error.localizedFailureReason];
        }];
        
        [netManager getWithAPIType:YAPITypeRankingDetial parameter:_rankingM.totalRank success:^(id response) {
            wself.totalArr = response;
        } failure:^(NSError *error) {
            [YProgressHUD showErrorHUDWith:error.localizedFailureReason];
        }];
    }
    
}

#pragma mark - tableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sourceArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YBookDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YBookDetailCell class]) forIndexPath:indexPath];
    cell.bookModel = _sourceArr[indexPath.row]; //先用YBookModel
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < _sourceArr.count) {
        YBookModel *bookM = _sourceArr[indexPath.row];
        YBookDetailViewController *detailVC = [[YBookDetailViewController alloc] init];
        detailVC.selectBook = bookM;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

- (IBAction)rankingBtnAction:(UIButton *)sender {
    if (sender.tag == _rankingType) {
        return;
    }
    CGFloat offset = 0.;
    switch (sender.tag) {
        case 100: {      //week
            _rankingType = YRankingTypeWeek;
            _sourceArr = _weekArr;
            offset = 0;
        }
            break;
        case 101: {      //month
            _rankingType = YRankingTypeMonth;
            _sourceArr = _monthArr;
            offset = kScreenWidth / 3.0;
        }
            break;
        case 102: {      //total
            _rankingType = YRankingTypeTotal;
            _sourceArr = _totalArr;
            offset = kScreenWidth * 2 / 3.0;
        }
            break;
        default:
            break;
    }
    
    [_tableView reloadData];
    [UIView animateWithDuration:0.25 animations:^{
        self.lineViewLeading.constant = offset;
        [self.view layoutIfNeeded];
    }];
}


- (IBAction)backBtnAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
