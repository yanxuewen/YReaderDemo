//
//  YBookUpdateModel.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/18.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YBookUpdateModel.h"
#import "YDateModel.h"

@implementation YBookUpdateModel

+ (NSArray *)modelPropertyBlacklist {
    return @[@"updated"];
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSString *time = dic[@"updated"];
    if (![time isKindOfClass:[NSString class]]) return NO;
    _updated = [[YDateModel shareDateModel] dateWithCustomDateFormat:time];
    return YES;
}

@end
