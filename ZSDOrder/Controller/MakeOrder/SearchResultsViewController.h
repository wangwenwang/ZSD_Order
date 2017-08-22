//
//  SearchResultsViewController.h
//  ZSDOrder
//
//  Created by 凯东源 on 17/4/27.
//  Copyright © 2017年 凯东源. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultsViewController : UIViewController

@property (strong, nonatomic) NSMutableDictionary *productsFilter;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (assign, nonatomic) NSInteger currentSection;

@property (assign, nonatomic) NSInteger brandRow;

@end
