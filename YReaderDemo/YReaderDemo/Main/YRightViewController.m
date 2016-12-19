//
//  YRightViewController.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/8.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YRightViewController.h"

@interface YRightViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *dataArr;
@property (strong, nonatomic) NSArray *testArr;
@property (strong, nonatomic) NSArray *imageArr;

@end

@implementation YRightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataArr = @[@"搜索",@"书城",@"包月专区",@"排行榜",@"主题书单",@"分类",@"听书专区",@"随机看书"];
    _testArr = @[@"搜索",@"排行榜"];
    _imageArr = @[@"rsm_icon_0",@"rsm_icon_3"];
    
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"YReuseCell"];
    _tableView.rowHeight = 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _testArr.count;
//    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YReuseCell" forIndexPath:indexPath];
    cell.backgroundColor = YRGBColor(40, 40, 40);
    cell.textLabel.textColor = YRGBColor(230, 230, 230);
    UIView *bgview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, tableView.rowHeight)];
    bgview.backgroundColor = YRGBColor(28, 28, 28);
    cell.selectedBackgroundView = bgview;
//    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"rsm_icon_%zi",indexPath.row]];
//    cell.textLabel.text = _dataArr[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:_imageArr[indexPath.row]];
    cell.textLabel.text = _testArr[indexPath.row];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, tableView.rowHeight - 1.5, tableView.width, 1.5)];
    line.backgroundColor = YRGBColor(20, 20, 20);
    [cell addSubview:line];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.selectCell) {
        self.selectCell(indexPath.row);
    }
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
