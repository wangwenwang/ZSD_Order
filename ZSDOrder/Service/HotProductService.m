//
//  HotProductService.m
//  Order
//
//  Created by 凯东源 on 16/10/8.
//  Copyright © 2016年 凯东源. All rights reserved.
//

#import "HotProductService.h"
#import "AppDelegate.h"
#import <AFNetworking.h>
#import "ProductChartModel.h"

@interface HotProductService ()

@property (strong, nonatomic) AppDelegate *app;

@end

@implementation HotProductService

- (void)getHotProductData:(NSString *)strUserId andstrBusinessIdx:(NSString *)strBusinessIdx andstrStDate:(NSString *)strStDate andstrEdDate:(NSString *)strEdDate {
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                  strUserId, @"strUserId",
                  strBusinessIdx, @"strBusinessIdx",
                  strStDate, @"strStDate",
                  strEdDate, @"strEdDate",
                  @"", @"strProductType",
                  @"", @"strLicense",
                  nil];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:API_GET_PRODUCT_CHART_DATA parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"请求成功---%@", responseObject);
        int _type = [responseObject[@"type"] intValue];
        NSString *msg = responseObject[@"msg"];
        if(_type == 1) {
            NSArray *arrResult = responseObject[@"result"];
            if([arrResult isKindOfClass:[NSArray class]]) {
                if(arrResult.count > 0) {
                    
                    @try {
                        
                        NSMutableArray *ProductCharts = [[NSMutableArray alloc] init];
                        
                        for (int i = 0; i < arrResult.count; i++) {
                            
                            ProductChartModel *m = [ProductChartModel alloc];
                            [m setDict:arrResult[i]];
                            
                            // 截取出规格
                            NSArray *formArray = [m.PRODUCT_NAME componentsSeparatedByString:@"/"];
                            NSString *formStr = @"";
                            
                            if(formArray.count > 0) {
                                
                                NSString *first = [NSString stringWithFormat:@"%@/", formArray[0]];
                                
                                formStr = [m.PRODUCT_NAME stringByReplacingOccurrencesOfString:first withString:@""];
                            }
                            
                            m.PRODUCT_DESC = formStr;
                            
                            [ProductCharts addObject:m];
                        }
                        
                        if([_delegate respondsToSelector:@selector(successOfHotProduct:)]) {
                            [_delegate successOfHotProduct:[ProductCharts copy]];
                        }
                    } @catch (NSException *exception) {
                    
                        [self failureOfHotProduct:@"数据异常"];
                    }
                }
            } else {
                [self failureOfHotProduct:msg];
            }
        }else {
            [self failureOfHotProduct:msg];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求热销产品失败:%@", error);
        [self failureOfHotProduct:nil];
    }];
}

- (void)failureOfHotProduct:(NSString *)msg {
    if([_delegate respondsToSelector:@selector(failureOfHotProduct:)]) {
        [_delegate failureOfHotProduct:msg];
    }
}

@end
