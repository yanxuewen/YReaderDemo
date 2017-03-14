//
//  VerifyViewController.m
//  SMS_SDKDemo
//
//  Created by admin on 14-6-4.
//  Copyright (c) 2014年 admin. All rights reserved.
//

#import "VerifyViewController.h"
#import <AddressBook/AddressBook.h>
#import "YJLocalCountryData.h"
#import <SMS_SDK/SMSSDK.h>
#import <SMS_SDK/Extend/SMSSDKUserInfo.h>
#import <SMS_SDK/Extend/SMSSDKAddressBook.h>


#define TRY_AGAIN_GETSMSCODE_ALERTVIEW_TAG    10
#define CLICKLEFTBUTTON_ALERTVIEW_TAG         11
#define COMMITCODE_SUCCES_ALERTVIEW_TAG       12
#define TRY_AGAIN_GETVOICECODE_ALERTVIEW_TAG  13

@interface VerifyViewController ()
{
    NSString* _phone;
    NSString* _areaCode;
    NSError *verifyError;
    NSBundle *_bundle;

}

@property (nonatomic, strong) NSTimer* timer2;

@property (nonatomic, strong) NSTimer* timer1;

@end

static int count = 0;

@implementation VerifyViewController

-(void)clickLeftButton
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"notice", @"Localizable", _bundle, nil)
                                                  message:NSLocalizedStringFromTableInBundle(@"codedelaymsg", @"Localizable", _bundle, nil)
                                                 delegate:self
                                        cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"back", @"Localizable", _bundle, nil)
                                        otherButtonTitles:NSLocalizedStringFromTableInBundle(@"wait", @"Localizable", _bundle, nil), nil];

    alert.tag = CLICKLEFTBUTTON_ALERTVIEW_TAG;
    [alert show];    
}

-(void)setPhone:(NSString*)phone AndAreaCode:(NSString*)areaCode
{
    _phone = phone;
    _areaCode = areaCode;
}

-(void)submit
{
    //验证号码
    [self.view endEditing:YES];
    
    if(self.verifyCodeField.text.length != 4)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"notice", @"Localizable", _bundle, nil)
                                                      message:NSLocalizedStringFromTableInBundle(@"verifycodeformaterror", @"Localizable", _bundle, nil)
                                                     delegate:self
                                            cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"sure", @"Localizable", _bundle, nil)
                                            otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        [SMSSDK commitVerificationCode:self.verifyCodeField.text phoneNumber:_phone zone:_areaCode result:^(SMSSDKUserInfo *userInfo, NSError *error) {
            
            {
                if (!error)
                {
                    userInfo.nickname = @"David";
                    userInfo.uid = @"010";
                    userInfo.avatar = @"www.mob.com";
                    NSLog(@"验证成功");
                    verifyError = error;
                    NSString* str = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"verifycoderightmsg", @"Localizable", _bundle, nil)];
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"verifycoderighttitle", @"Localizable", _bundle, nil)
                                                                    message:str
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"sure", @"Localizable", _bundle, nil)
                                                          otherButtonTitles:nil, nil];
                    [alert show];
                    alert.tag = COMMITCODE_SUCCES_ALERTVIEW_TAG;
                }
                else
                {
                    NSLog(@"验证失败");
                    NSString *messageStr = [NSString stringWithFormat:@"%zidescription",error.code];
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"verifycodeerrortitle", @"Localizable", _bundle, nil)
                                                                    message:NSLocalizedStringFromTableInBundle(messageStr, @"Localizable", _bundle, nil)
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"sure", @"Localizable", _bundle, nil)
                                                          otherButtonTitles:nil, nil];
                    [alert show];
                }
            }
            
        }];
    }
}


-(void)CannotGetSMS
{
    NSString* str = [NSString stringWithFormat:@"%@:%@",NSLocalizedStringFromTableInBundle(@"cannotgetsmsmsg", @"Localizable", _bundle, nil) ,_phone];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"surephonenumber", @"Localizable", _bundle, nil) message:str delegate:self cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"cancel", @"Localizable", _bundle, nil) otherButtonTitles:NSLocalizedStringFromTableInBundle(@"sure", @"Localizable", _bundle, nil), nil];
    alert.tag = TRY_AGAIN_GETSMSCODE_ALERTVIEW_TAG;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    __weak VerifyViewController *verifyViewController = self;
    
    switch (alertView.tag)
    {
        case TRY_AGAIN_GETSMSCODE_ALERTVIEW_TAG:
        {
            switch (buttonIndex)
            {
                case 1:
                {
                    NSLog(@"重发验证码");
                    [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:_phone zone:_areaCode customIdentifier:nil result:^(NSError *error) {
                        if (!error)
                        {
                            NSLog(@"获取验证码成功");
                        }
                        else
                        {
                            NSString *messageStr = [NSString stringWithFormat:@"%zidescription",error.code];
                            UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"codesenderrtitle", @"Localizable", _bundle, nil)
                                                                          message:NSLocalizedStringFromTableInBundle(messageStr, @"Localizable", _bundle, nil)
                                                                         delegate:self
                                                                cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"sure", @"Localizable", _bundle, nil)
                                                                otherButtonTitles:nil, nil];
                            [alert show];
                        }
                    }];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case CLICKLEFTBUTTON_ALERTVIEW_TAG:
        {
            switch (buttonIndex)
            {
                case 0:
                {
                    [verifyViewController dismissViewControllerAnimated:YES completion:^{
                        [verifyViewController.timer2 invalidate];
                        [verifyViewController.timer1 invalidate];
                    }];
   
                    break;
                }
                default:
                    break;
            }
            break;
        }
            
        case COMMITCODE_SUCCES_ALERTVIEW_TAG:
        {
            if (self.verificationCodeResult)
            {
                self.verificationCodeResult (SMSUIResponseStateSuccess,_phone,_areaCode,verifyError);
                //解决等待时间乱跳的问题
                [verifyViewController.timer2 invalidate];
                [verifyViewController.timer1 invalidate];
            }
            break;
        }
        case TRY_AGAIN_GETVOICECODE_ALERTVIEW_TAG:
        {
            switch (buttonIndex)
            {
                case 0:
                {
                    [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodVoice
                                            phoneNumber:_phone
                                                   zone:_areaCode
                                       customIdentifier:nil
                                                 result:^(NSError *error)
                     {
                         if (error)
                         {
                             NSString *messageStr = [NSString stringWithFormat:@"%zidescription",error.code];
                             UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"codesenderrtitle", @"Localizable", _bundle, nil)
                                                                             message:NSLocalizedStringFromTableInBundle(messageStr, @"Localizable", _bundle, nil)
                                                                            delegate:self
                                                                   cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"sure", @"Localizable", _bundle, nil)
                                                                   otherButtonTitles:nil, nil];
                             [alert show];
                         }
                     }];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat statusBarHeight = 0;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
    {
        statusBarHeight = 20;
    }
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"SMSSDKUI" ofType:@"bundle"];
    NSBundle *bundle = [[NSBundle alloc] initWithPath:filePath];
    _bundle = bundle;
    //创建一个导航栏
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0,0+statusBarHeight, self.view.frame.size.width, 44)];
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@""];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"back", @"Localizable", bundle, nil)
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(clickLeftButton)];
    
    //设置导航栏内容
    [navigationItem setTitle:NSLocalizedStringFromTableInBundle(@"verifycode", @"Localizable", bundle, nil)];
    [navigationBar pushNavigationItem:navigationItem animated:NO];
    [navigationItem setLeftBarButtonItem:leftButton];
    [self.view addSubview:navigationBar];
    
    UILabel* label = [[UILabel alloc] init];
    label.frame = CGRectMake(15, 53+statusBarHeight, self.view.frame.size.width - 30, 21);
    label.text = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"verifylabel", @"Localizable", bundle, nil)];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Helvetica" size:17];
    [self.view addSubview:label];
    
    UILabel* telLabel = [[UILabel alloc] init];
    telLabel.frame=CGRectMake(15, 82+statusBarHeight, self.view.frame.size.width - 30, 21);
    telLabel.textAlignment = NSTextAlignmentCenter;
    telLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
    [self.view addSubview:telLabel];
    telLabel.text = [NSString stringWithFormat:@"+%@ %@",_areaCode,_phone];
    
    UILabel *seperaterLineUp = [[UILabel alloc] initWithFrame:CGRectMake(10, 110 + statusBarHeight, self.view.frame.size.width - 20, 1)];
    seperaterLineUp.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:seperaterLineUp];
    
    UILabel *verifyCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 111 + statusBarHeight, 80, 46)];
    verifyCodeLabel.text = NSLocalizedStringFromTableInBundle(@"Code", @"Localizable", bundle, nil);
    [self.view addSubview:verifyCodeLabel];
    
    UILabel *verticalLine = [[UILabel alloc] initWithFrame:CGRectMake(verifyCodeLabel.frame.origin.x - 10 + verifyCodeLabel.frame.size.width + 1, verifyCodeLabel.frame.origin.y, 1, verifyCodeLabel.frame.size.height)];
    verticalLine.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:verticalLine];
    
    _verifyCodeField = [[UITextField alloc] init];
    _verifyCodeField.frame = CGRectMake(verticalLine.frame.origin.x, 111 + statusBarHeight, self.view.frame.size.width - verifyCodeLabel.frame.size.width - 20, 46);
    _verifyCodeField.textAlignment = NSTextAlignmentCenter;
    _verifyCodeField.placeholder = NSLocalizedStringFromTableInBundle(@"verifycode", @"Localizable", bundle, nil);
    _verifyCodeField.font = [UIFont fontWithName:@"Helvetica" size:18];
    _verifyCodeField.keyboardType = UIKeyboardTypePhonePad;
    _verifyCodeField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:_verifyCodeField];
    
    UILabel *seperaterLineDown = [[UILabel alloc] initWithFrame:CGRectMake(seperaterLineUp.frame.origin.x, _verifyCodeField.frame.origin.y + _verifyCodeField.frame.size.height + 1, seperaterLineUp.frame.size.width, 1)];
    seperaterLineDown.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:seperaterLineDown];
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.frame = CGRectMake(15, 169 + statusBarHeight, self.view.frame.size.width - 30, 40);
    _timeLabel.numberOfLines = 0;
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    _timeLabel.text = NSLocalizedStringFromTableInBundle(@"timelabel", @"Localizable", bundle, nil);
    [self.view addSubview:_timeLabel];
    
    _repeatSMSBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _repeatSMSBtn.frame = CGRectMake(15, 169 + statusBarHeight, self.view.frame.size.width - 30, 30);
    [_repeatSMSBtn setTitle:NSLocalizedStringFromTableInBundle(@"repeatsms", @"Localizable", bundle, nil) forState:UIControlStateNormal];
    [_repeatSMSBtn addTarget:self action:@selector(CannotGetSMS) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_repeatSMSBtn];
    
    UIButton * submitBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [submitBtn setTitle:NSLocalizedStringFromTableInBundle(@"submit", @"Localizable", bundle, nil) forState:UIControlStateNormal];
    NSString *icon = [NSString stringWithFormat:@"SMSSDKUI.bundle/button4.png"];

    NSString *imageString = [bundle pathForResource:@"button4" ofType:@"png"];

    [submitBtn setBackgroundImage:[[UIImage alloc] initWithContentsOfFile:imageString] forState:UIControlStateNormal];
    submitBtn.frame = CGRectMake(15, 220 + statusBarHeight, self.view.frame.size.width - 30, 42);
    [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitBtn addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submitBtn];
    
    _voiceCallMsgLabel = [[UILabel alloc] init];
    _voiceCallMsgLabel.frame = CGRectMake(15, 268 + statusBarHeight, self.view.frame.size.width - 30, 25);
    _voiceCallMsgLabel.textAlignment = NSTextAlignmentCenter;
    _voiceCallMsgLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    [_voiceCallMsgLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
    _voiceCallMsgLabel.text = NSLocalizedStringFromTableInBundle(@"voiceCallMsgLabel", @"Localizable", bundle, nil);
    [self.view addSubview:_voiceCallMsgLabel];
    _voiceCallMsgLabel.hidden = YES;
    
    _voiceCallButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_voiceCallButton setTitle:NSLocalizedStringFromTableInBundle(@"try voice call", @"Localizable", bundle, nil) forState:UIControlStateNormal];
    [_voiceCallButton setBackgroundImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    _voiceCallButton.frame = CGRectMake(15, 300 + statusBarHeight, self.view.frame.size.width - 30, 42);
    [_voiceCallButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_voiceCallButton addTarget:self action:@selector(tryVoiceCall) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_voiceCallButton];
    _voiceCallButton.hidden = YES;

    self.repeatSMSBtn.hidden = YES;
    
    [_timer2 invalidate];
    [_timer1 invalidate];
    
    count = 0;
    
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:60
                                           target:self
                                         selector:@selector(showRepeatButton)
                                         userInfo:nil
                                          repeats:YES];
    
    self.timeLabel.textColor = [UIColor lightGrayColor];
    NSTimer* timer2 = [NSTimer scheduledTimerWithTimeInterval:1
                                                    target:self
                                                  selector:@selector(updateTime)
                                                  userInfo:nil
                                                   repeats:YES];
    _timer1 = timer;
    _timer2 = timer2;
    
    [YJLocalCountryData showMessag:NSLocalizedStringFromTableInBundle(@"sendingin", @"Localizable", bundle, nil) toView:self.view];
    
}

-(void)tryVoiceCall
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"verificationByVoiceCallConfirm", @"Localizable", _bundle, nil)
                                                  message:[NSString stringWithFormat:@"%@: +%@ %@",NSLocalizedStringFromTableInBundle(@"willsendthecodeto", @"Localizable", _bundle, nil),_areaCode, _phone]
                                                 delegate:self
                                        cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"sure", @"Localizable", _bundle, nil)
                                        otherButtonTitles:NSLocalizedStringFromTableInBundle(@"cancel", @"Localizable", _bundle, nil), nil];
    
    alert.tag = TRY_AGAIN_GETVOICECODE_ALERTVIEW_TAG;
    [alert show];
}


-(void)updateTime
{
    
    count ++;
    if (count >= 60)
    {
        [_timer2 invalidate];
        return;
    }
    //NSLog(@"更新时间");
    
    self.timeLabel.text = [NSString stringWithFormat:@"%@%i%@",NSLocalizedStringFromTableInBundle(@"timelablemsg", @"Localizable", _bundle, nil),60 - count, NSLocalizedStringFromTableInBundle(@"second", @"Localizable", _bundle, nil)];
    
    if (count == 30)
    {
        if (self.getCodeMethod == SMSGetCodeMethodSMS) {
            
            if (_voiceCallMsgLabel.hidden)
            {
                _voiceCallMsgLabel.hidden = NO;
            }
            
            if (_voiceCallButton.hidden)
            {
                _voiceCallButton.hidden = NO;
            }
        }
        
    }
}

-(void)showRepeatButton{
    self.timeLabel.hidden = YES;
    self.repeatSMSBtn.hidden = NO;
    
    [_timer1 invalidate];
    return;
}

@end
