//
//  YCenterViewController.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/8.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YCenterViewController.h"
#import "YReaderViewController.h"
#import "YBookDetailModel.h"
#import "YBookViewCell.h"
#import "YSQLiteManager.h"
#import "YNetworkManager.h"
#import "YBookUpdateModel.h"
#import "YDownloadManager.h"

@interface YCenterViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *booksTableView;
@property (strong, nonatomic) NSArray *booksArr;
@property (strong, nonatomic) YSQLiteManager *sqliteM;
@property (strong, nonatomic) YNetworkManager *netManager;

@end

@implementation YCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    self.sqliteM = [YSQLiteManager shareManager];
    self.netManager = [YNetworkManager shareManager];
    self.booksArr = self.sqliteM.userBooks;
    [self.sqliteM addObserver:self forKeyPath:@"userBooks" options:NSKeyValueObservingOptionNew context:NULL];
    self.booksTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshbooks)];
}

- (void)autoRefreshbooks {
    if (self.booksArr.count > 0) {
        [self.booksTableView.mj_header beginRefreshing];
    }
}

- (void)refreshbooks {
    if (self.booksArr.count == 0) {
        [self.booksTableView.mj_header endRefreshing];
        return;
    }
    NSArray *books = self.booksArr.copy;
    NSMutableString *parameter = [NSMutableString string];
    for (NSUInteger i = 0; i < books.count; i ++) {
        [parameter appendString:((YBookDetailModel *)books[i]).idField];
        if (i < books.count - 1 ) {
            [parameter appendString:@","];
        }
    }
    if (parameter.length == 0) {
        
        return;
    }
    __weak typeof(self) wself = self;
    [_netManager getWithAPIType:YAPITypeBookUpdate parameter:parameter.copy success:^(id response) {
        NSArray *arr = response;
        for (YBookUpdateModel *updateM in arr) {
            for (YBookDetailModel *bookM in books) {
                if ([updateM.idField isEqualToString:bookM.idField] && [updateM.updated compare:bookM.updated] == NSOrderedDescending) {
                    bookM.lastChapter = updateM.lastChapter;
                    bookM.updated = updateM.updated;
                    bookM.chaptersCount = updateM.chaptersCount;
                    bookM.hasUpdated = YES;
                }
            }
        }
        [wself.sqliteM updateUserBooksStatus];
        [wself.booksTableView.mj_header endRefreshing];
        [wself.booksTableView reloadData];
    } failure:^(NSError *error) {
        [wself.booksTableView.mj_header endRefreshing];
    }];
}

- (void)setupUI {
    [self.booksTableView registerNib:[UINib nibWithNibName:NSStringFromClass([YBookViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([YBookViewCell class])];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 50)];
    view.backgroundColor = YRGBColor(235, 235, 235);
    UIImageView *imageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"show_right_sidemenu_icon"]];
    imageV.left = 20.0;
    imageV.centerY = view.height/2;
    [view addSubview:imageV];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imageV.left + imageV.width + 15, 0, 250, view.height)];
    label.text = @"添加您喜欢的小说";
    label.textColor = YRGBColor(33, 33, 33);
    [view addSubview:label];
    __weak typeof(self) wself = self;
    [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        if (wself.tapBarButton) {
            wself.tapBarButton(YShowStateRight);
        }
    }]];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.booksArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YBookViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YBookViewCell class]) forIndexPath:indexPath];
    cell.bookM = self.booksArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.booksArr.count) {
        YBookDetailModel *bookM = self.booksArr[indexPath.row];
        YReaderViewController *readerVC = [[YReaderViewController alloc] init];
        readerVC.readingBook = [self.sqliteM addUserBooksWith:bookM];
        [self presentViewController:readerVC animated:YES completion:^{
            bookM.hasUpdated = NO;
            [self.sqliteM updateUserBooksStatus];
            [self.booksTableView reloadData];
        }];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return UITableViewCellEditingStyleDelete;
//}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    YBookDetailModel *editBookM = self.booksArr[indexPath.row];
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        NSLog(@"点击了删除");
        [tableView setEditing:NO animated:YES];
        [self showAlcrtViewWithDeleteBook:editBookM];
    }];
    deleteAction.backgroundColor = YRGBColor(255, 59, 48);
    UITableViewRowAction *loadAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:editBookM.loadStatus == YDownloadStatusNone ? @"下载" : @"取消下载" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        NSLog(@"点击了下载/取消下载");
        [tableView setEditing:NO animated:YES];
        if (editBookM.loadStatus == YDownloadStatusCancel) {
            [YProgressHUD showErrorHUDWith:@"正在取消中..."];
            return ;
        }
        if (editBookM.loadStatus == YDownloadStatusNone) {
            [[YDownloadManager shareManager] downloadReaderBookWith:editBookM type:YDownloadTypeAllLoad];
        } else {
            [[YDownloadManager shareManager] cancelDownloadBookWith:editBookM];
        }
        [tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
        
    }];
    loadAction.backgroundColor = YRGBColor(255, 156, 0);
    UITableViewRowAction *stickyAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:editBookM.hasSticky ? @"取消置顶" : @"置顶" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        NSLog(@"点击了置顶/取消置顶");
        [tableView setEditing:NO animated:YES];
        editBookM.hasSticky = !editBookM.hasSticky;
        [[YSQLiteManager shareManager] stickyUserBookWith:editBookM];
        
    }];
    stickyAction.backgroundColor = YRGBColor(199, 199, 204);
    NSArray *arr = @[deleteAction,loadAction,stickyAction];
    return arr;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"userBooks"]) {
        self.booksArr = self.sqliteM.userBooks;
        [self.booksTableView reloadData];
    }
}

- (IBAction)tapAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    YShowState state = button.tag == 100 ? YShowStateLeft : YShowStateRight;
    if (self.tapBarButton) {
        self.tapBarButton(state);
    }
}

- (void)showAlcrtViewWithDeleteBook:(YBookDetailModel *)bookM {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"是否选择彻底删除此书？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (bookM.loadStatus != YDownloadStatusNone) {
            bookM.loadStatus = YDownloadStatusCancel;
        }
        [self.sqliteM deleteBookWith:bookM];
    }];
    [alertVC addAction:cancelAction];
    [alertVC addAction:sureAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)dealloc {
    [_sqliteM removeObserver:self forKeyPath:@"userBooks"];
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
