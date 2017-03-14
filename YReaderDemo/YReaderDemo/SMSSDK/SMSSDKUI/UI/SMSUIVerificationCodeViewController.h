//
//  SMSUIShowActionViewController.h
//  SMSUI
//
//  Created by 李愿生 on 15/8/12.
//  Copyright (c) 2015年 liys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SMSUIVerificationCodeViewResultDef.h"
#import <SMS_SDK/SMSSDK.h>
@class RegViewController;

@interface SMSUIVerificationCodeViewController : NSObject

@property (strong, nonatomic) RegViewController *registerViewBySMS;
/**
 *  初始化操作界面
 *
 *  @return 操作界面控制器对象
 */
- (instancetype)initVerificationCodeViewWithMethod:(SMSGetCodeMethod)whichMethod;

/**
 *
 *  展示获取验证码界面
 */
- (void)show;

/**
 *
 *  移除获取验证码界面
 */
- (void)dismiss;

/**
 *
 *  验证码界面回调结果处理
 * @param result 回调结果
 */
- (void)onVerificationCodeViewReslut:(SMSUIVerificationCodeResultHandler)result;


@end
