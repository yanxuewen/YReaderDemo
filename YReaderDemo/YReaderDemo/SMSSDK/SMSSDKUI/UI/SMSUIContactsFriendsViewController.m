//
//  SMSUIGetContactFriendsViewController.m
//  SMSUI
//
//  Created by 李愿生 on 15/8/27.
//  Copyright (c) 2015年 liys. All rights reserved.
//

#import "SMSUIContactsFriendsViewController.h"
#import "SectionsViewControllerFriends.h"
#import <SMS_SDK/SMSSDK.h>
#import <SMS_SDK/Extend/SMSSDK+AddressBookMethods.h>

@interface SMSUIContactsFriendsViewController ()
{
     NSMutableArray *_newFriends;
    
}

@property (nonatomic, copy) SMSUIOnCloseResultHandler  onCloseResultHandler;

@property (nonatomic, copy) SMSShowNewFriendsCountBlock newFriendsCountBlock;

@property (nonatomic, strong) UIWindow *contactsFriendsWindow;


@end

@implementation SMSUIContactsFriendsViewController

- (instancetype)initWithNewFriends:(NSMutableArray *)newFriends newFriendsCountBlock:(SMSShowNewFriendsCountBlock)newFriendsCountBlock
{
    if (self = [super init]) {
     
        self.newFriendsCountBlock = newFriendsCountBlock;
        
        _newFriends = newFriends;
        
    }
    
    return self;
}


- (void)show
{
    self.selfContactsFriendsController = self;
    
    self.contactsFriendsWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    UIViewController *rootVC = [[UIViewController alloc] init];
    
    self.contactsFriendsWindow.rootViewController = rootVC;
    
    self.contactsFriendsWindow.userInteractionEnabled = YES;
    
    [self.contactsFriendsWindow makeKeyAndVisible];
    
    __weak SMSUIContactsFriendsViewController *contactsFriendsViewController = self;
    
    SectionsViewControllerFriends *contactsListVC = [[SectionsViewControllerFriends alloc] init];
    
    [contactsListVC setMyData:_newFriends];
    
    [contactsListVC setMyBlock:self.newFriendsCountBlock];
    
    contactsListVC.onCloseResultHandler = ^(){
        
        [contactsFriendsViewController dismiss];
        
    };
    
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:contactsListVC];
    
    [self.contactsFriendsWindow.rootViewController presentViewController:navc animated:YES completion:^{
        
    }];
    
}

- (void)dismiss
{
    
    [self.contactsFriendsWindow.rootViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    self.selfContactsFriendsController = nil;
    self.contactsFriendsWindow = nil;
}


- (void)onCloseResult:(SMSUIOnCloseResultHandler)closeHandler
{
    
    self.onCloseResultHandler = closeHandler;
    
}

@end
