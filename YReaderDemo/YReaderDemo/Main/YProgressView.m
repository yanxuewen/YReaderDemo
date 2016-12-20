//
//  YProgressView.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/20.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YProgressView.h"

#define kYFillColor YRGBColor(0, 120, 251)

@interface YProgressView ()

@property (strong, nonatomic) CADisplayLink *displayLink;
@property (assign, nonatomic) double startAngle;

@end

@implementation YProgressView

- (void)setLoadStatus:(YDownloadStatus)loadStatus {
    if (_loadStatus == loadStatus) {
        return;
    }
    _loadStatus = loadStatus;
    if (_loadStatus == YDownloadStatusWait) {
        if (self.displayLink) {
            [self.displayLink invalidate];
            self.displayLink = nil;
        }
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgressView)];
        self.displayLink.frameInterval = 2;
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    } else if (_loadStatus != YDownloadStatusNone) {
        if (self.displayLink) {
            [self.displayLink invalidate];
            self.displayLink = nil;
        }
        
    }
}

- (void)setProgress:(double)progress {
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    if (_loadStatus == YDownloadStatusNone) {
        return;
    } else if (_loadStatus == YDownloadStatusWait) {
        [self drawWaitingArc];
    } else {
        [self drawProgressArc];
    }
    
}


- (void)updateProgressView {
    _startAngle += 1 /(60.0 / _displayLink.frameInterval) / 0.8 * 2*M_PI;
    if (_startAngle > 2*M_PI) {
        _startAngle -= 2*M_PI;
    }
    [self setNeedsDisplay];
}

- (void)drawWaitingArc  {
    static double endAngle = 320 / 360.0 * 2*M_PI;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, kYFillColor.CGColor);
    
    CGContextAddArc(context, self.width/2, self.height/2, self.width/2-1, _startAngle, _startAngle+endAngle, false);
    CGContextStrokePath(context);
}

- (void)drawProgressArc {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, kYFillColor.CGColor);
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextAddArc(context, self.width/2, self.height/2, self.width/2-1, 0, 2*M_PI, false);
    CGContextStrokePath(context);
    
    CGContextSetFillColorWithColor(context, kYFillColor.CGColor);
    CGRect centerRect = CGRectMake(self.width/2 - 4, self.height/2 - 4, 8, 8);
    CGContextFillRect(context, centerRect);
    
    CGContextSetLineWidth(context, 2);
    CGContextAddArc(context, self.width/2, self.height/2, self.width/2-2, -M_PI_2,_progress * 2.0*M_PI - M_PI_2, false);
    CGContextStrokePath(context);
    
}

@end
