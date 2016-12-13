//
//  YNavHeaderView.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/10.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YNavHeaderView.h"

@implementation YNavHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
    UIView *view = [[NSBundle mainBundle] loadNibNamed:@"YTableHeaderView" owner:self options:nil].firstObject;
    view.frame = self.bounds;
    [self addSubview:view];
//    __weak typeof(self) wself = self;
    
}

@end
