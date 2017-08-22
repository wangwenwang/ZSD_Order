//
//  OrderDetailTableViewCell.m
//  Order
//
//  Created by 凯东源 on 16/10/8.
//  Copyright © 2016年 凯东源. All rights reserved.
//

#import "OrderDetailTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Tools.h"

@interface OrderDetailTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *goodsImageView;

/// 订单编号
@property (weak, nonatomic) IBOutlet UILabel *orderNoLabel;

/// 货物名称
@property (weak, nonatomic) IBOutlet UILabel *goodsNameLabel;

/// 数量
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;

/// 重量
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;

/// 体积
@property (weak, nonatomic) IBOutlet UILabel *volumeLabel;

// 采购单价
@property (weak, nonatomic) IBOutlet UILabel *LOTTABLE06;

// 销售单价
@property (weak, nonatomic) IBOutlet UILabel *ACT_PRICE;

// 采购总价
@property (weak, nonatomic) IBOutlet UILabel *totalLOTTABLE06;

// 销售总价
@property (weak, nonatomic) IBOutlet UILabel *totalACT_PRICE;

// 毛利率 提示Label
@property (weak, nonatomic) IBOutlet UILabel *GrossProfitRateLabel;

// 毛利率
@property (weak, nonatomic) IBOutlet UILabel *GrossProfitRate;

// 毛利润 提示Label
@property (weak, nonatomic) IBOutlet UILabel *GrossProfitLabel;

// 毛利润
@property (weak, nonatomic) IBOutlet UILabel *GrossProfit;

// 全局变量
@property (strong, nonatomic) AppDelegate *app;

@end

@implementation OrderDetailTableViewCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


- (void)setOrderDetailM:(OrderDetailModel *)orderDetailM {
    
    _orderDetailM = orderDetailM;
    _app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // 采购总价
    CGFloat totalLOTTABLE06 = orderDetailM.ORDER_QTY * [orderDetailM.LOTTABLE06 floatValue];
    
    // 销售总价
    CGFloat totalPrice = orderDetailM.ORDER_QTY * orderDetailM.ACT_PRICE;
    NSString *imageURL = [NSString stringWithFormat:@"%@/%@", API_ServerAddress, orderDetailM.PRODUCT_URL];
    
    // 进货价
    CGFloat inPrice = [orderDetailM.LOTTABLE06 floatValue];
    
    // 售价
    CGFloat outPrice = orderDetailM.ACT_PRICE;
    
    // 毛利率
    NSString *GrossProfitRate = [NSString stringWithFormat:@"%.1f%%", ((outPrice - inPrice) / outPrice) * 100.0];
    
    // 毛利润(总的)
    NSString *GrossProfit = [NSString stringWithFormat:@"￥%.1f", totalPrice - totalLOTTABLE06];
    
    
    //填充数据
    [_goodsImageView sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:@"ic_information_picture"]];
    _orderNoLabel.text = orderDetailM.PRODUCT_NO;
    _goodsNameLabel.text = orderDetailM.PRODUCT_NAME;
    _quantityLabel.text = orderDetailM.ISSUE_QTY ? [NSString stringWithFormat:@"%.1f台", orderDetailM.ISSUE_QTY] : @"";
    _weightLabel.text = [NSString stringWithFormat:@"%@吨", orderDetailM.ORDER_WEIGHT];
    _volumeLabel.text = [NSString stringWithFormat:@"%@m³", orderDetailM.ORDER_VOLUME];
    
    // 采购单价
    _LOTTABLE06.text = orderDetailM.LOTTABLE06 ? [NSString stringWithFormat:@"￥%.1f", [orderDetailM.LOTTABLE06 floatValue]] : @"￥0.0";
    
    // 销售单价
    _ACT_PRICE.text = orderDetailM.ACT_PRICE ? [NSString stringWithFormat:@"￥%.1f", orderDetailM.ACT_PRICE] : @"￥0.0";
    
    // 采购总价
    _totalLOTTABLE06.text = totalLOTTABLE06 ? [NSString stringWithFormat:@"￥%.1f", totalLOTTABLE06] : @"￥0.0";
    
    // 销售总价
    _totalACT_PRICE.text = totalPrice ? [NSString stringWithFormat:@"￥%.1f", totalPrice] : @"￥0.0";
    
    _GrossProfitRate.text = GrossProfitRate;
    _GrossProfit.text = GrossProfit;
    
    // 客户与业务 不能看毛利率和毛利
    if([_app.user.USER_TYPE isEqualToString:kPARTY] || [_app.user.USER_TYPE isEqualToString:kBUSINESS]) {
        
        [_GrossProfitRateLabel setHidden:YES];
        [_GrossProfitRate setHidden:YES];
        [_GrossProfitLabel setHidden:YES];
        [_GrossProfit setHidden:YES];
    } else {
        
        [_GrossProfitRateLabel setHidden:NO];
        [_GrossProfitRate setHidden:NO];
        [_GrossProfitLabel setHidden:NO];
        [_GrossProfit setHidden:NO];
    }
    
    [_goodsNameLabel sizeToFit];
    CGFloat black = (ScreenWidth - (66 + 65 + 5));
    CGFloat overflowWidth = _goodsNameLabel.frame.size.width - (ScreenWidth - (66 + 65));
    if(overflowWidth > 0) {
        [Tools msgChange:overflowWidth andLabel:_goodsNameLabel andBeginAnimations:@"OrderDetailTableViewCell.h"];
    }
    
    NSRange range = [_goodsNameLabel.text rangeOfString:@"康师傅每日C水晶"];
    if(range.length > 0) {
        NSLog(@"black:%f", black);
        NSLog(@"overflowWidth:%f", overflowWidth);
        NSLog(@"goodsNameLabelWidth:%f", _goodsNameLabel.frame.size.width);
        
    }
}

@end
