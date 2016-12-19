//
//  YRankingViewCell.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/19.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YRankingViewCell.h"
#import "YRankingModel.h"

@interface YRankingViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *rankingImageV;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation YRankingViewCell

- (void)setRankingM:(YRankingModel *)rankingM {
    _rankingM = rankingM;
    self.rankingImageV.image = nil;
    self.accessoryView = nil;
    _expand = NO;
    if (!rankingM.idField) {
        self.rankingImageV.image = [UIImage imageNamed:@"ranking_other"];
        self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ranking_arrow_down"]];
    } else if (!rankingM.collapse){
        [self.rankingImageV sd_setImageWithURL:[YURLManager getURLWith:YAPITypeBookCover parameter:rankingM.cover] placeholderImage:nil];
    }
    self.titleLabel.text = rankingM.title;
}

- (void)setExpand:(BOOL)expand {
    if (self.accessoryView && expand) {
        self.accessoryView.layer.transform = CATransform3DMakeRotation(M_PI, 1, 0, 0);
    }
}

@end
