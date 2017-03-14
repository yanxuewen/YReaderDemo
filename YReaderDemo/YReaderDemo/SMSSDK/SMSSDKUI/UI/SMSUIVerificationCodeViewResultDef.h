//
//  SMSUIVViewResultDef.h
//  SMSUI
//
//  Created by 李愿生 on 15/8/13.
//  Copyright (c) 2015年 liys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SMS_SDK/SMSSDK.h>


enum SMSUIResponseState
{
    SMSUIResponseStateSuccess = 0,
    SMSUIResponseStateFail = 1,
    SMSUIResponseStateCancel = 2,
};

/**
 * @from  v1.0.0
 * @brief 通讯录好友获取回调
 * @param error 当error为空表示未触发该操作
 * @param state 展示界面的返回状态
 * @param 返回的好友信息数组
 */
typedef void (^SMSUIVerificationCodeResultHandler)(enum SMSUIResponseState state,NSString *phoneNumber,NSString *zone,NSError *error);


/**
 * @from  v1.0.0
 * @brief 通讯录好友获取回调
 * @param error 当error为空时表示成功
 */
typedef void (^SMSUIOnCloseResultHandler)();

/**
 * @brief 设置最近新好友回调
 * @param 0:代表成功 1:代表失败
 * @param 代表最近新好友条数
 */
typedef void (^SMSShowNewFriendsCountBlock)(enum SMSResponseState state,int latelyFriendsCount);

