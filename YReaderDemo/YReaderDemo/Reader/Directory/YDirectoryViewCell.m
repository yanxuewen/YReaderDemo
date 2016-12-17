//
//  YDirectoryViewCell.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/16.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YDirectoryViewCell.h"

@interface YDirectoryViewCell ()



@end

@implementation YDirectoryViewCell

- (void)setChapterM:(YChapterContentModel *)chapterM {
    _chapterM = chapterM;
    if (_isReadingChapter) {
        self.imageV.image = [UIImage imageNamed:@"bookDirectory_selected"];
    } else if (chapterM.isLoadCache) {
        self.imageV.image = [UIImage imageNamed:@"directory_previewed"];
    } else {
        self.imageV.image = [UIImage imageNamed:@"directory_not_previewed"];
    }
    self.numberLabel.text = [NSString stringWithFormat:@"%zi.",_count];
    CGSize size = [self.numberLabel.text boundingRectWithSize:CGSizeMake(100, 100) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.numberLabel.font} context:NULL].size;
    self.numberLabelWidth.constant = size.width+2;
    self.titleLabel.text = chapterM.title;
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
