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
    if (!bookM || ![bookM isKindOfClass:[YBookDetailModel class]]) {
        DDLogError(@"addUserBooksWith error %@",bookM);
        return nil;
    }
    
    
    YBookDetailModel *sameM = nil;
    NSMutableArray *arr = self.userBooks.mutableCopy;
    /*
     这里重写了 YBookDetailModel 的isEqual 方法,userBooks如果存在这本书,就只需要重新排序
     不能用新加bookM替换数组中同一本书,因为这本书可能有其他状态需要保存
     */
    for (YBookDetailModel *book in arr) {
        if ([bookM isEqual:book]) {
            sameM = book;
        }
    }
    if (sameM) {
        [arr removeObject:sameM];
    } else {
        sameM = bookM;
    }
    [arr addObject:sameM];
    _userBooks = arr.copy;
    arr = [self reorderUserBooksWith:bookM];
    if (!arr) {
        return nil;
    }
    
    self.userBooks = arr.copy;
    [self saveUserBooksStatus];
    return sameM;
}

- (void)stickyUserBookWith:(YBookDetailModel *)bookM {
    NSMutableArray *arr = [self reorderUserBooksWith:bookM];
    if (!arr) {
        return;
    }
    self.userBooks = arr.copy;
    [self saveUserBooksStatus];
}

- (NSMutableArray *)reorderUserBooksWith:(YBookDetailModel *)bookM {
    if (!bookM || ![bookM isKindOfClass:[YBookDetailModel class]]) {
        DDLogError(@"stickyUserBookWith error %@",bookM);
        return nil;
    }
    
    NSMutableArray *arr = _userBooks.mutableCopy;
    if (![arr containsObject:bookM]) {
        DDLogError(@"stickyUserBookWith containsObject error %@",bookM);
        return nil;
    }
    [arr removeObject:bookM];
    NSInteger firstCount = 0;
    for (NSInteger i = 0; i < arr.count; i ++) {
        YBookDetailModel * book = arr[i];
        if (book.hasSticky) {
            firstCount ++;
        }
    }
    
    [arr insertObject:bookM atIndex:firstCount];
    return arr;
}

- (void)saveUserBooksStatus {
    [self.cache setObject:self.userBooks forKey:kYUesrBooks withBlock:^{
        NSLog(@"saveUserBooksStatus ok ");
    }];
}

@end
