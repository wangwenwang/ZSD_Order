//
//  UITableView+NoDataPrompt.h
//  Order
//
//  Created by 凯东源 on 16/12/1.
//  Copyright © 2016年 凯东源. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (NoDataPrompt)

/// 添加TableView无数据提示
- (void)noOrder:(NSString *)title;

/// 移除TableView无数据提示
- (void)removeNoOrderPrompt;

@end
