//
//  SMSUIShowActionViewController.m
//  SMSUI
//
//  Created by 李愿生 on 15/8/12.
//  Copyright (c) 2015年 liys. All rights reserved.
//

#import "SMSUIVerificationCodeViewController.h"

#import "RegViewController.h"
#import "SMSUIVerificationCodeViewResultDef.h"
#import <SMS_SDK/SMSSDK.h>

@interface SMSUIVerificationCodeViewController ()
{
    
    SMSGetCodeMethod _getCodeMethod;
    
}

@property (nonatomic, copy) SMSUIVerificationCodeResultHandler verificationCodeResult;

@property (nonatomic, strong) UIWindow *actionViewWindow;

@property (nonatomic, strong) SMSUIVerificationCodeViewController *selfVerificationCodeViewController;

@end

@implementation SMSUIVerificationCodeViewController

- (instancetype)initVerificationCodeViewWithMethod:(SMSGetCodeMethod)whichMethod
{
    
    if (self = [super init])
    {
        _getCodeMethod = whichMethod;
        _registerViewBySMS = [[RegViewController alloc] init];
        
        _registerViewBySMS.getCodeMethod = _getCodeMethod;
    }
    return self;
}

- (void)show
{
//    self.selfVerificationCodeViewController = self;
//    
//    self.actionViewWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    
//    UIViewController *rootVC = [[UIViewController alloc] init];
//    
//    self.actionViewWindow.rootViewController = rootVC;
//    
//    self.actionViewWindow.userInteractionEnabled = YES;
//    
//    [self.actionViewWindow makeKeyAndVisible];
    
    __weak RegViewController *registerViewBySMS = _registerViewBySMS;
    __weak SMSUIVerificationCodeViewController *verificationCodeVC = self;
    
    
    _registerViewBySMS.verificationCodeResult = ^(enum SMSUIResponseState state,NSString *phoneNumber,NSString *zone,NSError *error){
        __strong SMSUIVerificationCodeViewController *strongSelf = self;
        [registerViewBySMS.navigationController dismissViewControllerAnimated:YES completion:^{
            
            if (state == SMSUIResponseStateCancel)
            {
                
                if (strongSelf.verificationCodeResult)
                {
                    
                    strongSelf.verificationCodeResult (SMSUIResponseStateCancel ,phoneNumber,zone,error);
                    
                }
                
            }
            else if (state == SMSUIResponseStateSuccess )
            {
                
                if (strongSelf.verificationCodeResult)
                {
                    
                    strongSelf.verificationCodeResult (SMSUIResponseStateSuccess,phoneNumber,zone,error);
                }
                
                
            }
            else if (state == SMSUIResponseStateFail )
            {
                
                if (strongSelf.verificationCodeResult)
                {
                    strongSelf.verificationCodeResult (SMSUIResponseStateFail,phoneNumber,zone,error);
                }
            }
            
            strongSelf.registerViewBySMS.verificationCodeResult = nil;
            strongSelf.registerViewBySMS = nil;
            strongSelf.verificationCodeResult = nil;
        }];
        
        
    };
    
}

- (void)dismiss;
{
    self.selfVerificationCodeViewController = nil;
    
    [self.actionViewWindow.rootViewController dismissViewControllerAnimated:YES completion:^{
        
        self.actionViewWindow = nil;
        
    }];
}

- (void)onVerificationCodeViewReslut:(SMSUIVerificationCodeResultHandler)result
{
    self.verificationCodeResult = result;
}


@end
