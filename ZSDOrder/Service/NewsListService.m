//
//  NewsListService.m
//  ZSDOrder
//
//  Created by 凯东源 on 17/5/11.
//  Copyright © 2017年 凯东源. All rights reserved.
//

#import "NewsListService.h"
#import <AFNetworking.h>
#import "Tools.h"
#import "NewsListModel.h"


#define kAPIName @"获取APP推送消息"

@implementation NewsListService

#pragma mark - 获取APP推送消息
- (void)GetAppNews:(NSUInteger)strPage andstrPageCount:(NSUInteger)strPageCount {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSDictionary *parameters = @{@"strPage" : @(strPage),
                                 @"strPageCount" : @(strPageCount),
                                 @"strLicense" : @""
                                 };
    
    NSLog(@"请求%@参数:%@", kAPIName, parameters);
    
    [manager POST:API_GetAppNews parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        // 返回json
        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@,请求成功,返回值:%@", kAPIName, responseString);
        
        // json转字典
        NSDictionary *dict = [self fd:responseString];
        NSLog(@"");
        
        NSInteger type = [dict[@"type"] intValue];
        NSString *msg = dict[@"msg"];

        // 返回数据TYPE:0为订单;     1为公告
        // 返回数据ISREAD:0为未读;   1为已读
        if(type == 0 || type == 1) {
            
            NSLog(@"%@成功，msg:%@", kAPIName, msg);
            NSArray *result = dict[@"result"];
            
            NSMutableArray *newsList = [[NSMutableArray alloc] init];
            for (int i = 0; i < result.count; i++) {
                
                NewsListModel *m = [[NewsListModel alloc] initWithDictionary:result[i]];
                [newsList addObject:m];
            }
            
            [self successOfGetAppNews:newsList];
        } else if(type == -2){
            
            NSLog(@"%@成功，没有消息，msg:%@", kAPIName, msg);
            [self successOfGetAppNewsNoData];
        }else {
            
            NSLog(@"%@失败，msg:%@", kAPIName, msg);
            [self failureOfGetAppNews:msg];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self failureOfGetAppNews:@"请求失败"];
        NSLog(@"%@时，请求失败，error:%@", kAPIName, error);
    }];
}


#pragma mark - 功能函数

- (void)successOfGetAppNews:(NSArray *)newsList {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if([_delegate respondsToSelector:@selector(successOfGetAppNews:)]) {
            
            [_delegate successOfGetAppNews:newsList];
        }
    });
}


- (void)successOfGetAppNewsNoData {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if([_delegate respondsToSelector:@selector(successOfGetAppNewsNoData)]) {
            
            [_delegate successOfGetAppNewsNoData];
        }
    });
}


- (void)failureOfGetAppNews:(NSString *)msg {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if([_delegate respondsToSelector:@selector(failureOfGetAppNews:)]) {
            
            [_delegate failureOfGetAppNews:msg];
        }
    });
}

//+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
//    if (jsonString == nil) {
//        return nil;
//    }
//    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
//    NSError *err;
//    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
//                                                        options:NSJSONReadingMutableContainers
//                                                          error:&err];
//    if(err) {
//        NSLog(@"json解析失败：%@",err);
//        return nil;
//    }
//    return dic;
//}

- (NSDictionary *)fd:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
//    NSRange ran_CONTENT = [jsonString rangeOfString:@"CONTENT"];
//    NSRange ran_ISREAD = [jsonString rangeOfString:@"ISREAD"];
//    
//    NSRange ran_between = NSMakeRange((ran_CONTENT.location + ran_CONTENT.length), (ran_ISREAD.location - ran_CONTENT.location - 9));
    
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\t" withString:@"" ];
    
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
//    data = [[jsonString stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"] dataUsingEncoding:NSUTF8StringEncoding];
//    data = [[jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if(error) {
        NSLog(@"json解析失败：%@",error);
        return nil;
    }
    return dic;
}

@end
