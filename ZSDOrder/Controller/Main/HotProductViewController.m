//
//  HotProductViewController.m
//  Order
//
//  Created by 凯东源 on 16/10/8.
//  Copyright © 2016年 凯东源. All rights reserved.
//

#import "HotProductViewController.h"
#import "HotProductTableViewCell.h"
#import "HotProductService.h"
#import "Tools.h"
#import "NSString+Trim.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD.h>
#import "ProductChartModel.h"

@interface HotProductViewController ()<UITableViewDataSource, UITableViewDelegate, HotProductServiceDelegate>

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property (strong, nonatomic) HotProductService *service;

@property (strong, nonatomic) NSArray *products;

@property (strong, nonatomic) AppDelegate *app;

@end

@implementation HotProductViewController

- (instancetype)init {
    
    if(self = [super init]) {
        
        _service = [[HotProductService alloc] init];
        _service.delegate = self;
        _app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"热销产品";
    
    [self registerCell];
    
    // 开始日期 前90天
    NSString *strStDate = [Tools ClearHourMinuteSecond:[Tools getCurrentBeforeDate:-90 * 24 * 60 * 60]];
    
    // 结束日期
    NSString *strEdDate = [Tools getCurrentDate];
    
    //
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_service getHotProductData:_app.user.IDX andstrBusinessIdx:_app.business.BUSINESS_IDX andstrStDate:strStDate andstrEdDate:strEdDate];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}


#pragma mark - 私有方法

- (void)registerCell {
    [_myTableView registerNib:[UINib nibWithNibName:@"HotProductTableViewCell" bundle:nil] forCellReuseIdentifier:@"HotProductTableViewCell"];
    
    _myTableView.separatorStyle = NO;
}


#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _products.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 70.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 界面处理
    static NSString *cellID = @"HotProductTableViewCell";
    HotProductTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    // 数据处理
    ProductChartModel *m = _products[indexPath.row];
    
    cell.nameLabel.text = m.PRODUCT_NAME;
    cell.formatLabel.text = m.PRODUCT_DESC;
    cell.priceLabel.text = [NSString stringWithFormat:@"￥%@", m.ACT_PRICE];
    
    // 返回Cell
    return cell;
}

#pragma mark - HotProductServiceDelegate
- (void)successOfHotProduct:(NSArray *)products {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    _products = products;
    
    [_myTableView reloadData];
}

- (void)failureOfHotProduct:(NSString *)msg {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Tools showAlert:self.view andTitle:msg ? msg : @"获取失败"];
}

@end
