//
//  YRecommendBookCell.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/10.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YRecommendBookCell.h"
#import "YRecommendBookModel.h"

@interface YRecommendBookCell ()

@property (weak, nonatomic) IBOutlet UIImageView *bookImageView;
@property (weak, nonatomic) IBOutlet UILabel *bookNameLabel;


@end

@implementation YRecommendBookCell

- (void)setRecommendModel:(YRecommendBookModel *)recommendModel {
    _recommendModel = recommendModel;
    [_bookImageView sd_setImageWithURL:[YURLManager getURLWith:YAPITypeBookCover parameter:recommendModel.cover] placeholderImage:kImageDefaltBookCover];
    _bookNameLabel.text = recommendModel.title;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _bookImageView.layer.borderColor = YRGBColor(33, 33, 33).CGColor;
    _bookImageView.layer.borderWidth = 0.5;
}

@end
