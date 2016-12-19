//
//  YNetworkManager.m
//  YReaderDemo
//
//  Created by yanxuewen on 2016/12/9.
//  Copyright © 2016年 yxw. All rights reserved.
//

#import "YNetworkManager.h"
#import "YBookModel.h"
#import "YBookDetailModel.h"
#import "YBookReviewModel.h"
#import "YRecommendBookModel.h"
#import "YRecommendBookListModel.h"
#import "YBookSummaryModel.h"
#import "YChaptersLinkModel.h"
#import "YChapterContentModel.h"
#import "YBookUpdateModel.h"
#import "YRankingModel.h"

@interface YNetworkManager ()

@property (strong, nonatomic) AFURLSessionManager *manager;
@property (assign, nonatomic) AFNetworkReachabilityStatus networkStatus;

@end

@implementation YNetworkManager

+ (instancetype)shareManager {
    static YNetworkManager *netManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        netManager = [[self alloc] init];
    });
    return netManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.networkStatus = AFNetworkReachabilityStatusNotReachable;
        NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
        cfg.timeoutIntervalForRequest = 15.0;
        cfg.timeoutIntervalForResource = 15.0;
        self.manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:cfg];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        [self monitorNetWork];
        
    }
    return self;
}

- (NSURLSessionTask *)getWithAPIType:(YAPIType)type parameter:(id)parameter success:(void (^)(id response))success failure:(void (^)(NSError *error))failure {
    
    NSURL *url = [YURLManager getURLWith:type parameter:parameter];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0];
    
    __weak typeof(self) wself = self;
    NSURLSessionTask *task = [self.manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (type != YAPITypeChapterContent) {
            DDLogInfo(@"\n---------------------------------------begin---------------------------------------\n请求地址:%@ \n参数:%@ \n返回:%@  \n---------------------------------------end---------------------------------------",url,parameter,responseObject);
        } 
        
        if (error) {
            if (failure) {
                failure([wself formatWithResponseObject:nil error:error]);
            }
        } else {
            id object = [wself parsingResponseObject:responseObject type:type];
            if (object) {
                success(object);
            } else {
                if (failure) {
                    failure([wself formatWithResponseObject:nil error:error]);
                }
            }
        }
    }];
    [task resume];
    return task;
}

- (id)parsingResponseObject:(id)response type:(YAPIType)type{
    if (response == nil) {
        return nil;
    }
    
    if (type == YAPITypeBookDetail) {
        YBookDetailModel *bookD = [YBookDetailModel yy_modelWithJSON:response];
        return bookD;
    }
    if (type == YAPITypeChapterContent) {
        if ([response[@"ok"] boolValue]) {
            YChapterContentModel *chapter = [YChapterContentModel yy_modelWithJSON:response[@"chapter"]];
            return chapter;
        }
        return nil;
    }
    if (type == YAPITypeRanking) {
        if ([response[@"ok"] boolValue]) {
            NSArray *arr = @[response[@"male"],response[@"female"]];
            NSMutableArray *maleArr = [NSMutableArray new];
            NSMutableArray *femaleArr = [NSMutableArray new];
            for (NSInteger i = 0; i < arr.count; i++) {
                for (NSDictionary *dict in arr[i]) {
                    YRankingModel *rankingM = [YRankingModel yy_modelWithDictionary:dict];
                    if (rankingM) {
                        if (i == 0) {
                            [maleArr addObject:rankingM];
                        } else {
                            [femaleArr addObject:rankingM];
                        }
                    }
                }
            }
            return @[maleArr,femaleArr];
        }
        return nil;
    }
    
    NSMutableArray *dataArr = [NSMutableArray new];
    NSString *key = nil;
    if (type == YAPITypeAutoCompletion) {
        key = @"keywords";
    } else if (type == YAPITypeFuzzySearch || type == YAPITypeRecommendBook) {
        key = @"books";
    } else if (type == YAPITypeRecommendBookList) {
        key = @"booklists";
    } else if (type == YAPITypeBookReview) {
        key = @"reviews";
    } else if (type == YAPITypeChaptersLink) {
        key = @"chapters";
    } else if (type == YAPITypeRankingDetial) {
        response = response[@"ranking"];
        if (!response) {
            return  nil;
        }
        key = @"books";
    }
    
    if (type == YAPITypeAutoCompletion) {
        dataArr = response[key];
        return dataArr;
    }
    
    NSArray *arr = response;
    if (key) {
        arr = response[key];
    }
    
    NSAssert(arr != nil, @"parsingResponseObject error %@  type %zi",response,type);
    for (NSInteger i = 0 ; i < arr.count; i++) {
        YBaseModel *bookM = nil;
        if (type == YAPITypeFuzzySearch) {
            bookM = [YBookModel yy_modelWithJSON:arr[i]];
        } else if (type == YAPITypeRecommendBook) {
            bookM = [YRecommendBookModel yy_modelWithJSON:arr[i]];
        } else if (type == YAPITypeRecommendBookList) {
            bookM = [YRecommendBookListModel yy_modelWithJSON:arr[i]];
        } else if (type == YAPITypeBookReview) {
            bookM = [YBookReviewModel yy_modelWithJSON:arr[i]];
        } else if (type == YAPITypeBookSummary) {
            bookM = [YBookSummaryModel yy_modelWithJSON:arr[i]];
        } else if (type == YAPITypeChaptersLink) {
            bookM = [YChaptersLinkModel yy_modelWithJSON:arr[i]];
        } else if (type == YAPITypeBookUpdate) {
            bookM = [YBookUpdateModel yy_modelWithJSON:arr[i]];
        } else if (type == YAPITypeRankingDetial) {
            bookM = [YBookModel yy_modelWithJSON:arr[i]];//先这样
        }
        
        if (!bookM) {
            continue;
        }
        [dataArr addObject:bookM];
    }
    
    
    return dataArr;
}

- (NSError *)formatWithResponseObject:(id)response error:(NSError *)error {
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[error userInfo]];
    if (self.networkStatus == AFNetworkReachabilityStatusNotReachable) {
        [userInfo setObject:@"网络中断" forKey:NSLocalizedFailureReasonErrorKey];
    } else if (error.code == kCFURLErrorTimedOut) {
        [userInfo setObject:@"请求超时" forKey:NSLocalizedFailureReasonErrorKey];
    } else if (error.code == kCFURLErrorCannotConnectToHost || error.code == kCFURLErrorCannotFindHost || error.code == kCFURLErrorBadURL || error.code == kCFURLErrorNetworkConnectionLost) {
        [userInfo setObject:@"无法连接服务器" forKey:NSLocalizedFailureReasonErrorKey];
    }
    NSError *formattedError = [[NSError alloc] initWithDomain:NSOSStatusErrorDomain code:error.code userInfo:userInfo];
    return formattedError;
}

- (void)monitorNetWork {
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        self.networkStatus = status;
        DDLogInfo(@"networkStatus %zi",status);
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                
                break;
                
            default:
                break;
        }
    }];
}

@end
