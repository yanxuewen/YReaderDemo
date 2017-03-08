//
//  YReaderView.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/13.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YReaderView.h"

@interface YReaderView ()

@end

@implementation YReaderView

- (void)setContentFrame:(CTFrameRef)contentFrame {
    if (_contentFrame) {
        CFRelease(_contentFrame);
    }
    _contentFrame = contentFrame;
    [self setNeedsDisplay];
}

-(void)dealloc {
    if (_contentFrame) {
        CFRelease(_contentFrame);
    }
}

- (void)setContent:(NSAttributedString *)content {
    _content = content;
    CTFramesetterRef setterRef = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)content);
    CGPathRef pathRef = CGPathCreateWithRect(self.bounds, NULL);
    CTFrameRef frameRef = CTFramesetterCreateFrame(setterRef, CFRangeMake(0, 0), pathRef, NULL);
    if (setterRef) {
        CFRelease(setterRef);
    }
    if (pathRef) {
        CFRelease(pathRef);
    }
    self.contentFrame = frameRef;
}

- (void)updateSpeakString:(NSString *)string {
    if (!string) {
        return;
    }
    NSRange range = [_sourceAttributedString.string rangeOfString:string];
    if ([string hasPrefix:@"\t"]) {
        range.location ++;
        range.length --;
    }
    if (range.location != NSNotFound && range.length > 0) {
        
        NSMutableAttributedString *attStr = _sourceAttributedString.mutableCopy;
        [attStr addAttributes:@{NSBackgroundColorAttributeName:YRGBColor(158, 191, 163)} range:range];
        self.content = attStr;
    }
}

- (void)drawRect:(CGRect)rect {
    if (!_contentFrame) {
        return;
    }
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    CGContextTranslateCTM(ctx, 0, self.bounds.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    CTFrameDraw(_contentFrame, ctx);
    
}

@end
