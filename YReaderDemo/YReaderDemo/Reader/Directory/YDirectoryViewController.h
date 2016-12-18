//
//  YDirectoryViewController.h
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/16.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YBaseViewController.h"

@interface YDirectoryViewController : YBaseViewController

@property (assign, nonatomic) NSUInteger readingChapter;
@property (strong, nonatomic) NSArray *chaptersArr;
@property (copy, nonatomic) void(^selectChapter)(NSUInteger);

@end
