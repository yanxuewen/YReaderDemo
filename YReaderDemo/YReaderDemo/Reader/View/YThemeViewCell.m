//
//  YThemeViewCell.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/17.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YThemeViewCell.h"

@implementation YThemeViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    __weak typeof(self) wself = self;
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        if (wself.themeSelect) {
            wself.themeSelect();
        }
    }]];
}


@end
