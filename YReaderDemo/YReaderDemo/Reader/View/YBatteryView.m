//
//  YElectricView.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/12.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YBatteryView.h"

@implementation YBatteryView


- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1);
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextSetStrokeColorWithColor(context, _fillColor.CGColor);
    CGRect newR = CGRectMake(0.5, 0.5, rect.size.width - 4, rect.size.height-1);
    CGContextStrokeRect(context, newR);
    
    CGContextSetFillColorWithColor(context, _fillColor.CGColor);
    newR = CGRectMake(rect.size.width - 4 + 0.5, (rect.size.height - 4) / 2,  4, 4);
    CGContextFillRect(context, newR);
    
    newR = CGRectMake(2, 2, (rect.size.width - 7)*[self getCurrentBatteryLevel], rect.size.height-4);
    CGContextFillRect(context, newR);
    
}

- (double)getCurrentBatteryLevel {
    UIApplication *app = [UIApplication sharedApplication];
    if (app.applicationState == UIApplicationStateActive || app.applicationState==UIApplicationStateInactive) {
        Ivar ivar = class_getInstanceVariable([app class],"_statusBar");
        id status  = object_getIvar(app, ivar);
        for (id aview in [status subviews]) {
            int batteryLevel = 0;
            for (id bview in [aview subviews]) {
                if ([NSStringFromClass([bview class]) caseInsensitiveCompare:@"UIStatusBarBatteryItemView"] == NSOrderedSame) {
                
                    Ivar ivar=  class_getInstanceVariable([bview class],"_capacity");
                    if (ivar) {
                        batteryLevel = ((int (*)(id, Ivar))object_getIvar)(bview, ivar);
//                        NSLog(@"电池电量:%d %%",batteryLevel);
                        if (batteryLevel > 0 && batteryLevel <= 100) {
                            return batteryLevel/100.0;
                        }
                    }
                }
            }
        }
    }
    
    return 0;
}

@end
