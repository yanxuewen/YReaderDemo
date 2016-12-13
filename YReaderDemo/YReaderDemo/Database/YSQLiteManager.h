//
//  YSQLiteManager.h
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/10.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YSQLiteManager : NSObject

@property (strong, nonatomic, readonly) YYCache *cache;

+ (instancetype)shareManager;

- (NSArray *)getHistorySearchTextArray;
- (void)updateHistorySearchTextArrayWith:(NSArray *)array;

@end
