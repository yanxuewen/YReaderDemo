//
//  YBookDetailViewController.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/10.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YBookDetailViewController.h"
#import "YReaderViewController.h"
#import "YBookModel.h"
#import "YBookDetailModel.h"
#import "YBookReviewModel.h"
#import "YRecommendBookModel.h"
#import "YRecommendBookListModel.h"
#import "YNetworkManager.h"
#import "YCollectionViewLayout.h"
#import "YTagViewCell.h"
#import "YRecommendBookCell.h"
#import "YReviewTableViewCell.h"
#import "YBookDetailCell.h"
#import "YTableHeaderView.h"
#import "YDateModel.h"
#import "YSQLiteManager.h"

@interface YBookDetailViewController ()<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *bookImageView;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *majorCateLabel;
@property (weak, nonatomic) IBOutlet UILabel *wordCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *updateLabel;
@property (weak, nonatomic) IBOutlet UILabel *followerLabel;
@property (weak, nonatomic) IBOutlet UILabel *retentionLabel;
@property (weak, nonatomic) IBOutlet UILabel *serializeWordLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *tagCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagCollectionViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *longIntroLabel;
@property (weak, nonatomic) IBOutlet UIImageView *longIntroImage;
@property (weak, nonatomic) IBOutlet UITableView *reviewTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *reviewsHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *reviewsTop;
@property (weak, nonatomic) IBOutlet UIView *communityView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *communityViewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *communityViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *communityLabel;
@property (weak, nonatomic) IBOutlet UILabel *communityNumberLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *recommendCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recommendCollectionViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recommendCollectionViewTop;
@property (weak, nonatomic) IBOutlet UITableView *recommendListView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recommendListViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recommendListViewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgViewHeight;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (strong, nonatomic) UICollectionReusableView *recommendHeaderView;
@property (strong, nonatomic) YNetworkManager *netManager;
@property (strong, nonatomic) YBookDetailModel *bookDetail;
@property (copy, nonatomic) NSArray *reviewArr;
@property (copy, nonatomic) NSArray *recommendBookArr;
@property (copy, nonatomic) NSArray *recommendBookListArr;
@property (copy, nonatomic) NSArray *tagColorArr;
@property (assign, nonatomic) BOOL isDidLoad;

@property (strong, nonatomic) NSURLSessionTask *detailTask;
@property (strong, nonatomic) NSURLSessionTask *recommendTask;
@property (strong, nonatomic) NSURLSessionTask *recommendListTask;
@property (strong, nonatomic) NSURLSessionTask *reviewsTask;

@end

@implementation YBookDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bgView.alpha = 0;
    _netManager = [YNetworkManager shareManager];
    _tagColorArr = @[YRGBColor(146, 197, 238),YRGBColor(192, 104, 208),YRGBColor(245, 188, 120),YRGBColor(145, 206, 213),YRGBColor(103, 204, 183),YRGBColor(231, 143, 143)];
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    if (!_isDidLoad) {
        _isDidLoad = YES;
        self.view.userInteractionEnabled = NO;
        __weak typeof(self) wself = self;
        [[YProgressHUD shareProgressHUD] setCancelAction:^{
            [wself cancelAllTasks];
            [wself.navigationController popViewControllerAnimated:YES];
        }];
        [YProgressHUD showLoadingHUD];
        [self getNetBookDetailData];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)cancelAllTasks {
    if (self.detailTask.state == NSURLSessionTaskStateRunning) {
        [self.detailTask cancel];
    }
    if (self.recommendTask.state == NSURLSessionTaskStateRunning) {
        [self.recommendTask cancel];
    }
    if (self.recommendListTask.state == NSURLSessionTaskStateRunning) {
        [self.recommendListTask cancel];
    }
    if (self.reviewsTask.state == NSURLSessionTaskStateRunning) {
        [self.reviewsTask cancel];
    }
}

- (void)setupUI {
    YCollectionViewLayout *tagLayout = [[YCollectionViewLayout alloc] initWithStyle:YLayoutStyleTag];
    [self.tagCollectionView setCollectionViewLayout:tagLayout];
    [self.tagCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([YTagViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([YTagViewCell class])];
    
    YCollectionViewLayout *recommendLayout = [[YCollectionViewLayout alloc] initWithStyle:YLayoutStyleRecommend];
    [self.recommendCollectionView setCollectionViewLayout:recommendLayout];
    [self.recommendCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([YRecommendBookCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([YRecommendBookCell class])];
    [self.recommendCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"YCollectionHeaderView"];
    
    [self.reviewTableView registerNib:[UINib nibWithNibName:NSStringFromClass([YReviewTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([YReviewTableViewCell class])];
    
    [self.recommendListView registerNib:[UINib nibWithNibName:NSStringFromClass([YBookDetailCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([YBookDetailCell class])];
    
    //action
    __weak typeof(self) wself = self;
    [self.longIntroLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        BOOL isUp = NO;
        if ([wself.longIntroLabel.text isEqualToString:wself.selectBook.shortIntro]) {
            wself.longIntroLabel.text = wself.bookDetail.longIntro;
            isUp = YES;
            
        } else {
            wself.longIntroLabel.text = wself.selectBook.shortIntro;
        }
        [UIView animateWithDuration:0.25 animations:^{
            wself.longIntroImage.layer.transform = CATransform3DMakeRotation(isUp?M_PI:0, 1, 0, 0);
        }];
        
    }]];
    
}

#pragma mark - 开始阅读
- (IBAction)startReading:(id)sender {
    YReaderViewController *readerVC = [[YReaderViewController alloc] init];
    readerVC.readingBook = [[YSQLiteManager shareManager] addUserBooksWith:self.bookDetail];
    [self presentViewController:readerVC animated:YES completion:^{
        
    }];;
}

- (void)getNetBookDetailData {
    __weak typeof(self) wself = self;
    NSString *parameter = _selectBook.idField ? _selectBook.idField : _recommendBook.idField;
    if (!parameter) {
        [YProgressHUD showErrorHUDWith:@"参数错误"];
        DDLogError(@"getNetBookDetailData parameter == nil");
        [self.navigationController popViewControllerAnimated:YES];
    }
    _detailTask = [_netManager getWithAPIType:YAPITypeBookDetail parameter:parameter success:^(id response) {
        wself.bookDetail = response;
        [wself refleshView];
        DDLogInfo(@"bookDetail %@",response);
    } failure:^(NSError *error) {
        if (error.code == -999) {
            DDLogInfo(@"getNetBookDetailData detailTask cancel");
        } else {
            DDLogError(@"YAPITypeBookDetail %@ error ",wself.selectBook.idField);
            [YProgressHUD showErrorHUDWith:error.localizedFailureReason];
            [wself.navigationController popViewControllerAnimated:YES];
        }
        
    }];
    
    _reviewsTask = [_netManager getWithAPIType:YAPITypeBookReview parameter:parameter success:^(id response) {
        wself.reviewArr = response;
        [wself refleshView];
        DDLogInfo(@"reviewArr %@",response);
    } failure:^(NSError *error) {
        if (error.code == -999) {
            DDLogInfo(@"getNetBookDetailData reviewsTask cancel");
        } else {
            wself.reviewArr = @[];
            [wself refleshView];
        }
    }];
    
    _recommendTask = [_netManager getWithAPIType:YAPITypeRecommendBook parameter:parameter success:^(id response) {
        wself.recommendBookArr = response;
        [wself refleshView];
        DDLogInfo(@"recommendBookArr %@",response);
    } failure:^(NSError *error) {
        if (error.code == -999) {
            DDLogInfo(@"getNetBookDetailData recommendTask cancel");
        } else {
            wself.recommendBookArr = @[];
            [wself refleshView];
        }
    }];
    
   _recommendListTask = [_netManager getWithAPIType:YAPITypeRecommendBookList parameter:parameter success:^(id response) {
        wself.recommendBookListArr = response;
        [wself refleshView];
        DDLogInfo(@"recommendBookListArr %@",response);
    } failure:^(NSError *error) {
        if (error.code == -999) {
            DDLogInfo(@"getNetBookDetailData recommendListTask cancel");
        } else {
            wself.recommendBookListArr = @[];
            [wself refleshView];
        }
    }];
}

- (void)refleshView {
    
    if (!_bookDetail || !_recommendBookListArr || !_recommendBookArr || !_reviewArr) {
        return;
    }
    _detailTask = nil;
    _reviewsTask = nil;
    _recommendListTask = nil;
    _recommendTask = nil;
    
    [_bookImageView sd_setImageWithURL:[YURLManager getURLWith:YAPITypeBookCover parameter:_bookDetail.cover] placeholderImage:kImageDefaltBookCover];
    _titleLabel.text = _bookDetail.title;
    _authorLabel.text = _bookDetail.author;
    _majorCateLabel.text = _bookDetail.minorCate;
    _wordCountLabel.text = [_bookDetail getBookWordCount];
    if (_bookDetail.isSerial) {
        _updateLabel.text = [[[YDateModel shareDateModel] getUpdateStringWith:_bookDetail.updated] stringByAppendingString:@"更新"];
    } else {
        _updateLabel.text = @"已完结";
    }
    
    if (_bookDetail.retentionRatio > 0.0) {
        _retentionLabel.text = [NSString stringWithFormat:@"%g%%",_bookDetail.retentionRatio];
    } else {
        _retentionLabel.text = @"暂未统计";
        _retentionLabel.textColor = YRGBColor(180, 180, 180);
    }
    if (_bookDetail.serializeWordCount >= 0 ) {
        _serializeWordLabel.text = [NSString stringWithFormat:@"%zi",_bookDetail.serializeWordCount];
    } else {
        _serializeWordLabel.text = @"暂未统计";
        _serializeWordLabel.textColor = YRGBColor(180, 180, 180);
    }
    _followerLabel.text = [NSString stringWithFormat:@"%zi",_bookDetail.latelyFollower];
    _longIntroLabel.text = _selectBook.shortIntro;
    
    if (_bookDetail.postCount > 0) {
        _communityLabel.text = [NSString stringWithFormat:@"%@的社区",_bookDetail.title];
        _communityNumberLabel.text = [NSString stringWithFormat:@"共有 %zi 个帖子",_bookDetail.postCount];
    } else {
        _communityViewHeight.constant = 0;
        _communityViewTop.constant = 0;
        _communityView.hidden = YES;
    }
    
    //tag
    YCollectionViewLayout *tagLayout = (YCollectionViewLayout *)_tagCollectionView.collectionViewLayout;
    tagLayout.dataArr = _bookDetail.tags;
    [_tagCollectionView reloadData];
    
    //reviews
    if (_reviewArr.count > 0) {
        [_reviewTableView reloadData];
    } else {
        _reviewsHeight.constant = 0;
        _reviewsTop.constant = 0;
        _reviewTableView.hidden = YES;
    }
    
    //recommend book
    if (_recommendBookArr.count > 0) {
        YCollectionViewLayout *recommendLayout = (YCollectionViewLayout *)_recommendCollectionView.collectionViewLayout;
        NSMutableArray *array = @[].mutableCopy;
        for (YRecommendBookModel *model in _recommendBookArr) {
            [array addObject:model.title];
        }
        recommendLayout.dataArr = array.copy;
        [_recommendCollectionView reloadData];
    } else {
        _recommendCollectionViewHeight.constant = 0;
        _recommendCollectionViewTop.constant = 0;
        _recommendCollectionView.hidden = YES;
    }
    
    //recommend book list
    if (_recommendBookListArr.count > 0) {
        [_recommendListView reloadData];
    } else {
        _recommendListViewHeight.constant = 0;
        _recommendListViewTop.constant = 0;
        _recommendListView.hidden = YES;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.bgView.alpha = 1.0;
    }];
    [YProgressHUD hideLoadingHUD];
    self.view.userInteractionEnabled = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.bgViewHeight.constant = self.bottomView.top + self.bottomView.height;
    });
    
}

#pragma mark - collectionView delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([collectionView isEqual:self.tagCollectionView]) {
        return _bookDetail.tags.count;
    } else if ([collectionView isEqual:self.recommendCollectionView]) {
        return _recommendBookArr.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([collectionView isEqual:self.tagCollectionView]) {
        YTagViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([YTagViewCell class]) forIndexPath:indexPath];
        cell.textLabel.text = _bookDetail.tags[indexPath.row];
        cell.textLabel.backgroundColor = _tagColorArr[indexPath.row%_tagColorArr.count];
        return cell;

    } else if ([collectionView isEqual:self.recommendCollectionView]) {
        YRecommendBookCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([YRecommendBookCell class]) forIndexPath:indexPath];
        cell.recommendModel = self.recommendBookArr[indexPath.row];
        return cell;
        
    }
    return nil;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([collectionView isEqual:self.recommendCollectionView] && indexPath.section == 0 && [kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"YCollectionHeaderView" forIndexPath:indexPath];
        if (_recommendHeaderView) {
            return _recommendHeaderView;
        }
        UILabel *leftLabel = ({
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 150, 44)];
            label.text = @"你可能感兴趣";
            label.font = [UIFont systemFontOfSize:15];
            label.textColor = YRGBColor(33, 33, 33);
            label;
        });
        [headerView addSubview:leftLabel];
        UILabel *rightLabel = ({
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(headerView.width - 20 - 100 , 0, 100, 44)];
            label.text = @"更多";
            label.textAlignment = NSTextAlignmentRight;
            label.font = [UIFont systemFontOfSize:15];
            label.textColor = YRGBColor(33, 33, 33);
            label.userInteractionEnabled = YES;
            [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
                NSLog(@"点击感兴趣按钮  \"更多\"");
            }]];
            label;
        });
        [headerView addSubview:rightLabel];
        _recommendHeaderView = headerView;
        return headerView;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([collectionView isEqual:self.recommendCollectionView]) {
        if (indexPath.row < self.recommendBookArr.count) {
            YBookDetailViewController *detailVC = [[YBookDetailViewController alloc] init];
            detailVC.recommendBook = self.recommendBookArr[indexPath.row];
            [self.navigationController pushViewController:detailVC animated:YES];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        if ([collectionView isEqual:self.tagCollectionView]) {
            self.tagCollectionViewHeight.constant = self.tagCollectionView.contentSize.height;
        } else if ([collectionView isEqual:self.recommendCollectionView]) {
            self.recommendCollectionViewHeight.constant = self.recommendCollectionView.contentSize.height + 15.0;
        }
    }
}


#pragma mark - tableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:self.reviewTableView] || [tableView isEqual:self.recommendListView]) {
        return 44;
    }
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        YTableHeaderView *headerV = [[YTableHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
        headerV.textLabel.font = [UIFont systemFontOfSize:14];
        
        if ([tableView isEqual:self.reviewTableView]) {
            headerV.textLabel.text = @"热门评价";
            headerV.rightTitle = @"更多";
            headerV.tapAction = ^{
                NSLog(@"点击更多书评");
            };
        } else if ([tableView isEqual:self.recommendListView]) {
            headerV.textLabel.text = @"推荐书单";
            headerV.rightTitle = nil;
        }
        
        return headerV;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:self.reviewTableView]) {
        return self.reviewArr.count;
    } else if ([tableView isEqual:self.recommendListView]) {
        return self.recommendBookListArr.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.reviewTableView]) {
        YReviewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YReviewTableViewCell class]) forIndexPath:indexPath];
        cell.reviewModel = self.reviewArr[indexPath.row];
        return cell;
    } else if ([tableView isEqual:self.recommendListView]) {
        YBookDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YBookDetailCell class]) forIndexPath:indexPath];
        cell.recommendListModel = self.recommendBookListArr[indexPath.row];
        cell.backgroundColor = [UIColor whiteColor];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        if ([tableView isEqual:self.reviewTableView]) {
            self.reviewsHeight.constant = self.reviewTableView.contentSize.height;
        } else if ([tableView isEqual:self.recommendListView]) {
            self.recommendListViewHeight.constant = self.recommendListView.contentSize.height;
        }
    }
}



- (IBAction)backVC:(id)sender {
    [self cancelAllTasks];
    [YProgressHUD hideLoadingHUD];
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
