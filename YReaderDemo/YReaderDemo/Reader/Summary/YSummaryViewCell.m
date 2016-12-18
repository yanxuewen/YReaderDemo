//
//  YSummaryViewCell.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/18.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YSummaryViewCell.h"
#import "YBookSummaryModel.h"
#import "YDateModel.h"

@interface YSummaryViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *summaryNumaLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageV;


@end

@implementation YSummaryViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.bgImageV.image = [UIImage imageWithColor:YRGBColor(98, 98, 98) size:self.bgImageV.size];
    self.bgImageV.layer.cornerRadius = self.bgImageV.width/2;
}

- (void)setIsSelectSummary:(BOOL)isSelectSummary {
    _isSelectSummary = isSelectSummary;
    self.selectLabel.hidden = !isSelectSummary;
}

- (void)setSummaryM:(YBookSummaryModel *)summaryM {
    _summaryM = summaryM;
    if (summaryM && summaryM.source.length > 0) {
        self.summaryLabel.text = [summaryM.source substringToIndex:1];
    }
    self.summaryNumaLabel.text = summaryM.source;
    self.timeLabel.text = [[YDateModel shareDateModel] getUpdateStringWith:summaryM.updated];
    self.titleLabel.text = summaryM.lastChapter;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
