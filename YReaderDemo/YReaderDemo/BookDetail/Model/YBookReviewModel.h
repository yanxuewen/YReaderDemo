//
//  YBookReviewModel.h
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/10.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YBaseModel.h"
#import "YBookAuthorModel.h"
#import "YBookHelpfulModel.h"

@interface YBookReviewModel : YBaseModel

@property (nonatomic, strong) YBookAuthorModel * author;
@property (nonatomic, assign) NSInteger commentCount;
@property (nonatomic, strong) NSString * content;
@property (nonatomic, strong) NSDate * created;
@property (nonatomic, strong) YBookHelpfulModel * helpful;
@property (nonatomic, assign) NSInteger likeCount;
@property (nonatomic, assign) double rating;
@property (nonatomic, strong) NSString * state;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * updated;

@end
