//
//  YSQLiteManager.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/10.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YSQLiteManager.h"
#import "YBookDetailModel.h"

#define kYReaderSqliteName @"kYReaderSqliteName"
#define kYHistorySearchText @"kYHistorySearchText"
#define kYUesrBooks @"kYUesrBooks"

@interface YSQLiteManager ()

@property (strong, nonatomic) YYCache *cache;
@property (copy, nonatomic) NSArray *userBooks;

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
        self.cache = [[YYCache alloc] initWithPath:path];
        _userBooks = (NSArray *)[self.cache objectForKey:kYUesrBooks];
        if (!_userBooks) {
            _userBooks = @[];
        }
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

- (YBookDetailModel *)addUserBooksWith:(YBookDetailModel *)bookM; {
    NSMutableArray *arr = _userBooks.mutableCopy;
    YBookDetailModel *sameM = nil;
    for (YBookDetailModel * book in arr) {
        if ([book isEqual:bookM]) {
            sameM = book;
            break;
        }
    }
    if ([arr containsObject:bookM]) {
        NSLog(@"addUserBooksWith containsObject OK");
    }
    if (sameM) {
        [arr setObject:sameM atIndexedSubscript:0];
    } else {
        [arr insertObject:bookM atIndex:0];
        sameM = bookM;
    }
    
    self.userBooks = arr.copy;
    [self.cache setObject:self.userBooks forKey:kYUesrBooks withBlock:^{
        
    }];
    return sameM;
}

- (void)saveUserBooksStatus {
    [self.cache setObject:self.userBooks forKey:kYUesrBooks withBlock:^{
        NSLog(@"saveUserBooksStatus ok ");
    }];
}

@end
