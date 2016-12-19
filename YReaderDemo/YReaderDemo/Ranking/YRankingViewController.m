//
//  YRankingViewController.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/19.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YRankingViewController.h"
#import "YRankingDetailController.h"
#import "YNetworkManager.h"
#import "YURLManager.h"
#import "YRankingModel.h"
#import "YRankingViewCell.h"

@interface YRankingViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (copy, nonatomic) NSArray *maleMoreArr;
@property (copy, nonatomic) NSArray *femaleMoreArr;
@property (strong, nonatomic) NSArray *rankingArr;
@property (strong, nonatomic) YNetworkManager *netManager;
@property (strong, nonatomic) NSURLSessionTask *urlTask;

@property (assign, nonatomic) BOOL maleMoreExpand;
@property (assign, nonatomic) BOOL femaleMoreExpand;
@property (assign, nonatomic) BOOL hasLoad;
@end

@implementation YRankingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _netManager = [YNetworkManager shareManager];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([YRankingViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([YRankingViewCell class])];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!_hasLoad) {
        _hasLoad = YES;
        [self getRankingSource];
    }
}

- (void)getRankingSource {
    
    __weak typeof(self) wself = self;
    _urlTask = [_netManager getWithAPIType: YAPITypeRanking parameter:nil success:^(id response) {
        NSArray *arr = response;
        NSMutableArray *maleArr = @[].mutableCopy;
        NSMutableArray *maleMoreArr = @[].mutableCopy;
        NSMutableArray *femaleArr = @[].mutableCopy;
        NSMutableArray *femaleMoreArr = @[].mutableCopy;
        for (NSInteger i = 0; i < arr.count; i++) {
            for (YRankingModel * model in (NSArray *)arr[i]) {
                if (model.collapse) {
                    if (i == 0) {
                        [maleMoreArr addObject:model];
                    } else {
                        [femaleMoreArr addObject:model];
                    }
                    
                } else {
                    if (i == 0) {
                        [maleArr addObject:model];
                    } else {
                        [femaleArr addObject:model];
                    }
                }
            }
        }
        [maleArr addObject:[YRankingModel modelWithTitle:@"别人家的排行榜"]];
        [femaleArr addObject:[YRankingModel modelWithTitle:@"别人家的排行榜"]];
        wself.rankingArr = @[maleArr,femaleArr];
        wself.maleMoreArr = maleMoreArr.copy;
        wself.femaleMoreArr = femaleMoreArr.copy;
        [wself.tableView reloadData];
    } failure:^(NSError *error) {
        [YProgressHUD showErrorHUDWith:error.localizedFailureReason];
    }];
    
}

#pragma mark - tableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"男生";
    }
    return @"女生";
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _rankingArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray *)_rankingArr[section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YRankingViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YRankingViewCell class]) forIndexPath:indexPath];
    cell.rankingM = ((NSArray *)_rankingArr[indexPath.section])[indexPath.row];
    if (indexPath.section == 0 && _maleMoreExpand && indexPath.row == ((NSArray *)_rankingArr[indexPath.section]).count - _maleMoreArr.count - 1) {
        cell.expand = YES;
    } else if (indexPath.section == 1 && _femaleMoreExpand && indexPath.row == ((NSArray *)_rankingArr[indexPath.section]).count - _femaleMoreArr.count - 1) {
        cell.expand = YES;
    } 
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    YRankingModel *rankingM = ((NSArray *)_rankingArr[indexPath.section])[indexPath.row];
    if (!rankingM.idField) {
        NSArray *arr = indexPath.section == 0 ? _maleMoreArr : _femaleMoreArr;
        BOOL expand = indexPath.section == 0 ? _maleMoreExpand : _femaleMoreExpand;
        if (expand) {
            [_rankingArr[indexPath.section] removeObjectsInArray:arr];
        } else {
            
            [_rankingArr[indexPath.section] addObjectsFromArray:arr];
        }
        if (indexPath.section == 0) {
            _maleMoreExpand = !_maleMoreExpand;
        } else {
            _femaleMoreExpand = !_femaleMoreExpand;
        }
        [self.tableView reloadData];
    } else {
        YRankingDetailController *rankingDetailVC = [[YRankingDetailController alloc] init];
        rankingDetailVC.rankingM = rankingM;
        [self.navigationController pushViewController:rankingDetailVC animated:YES];
    }
}

- (IBAction)backBtnAction:(id)sender {
    if (self.urlTask.state == NSURLSessionTaskStateRunning) {
        [self.urlTask cancel];
    }
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
