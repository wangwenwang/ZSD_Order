//
//  NewsListService.h
//  ZSDOrder
//
//  Created by 凯东源 on 17/5/11.
//  Copyright © 2017年 凯东源. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 回调协议
@protocol NewsListServiceDelegate <NSObject>

@optional
- (void)successOfGetAppNews:(NSArray *)newsList;

@optional
- (void)successOfGetAppNewsNoData;

@optional
- (void)failureOfGetAppNews:(NSString *)msg;

@end

@interface NewsListService : NSObject

@property (weak, nonatomic)id <NewsListServiceDelegate> delegate;



/**
 <#Description#>

 @param strPage      <#strPage description#>
 @param strPageCount <#strPageCount description#>
 */
- (void)GetAppNews:(NSUInteger)strPage andstrPageCount:(NSUInteger)strPageCount;

@end


