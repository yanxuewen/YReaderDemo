//
//  SMSUIGetContactFriendsViewController.h
//  SMSUI
//
//  Created by 李愿生 on 15/8/27.
//  Copyright (c) 2015年 liys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SMSUIVerificationCodeViewResultDef.h"
#import <SMS_SDK/SMSSDK.h>

@interface SMSUIContactsFriendsViewController : NSObject

@property (nonatomic, strong) SMSUIContactsFriendsViewController *selfContactsFriendsController;

/**
 *  初始化通讯录好友界面
 *
 *  @return 通讯录好友界面控制器对象
 */
- (instancetype)initWithNewFriends:(NSMutableArray *)newFriends newFriendsCountBlock:(SMSShowNewFriendsCountBlock)newFriendsCountBlock;


/**
 *  展示通讯录好友界面
 *
 */
- (void)show;

/**
 *
 *  移除获取验证码界面
 */
- (void)dismiss;


/**
 *
 *  通讯录好友界面回调结果处理
 * @param result 回调结果
 */
- (void)onCloseResult:(SMSUIOnCloseResultHandler)closeHandler;




@end
