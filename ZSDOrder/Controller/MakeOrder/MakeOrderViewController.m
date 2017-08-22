//
//  MakeOrderViewController.m
//  Order
//
//  Created by 凯东源 on 16/9/27.
//  Copyright © 2016年 凯东源. All rights reserved.
//

#import "MakeOrderViewController.h"
#import "MakeOrderTableViewCell.h"
#import "MakeOrderService.h"
#import <MBProgressHUD.h>
#import "Tools.h"
#import "PartyModel.h"
#import "AddressModel.h"
#import "CustomerAddressTableViewCell.h"
#import "NSString+Trim.h"
#import "SelectGoodsViewController.h"
#import "UITableView+NoDataPrompt.h"
#import <Masonry.h>

//跳下个页面使用
#import "SelectGoodsService.h"
#import "PayTypeModel.h"


/*
 *
 *   本类设计思路：
 *
 *   获取产品类型，成功回调后 --> 获取产品类型成功回调后 --> 获取产品数据成功回调后push下一页
 *
 *
 */
@interface MakeOrderViewController ()<UITableViewDelegate, UITableViewDataSource, MakeOrderServiceDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate, SelectGoodsServiceDelegate>

//客户资料tableView
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

//网络请求服务
@property (strong, nonatomic)MakeOrderService *service;

//客户资料列表数据(总的)
@property (strong, nonatomic)NSMutableArray *partys;

//客户资料列表数据(搜索过滤后的)
@property (strong, nonatomic)NSMutableArray *partysFilter;

//客户地址列表数据
@property (strong, nonatomic)NSMutableArray *address;

//遮挡层
@property (weak, nonatomic) IBOutlet UIView *coverView;

//地址View
@property (weak, nonatomic) IBOutlet UIView *addressView;

//地址tableView
@property (weak, nonatomic) IBOutlet UITableView *addressTableView;

//取消选择地址
- (IBAction)cancelSelectAddressOnclick:(UIButton *)sender;

@property (strong, nonatomic) SelectGoodsService *selectGoodsService;

//暂存请求支付方式的回调结果
@property (strong, nonatomic) NSMutableArray *payTypes;

//暂存请求产品类型的回调结果
@property (strong, nonatomic) NSMutableArray *productTypes;

//点击的Cell下标
//@property (assign, nonatomic) int indexRow;

//选择的party
@property (strong, nonatomic) PartyModel *currentParty;

//选择的address
@property (strong, nonatomic) AddressModel *currentAddress;

@property (strong, nonatomic) AppDelegate *app;

// window遮罩
@property (strong, nonatomic) UIView *windowCover;

//@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBar_Top;

@property (strong, nonatomic) UISearchBar *searchBar;

@end

#define kSearchBar_Top 20

#define kCellHeight 79.0

@implementation MakeOrderViewController

- (instancetype)init {
    if(self = [super init]) {
        self.title = @"下单";
        self.tabBarItem.image = [UIImage imageNamed:@"menu_order_unpay_unselected"];
        
        _service = [[MakeOrderService alloc] init];
        _service.delegate = self;
        
        _partysFilter = [[NSMutableArray alloc] init];
        
        _selectGoodsService = [[SelectGoodsService alloc] init];
        _selectGoodsService.delegate = self;
        _app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerCell];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_service getCustomerData];
    
    _coverView.hidden = YES;
    _addressView.hidden = YES;
    
    [self addTap];
    
    [self addTableViewHeadView];
    
    _searchBar.backgroundImage = [UIImage new];
    
    
//    UITextField *searchField=[_searchBar valueForKey:@"_searchField"];
//    searchField.backgroundColor = [UIColor groupTableViewBackgroundColor];
}


//- (UISearchBar *)searchBar {
//    
//    if(!_searchBar) {
//        
//        _searchBar = [[UISearchBar alloc] init];
//        _searchBar.delegate = self;
//        _searchBar.placeholder = @"按客户名称关键字搜索";
//        _searchBar.backgroundImage = [UIImage new];
//    }
//    return _searchBar;
//}

- (void)addTableViewHeadView {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 45)];
    
//    [view addSubview:self.searchBar];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"请选择下单客户";
    [label setFont:[UIFont systemFontOfSize:16.0]];
    [view addSubview:label];
    
//    [_searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(@(0));
//        make.left.equalTo(@(0));
//        make.right.equalTo(@(0));
//        make.height.mas_equalTo(@(44));
//    }];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        // make.top.equalTo(_searchBar.mas_bottom).with.offset(0);
        make.top.equalTo(@(0));
        make.left.equalTo(@(8));
        make.right.equalTo(@(0));
        make.bottom.equalTo(@(0));
    }];
    
    _myTableView.tableHeaderView = view;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.topItem.title = @"下单";
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 私有方法
- (void)registerCell {
    [_myTableView registerNib:[UINib nibWithNibName:@"MakeOrderTableViewCell" bundle:nil] forCellReuseIdentifier:@"MakeOrderTableViewCell"];
    _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [_addressTableView registerNib:[UINib nibWithNibName:@"CustomerAddressTableViewCell" bundle:nil] forCellReuseIdentifier:@"CustomerAddressTableViewCell"];
    _addressTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

/// 计算Label的Size
- (CGSize)sizeWithString:(NSString *)str font:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *dict = @{NSFontAttributeName : font};
    CGSize size =  [str boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    return size;
}

//给coverView添加单击手势
- (void)addTap {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditingWithCoverView)];
    tap.numberOfTapsRequired = 1;
    tap.delegate = self;
    [_coverView addGestureRecognizer:tap];
}


// 收回键盘
- (void)endEditingWithCoverView {
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    _searchBar_Top.constant = 0;
    [self.view endEditing:YES];
    _coverView.hidden = YES;
}


- (void)getPayTypeData {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_selectGoodsService getPayTypeData];
}

#pragma mark - GET方法

- (UIView *)windowCover {
    
    if(!_windowCover) {
        
        _windowCover = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _windowCover.backgroundColor = [UIColor blackColor];
        _windowCover.alpha = 0.3;
//        [_app.window insertSubview:_windowCover belowSubview:_searchBar];
        [_app.window addSubview:_windowCover];
        [_app.window addSubview:_searchBar];
        
        // 添加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(windowTapOnclick)];
        tap.numberOfTapsRequired = 1;
        [_windowCover addGestureRecognizer:tap];
    }
    return _windowCover;
}


#pragma mark - 手势

- (void)windowTapOnclick {
    
    [self.view endEditing:YES];
    [_windowCover setHidden:YES];
}


#pragma mark - 点击事件

- (IBAction)cancelSelectAddressOnclick:(UIButton *)sender {
    _coverView.hidden = YES;
    _addressView.hidden = YES;
}


#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView.tag == 1001) {
        return _partysFilter.count;
    } else if(tableView.tag == 1002) {
        return _address.count;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView.tag == 1001) {
        
        PartyModel *m = _partysFilter[indexPath.row];
        return m.cellHeight;
    } else if(tableView.tag == 1002) {
        
        AddressModel *m = _address[indexPath.row];
        
        //地址详情的Label高度，根据文字计算出来
        return 58.0 + m.cellAddressDetailLabelHeight;
    } else {
        
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView.tag == 1001) {
        static NSString *cellId = @"MakeOrderTableViewCell";
        MakeOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
        
        PartyModel *m = _partysFilter[indexPath.row];
        cell.customerTypeLabel.text = m.PARTY_TYPE;
        cell.customerCodeLabel.text = m.PARTY_CODE;
        cell.customerCityLabel.text = m.PARTY_CITY;
        cell.customerNameLabel.text = m.PARTY_NAME;
        
        return cell;
        
    } else if(tableView.tag == 1002) {
        static NSString *cellId = @"CustomerAddressTableViewCell";
        CustomerAddressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
        
        AddressModel *m = _address[indexPath.row];
        
        cell.nameLabel.text = m.CONTACT_PERSON;
        cell.telLabel.text = m.CONTACT_TEL;
        cell.addressCodeLabel.text = m.ADDRESS_CODE;
        cell.addressDetailLabel.text = m.ADDRESS_INFO;
        NSLog(@"%@", [NSValue valueWithCGRect:cell.addressDetailLabel.frame]);
        
        return cell;
        
    } else {
        
        return [[UITableViewCell alloc] init];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    _indexRow = (int)indexPath.row;
    
    [self.view endEditing:YES];
    
    if(tableView.tag == 1001) {
        
        PartyModel *m = _partysFilter[indexPath.row];
        _currentParty = m;
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [_service getPartygetAddressInfo:m.IDX];
        
    } else if(tableView.tag == 1002) {
        
        _currentAddress = _address[indexPath.row];
        
        [self getPayTypeData];
        
    } else {
        
        nil;
    }
    
}


#pragma mark - MakeOrderServiceDelegate

// 获取客户资料列表回调
- (void)successOfMakeOrder:(NSMutableArray *)partys {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    _partys = partys;
    _partysFilter = [partys mutableCopy];
    
    if(_partys.count == 0) {
        
        [_myTableView noOrder:@"您还没有客户，赶紧去找小伙伴吧"];
    }else {
        
        // Label 容器宽度
        CGFloat contentWidth = ScreenWidth - 15 - 72;
        // Label 单行高度
        CGFloat oneLineHeight = [Tools getHeightOfString:@"fds" fontSize:14 andWidth:999.9];
        for(int i = 0; i < _partys.count; i++) {
            
            PartyModel *m = _partys[i];
            CGFloat overflowHeight = [Tools getHeightOfString:m.PARTY_NAME fontSize:14 andWidth:contentWidth] - oneLineHeight;
            m.cellHeight = overflowHeight ? (overflowHeight + kCellHeight + 11) : kCellHeight;
        }
        
        [_myTableView reloadData];
    }
}


- (void)failureOfMakeOrder:(NSString *)msg {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [_myTableView noOrder:@"您还没有客户，赶紧去找小伙伴吧"];
}


// 获取客户地址列表回调
- (void)successOfGetPartygetAddressInfo:(NSMutableArray *)address {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    _address = address;
    
    if(address.count > 1) {
        
        for(int i = 0; i < _address.count; i++) {
            
            AddressModel *m = _address[i];
            
            // 地址详情的Label高度，根据文字计算出来
            UILabel *label = [[UILabel alloc]init];
            label.text = m.ADDRESS_INFO;
            label.numberOfLines = 0;
            label.font = [UIFont systemFontOfSize:13];
            CGSize textSize = [self sizeWithString:label.text font:[UIFont systemFontOfSize:13] maxSize:CGSizeMake(177, MAXFLOAT)];
            
            m.cellAddressDetailLabelHeight = textSize.height;
        }
        
        _coverView.hidden = NO;
        _addressView.hidden = NO;
        [_addressTableView reloadData];
        
    }else if(_address.count == 1) {
        
        _currentAddress = _address[0];
        
        [self getPayTypeData];
    }else {
        
        [Tools showAlert:self.view andTitle:@"没有可用地址"];
    }
}


- (void)failureOfGetPartygetAddressInfo:(NSString *)msg {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Tools showAlert:self.view andTitle:msg ? msg : @"获取客户地址失败"];
}


#pragma mark - SelectGoodsServiceDelegate

//获取支付类型回调
- (void)successOfGetPayTypeData:(NSMutableArray *)payTypes {
    
    _payTypes = payTypes;
    
    //关闭上一个菊花
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    //开启一个新菊花来请求网络，这两个菊花可以打平
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [_selectGoodsService getProductTypesData];
}

- (void)failureOfGetPayTypeData:(NSString *)msg {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [Tools showAlert:self.view andTitle:msg ? msg : @"获取支付方式失败"];
}


//获取产品类型回调
- (void)successOfGetProductTypeData:(NSMutableArray *)productTypes {
    
    _productTypes = productTypes;
    
    //关闭上一个菊花
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    //开启一个新菊花来请求网络，这两个菊花可以打平
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [_selectGoodsService getProductsData:_currentParty.IDX andOrderAddressIdx:_currentAddress.IDX andProductTypeIndex:0 andProductType:@"" andOrderBrand:@""];
    
}

- (void)failureOfGetProductTypeData:(NSString *)msg {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [Tools showAlert:self.view andTitle:msg ? msg : @"获取产品类型失败"];
}


// 获取产品数据回调
- (void)successOfGetProductData:(NSMutableArray *)products {
    
    
    //测试，寻找要考虑库存的产品
//    for (int i = 0; i < products.count; i++) {
//        ProductModel *m = products[i];
//        if([m.ISINVENTORY isEqualToString:@"Y"]) {
//            NSLog(@"%d, %@, %lld", i, m.PRODUCT_NAME, m.PRODUCT_INVENTORY);
//        }
//    }
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    SelectGoodsViewController *vc = [[SelectGoodsViewController alloc] init];
    vc.payTypes = _payTypes;
    vc.productTypes = _productTypes;
    NSDictionary *dict = [NSDictionary dictionaryWithObject:products forKey:@(0)];
    vc.dictProducts = [NSMutableDictionary dictionaryWithObject:dict forKey:@(0)];
    vc.address = _currentAddress;
    vc.party = _currentParty;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)failureOfGetProductData:(NSString *)msg {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [Tools showAlert:self.view andTitle:msg ? msg : @"获取产品列表失败"];
}


#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSLog(@"textDidChange : %@", searchText);
    
    [_partysFilter removeAllObjects];
    if([[searchText trim] isEqualToString:@""]) {
        
        _partysFilter = [_partys mutableCopy];
    } else {
        
        for (int i = 0; i < _partys.count; i++) {
            
            PartyModel *m = _partys[i];
            if([m.PARTY_NAME rangeOfString:searchText].length > 0) {
                [_partysFilter addObject:m];
            } else {
                
            }
        }
    }
    [_myTableView reloadData];
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    _searchBar_Top.constant = kSearchBar_Top;
    [_coverView setHidden:NO];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    _searchBar_Top.constant = kSearchBar_Top;
    [searchBar resignFirstResponder];
    [_coverView setHidden:YES];
}

@end
