//
//  YBottomButton.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/12.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YBottomButton.h"

@interface YBottomButton ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation YBottomButton

+ (instancetype)bottonWith:(NSString *)title imageName:(NSString *)imageName tag:(NSInteger)tag {
    YBottomButton *btn = [[self alloc] init];
    btn.userInteractionEnabled = YES;
    CGFloat width = kScreenWidth/5;
    btn.frame = CGRectMake(tag * width, 0, width, 54);
    btn.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, btn.height/2, width, btn.height/2)];
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    btn.titleLabel.font = [UIFont systemFontOfSize:13];
    btn.titleLabel.textColor = YRGBColor(180, 180, 180);
    btn.titleLabel.text = title;
    
    UIImage *img = [UIImage imageNamed:imageName];
    btn.imageView = [[UIImageView alloc] initWithImage:img];
    btn.imageView.center = CGPointMake(width/2, (btn.height-img.size.height)/2);

    btn.backgroundColor = YRGBColor(40, 40, 40);
    btn.tag = 200 + tag;
    [btn addSubview:btn.imageView];
    [btn addSubview:btn.titleLabel];
    [btn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:btn action:@selector(buttonAction)]];
    return btn;
}

//- (void)setHighlighted:(BOOL)highlighted {
//    [super setHighlighted:highlighted];
//    if (highlighted) {
//        self.backgroundColor = YRGBColor(20, 20, 20);
//    } else {
//        self.backgroundColor = YRGBColor(40, 40, 40);
//    }
//}
    
- (void)buttonAction {
    NSLog(@"%s  %zi",__func__,self.tag);
    if (self.tapAction) {
        self.tapAction(self.tag);
    }
}

- (UIImage *) imageWith:(UIImage *)image TintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    [tintColor setFill];//填充颜⾊色
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    //设置绘画透明混合模式和透明度
    [image drawInRect:bounds blendMode:blendMode alpha:1.0f];
    if (blendMode == kCGBlendModeOverlay) {
        //保留透明度信息
        [image drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    }
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tintedImage;
}


@end
