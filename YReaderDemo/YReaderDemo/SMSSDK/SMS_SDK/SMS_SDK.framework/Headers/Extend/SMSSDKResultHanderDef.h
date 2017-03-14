//
//  SMS_SDKResultHanderDef.h
//  SMS_SDKDemo
//
//  Created by 掌淘科技 on 14-7-11.
//  Copyright (c) 2014年 掌淘科技. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SMSSDKUserInfo;
///#begin zh-cn
/**
 *	@brief	错误代码，如果为调用API出错则应该参考API错误码对照表。错误码对照表如下：
 错误码	错误描述	                         备注
 252    发送短信条数超过限制                发送短信条数超过规则限制
 253    无权限进行此操作                   无权限进行此操作
 254    无权限发送验证码                   无权限发送验证码
 255    无权限发送国内验证码                无权限发送国内验证码
 256    无权限发送港澳台验证码              无权限发送港澳台验证码
 257    无权限发送国外验证码                无权限发送国外验证码
 258    操作过于频繁                       操作过于频繁
 259    未知错误                          未知错误
 260    未知错误                          未知错误
 261    数据错误                          数据未知错误
 262    请检查网络授权                     请检查网络授权设置
 263    数据错误                          数据未知错误
 264    数据错误                          duid获取错误
 400	无效请求	                         客户端请求不能被识别。
 406    AppKey错误                        请求的AppKey不存在。
 408	无效参数                          无效的请求参数
 456	手机号码为空	                     提交的手机号或者区号为空
 457	手机号码格式错误	                 提交的手机号格式不正确(包括手机的区号)
 458	appkey在黑名单中	                 appkey在发送很名单中
 459	无appKey的控制数据	                 获取appKey控制发送短信的数据失败
 460	无权限发送短信	                     没有打开客户端发送短信的开关
 461	不支持该地区发送短信                没有开通当前地区发送短信的功能
 462	每分钟发送次数超限	                 每分钟发送短息的次数超出限制
 463	手机号码每天发送次数超限	             手机号码每天发送短信的次数超出限制
 464	每台手机每天发送次数超限	             每台手机每天发送短信的次数超限
 465	号码在App中每天发送短信的次数超限	     手机号码在App中每天发送短信的数量超限
 466	校验的验证码为空	                 提交的校验验证码为空
 467    校验验证码请求频繁                  5分钟内校验错误超过3次，验证码失效
 468    需要校验的验证码错误                用户提交的验证码错误
 470    账号余额不足                       账号短信余额不足
 472    客户端请求发送短信验证过于频繁        客户端请求发送短信验证过于频繁
 475    appKey的应用信息不存在              appKey的应用信息不存在
 476    当前appkey发送短信的数量超过限额     如果当前appkey对应的包名没有通过审核，每天次appkey+包名最多可以发送20条短信
 477    当前手机号发送短信的数量超过当天限额   当前手机号码在SMSSDK平台内每天最多可发送短信10条，包括客户端发送和WebApi发送
 478    当前手机号在当前应用内发送超过限额     当前手机号码在当前应用下12小时内最多可发送文本验证码5条
 479    SDK使用的公共库版本错误              当前SDK使用的公共库版本为非IDFA版本，需要更换为IDFA版本
 480    SDK没有提交AES-KEY                 客户端在获取令牌的接口中没有传递aesKey。
 500    服务器内部错误                     服务器程序报错
 */
///#end
///#begin en
/**
 *	@brief	Error code，If it is you call the API, you should see the error code table, if it is an HTTP error, this attribute indicates the HTTP error code.
 ErrorCode	 Error description                             Remarks
 252    Sending messages more than limit                   Sending messages more than limit
 253    No permission to do this                           No permission to do this
 254    No permission to get verificationcode              No permission to get verificationcode
 255    No permission to send domestic verificationcode    No permission to send domestic verificationcode
 256    No permission to send verificationcode from Hong Kong, Macao and Taiwan              No permission to send verificationcode from Hong Kong, Macao and Taiwan
 257    No permission verification code sent abroad                                          No permission verification code sent abroad
 258    Action is too frequent                             Action is too frequent
 259    Unknown error                                      Unknown error
 260    Unknown error                                      Unknown error
 261    Data is error                                      Data is error of the unknown reason
 262    Internet is error                                  The Internet connection appears to be offline
 263    Data is error                                      Data is error of the unknown reason";
 264    Data is error                                      Data is error of the unknown reason";
 400    Invalid request                                    The request could not be identified
 406    AppKey is error                                    The AppKey is not exist
 408    Invalid parameter                                  The parameters are invalid in the request
 456    Phone number is empty                              The submitted phone number or country code is empty
 457    Phone number is illegal                            The submitted phone number or country code is incorrect
 458    AppKey in the blacklist                            AppKey in the blacklist
 459    Unable to obtain data                              Unable to obtain data related to the appkey
 460    Permission denied                                  Please turn on the switch to sending text messages by clients
 461    Do not support the region to send text messages    Do not support the region to send text messages
 462    Sending messages limited per minute                Sending text message already hit its time limit
 463    Sending messages limited everyday                  Sending text message to the phone number already hit its limit
 464    Sending text message hits limit                    Sending text message to the device already hit its limit
 465    Sending text message hits limit                    Sending text message to the device already hit the app's limit
 466    The verification code is empty                     The submitted verification code is empty
 467    Too frequently                                     Check validation code too frequently
 468    Invalid validation code                            Invalid validation code
 470    Insufficient balance                               Insufficient balance
 472    Unable to obtain data                              Obtaining client platform information failed
 475    No application information of appkey exists        No application information of appkey exists
 476    The current appkey send text messages over limit
 477    The current phone number send messages over the limit
 478    The current phone number in the current application sends messages over the limit
 479    The MOBFoundation.framework's version is wrong, please use it with idfa
 480    SDK not submit aeskey in the interface of the access token
 500    Server Error                                       Server Error
 */
///#end

/**
 * @brief 返回状态。
 */
enum SMSResponseState
{
    SMSResponseStateSuccess = 0,
    SMSResponseStateFail = 1,
    SMSResponseStateCancel = 2
};


typedef enum SMSGetCodeMethod
{
    SMSGetCodeMethodSMS = 0,  //文本短信方式
    SMSGetCodeMethodVoice = 1 //语音方式
    
} SMSGetCodeMethod;

/**
 *  @brief 验证码获取回调
 *  @param error 当error为空时表示成功
 */
typedef void (^SMSGetCodeResultHandler) (NSError *error);

/**
 * @from  v2.0.7
 * @brief 验证码验证回调
 * @param userInfo 用来设置用户个人资料
 * @param error 当error为空时表示成功
 */
typedef void (^SMSCommitCodeResultHandler) (SMSSDKUserInfo *userInfo,NSError *error);

/**
 * @brief 验证码验证回调
 * @param 0:代表验证成功 1:代表验证失败
 */
typedef void (^SMSCommitVerifyCodeBlock)(enum SMSResponseState state);

/**
 * @from  v1.1.1
 * @brief 国家区号获取回调
 * @param error 当error为空时表示成功
 * @param 返回的区号数组
 */
typedef void (^SMSGetZoneResultHandler)(NSError *error,NSArray* zonesArray);

/**
 * @brief 国家区号获取回调
 * @param 0:代表获取成功 1:代表获取失败
 * @param 返回的区号数组
 */
typedef void (^SMSGetZoneBlock)(enum SMSResponseState state,NSArray* zonesArray);

/**
 * @from  v1.1.1
 * @brief 通讯录好友获取回调
 *
 * @param error 当error为空时表示成功
 * @param 返回的好友信息数组
 */
typedef void (^SMSGetAllContactFriendsResultHandler)(NSError *error,NSArray* friendsArray);


/**
 * @brief 通讯录好友获取回调
 * @param 0:代表获取成功 1:代表获取失败
 * @param 返回的好友信息数组
 */
typedef void (^SMSGetAppContactFriendsBlock)(enum SMSResponseState state,NSArray* friendsArray);


/**
 * @brief 提交用户信息回调
 * @from v1.1.1
 * @param error 当error为空时表示成功
 */
typedef void (^SMSSubmitUserInfoResultHandler) (NSError *error);

/**
 * @brief 提交用户信息回调
 * @param 0:代表获取成功 1:代表获取失败
 */
typedef void (^SMSSubmitUserInfoBlock) (enum SMSResponseState state);

/**
 * @brief 设置最近新好友回调
 * @param 0:代表成功 1:代表失败
 * @param 代表最近新好友条数
 */
typedef void (^SMSShowNewFriendsCountBlock)(enum SMSResponseState state,int latelyFriendsCount);



