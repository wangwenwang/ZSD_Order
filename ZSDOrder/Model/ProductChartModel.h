//
//  ProductChartModel.h
//  Order
//
//  Created by 凯东源 on 16/10/20.
//  Copyright © 2016年 凯东源. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 产品图表
@interface ProductChartModel : NSObject

@property (copy, nonatomic) NSString *PRODUCT_NAME;

@property (copy, nonatomic) NSString *PRODUCT_TYPE;

@property (copy, nonatomic) NSString *ACT_PRICE;

@property (copy, nonatomic) NSString *PO_QTY;

// 产品规格 用于热销产品
@property (copy, nonatomic) NSString *PRODUCT_DESC;

- (void)setDict:(NSDictionary *)dict;

@end
