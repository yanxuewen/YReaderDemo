//
//  YBookSummaryModel.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/12.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YBookSummaryModel.h"
#import "YDateModel.h"

@implementation YBookSummaryModel

+ (NSArray *)modelPropertyBlacklist {
    return @[@"updated"];
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSString *time = dic[@"updated"];
    if (![time isKindOfClass:[NSString class]]) return NO;
    _updated = [[YDateModel shareDateModel] dateWithCustomDateFormat:time];
    return YES;
}

- (BOOL)isEqual:(id)object {
    if (!object || ![object isKindOfClass:[self class]]) {
        return NO;
    }
    YBookSummaryModel *model = (YBookSummaryModel *)object;
    if ([self.idField isEqualToString:model.idField]) {
        return YES;
    }
    return NO;
}

@end
