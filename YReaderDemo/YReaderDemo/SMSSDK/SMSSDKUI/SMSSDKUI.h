//
//  SMSSDKUI.h
//  SMSSDKUI
//
//  Created by 李愿生 on 15/12/30.
//  Copyright © 2015年 zhangtaokeji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SMS_SDK/Extend/SMSSDKUserInfo.h>
#import <SMS_SDK/Extend/SMSSDKResultHanderDef.h>
#import "SMSUIVerificationCodeViewController.h"
#import "SMSUIContactsFriendsViewController.h"


@interface SMSSDKUI : NSObject

/**
 *  显示操作界面
 *  @param whichMethod 获取验证码方法 (The method of getting verificationCode )
 *  @param result      展示操作界面结果回调(Results of the showView )
 */

+ (SMSUIVerificationCodeViewController *)showVerificationCodeViewWithMetohd:(SMSGetCodeMethod)whichMethod result:(SMSUIVerificationCodeResultHandler)result;



/**
 * @brief 向服务端请求获取通讯录好友信息(Get the data of address book which save in the server)
 * @param result 请求结果回调(Results of the request)
 */

+ (SMSUIContactsFriendsViewController *)showGetContactsFriendsViewWithNewFriends:(NSMutableArray *)newFriends newFriendClock:(SMSShowNewFriendsCountBlock)newFriendsCountBlock  result:(SMSUIOnCloseResultHandler)result;


@end
