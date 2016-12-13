//
//  YBookDetailCell.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/9.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YBookDetailCell.h"

@interface YBookDetailCell ()

@property (weak, nonatomic) IBOutlet UIImageView *bookImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *shortIntroLabel;
@property (weak, nonatomic) IBOutlet UILabel *latelyFollowerLabel;

@end

@implementation YBookDetailCell

- (void)setBookModel:(YBookModel *)bookModel {
    _bookModel = bookModel;
    [self.bookImage sd_setImageWithURL:[YURLManager getURLWith:YAPITypeBookCover parameter:bookModel.cover] placeholderImage:kImageDefaltBookCover];
    self.titleLabel.text = bookModel.title;
    NSString *author = bookModel.author;
    if (bookModel.cat) {
        author = [author stringByAppendingFormat:@"  l  %@",bookModel.cat];
    }
    self.authorLabel.text = author;
    self.shortIntroLabel.text = bookModel.shortIntro;
    NSString *follower = [NSString stringWithFormat:@"%zi 人在追",bookModel.latelyFollower];
    if (bookModel.retentionRatio > 0.0) {
        follower = [follower stringByAppendingFormat:@"  l  %g%% 读者留存",bookModel.retentionRatio];
    }
    self.latelyFollowerLabel.text = follower;
    
}

- (void)setRecommendListModel:(YRecommendBookListModel *)recommendListModel {
    _recommendListModel = recommendListModel;
    [self.bookImage sd_setImageWithURL:[YURLManager getURLWith:YAPITypeBookCover parameter:recommendListModel.cover] placeholderImage:kImageDefaltBookCover];
    self.titleLabel.text = recommendListModel.title;
    self.authorLabel.text = recommendListModel.author;
    self.shortIntroLabel.text = recommendListModel.desc;
    NSString *bookCount = [NSString stringWithFormat:@"共 %zi 本书",recommendListModel.bookCount];
    if (recommendListModel.collectorCount > 0) {
        bookCount = [bookCount stringByAppendingFormat:@"  l  %zi 人收藏",recommendListModel.collectorCount];
    }
    self.latelyFollowerLabel.text = bookCount;
}


@end
