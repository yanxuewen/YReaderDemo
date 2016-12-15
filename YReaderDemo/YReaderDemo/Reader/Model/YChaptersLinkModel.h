//
//  YChaptersLinkModel.h
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/12.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YBaseModel.h"

@interface YChaptersLinkModel : YBaseModel

@property (nonatomic, assign) NSInteger currency;
@property (nonatomic, assign) BOOL isVip;
@property (nonatomic, strong) NSString * link;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, assign) BOOL unreadble;
@property (assign, atomic) BOOL isLoadCache;

@end
