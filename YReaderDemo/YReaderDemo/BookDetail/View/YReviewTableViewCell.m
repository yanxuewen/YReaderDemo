//
//  YReviewTableViewCell.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/10.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YReviewTableViewCell.h"
#import "YBookReviewModel.h"
#import "CWStarRateView.h"
#import "YURLManager.h"
#import "YDateModel.h"

@interface YReviewTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *authorImgeView;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *createLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet CWStarRateView *starView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *usefulNumberLabel;


@end

@implementation YReviewTableViewCell

- (void)setReviewModel:(YBookReviewModel *)reviewModel {
    _reviewModel = reviewModel;
    [self.authorImgeView sd_setImageWithURL:[YURLManager getURLWith:YAPITypeAuthorAvatar parameter:reviewModel.author.avatar] placeholderImage:kImageDefaltAuthorAvatar];
    self.authorLabel.text = reviewModel.author.nickname;
    self.titleLabel.text = reviewModel.title;
    self.contentLabel.text = reviewModel.content;
    self.usefulNumberLabel.text = [NSString stringWithFormat:@"%zi",reviewModel.likeCount];
    self.createLabel.text = [[YDateModel shareDateModel] getUpdateStringWith:reviewModel.created];
    self.starView.scorePercent = reviewModel.rating / 5.0;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
