//
//  YBookDetailModel.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/10.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YBookDetailModel.h"
#import "YDateModel.h"


@interface YBookDetailModel ()<NSCoding>

@end

@implementation YBookDetailModel

- (NSString *)description {
    return [NSString stringWithFormat:@"<YBookDetailModel: title:%@ author:%@ hasLoadCompletion:%zi loadStatus:%zi>",self.title,self.author,self.hasLoadCompletion,self.loadStatus];
}

+ (NSArray *)modelPropertyBlacklist {
    return @[@"updated",@"loadStatus",@"loadProgress",@"loadCompletion",@"loadFailure",@"loadCancel",@"downloadM"];
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

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.updated forKey:@"updated"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    self.updated = [aDecoder decodeObjectForKey:@"updated"];
    return self;
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

- (NSArray *)tags {
    if (_tags.count == 0) {
        if (_majorCate) {
            _tags = @[_majorCate];
        } else if (_minorCate) {
            _tags = @[_minorCate];
        }
    }
    return _tags;
}

@end
