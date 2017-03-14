//
//  MKNumberBadgeView.m
//  MKNumberBadgeView
//
// Copyright 2009 Michael F. Kamprath
// michael@claireware.com
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// 
//  origin from michael, change by Huang Yuzhen
//  Created by Huang Yuzhen on 11-5-18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kPlaceUR = 0,
    kPlaceUL,
} HYZBadgePlace;


@interface SMS_HYZBadgeView : UIView {
    NSString * _value;
    UIFont * _font;
	UIColor * _fillColor;
	UIColor * _strokeColor;
	UIColor * _textColor;
	NSUInteger _pad;
    BOOL _shine;
	NSTextAlignment _alignment;
    HYZBadgePlace _place;
}

// The current value displayed in the badge. Updating the value will update the view's display
@property (copy,nonatomic) NSString *value;

@property (assign,nonatomic) BOOL shine;

// The font to be used for drawing the numbers. NOTE: not all fonts are created equal for this purpose.
// Only "system fonts" should be used.
@property (retain,nonatomic) UIFont* font;

// The color used for the background of the badge.
@property (retain,nonatomic) UIColor* fillColor;

// The color to be used for drawing the stroke around the badge.
@property (retain,nonatomic) UIColor* strokeColor;

// The color to be used for drawing the badge's numbers.
@property (retain,nonatomic) UIColor* textColor;

// How the badge image hould be aligned horizontally in the view. 
@property (assign,nonatomic) NSTextAlignment alignment;

// Returns the visual size of the badge for the current value. Not the same hing as the size of the view's bounds.
// The badge view bounds should be wider than space needed to draw the badge.
@property (readonly,nonatomic) CGSize badgeSize;

// The number of pixels between the number inside the badge and the stroke around the badge. This value 
// is approximate, as the font geometry might effectively slightly increase or decrease the apparent pad.
@property (nonatomic) NSUInteger pad;

@property (nonatomic) HYZBadgePlace place;

- (void)setNumber:(NSUInteger)inValue;

@end


@interface UIView(HYZBadgeView)
@property(nonatomic, readonly) SMS_HYZBadgeView *badge;
@end