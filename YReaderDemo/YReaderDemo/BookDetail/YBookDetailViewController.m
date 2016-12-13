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

@interface YBookDetailViewController ()<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *bookImageView;
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

@end

@implementation YBookDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _netManager = [YNetworkManager shareManager];
    
    _tagColorArr = @[YRGBColor(146, 197, 238),YRGBColor(192, 104, 208),YRGBColor(245, 188, 120),YRGBColor(145, 206, 213),YRGBColor(103, 204, 183),YRGBColor(231, 143, 143)];
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getNetBookDetailData];
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

- (IBAction)startReading:(id)sender {
    YReaderViewController *readerVC = [[YReaderViewController alloc] init];
    readerVC.readingBook = self.bookDetail;
    [self presentViewController:readerVC animated:YES completion:nil];
}

- (void)getNetBookDetailData {
    __weak typeof(self) wself = self;
    [_netManager getWithAPIType:YAPITypeBookDetail parameter:_selectBook.idField success:^(id response) {
        wself.bookDetail = response;
        [self refleshView];
        DDLogInfo(@"bookDetail %@",response);
    } failure:^(NSError *error) {
        DDLogError(@"YAPITypeBookDetail %@ error ",_selectBook.idField);
    }];
    
    [_netManager getWithAPIType:YAPITypeBookReview parameter:_selectBook.idField success:^(id response) {
        wself.reviewArr = response;
        [self refleshView];
        DDLogInfo(@"reviewArr %@",response);
    } failure:^(NSError *error) {
        wself.reviewArr = @[];
        [self refleshView];
    }];
    
    [_netManager getWithAPIType:YAPITypeRecommendBook parameter:_selectBook.idField success:^(id response) {
        wself.recommendBookArr = response;
        [self refleshView];
        DDLogInfo(@"recommendBookArr %@",response);
    } failure:^(NSError *error) {
        wself.recommendBookArr = @[];
        [self refleshView];
    }];
    
    [_netManager getWithAPIType:YAPITypeRecommendBookList parameter:_selectBook.idField success:^(id response) {
        wself.recommendBookListArr = response;
        [self refleshView];
        DDLogInfo(@"recommendBookListArr %@",response);
    } failure:^(NSError *error) {
        wself.recommendBookListArr = @[];
        [self refleshView];
    }];
}

- (void)refleshView {
    
    if (!_bookDetail || !_recommendBookListArr || !_recommendBookArr || !_reviewArr) {
        return;
    }
    
    [_bookImageView sd_setImageWithURL:[YURLManager getURLWith:YAPITypeBookCover parameter:_bookDetail.cover] placeholderImage:kImageDefaltBookCover];
    _titleLabel.text = _bookDetail.title;
    _authorLabel.text = _bookDetail.author;
    _majorCateLabel.text = _bookDetail.minorCate;
    _wordCountLabel.text = [_bookDetail getBookWordCount];
    if (_bookDetail.isSerial) {
        _updateLabel.text = [[YDateModel shareDateModel] getUpdateStringWith:_bookDetail.updated];
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
        headerV.rightLabel.font = [UIFont systemFontOfSize:14];
        headerV.imageView.image = nil;
        if ([tableView isEqual:self.reviewTableView]) {
            headerV.textLabel.text = @"热门评价";
            headerV.rightLabel.text = @"更多";
            headerV.tapAction = ^{
                NSLog(@"点击更多书评");
            };
        } else if ([tableView isEqual:self.recommendListView]) {
            headerV.textLabel.text = @"推荐书单";
            headerV.rightLabel.text = nil;
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
