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

- (instancetype)init {
    self = [super init];
    if (self) {
        self.chaptersLink = @[];
        self.readingPage = 0;
        self.readingChapter = 0;
    }
    return self;
}

@end
