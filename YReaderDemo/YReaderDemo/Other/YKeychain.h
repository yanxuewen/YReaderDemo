//
//  YKeychain.h
//  YKeychainDemo
//
//  Created by Adsmart on 16/6/12.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YKeychain : NSObject
NS_ASSUME_NONNULL_BEGIN

+ (BOOL)setValue:(id)value forKey:(NSString *)key;

+ (BOOL)setValue:(id)value forKey:(NSString *)key forAccessGroup:(nullable NSString *)group;


+ (id)valueForKey:(NSString *)key;

+ (id)valueForKey:(NSString *)key forAccessGroup:(nullable NSString *)group;

+ (BOOL)deleteValueForKey:(NSString *)key;

+ (BOOL)deleteValueForKey:(NSString *)key forAccessGroup:(nullable NSString *)group;

+ (NSString *)getBundleSeedIdentifier;

@end
NS_ASSUME_NONNULL_END