//
//  CustomCell.m
//  Custom Cell
//
//  Created by Yang on 12-6-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CustomCell.h"

@implementation CustomCell

@synthesize imageView;
@synthesize nameLabel;
@synthesize image;
@synthesize name;
@synthesize nameDesc;

- (void)btnClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(CustomCellBtnClick:)])
    {
        [self.delegate CustomCellBtnClick:self];
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(15, 5, 50, 50);
        [self.contentView addSubview:imageView];
        
        nameLabel=[[UILabel alloc] init];
        nameLabel.frame = CGRectMake(73, 19, 98, 20);
        nameLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
        [self.contentView addSubview:nameLabel];
        
        _nameDescLabel = [[UILabel alloc] init];
        _nameDescLabel.frame = CGRectMake(73, 40, 150, 15);
        _nameDescLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
        [self.contentView addSubview:_nameDescLabel];
        
        _btn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
        [_btn setTitle:@"邀请" forState:UIControlStateNormal];
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"SMSSDKUI" ofType:@"bundle"];
        NSBundle *bundle = [[NSBundle alloc] initWithPath:filePath];
        NSString *imageString = [bundle pathForResource:@"button2" ofType:@"png"];
        
        [_btn setBackgroundImage:[[UIImage alloc] initWithContentsOfFile:imageString] forState:UIControlStateNormal];
        [_btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.contentView addSubview:_btn];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _btn.frame = CGRectMake(self.frame.size.width -80, 15, 65, 30);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setImage:(UIImage *)img
{
    if (![img isEqual:image])
    {
        image = [img copy];
        self.imageView.image = image;
    }
}

-(void)setName:(NSString *)n
{
    if (![n isEqualToString:name])
    {
        name = [n copy];
        self.nameLabel.text = name;
    }
}

-(void)setNameDesc:(NSString *)nDesc
{
    if (![nDesc isEqualToString:nameDesc])
    {
        nameDesc = [nDesc copy];
        self.nameDescLabel.text = nameDesc;
    }
}

@end
