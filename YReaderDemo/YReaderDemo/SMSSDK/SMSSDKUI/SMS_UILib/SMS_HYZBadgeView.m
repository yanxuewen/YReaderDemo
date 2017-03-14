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
//
//  Created by Huang Yuzhen on 11-5-18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "SMS_HYZBadgeView.h"


@implementation SMS_HYZBadgeView

@synthesize value=_value;
@synthesize shine=_shine;
@synthesize font=_font;
@synthesize fillColor=_fillColor;
@synthesize strokeColor=_strokeColor;
@synthesize textColor=_textColor;
@synthesize alignment=_alignment;
@dynamic badgeSize;
@synthesize pad=_pad;
@synthesize place=_place;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.opaque = NO;
        self.pad = 1;
        self.font = [UIFont boldSystemFontOfSize:14];
        self.shine = YES;
        self.alignment = NSTextAlignmentCenter;
        self.fillColor = [UIColor redColor];
        self.strokeColor = [UIColor whiteColor];
        self.textColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (CGPathRef)createBadgePathForTextSize:(CGSize)inSize
{
	const CGFloat kPi = 3.14159265;
	
	CGFloat arcRadius = ceil((inSize.height+self.pad)/2.0);
	
	CGFloat badgeWidthAdjustment = inSize.width - inSize.height/2.0;
	CGFloat badgeWidth = 2.0*arcRadius;
	
	if ( badgeWidthAdjustment > 0.0 )
	{
		badgeWidth += badgeWidthAdjustment;
	}
	else
	{
		badgeWidthAdjustment = 0;
	}
	
	CGMutablePathRef badgePath = CGPathCreateMutable();
	
	CGPathMoveToPoint( badgePath, NULL, arcRadius, 0 );
	CGPathAddArc( badgePath, NULL, arcRadius, arcRadius, arcRadius, 3.0 * kPi/2.0, kPi/2.0, YES);
	CGPathAddLineToPoint( badgePath, NULL, badgeWidth - arcRadius, 2.0 * arcRadius);
	CGPathAddArc( badgePath, NULL, badgeWidth - arcRadius, arcRadius, arcRadius, kPi/2.0, 3.0 * kPi/2.0, YES);
	CGPathAddLineToPoint( badgePath, NULL, arcRadius, 0 );
	
	return badgePath;
	
}


- (void)drawRect:(CGRect)rect 
{
	CGRect viewBounds = self.bounds;
	
	CGContextRef curContext = UIGraphicsGetCurrentContext();
	
	CGSize numberSize = [self.value sizeWithFont:self.font];
    
	CGPathRef badgePath = [self createBadgePathForTextSize:numberSize];
	
	CGRect badgeRect = CGPathGetBoundingBox(badgePath);
	
	badgeRect.origin.x = 0;
	badgeRect.origin.y = 0;
	badgeRect.size.width = ceil( badgeRect.size.width );
	badgeRect.size.height = ceil( badgeRect.size.height );
	
	
	CGContextSaveGState( curContext );
	CGContextSetLineWidth( curContext, 2.0 );
	CGContextSetStrokeColorWithColor(  curContext, self.strokeColor.CGColor  );
	CGContextSetFillColorWithColor( curContext, self.fillColor.CGColor );
    
	CGPoint ctm;
	
	switch (self.alignment) 
	{
		default:
		case NSTextAlignmentCenter:
			ctm = CGPointMake( round((viewBounds.size.width - badgeRect.size.width)/2), round((viewBounds.size.height - badgeRect.size.height)/2) );
			break;
		case NSTextAlignmentLeft:
			ctm = CGPointMake( 0, round((viewBounds.size.height - badgeRect.size.height)/2) );
			break;
		case NSTextAlignmentRight:
			ctm = CGPointMake( (viewBounds.size.width - badgeRect.size.width), round((viewBounds.size.height - badgeRect.size.height)/2) );
			break;
	}
	
	CGContextTranslateCTM( curContext, ctm.x, ctm.y);

	CGContextBeginPath( curContext );
	CGContextAddPath( curContext, badgePath );
	CGContextClosePath( curContext );
	CGContextDrawPath( curContext, kCGPathFillStroke );
    
	if (self.shine)
	{
		CGContextBeginPath( curContext );
		CGContextAddPath( curContext, badgePath );
		CGContextClosePath( curContext );
		CGContextClip(curContext);
		
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
		CGFloat shinyColorGradient[8] = {1, 1, 1, 0.8, 1, 1, 1, 0}; 
		CGFloat shinyLocationGradient[2] = {0, 1}; 
		CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, 
                                                                     shinyColorGradient, 
                                                                     shinyLocationGradient, 2);
		
		CGContextSaveGState(curContext); 
		CGContextBeginPath(curContext); 
		CGContextMoveToPoint(curContext, 0, 0); 
		
		CGFloat shineStartY = badgeRect.size.height*0.25;
		CGFloat shineStopY = shineStartY + badgeRect.size.height*0.4;
		
		CGContextAddLineToPoint(curContext, 0, shineStartY); 
		CGContextAddCurveToPoint(curContext, 0, shineStopY, 
                                 badgeRect.size.width, shineStopY, 
                                 badgeRect.size.width, shineStartY); 
		CGContextAddLineToPoint(curContext, badgeRect.size.width, 0); 
		CGContextClosePath(curContext); 
		CGContextClip(curContext); 
		CGContextDrawLinearGradient(curContext, gradient, 
									CGPointMake(badgeRect.size.width / 2.0, 0), 
									CGPointMake(badgeRect.size.width / 2.0, shineStopY), 
									kCGGradientDrawsBeforeStartLocation); 
		CGContextRestoreGState(curContext); 
		
		CGColorSpaceRelease(colorSpace); 
		CGGradientRelease(gradient); 
		
	}
	CGContextRestoreGState( curContext );
	CGPathRelease(badgePath);
	
	CGContextSaveGState( curContext );
	CGContextSetFillColorWithColor( curContext, self.textColor.CGColor );
    
	CGPoint textPt = CGPointMake( ctm.x + (badgeRect.size.width - numberSize.width)/2 , ctm.y + (badgeRect.size.height - numberSize.height)/2 );
	
	[self.value drawAtPoint:textPt withFont:self.font];
    
	CGContextRestoreGState( curContext );
    
}


#pragma mark -
- (void)setValue:(NSString *)value
{
    if ( ! [_value isEqualToString: value] ) {
        _value = [value copy];
        
        CGSize size = [self badgeSize];
        self.bounds = CGRectMake(0, 0, size.width+4, size.height+4);
        
        CGRect superviewFrame = self.superview.frame;
        if ( self.place == kPlaceUR ) {
            self.center = CGPointMake(superviewFrame.size.width, 0);
        }else if ( self.place == kPlaceUL) {
            self.center = CGPointMake(0, 0);
        }
        
        [self setNeedsDisplay];
    }
}

- (void)setNumber:(NSUInteger)inValue
{
    if( inValue == 0 ) {
        self.frame = CGRectZero;
        [self setNeedsLayout];
        return;
    }else {
        [self setValue:[NSString stringWithFormat:@"%zi", inValue]];
    }
}

- (CGSize)badgeSize
{	
	CGSize numberSize = [self.value sizeWithFont:self.font];
	
	CGPathRef badgePath = [self createBadgePathForTextSize:numberSize];
	
	CGRect badgeRect = CGPathGetBoundingBox(badgePath);
	
	badgeRect.origin.x = 0;
	badgeRect.origin.y = 0;
	badgeRect.size.width = ceil( badgeRect.size.width );
	badgeRect.size.height = ceil( badgeRect.size.height );
	
	CGPathRelease(badgePath);
	
	return badgeRect.size;
}

@end

#define HYZ_BADGE_TAG 8111
@implementation UIView(SMS_HYZBadgeView)

- (SMS_HYZBadgeView *)badge
{
    id exist = [self viewWithTag:HYZ_BADGE_TAG];
    if(exist) {
        if(![exist isKindOfClass:[SMS_HYZBadgeView class]]) {
            return nil;
        } else {
            return (SMS_HYZBadgeView *)exist;
        }
    }
    SMS_HYZBadgeView *badge = [[SMS_HYZBadgeView alloc]initWithFrame:CGRectZero];
    badge.tag = HYZ_BADGE_TAG;
    [self addSubview:badge];
    return badge;
}

@end


