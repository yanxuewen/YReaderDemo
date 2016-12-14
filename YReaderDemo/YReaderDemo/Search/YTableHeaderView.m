//
//  YTableHeaderView.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/8.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YTableHeaderView.h"

@interface YTableHeaderView ()
@property (weak, nonatomic) IBOutlet UIButton *rightButton;

@end

@implementation YTableHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIView *view = [[NSBundle mainBundle] loadNibNamed:@"YTableHeaderView" owner:self options:nil].firstObject;
        view.frame = self.bounds;
        [self addSubview:view];
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    [self.rightButton setImage:image forState:UIControlStateNormal];
}

- (void)setRightTitle:(NSString *)rightTitle {
    _rightTitle = rightTitle;
    if (rightTitle) {
        rightTitle = [rightTitle stringByAppendingString:@"   "];
        self.rightButton.hidden = NO;
        [self.rightButton setTitle:rightTitle forState:UIControlStateNormal];
    } else {
        self.rightButton.hidden = YES;
    }
    
}

- (IBAction)handleButton:(id)sender {
    if (self.tapAction) {
        self.tapAction();
    }
}

@end
