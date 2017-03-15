//
//  RegViewController.m
//  SMS_SDKDemo
//
//  Created by 掌淘科技 on 14-6-4.
//  Copyright (c) 2014年 掌淘科技. All rights reserved.
//

#import "RegViewController.h"
#import "VerifyViewController.h"
#import "SectionsViewController.h"
#import <SMS_SDK/SMSSDK.h>
#import <SMS_SDK/Extend/SMSSDKCountryAndAreaCode.h>
#import <SMS_SDK/Extend/SMSSDK+ExtexdMethods.h>
#import <MOBFoundation/MOBFoundation.h>
#import "YJLocalCountryData.h"


@interface RegViewController ()
{
    SMSSDKCountryAndAreaCode* _data2;
    
    NSString* _defaultCode;
    NSString* _defaultCountryName;
    NSBundle *_bundle;
    
}

@property (nonatomic, strong) NSMutableArray* areaArray;
@property (nonatomic, strong) UIButton *nextButton;


@end

@implementation RegViewController

-(void)clickLeftButton
{
    if (self.verificationCodeResult) {
        
        self.verificationCodeResult (SMSUIResponseStateCancel,nil,nil, nil);
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    //不允许用户输入 国家码
    if (textField ==_areaCodeField)
    {
        [self.view endEditing:YES];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

#pragma mark - SecondViewControllerDelegate的方法
- (void)setSecondData:(SMSSDKCountryAndAreaCode *)data
{
    _data2 = data;
    NSLog(@"the area data：%@,%@", data.areaCode,data.countryName);
    
    self.areaCodeField.text = [NSString stringWithFormat:@"+%@",data.areaCode];
    [self.tableView reloadData];
}

-(void)nextStep
{
    int compareResult = 0;
    for (int i = 0; i < _areaArray.count; i++)
    {
        NSDictionary* dict1 = [_areaArray objectAtIndex:i];
        NSString* code1 = [dict1 valueForKey:@"zone"];
        if ([code1 isEqualToString:[_areaCodeField.text stringByReplacingOccurrencesOfString:@"+" withString:@""]])
        {
            compareResult = 1;
            NSString* rule1 = [dict1 valueForKey:@"rule"];
            NSPredicate* pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",rule1];
            BOOL isMatch = [pred evaluateWithObject:self.telField.text];
            if (!isMatch)
            {
                //手机号码不正确
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"notice", @"Localizable", _bundle, nil)
                                                                message:NSLocalizedStringFromTableInBundle(@"errorphonenumber", @"Localizable", _bundle, nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"sure", @"Localizable", _bundle, nil)
                                                      otherButtonTitles:nil, nil];
                [alert show];
                return;
            }
            break;
        }
    }
    
    if (!compareResult)
    {
        if (self.telField.text.length != 11)
        {
            //手机号码不正确
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"notice", @"Localizable", _bundle, nil)
                                                            message:NSLocalizedStringFromTableInBundle(@"errorphonenumber", @"Localizable", _bundle, nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"sure", @"Localizable", _bundle, nil)
                                                  otherButtonTitles:nil, nil];
            [alert show];
            
            return;
        }
    }
    
    NSString* str = [NSString stringWithFormat:@"%@:%@ %@",NSLocalizedStringFromTableInBundle(@"willsendthecodeto", @"Localizable", _bundle, nil),self.areaCodeField.text,self.telField.text];

    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"surephonenumber", @"Localizable", _bundle, nil)
                                                    message:str delegate:self
                                          cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"cancel", @"Localizable", _bundle, nil)
                                          otherButtonTitles:NSLocalizedStringFromTableInBundle(@"sure", @"Localizable", _bundle, nil), nil];
    [alert show];

    NSString *imageString = [_bundle pathForResource:@"button1" ofType:@"png"];
    
    self.nextButton.enabled = NO;
    [self.nextButton setBackgroundImage:[[UIImage alloc] initWithContentsOfFile:imageString] forState:UIControlStateNormal];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (1 == buttonIndex)
    {
        NSString* str2 = [self.areaCodeField.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
        
        [self getVerificationCodeByMethod:self.getCodeMethod phoneNumber:self.telField.text zone:str2];
    }
    else
    {
        NSString *imageString = [_bundle pathForResource:@"button4" ofType:@"png"];
        self.nextButton.enabled = YES;
        [self.nextButton setBackgroundImage:[[UIImage alloc] initWithContentsOfFile:imageString] forState:UIControlStateNormal];
    }
}

- (void)getVerificationCodeByMethod:(SMSGetCodeMethod)getCodeMethod phoneNumber:(NSString *)phoneNumber zone:(NSString *)zone
{
    __weak RegViewController *regViewController = self;
    
    if (getCodeMethod == SMSGetCodeMethodSMS) {
        
        [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:phoneNumber
                                       zone:zone
                           customIdentifier:nil
                                     result:^(NSError *error)
         {
             
             [regViewController getVerificationCodeResultHandler:phoneNumber zone:zone error:error];
             
         }];
        
    }
    else if (getCodeMethod == SMSGetCodeMethodVoice)
    {
        [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodVoice phoneNumber:phoneNumber
                                       zone:zone
                           customIdentifier:nil
                                     result:^(NSError *error)
         {
             [regViewController getVerificationCodeResultHandler:phoneNumber zone:zone error:error];
             
         }];
    }
}

- (void)getVerificationCodeResultHandler:(NSString *)phoneNumber zone:(NSString *)zone error:(NSError *)error
{
    NSString *imageString = [_bundle pathForResource:@"button4" ofType:@"png"];
    self.nextButton.enabled = YES;
    [self.nextButton setBackgroundImage:[[UIImage alloc] initWithContentsOfFile:imageString] forState:UIControlStateNormal];
    
    if (!error)
    {
        if (self.getCodeMethod == SMSGetCodeMethodSMS)
        {
             NSLog(@"文本短信验证码发送成功");
        }
        else
        {
             NSLog(@"语音短信验证码发送成功");
        }
        
        VerifyViewController* verify = [[VerifyViewController alloc] init];
        
        verify.getCodeMethod = self.getCodeMethod;
        
        //发送验证码成功，进行回调
        verify.verificationCodeResult = ^(enum SMSUIResponseState state,NSString *phoneNumber,NSString *zone,NSError *error){
            
            if (!error) {
                
                if (state == SMSUIResponseStateSuccess) {
                    
                    self.verificationCodeResult (SMSUIResponseStateSuccess,phoneNumber,zone,error);
                }
                
            }
        };
        
        [verify setPhone:phoneNumber AndAreaCode:zone];
        
        [self presentViewController:verify animated:YES completion:^{
            
            
        }];
    }
    else
    {
        
        NSString *messageStr = [NSString stringWithFormat:@"%zidescription",error.code];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"codesenderrtitle", @"Localizable", _bundle, nil)
                                                        message:NSLocalizedStringFromTableInBundle(messageStr, @"Localizable", _bundle, nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"sure", @"Localizable", _bundle, nil)
                                              otherButtonTitles:nil, nil];
        [alert show];
        
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
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0,0 + statusBarHeight, self.view.frame.size.width, 44)];
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@""];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(clickLeftButton)];
    self.navigationItem.leftBarButtonItem = leftButton;
    NSLocalizedStringFromTableInBundle(@"register", @"Localizable", bundle, nil);
    self.navigationItem.title = @"注册";//NSLocalizedStringFromTableInBundle(@"register", @"Localizable", bundle, nil);
    [navigationBar pushNavigationItem:navigationItem animated:NO];
    [self.view addSubview:navigationBar];
   
    //
    UILabel* label = [[UILabel alloc] init];
    label.frame = CGRectMake(15, 56 + statusBarHeight, self.view.frame.size.width - 30, 50);
    label.text = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"labelnotice", @"Localizable", _bundle, nil)];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Helvetica" size:16];
    label.textColor = [UIColor darkGrayColor];
    [self.view addSubview:label];
    
    UITableView* tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 106 + statusBarHeight, self.view.frame.size.width - 20, 45) style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    
    //区域码
    UILabel *seperateLineUp = [[UILabel alloc] initWithFrame:CGRectMake(10, 154 + statusBarHeight, self.view.frame.size.width - 20, 1)];
    seperateLineUp.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:seperateLineUp];
    
    UITextField* areaCodeField = [[UITextField alloc] init];
    areaCodeField.frame = CGRectMake(10, 155 + statusBarHeight, (self.view.frame.size.width - 30)/4, 40 + statusBarHeight/4);
    areaCodeField.text = [NSString stringWithFormat:@"+86"];
    areaCodeField.textAlignment = NSTextAlignmentCenter;
    areaCodeField.font = [UIFont fontWithName:@"Helvetica" size:18];
    areaCodeField.keyboardType = UIKeyboardTypePhonePad;
    [self.view addSubview:areaCodeField];
    
    UILabel *verticalLine = [[UILabel alloc] initWithFrame:CGRectMake(areaCodeField.frame.origin.x + areaCodeField.frame.size.width + 1, seperateLineUp.frame.origin.y +1, 1, areaCodeField.frame.size.height)];
    verticalLine.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:verticalLine];
    
    //
    UITextField* telField = [[UITextField alloc] init];
    telField.frame = CGRectMake(20 + (self.view.frame.size.width - 30)/4, 155 + statusBarHeight,(self.view.frame.size.width - 30)*3/4 , 40 + statusBarHeight/4);
    telField.placeholder = NSLocalizedStringFromTableInBundle(@"telfield", @"Localizable", _bundle, nil);
    telField.keyboardType = UIKeyboardTypePhonePad;
    telField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:telField];
    
    UILabel *seperateLineDown = [[UILabel alloc] initWithFrame:CGRectMake(seperateLineUp.frame.origin.x, seperateLineUp.frame.origin.y + areaCodeField.frame.size.height + 1, seperateLineUp.frame.size.width, 1)];
    seperateLineDown.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:seperateLineDown];
    
    //
    UIButton* nextBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [nextBtn setTitle:NSLocalizedStringFromTableInBundle(@"nextbtn", @"Localizable", bundle, nil) forState:UIControlStateNormal];
    
    NSString *imageString = [bundle pathForResource:@"button4" ofType:@"png"];
    
    [nextBtn setBackgroundImage:[[UIImage alloc] initWithContentsOfFile:imageString] forState:UIControlStateNormal];
    nextBtn.frame = CGRectMake(10, 220 + statusBarHeight, self.view.frame.size.width - 20, 42);
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(nextStep) forControlEvents:UIControlEventTouchUpInside];
    self.nextButton = nextBtn;
    [self.view addSubview:nextBtn];
    
    _telField = telField;
    _areaCodeField = areaCodeField;
    _tableView = tableView;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.areaCodeField.delegate = self;
    self.telField.delegate = self;
    
    //设置本地区号
    [self setTheLocalAreaCode];
    
    NSString *saveTimeString = [[NSUserDefaults standardUserDefaults] objectForKey:@"saveDate"];
    
    NSDateComponents *dateComponents = nil;
    
    if (saveTimeString.length != 0)
    {
        dateComponents = [YJLocalCountryData compareTwoDays:saveTimeString];
    }
    
    if (dateComponents.day >= 1 || saveTimeString.length == 0)
    { //day = 0 ,代表今天，day = 1  代表昨天  day >= 1 表示至少过了一天  saveTimeString.length == 0表示从未进行过缓存
        __weak RegViewController *regViewController = self;
        //获取支持的地区列表
        [SMSSDK getCountryZone:^(NSError *error, NSArray *zonesArray) {
            
            if (!error)
            {
                NSLog(@"get the area code sucessfully");
                //区号数据
                if ([zonesArray isKindOfClass:[NSArray class]])
                {
                    regViewController.areaArray = [NSMutableArray arrayWithArray:zonesArray];
                }
                //获取到国家列表数据后对进行缓存
                [[MOBFDataService sharedInstance] setCacheData:regViewController.areaArray forKey:@"countryCodeArray" domain:nil];
                //设置缓存时间
                NSDate *saveDate = [NSDate date];
                [[NSUserDefaults standardUserDefaults] setObject:[MOBFDate stringByDate:saveDate withFormat:@"yyyy-MM-dd"] forKey:@"saveDate"];
                
//                NSLog(@"_areaArray_%@",regViewController.areaArray);
            }
            else
            {
                NSLog(@"failed to get the area code _%@______error_%@",[error.userInfo objectForKey:@"getZone"],error);
            }
        }];
    }
    else
    {
        _areaArray = [[MOBFDataService sharedInstance] cacheDataForKey:@"countryCodeArray" domain:nil];
    }
}


-(void)setTheLocalAreaCode
{
    NSLocale *locale = [NSLocale currentLocale];
    
    NSDictionary *dictCodes = [NSDictionary dictionaryWithObjectsAndKeys:@"972", @"IL",
                               @"93", @"AF", @"355", @"AL", @"213", @"DZ", @"1", @"AS",
                               @"376", @"AD", @"244", @"AO", @"1", @"AI", @"1", @"AG",
                               @"54", @"AR", @"374", @"AM", @"297", @"AW", @"61", @"AU",
                               @"43", @"AT", @"994", @"AZ", @"1", @"BS", @"973", @"BH",
                               @"880", @"BD", @"1", @"BB", @"375", @"BY", @"32", @"BE",
                               @"501", @"BZ", @"229", @"BJ", @"1", @"BM", @"975", @"BT",
                               @"387", @"BA", @"267", @"BW", @"55", @"BR", @"246", @"IO",
                               @"359", @"BG", @"226", @"BF", @"257", @"BI", @"855", @"KH",
                               @"237", @"CM", @"1", @"CA", @"238", @"CV", @"345", @"KY",
                               @"236", @"CF", @"235", @"TD", @"56", @"CL", @"86", @"CN",
                               @"61", @"CX", @"57", @"CO", @"269", @"KM", @"242", @"CG",
                               @"682", @"CK", @"506", @"CR", @"385", @"HR", @"53", @"CU",
                               @"537", @"CY", @"420", @"CZ", @"45", @"DK", @"253", @"DJ",
                               @"1", @"DM", @"1", @"DO", @"593", @"EC", @"20", @"EG",
                               @"503", @"SV", @"240", @"GQ", @"291", @"ER", @"372", @"EE",
                               @"251", @"ET", @"298", @"FO", @"679", @"FJ", @"358", @"FI",
                               @"33", @"FR", @"594", @"GF", @"689", @"PF", @"241", @"GA",
                               @"220", @"GM", @"995", @"GE", @"49", @"DE", @"233", @"GH",
                               @"350", @"GI", @"30", @"GR", @"299", @"GL", @"1", @"GD",
                               @"590", @"GP", @"1", @"GU", @"502", @"GT", @"224", @"GN",
                               @"245", @"GW", @"595", @"GY", @"509", @"HT", @"504", @"HN",
                               @"36", @"HU", @"354", @"IS", @"91", @"IN", @"62", @"ID",
                               @"964", @"IQ", @"353", @"IE", @"972", @"IL", @"39", @"IT",
                               @"1", @"JM", @"81", @"JP", @"962", @"JO", @"77", @"KZ",
                               @"254", @"KE", @"686", @"KI", @"965", @"KW", @"996", @"KG",
                               @"371", @"LV", @"961", @"LB", @"266", @"LS", @"231", @"LR",
                               @"423", @"LI", @"370", @"LT", @"352", @"LU", @"261", @"MG",
                               @"265", @"MW", @"60", @"MY", @"960", @"MV", @"223", @"ML",
                               @"356", @"MT", @"692", @"MH", @"596", @"MQ", @"222", @"MR",
                               @"230", @"MU", @"262", @"YT", @"52", @"MX", @"377", @"MC",
                               @"976", @"MN", @"382", @"ME", @"1", @"MS", @"212", @"MA",
                               @"95", @"MM", @"264", @"NA", @"674", @"NR", @"977", @"NP",
                               @"31", @"NL", @"599", @"AN", @"687", @"NC", @"64", @"NZ",
                               @"505", @"NI", @"227", @"NE", @"234", @"NG", @"683", @"NU",
                               @"672", @"NF", @"1", @"MP", @"47", @"NO", @"968", @"OM",
                               @"92", @"PK", @"680", @"PW", @"507", @"PA", @"675", @"PG",
                               @"595", @"PY", @"51", @"PE", @"63", @"PH", @"48", @"PL",
                               @"351", @"PT", @"1", @"PR", @"974", @"QA", @"40", @"RO",
                               @"250", @"RW", @"685", @"WS", @"378", @"SM", @"966", @"SA",
                               @"221", @"SN", @"381", @"RS", @"248", @"SC", @"232", @"SL",
                               @"65", @"SG", @"421", @"SK", @"386", @"SI", @"677", @"SB",
                               @"27", @"ZA", @"500", @"GS", @"34", @"ES", @"94", @"LK",
                               @"249", @"SD", @"597", @"SR", @"268", @"SZ", @"46", @"SE",
                               @"41", @"CH", @"992", @"TJ", @"66", @"TH", @"228", @"TG",
                               @"690", @"TK", @"676", @"TO", @"1", @"TT", @"216", @"TN",
                               @"90", @"TR", @"993", @"TM", @"1", @"TC", @"688", @"TV",
                               @"256", @"UG", @"380", @"UA", @"971", @"AE", @"44", @"GB",
                               @"1", @"US", @"598", @"UY", @"998", @"UZ", @"678", @"VU",
                               @"681", @"WF", @"967", @"YE", @"260", @"ZM", @"263", @"ZW",
                               @"591", @"BO", @"673", @"BN", @"61", @"CC", @"243", @"CD",
                               @"225", @"CI", @"500", @"FK", @"44", @"GG", @"379", @"VA",
                               @"852", @"HK", @"98", @"IR", @"44", @"IM", @"44", @"JE",
                               @"850", @"KP", @"82", @"KR", @"856", @"LA", @"218", @"LY",
                               @"853", @"MO", @"389", @"MK", @"691", @"FM", @"373", @"MD",
                               @"258", @"MZ", @"970", @"PS", @"872", @"PN", @"262", @"RE",
                               @"7", @"RU", @"590", @"BL", @"290", @"SH", @"1", @"KN",
                               @"1", @"LC", @"590", @"MF", @"508", @"PM", @"1", @"VC",
                               @"239", @"ST", @"252", @"SO", @"47", @"SJ", @"963", @"SY",
                               @"886", @"TW", @"255", @"TZ", @"670", @"TL", @"58", @"VE",
                               @"84", @"VN", @"1", @"VG", @"1", @"VI", nil];
    
    NSString* tt = [locale objectForKey:NSLocaleCountryCode];
    NSString* defaultCode = [dictCodes objectForKey:tt];
    _areaCodeField.text = [NSString stringWithFormat:@"+%@",defaultCode];
    
    NSString* defaultCountryName = [locale displayNameForKey:NSLocaleCountryCode value:tt];
    _defaultCode = defaultCode;
    _defaultCountryName = defaultCountryName;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] ;
    }
    cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"countrylable", @"Localizable", _bundle, nil);
    cell.textLabel.textColor = [UIColor darkGrayColor];
    
    if (_data2)
    {
        cell.detailTextLabel.text = _data2.countryName;
    }
    else
    {
        cell.detailTextLabel.text = _defaultCountryName;
    }
    cell.detailTextLabel.textColor = [UIColor blackColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UIView *tempView = [[UIView alloc] init];
    [cell setBackgroundView:tempView];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SectionsViewController* country2 = [[SectionsViewController alloc] init];
    country2.delegate = self;
    
    //读取本地countryCode
    if (_areaArray.count == 0)
    {
        NSMutableArray *dataArray = [YJLocalCountryData localCountryDataArray];
        
        _areaArray = dataArray;
    }
    
    [country2 setAreaArray:_areaArray];
    [self presentViewController:country2 animated:YES completion:^{
        
    }];
}

@end
