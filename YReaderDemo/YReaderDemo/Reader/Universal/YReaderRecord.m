//
//  YReaderRecord.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/13.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YReaderRecord.h"
#include "YSQLiteManager.h"

@interface YReaderRecord ()

@end

@implementation YReaderRecord

+ (NSArray *)modelPropertyBlacklist {
    return @[@"cover",@"idField"];
}

+ (instancetype)recordModelWith:(YBookDetailModel *)bookM {
    YReaderRecord *record = nil;
    YYCache *cache = [YSQLiteManager shareManager].cache;
    NSString *recordKey = [NSString stringWithFormat:@"%@_record",bookM.idField];
    if ([cache containsObjectForKey:recordKey]) {
        record = (YReaderRecord *)[cache objectForKey:recordKey];
    } else {
        record = [[YReaderRecord alloc] init];
        record.chaptersLink = @[];
        record.readingPage = 0;
        record.readingChapter = 0;
    }
    DDLogInfo(@"reading book %@ \n record %@  ",bookM,record);
    return record;
}

@end
