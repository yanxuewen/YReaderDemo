//
//  YSearchViewController.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/8.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YSearchViewController.h"
#import "YTableHeaderView.h"
#import "YCollectionViewLayout.h"
#import "YTagViewCell.h"
#import "YNetworkManager.h"
#import "YBookDetailCell.h"
#import "YSQLiteManager.h"
#import "YBookDetailViewController.h"

#define kKeyboardShowDuartion 0.3

@interface YSearchViewController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarTop;
@property (weak, nonatomic) IBOutlet UITableView *historyTableView;
@property (weak, nonatomic) IBOutlet UITableView *completionTable;
@property (weak, nonatomic) IBOutlet UITableView *bookTable;

@property (copy, nonatomic) NSArray *tagArr;
@property (copy, nonatomic) NSArray *tagColorArr;
@property (copy, nonatomic) NSArray *historyDataArr;
@property (copy, nonatomic) NSArray *completionArr;
@property (copy, nonatomic) NSArray *bookArr;

@property (strong, nonatomic) UICollectionView *tagView;
@property (strong, nonatomic) YNetworkManager *netManager;
@property (strong, nonatomic) NSTimer *autoSearchTimer;
@property (strong, nonatomic) YSQLiteManager *sqliteM;

@property (strong, nonatomic) NSURLSessionTask *autoCompletionTask;
@property (strong, nonatomic) NSURLSessionTask *searchBookTask;

@end

@implementation YSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _netManager = [YNetworkManager shareManager];
    _sqliteM = [YSQLiteManager shareManager];
    
    _historyDataArr = [_sqliteM getHistorySearchTextArray];
    _tagArr = [self randomTagArray];
    
    _tagColorArr = @[YRGBColor(146, 197, 238),YRGBColor(192, 104, 208),YRGBColor(245, 188, 120),YRGBColor(145, 206, 213),YRGBColor(103, 204, 183),YRGBColor(231, 143, 143)];
    
    [self setupUI];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)setupUI {
    [self setupHistoryHeaderView];
    [self.historyTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"YHistoryCell"];
    [self.completionTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"YCompletionCell"];
    [self.bookTable registerNib:[UINib nibWithNibName:NSStringFromClass([YBookDetailCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([YBookDetailCell class])];
    self.completionTable.alpha = 0;
    self.bookTable.alpha = 0;
}

- (void)setupHistoryHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 144)];
    headerView.backgroundColor = [UIColor whiteColor];
    __weak typeof(self) wself = self;
    YTableHeaderView *headerV = ({
        YTableHeaderView *headerV = [[YTableHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
        headerV.textLabel.text = @"大家都在搜";
        headerV.rightTitle = @"换一批";
        headerV.image = [UIImage imageNamed:@"search_refresh"];
        headerV.tapAction = ^{
            wself.tagArr = [wself randomTagArray];
            YCollectionViewLayout *layout = (YCollectionViewLayout *)wself.tagView.collectionViewLayout;
            layout.dataArr = wself.tagArr;
            [wself.tagView reloadData];
        };
        headerV;
    });
    [headerView addSubview:headerV];
    
    _tagView = ({
        YCollectionViewLayout *layout = [[YCollectionViewLayout alloc] initWithStyle:YLayoutStyleTag];
        layout.dataArr = _tagArr;

        UICollectionView *tagView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 44, kScreenWidth, 100) collectionViewLayout:layout];
        tagView.backgroundColor = [UIColor clearColor];
        [tagView registerNib:[UINib nibWithNibName:NSStringFromClass([YTagViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([YTagViewCell class])];
        tagView.delegate = self;
        tagView.dataSource = self;
        tagView;
    });
    [headerView addSubview:_tagView];
    
    self.historyTableView.tableHeaderView = headerView;
    
}

#pragma mark - collectionView delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _tagArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YTagViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([YTagViewCell class]) forIndexPath:indexPath];
    cell.textLabel.text = _tagArr[indexPath.row];
    cell.textLabel.backgroundColor = _tagColorArr[indexPath.row%_tagColorArr.count];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(nonnull UICollectionViewCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        collectionView.height = collectionView.contentSize.height;
        self.historyTableView.tableHeaderView.height = collectionView.height + 44;
        [self.historyTableView reloadData];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.tagArr.count) {
        [self fuzzySearchBookWith:self.tagArr[indexPath.row]];
    }
}

#pragma mark - tableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:self.historyTableView] && section == 0) {
        return 44.0;
    }
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:self.historyTableView]) {
        YTableHeaderView *headerV = [[YTableHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
        headerV.textLabel.text = @"搜索历史";
        headerV.rightTitle = @"清空";
        headerV.image = [UIImage imageNamed:@"search_delete"];
        __weak typeof(self) wself = self;
        headerV.tapAction = ^{
            [wself clearHistorySearchTextArray];
        };
        return headerV;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:self.historyTableView]) {
        return _historyDataArr.count;
    } else if ([tableView isEqual:self.completionTable]) {
        return _completionArr.count;
    } else if ([tableView isEqual:self.bookTable]) {
        return _bookArr.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.historyTableView]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YHistoryCell" forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@"search_history_mark"];
        cell.textLabel.textColor = YRGBColor(128, 128, 128);
        cell.textLabel.text = _historyDataArr[indexPath.row];
        return cell;
    } else if ([tableView isEqual:self.completionTable]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YCompletionCell" forIndexPath:indexPath];
        cell.textLabel.textColor = YRGBColor(50, 50, 50);
        cell.textLabel.text = _completionArr[indexPath.row];
        return cell;
    } else if ([tableView isEqual:self.bookTable]) {
        YBookDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YBookDetailCell class]) forIndexPath:indexPath];
        cell.bookModel = _bookArr[indexPath.row];
        return cell;
    }
    DDLogError(@"%s tableView error",__func__);
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *selectStr = nil;
    if ([tableView isEqual:self.historyTableView]) {
        if (indexPath.row < self.historyDataArr.count) {
            selectStr = self.historyDataArr[indexPath.row];
        }
    } else if ([tableView isEqual:self.completionTable]) {
        if (indexPath.row < self.completionArr.count) {
            selectStr = self.completionArr[indexPath.row];
        }
    } else if ([tableView isEqual:self.bookTable]) {
        if (indexPath.row < self.bookArr.count) {
            YBookDetailViewController *detailVC = [[YBookDetailViewController alloc] init];
            detailVC.selectBook = self.bookArr[indexPath.row];
            [self.navigationController pushViewController:detailVC animated:YES];
        }
    }
    if (selectStr) {
        
        [self fuzzySearchBookWith:selectStr];
    }
}

#pragma mark - Search bar delegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    if (self.completionTable.alpha > 0.1) {
        [UIView animateWithDuration:0.3 animations:^{
            self.completionTable.alpha = 0;
            self.historyTableView.alpha = 1;
            self.bookTable.alpha = 0;
        } completion:^(BOOL finished) {
            self.completionTable.alpha = 0;
            self.historyTableView.alpha = 1;
            self.bookTable.alpha = 0;
        }];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
//    NSLog(@"%s",__func__);
    [self stopSearchTimer];
    [self fuzzySearchBookWith:searchBar.text];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    [UIView animateWithDuration:kKeyboardShowDuartion animations:^{
        self.searchBarTop.constant = -44;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.searchBarTop.constant = -44;
    }];
    if (self.historyTableView.alpha < 0.1) {
        [UIView animateWithDuration:0.3 animations:^{
            self.completionTable.alpha = 0;
            self.historyTableView.alpha = 1;
            self.bookTable.alpha = 0;
        } completion:^(BOOL finished) {
            self.completionTable.alpha = 0;
            self.historyTableView.alpha = 1;
            self.bookTable.alpha = 0;
        }];
    }
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self startSearchTimer];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [UIView animateWithDuration:kKeyboardShowDuartion animations:^{
        self.searchBarTop.constant = 0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.searchBarTop.constant = 0;
    }];
    [self stopSearchTimer];
}

- (void)startSearchTimer {
    [self stopSearchTimer];
    self.autoSearchTimer = [NSTimer timerWithTimeInterval:0.2 target:self selector:@selector(searchAutoCompletion) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.autoSearchTimer forMode:NSRunLoopCommonModes];
}

- (void)stopSearchTimer {
    if (self.autoSearchTimer) {
        [self.autoSearchTimer invalidate];
        self.autoSearchTimer = nil;
    }
}

#pragma mark - Auto Completion
- (void)searchAutoCompletion {
    if (self.searchBar.text.length < 1) {
        return;
    }
    if (self.autoCompletionTask && self.autoCompletionTask.state == NSURLSessionTaskStateRunning) {
        [self.autoCompletionTask cancel];
        self.autoCompletionTask = nil;
    }
    __weak typeof(self) wself = self;
    self.autoCompletionTask = [self.netManager getWithAPIType:YAPITypeAutoCompletion parameter:self.searchBar.text success:^(id response) {
        wself.completionArr = response;
        [wself.completionTable reloadData];
        if (self.completionTable.alpha < 0.1) {
            [UIView animateWithDuration:0.3 animations:^{
                wself.completionTable.alpha = 1;
                wself.historyTableView.alpha = 0;
                wself.bookTable.alpha = 0;
            } completion:^(BOOL finished) {
                wself.completionTable.alpha = 1;
                wself.historyTableView.alpha = 0;
                wself.bookTable.alpha = 0;
            }];
        }
    } failure:^(NSError *error) {
        if (error.code == -999) {
            NSLog(@"autoCompletionTask cancle");
        }
    }];
    
}

- (void)fuzzySearchBookWith:(NSString *)string {
    if (string.length < 1 && [string stringByReplacingOccurrencesOfString:@" " withString:@""].length > 1) {
        return;
    }
    [self addHistorySearchText:string];
    self.searchBar.text = string;
    if (self.searchBar.isFirstResponder) {
        [self.searchBar resignFirstResponder];
    }
    if (self.searchBookTask && self.searchBookTask.state == NSURLSessionTaskStateRunning) {
        [self.searchBookTask cancel];
        self.searchBookTask = nil;
    }
    __weak typeof(self) wself = self;
    self.searchBookTask = [self.netManager getWithAPIType:YAPITypeFuzzySearch parameter:string success:^(id response) {
        wself.bookArr = response;
        [wself.bookTable reloadData];
        if (self.bookTable.alpha < 0.1) {
            [UIView animateWithDuration:0.3 animations:^{
                wself.completionTable.alpha = 0;
                wself.historyTableView.alpha = 0;
                wself.bookTable.alpha = 1;
            } completion:^(BOOL finished) {
                wself.completionTable.alpha = 0;
                wself.historyTableView.alpha = 0;
                wself.bookTable.alpha = 1;
            }];
        }
    } failure:^(NSError *error) {
        if (error.code == -999) {
            NSLog(@"searchBookTask cancle");
        }
    }];
}

- (IBAction)backVC:(id)sender {
    [self stopSearchTimer];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - random tag
- (NSArray *)randomTagArray {
    static NSArray *sourceTag = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sourceTag = @[@"辰东",@"我吃西红柿",@"唐家三少",@"天蚕土豆",@"耳根",@"烟雨江南",@"梦入神机",@"骷髅精灵",@"完美世界",@"大主宰",@"斗破苍穹",@"斗罗大陆",@"如果蜗牛有爱情",@"极品家丁",@"择天记",@"神墓",@"遮天",@"太古神王",@"帝霸",@"校花的贴身高手",@"武动乾坤"];
    });
    NSMutableArray *array = [NSMutableArray new];
    for (NSInteger i = 0; i < 8; i++) {
        NSString *tag = sourceTag[arc4random()%sourceTag.count];
        if (![array containsObject:tag]) {
            [array addObject:tag];
        }
    }
    return array.copy;
}

#pragma mark - dealWith history search text
- (void)addHistorySearchText:(NSString *)text {
    NSMutableArray *arr = _historyDataArr.mutableCopy;
    if ([arr containsObject:text]) {
        [arr removeObject:text];
    }
    [arr insertObject:text atIndex:0];
    _historyDataArr = arr.copy;
    [_historyTableView reloadData];
    [_sqliteM updateHistorySearchTextArrayWith:_historyDataArr];
}

- (void)clearHistorySearchTextArray {
    if (_historyDataArr.count == 0) {
        return;
    }
    _historyDataArr = @[];
    [_historyTableView reloadData];
    [_sqliteM updateHistorySearchTextArrayWith:_historyDataArr];
}


- (void)dealloc {
    NSLog(@"%s",__func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
