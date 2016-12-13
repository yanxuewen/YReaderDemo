//
//  YBookDetailModel.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/10.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YBookDetailModel.h"
#import "YDateModel.h"

@implementation YBookDetailModel

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
    YBookDetailModel *model = (YBookDetailModel *)object;
    if ([self.idField isEqualToString:model.idField]) {
        return YES;
    }
    return NO;
}

- (NSString *)getBookWordCount {
    NSString *unit = nil;
    double number = 0;
    if (self.wordCount > 10000) {
        number = self.wordCount / 10000;
        unit = @"万";
    } else if (self.wordCount > 1000) {
        number = self.wordCount / 1000;
        unit = @"万";
    } else {
        number = self.wordCount;
        unit = @"";
    }
    return [NSString stringWithFormat:@"%.f %@字",number,unit];
}

@end
