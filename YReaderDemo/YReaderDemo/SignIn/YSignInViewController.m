//
//  YSignInViewController.m
//  YReaderDemo
//
//  Created by yanxuewen on 2017/3/6.
//  Copyright © 2017年 yxw. All rights reserved.
//

#import "YSignInViewController.h"
#import "ViewController.h"

@interface YSignInViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *accountTextF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextF;
@property (weak, nonatomic) IBOutlet UIButton *signInBtn;

@end

@implementation YSignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = true;
    self.signInBtn.enabled = false;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:_accountTextF] && ![_passwordTextF.text isNotBlank]) {
        [_passwordTextF becomeFirstResponder];
    }
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)signInBtnAction:(id)sender {
    if ([_accountTextF.text.lowercaseString isEqualToString:@"test20171020"] && [_passwordTextF.text isEqualToString:@"abc12345678"]) {
        ViewController *viewC = [[ViewController alloc] init];
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        [window setRootViewController:[[UINavigationController alloc] initWithRootViewController:viewC]];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"kYHasLogin"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [self.view endEditing:true];
        [YProgressHUD showErrorHUDWith:@"请输入正确的密码和账号!"];
    }
}

- (void)textFieldTextDidChange:(NSNotification *)noti {
    if ([_accountTextF.text isNotBlank] && [_passwordTextF.text isNotBlank]) {
        _signInBtn.enabled = true;
    } else {
        _signInBtn.enabled = false;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
