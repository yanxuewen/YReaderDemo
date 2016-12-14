//
//  YCenterViewController.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/8.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YCenterViewController.h"
#import "YReaderViewController.h"
#import "YBookViewCell.h"
#import "YSQLiteManager.h"

@interface YCenterViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *booksTableView;
@property (copy, nonatomic) NSArray *booksArr;
@property (strong, nonatomic) YSQLiteManager *sqliteM;

@end

@implementation YCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    self.sqliteM = [YSQLiteManager shareManager];
    self.booksArr = self.sqliteM.userBooks;
    [self.sqliteM addObserver:self forKeyPath:@"userBooks" options:NSKeyValueObservingOptionNew context:NULL];
    
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
        readerVC.readingBook = bookM;
        [self presentViewController:readerVC animated:YES completion:^{
            [self.sqliteM addUserBooksWith:bookM];
        }];
    }
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
