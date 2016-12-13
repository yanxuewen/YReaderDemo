//
//  YSQLiteManager.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/10.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YSQLiteManager.h"

#define kYReaderSqliteName @"kYReaderSqliteName"
#define kYHistorySearchText @"kYHistorySearchText"

@interface YSQLiteManager ()

@property (strong, nonatomic) YYCache *cache;

@end

@implementation YSQLiteManager

+ (instancetype)shareManager {
    static YSQLiteManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *documentFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *path = [documentFolder stringByAppendingPathComponent:kYReaderSqliteName];
        NSLog(@"YSQLiteManager path %@",path);
        self.cache = [[YYCache alloc] initWithPath:path];
    }
    return self;
}

- (NSArray *)getHistorySearchTextArray {
    id arr = [self.cache objectForKey:kYHistorySearchText];
    if (!arr) {
        arr = @[];
    }
    return arr;
}

- (void)updateHistorySearchTextArrayWith:(NSArray *)array {
    [self.cache setObject:array forKey:kYHistorySearchText];
}



@end
