//
//  YDirectoryViewController.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/16.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YDirectoryViewController.h"
#import "YDirectoryViewCell.h"
#import "YChapterContentModel.h"

@interface YDirectoryViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *goBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (assign, nonatomic) BOOL firstDisplay;
@property (assign, nonatomic) CGFloat beginOffsetY;
@property (weak, nonatomic) IBOutlet UIView *moveView;
@property (weak, nonatomic) IBOutlet UIImageView *moveImageV;

@end

@implementation YDirectoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.moveView.backgroundColor = YRGBAColor(0, 0, 0, 0.85);
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([YDirectoryViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([YDirectoryViewCell class])];
    self.tableView.rowHeight = 44;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _firstDisplay = YES;
    [self.tableView reloadData];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"%s",__func__);
    self.beginOffsetY = scrollView.contentOffset.y;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    NSLog(@"%s",__func__);
    [self showGoToBtn];
    if (scrollView.contentOffset.y > self.beginOffsetY) {
        [self.goBtn setTitle:@"到底部" forState:UIControlStateNormal];
        self.goBtn.tag = 100;
    } else {
        [self.goBtn setTitle:@"到顶部" forState:UIControlStateNormal];
        self.goBtn.tag = 101;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"%s",__func__);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        NSLog(@"%s",__func__);
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSLog(@"%s",__func__);
    [self hideGoToBtn];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chaptersArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YDirectoryViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YDirectoryViewCell class]) forIndexPath:indexPath];
    NSUInteger count = _chaptersArr.count - indexPath.row - 1;
    cell.isReadingChapter = count == _readingChapter;
    cell.count = count +1;
    cell.chapterM = _chaptersArr[count];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.chaptersArr.count) {
        BOOL needUpdate = self.readingChapter != (_chaptersArr.count - indexPath.row - 1);
        [self dismissViewControllerAnimated:YES completion:^{
            if (needUpdate && self.selectChapter) {
                self.selectChapter(_chaptersArr.count - indexPath.row - 1);
            }
        }];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (_firstDisplay) {
        _firstDisplay = NO;
        CGFloat offsetY = (_chaptersArr.count - 1 - _readingChapter) * tableView.rowHeight - tableView.height/2;
        if (offsetY > _chaptersArr.count * tableView.rowHeight - tableView.height) {
            offsetY = _chaptersArr.count * tableView.rowHeight - tableView.height;
        } else if (offsetY < 0) {
            offsetY = 0;
        }
        tableView.contentOffset = CGPointMake(0,offsetY);
    }
}

- (IBAction)tapAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)goToAction:(id)sender {
    if ([self.goBtn.currentTitle isEqualToString:@"到顶部"]) {
        self.moveImageV.image = [UIImage imageNamed:@"move-up"];
        [UIView animateWithDuration:0.05 animations:^{
            self.moveView.alpha = 1.0;
        }];
        [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
    } else {
        self.moveImageV.image = [UIImage imageNamed:@"move-down"];
        [UIView animateWithDuration:0.05 animations:^{
            self.moveView.alpha = 1.0;
        }];
        [_tableView setContentOffset:CGPointMake(0, (_chaptersArr.count - 1) * _tableView.rowHeight - _tableView.height) animated:YES];
    }
}

- (void)showGoToBtn {
    if (self.goBtn.alpha >= 0.9) {
        return;
    }
    [UIView animateWithDuration:0.1 animations:^{
        self.goBtn.alpha = 1;
    }];
}

- (void)hideGoToBtn {
    if (self.goBtn.alpha < 0.1) {
        return;
    }
    [UIView animateWithDuration:0.1 animations:^{
        self.goBtn.alpha = 0;
        self.moveView.alpha = 0.0;
    }];
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

- (IBAction)goBtn:(id)sender {
}
@end
