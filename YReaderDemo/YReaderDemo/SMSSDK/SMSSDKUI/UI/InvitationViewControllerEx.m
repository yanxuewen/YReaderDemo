//
//  InvitationViewControllerEx.m
//  SMS_SDKDemo
//
//  Created by 掌淘科技 on 14-7-15.
//  Copyright (c) 2014年 掌淘科技. All rights reserved.
//

#import "InvitationViewControllerEx.h"
#import <MessageUI/MessageUI.h>
#import <SMS_SDK/SMSSDK.h>

@interface InvitationViewControllerEx ()<MFMessageComposeViewControllerDelegate>
{
    NSString* _name;
    NSString* _phone;
    NSString* _phone2;
    
    NSBundle *_bundle;
}

@property (nonatomic ,strong) UIWindow* window;

@end

@implementation InvitationViewControllerEx

-(void)clickLeftButton
{
    [self dismissViewControllerAnimated:YES completion:^{
        ;
    }];
}

-(void)setData:(NSString *)name
{
    _name = name;
}

-(void)setPhone:(NSString *)phone AndPhone2:(NSString*)phone2
{
    _phone = phone;
    _phone2 = phone2;
}

-(void)sendInvite
{
    //发送短信
    if ([_phone2 length] > 0)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"notice", @"Localizable", _bundle, nil)
                                                        message:NSLocalizedStringFromTableInBundle(@"choosephonenumber", @"Localizable", _bundle, nil)
                                                       delegate:self
                                              cancelButtonTitle:_phone
                                              otherButtonTitles:_phone2, nil];
        [alert show];
    }
    else
    {
        [self sendSMS:_phone ? _phone : @"" message:NSLocalizedStringFromTableInBundle(@"smsmessage", @"Localizable", _bundle, nil)];
    }
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (1 == buttonIndex)
    {
        [self sendSMS:_phone2 ? _phone2 : _phone message:NSLocalizedStringFromTableInBundle(@"smsmessage", @"Localizable", _bundle, nil)];
        
    }
    else if (0 == buttonIndex)
    {
        [self sendSMS:_phone ? _phone : @"" message:NSLocalizedStringFromTableInBundle(@"smsmessage", @"Localizable", _bundle, nil)];
    }
}


- (void)sendSMS:(NSString *)phoneNumber message:(NSString *)message
{
    Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
    if (messageClass != nil)
    {
        if ([messageClass canSendText])
        {
            [self _displaySMSComposerSheet:phoneNumber AndMessage:message];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"notice", @"Localizable", _bundle, nil)
                                                            message:NSLocalizedStringFromTableInBundle(@"deviceFoundation", @"Localizable", _bundle, nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"close", @"Localizable", _bundle, nil)
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTableInBundle(@"notice", @"Localizable", _bundle, nil)
                                                       message:NSLocalizedStringFromTableInBundle(@"versionNotice", @"Localizable", _bundle, nil)
                                                      delegate:nil
                                             cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"close", @"Localizable", _bundle, nil)
                                             otherButtonTitles:nil];
        [alert show];
    }
}


#pragma mark - 短信代理相关方法
/**
 *  发送短信状态 代理函数
 */
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
    switch (result)
    {
        case MessageComposeResultCancelled:
//            YJLog(@"发送取消");
            break;
        case MessageComposeResultSent:
//            YJLog(@"发送成功");
            break;
        case MessageComposeResultFailed:
//            YJLog(@"发送失败");
            break;
        default:
//            YJLog(@"其它");
            break;
    }
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:^{
        self.window.hidden=YES;
    }];
}


/**
 *  显示短信窗口和信息
 */
-(void)_displaySMSComposerSheet:(NSString*)tel AndMessage:(NSString*)msg
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.windowLevel = UIWindowLevelNormal;
    self.window.hidden = NO;
    
    UIViewController *rootViewController = [[UIViewController alloc] init];
    self.window.rootViewController = rootViewController;
    
    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
    picker.messageComposeDelegate = self;
    
    NSArray *array = [NSArray arrayWithObject:tel];
    picker.recipients = array;
    picker.body = msg;
    [self.window.rootViewController presentViewController:picker animated:YES completion:^{
        
    }];
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = _name;
    cell.imageView.image = [UIImage imageNamed:@"2.png"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@:%@ %@",NSLocalizedStringFromTableInBundle(@"phonecode", @"Localizable", _bundle, nil),_phone ? _phone : @"", _phone2 ? _phone2 : @"2"];
    return cell;
}

#pragma mark TableViewDelegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"SMSSDKUI" ofType:@"bundle"];
    NSBundle *bundle = [[NSBundle alloc] initWithPath:filePath];
    _bundle = bundle;
    
    CGFloat statusBarHeight = 0;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
    {
        statusBarHeight = 20;
    }
    //创建一个导航栏
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0,0 + statusBarHeight, self.view.frame.size.width, 44)];
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@""];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"back",@"Localizable", bundle, nil)
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(clickLeftButton)];
    //把导航栏集合添加入导航栏中，设置动画关闭
    [navigationBar pushNavigationItem:navigationItem animated:NO];
    [navigationItem setLeftBarButtonItem:leftButton];
    [self.view addSubview:navigationBar];
    
    UITableView* tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44 + statusBarHeight, self.view.frame.size.width, 80) style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:NSLocalizedStringFromTableInBundle(@"sendinvite", @"Localizable", bundle, nil) forState:UIControlStateNormal];
    
    NSString *imageString = [bundle pathForResource:@"button4" ofType:@"png"];
    
    [btn setBackgroundImage:[[UIImage alloc] initWithContentsOfFile:imageString] forState:UIControlStateNormal];
    btn.frame = CGRectMake(15, 198 + statusBarHeight, self.view.frame.size.width - 30, 42);
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(sendInvite) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UILabel* label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, 146 + statusBarHeight, self.view.frame.size.width, 27);
    
    label.text = [NSString stringWithFormat:@"%@%@",_name,NSLocalizedStringFromTableInBundle(@"notjoined", @"Localizable", bundle, nil)];
    
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Helvetica" size:13];
    [self.view addSubview:label];

}
@end
