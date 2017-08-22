//
//  SearchResultsViewController.m
//  ZSDOrder
//
//  Created by 凯东源 on 17/4/27.
//  Copyright © 2017年 凯东源. All rights reserved.
//

#import "SearchResultsViewController.h"
#import "ProductModel.h"
#import "SelectGoodsTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSString+Trim.h"

@interface SearchResultsViewController ()<UITableViewDelegate, UITableViewDataSource, SelectGoodsTableViewCellDelegate>

@end


/// 促销Cell的高度
#define PolicyCellHeight 25


@implementation SearchResultsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [_tableView registerNib:[UINib nibWithNibName:@"SelectGoodsTableViewCell" bundle:nil] forCellReuseIdentifier:@"SelectGoodsTableViewCell"];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
        NSMutableArray *products = _productsFilter[@(_brandRow)][@(_currentSection)];
        NSLog(@"%lu", (unsigned long)products.count);
        return products.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
        ProductModel *m = _productsFilter[@(_brandRow)][@(_currentSection)][indexPath.row];
        
        //产品基本信息高度69.0， 促销提示30.0， 促销信息44.0*条数， Label文字换行额外高度
        
        CGFloat org = 69.0;
        CGFloat policy = 30.0;
        
        if(m.PRODUCT_POLICY.count > 0) {
            
            if(m.isClickCell) {
                
                return org + policy + PolicyCellHeight * m.PRODUCT_POLICY.count + m.additionalCellHeight;
            }else {
                
                return org + policy + m.additionalCellHeight;
            }
        } else {
            
            return org + m.additionalCellHeight;
        }
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
        // 处理界面
        static NSString *cellId = @"SelectGoodsTableViewCell";
        SelectGoodsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
        cell.delegate = self;
        cell.section = _currentSection;
        
        // 获取数据
        ProductModel *m = _productsFilter[@(_brandRow)][@(_currentSection)][indexPath.row];
        
        cell.tag = (int)indexPath.row;
        
        //        // 过滤 / 号前的字符串
        //        NSString *name = m.PRODUCT_NAME;
        //        NSRange range = [name rangeOfString:@"/"];
        //        if(name.length > range.location) {
        //            name = [name substringFromIndex:range.location + 1];
        //        }
        
        NSString *imageURL = [NSString stringWithFormat:@"%@/%@", API_ServerAddress, m.PRODUCT_URL];
        
        // 填充基本数据
        [cell.productImageView sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:@"ic_information_picture"] options:SDWebImageRefreshCached];
        cell.productNameLabel.text = m.PRODUCT_NAME;
        cell.productFormatLabel.text = m.PRODUCT_DESC;
        cell.productPriceLabel.text = [NSString stringWithFormat:@"￥%.1f", m.PRODUCT_PRICE];
        [cell.productNumberButton setTitle:[NSString stringWithFormat:@"%lld", m.CHOICED_SIZE] forState:UIControlStateNormal];
        
        //促销信息的处理
        //    if(m.PRODUCT_POLICY.count > 0) {
        //        cell.policyPromptView.hidden = NO;
        //    } else {
        //        cell.policyPromptView.hidden = YES;
        //    }
        //上面五行代码合为下面一行
        cell.policyPromptView.hidden = !m.PRODUCT_POLICY.count;
        cell.PolicyPromptImageView.image = m.isClickCell ? [UIImage imageNamed:@"button_drop_down"] : [UIImage imageNamed:@"button_drop_up"];
        cell.product = m;
        if(m.isClickCell) {
            cell.policys = m.PRODUCT_POLICY;
            cell.cellHeight = PolicyCellHeight;
        }
        cell.policyTableviewSuperView.hidden = !m.isClickCell;
        
        //库存是否显示
        if([[m.ISINVENTORY trim] isEqualToString:@"Y"]) {
            cell.inventoryLabel.hidden = NO;
            cell.inventoryLabel.text = [NSString stringWithFormat:@"库存: %lld", m.PRODUCT_INVENTORY];
        } else {
            
            cell.inventoryLabel.hidden = YES;
        }
        
        // Label额外高度
        cell.productViewHeight.constant = 69.0 + m.additionalCellHeight;
        
        return cell;
        
    
}

@end
