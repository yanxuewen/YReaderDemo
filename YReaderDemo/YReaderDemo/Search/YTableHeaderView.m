//
//  YTableHeaderView.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/8.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YTableHeaderView.h"

@interface YTableHeaderView ()

@property (weak, nonatomic) IBOutlet UIView *bgView;


@end

@implementation YTableHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIView *view = [[NSBundle mainBundle] loadNibNamed:@"YTableHeaderView" owner:self options:nil].firstObject;
        view.frame = self.bounds;
        [self addSubview:view];
        __weak typeof(self) wself = self;
        [self.bgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
            if (wself.tapAction) {
                wself.tapAction();
            }
        }]];
    }
    return self;
}

@end
