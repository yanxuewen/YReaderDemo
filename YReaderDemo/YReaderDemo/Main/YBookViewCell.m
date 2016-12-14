//
//  YBookViewCell.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/14.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YBookViewCell.h"
#import "YURLManager.h"
#import "YBookDetailModel.h"
#import "YDateModel.h"

@interface YBookViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *bookImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdate;
@property (weak, nonatomic) IBOutlet UIImageView *updateImage;

@end

@implementation YBookViewCell

- (void)setBookM:(YBookDetailModel *)bookM {
    _bookM = bookM;
    [self.bookImage sd_setImageWithURL:[YURLManager getURLWith:YAPITypeBookCover parameter:bookM.cover] placeholderImage:kImageDefaltBookCover];
    self.titleLabel.text = bookM.title;
    NSString *updateTime = [[YDateModel shareDateModel] getUpdateStringWith:bookM.updated];
    self.lastUpdate.text = [updateTime stringByAppendingFormat:@"更新 %@",bookM.lastChapter];
    self.updateImage.hidden = !bookM.hasUpdated;
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
