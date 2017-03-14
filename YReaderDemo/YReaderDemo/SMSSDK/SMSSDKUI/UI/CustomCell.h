//
//  CustomCell.h
//  Custom Cell
//
//  Created by Yang on 12-6-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomCellDelegate;

@interface CustomCell : UITableViewCell

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *nameDescLabel;
@property (strong, nonatomic) UIButton *btn;
@property (copy, nonatomic) UIImage *image;

@property (copy, nonatomic) NSString *name;
@property (copy,nonatomic) NSString* nameDesc;
@property (nonatomic, assign) int index;
@property (nonatomic,assign) int section;
@property (nonatomic, assign) id<CustomCellDelegate> delegate;

- (void)btnClick;

@end

@protocol CustomCellDelegate <NSObject>
- (void)CustomCellBtnClick:(CustomCell *)cell;
@end
