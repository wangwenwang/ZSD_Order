//
//  OrderDetailViewController.m
//  Order
//
//  Created by 凯东源 on 16/9/30.
//  Copyright © 2016年 凯东源. All rights reserved.
//

#import "OrderDetailViewController.h"
#import "Tools.h"
#import "OrderDetailTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TransportInformationViewController.h"
#import "TransportInformationService.h"
#import <MBProgressHUD.h>
#import "AuditService.h"
#import "AppDelegate.h"
#import "PhotoBroswerVC.h"
#import "OrderingViewController.h"
#import "OrderOneAuditViewController.h"
#import "OrderFinishViewController.h"

@interface OrderDetailViewController ()<UITableViewDelegate, UITableViewDataSource, TransportInformationServiceDelegate, AuditServiceDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *myScrollView;

// 订单编号
@property (weak, nonatomic) IBOutlet UILabel *orderNoLabel;

// 订单创建时间
@property (weak, nonatomic) IBOutlet UILabel *createTimeLabel;

//订单客户名称
@property (weak, nonatomic) IBOutlet UILabel *customerNameLabel;

// 订单客户地址
@property (weak, nonatomic) IBOutlet UILabel *customerAddressLabel;

// 订单起始地址
@property (weak, nonatomic) IBOutlet UILabel *beginAddressLabel;

// 下单员
@property (weak, nonatomic) IBOutlet UILabel *USER_NAME;

// 客户姓名
@property (weak, nonatomic) IBOutlet UILabel *ORD_TO_CNAME;

// 客户电话
@property (weak, nonatomic) IBOutlet UILabel *TO_CTEL;


// 下单数量
@property (weak, nonatomic) IBOutlet UILabel *orderNumberLabel;

// 订单总重
@property (weak, nonatomic) IBOutlet UILabel *orderTotalWeigthLabel;

// 订单体积
@property (weak, nonatomic) IBOutlet UILabel *orderVolumeLabel;

// 订单流程
@property (weak, nonatomic) IBOutlet UILabel *orderProcessLabel;

// 订单状态
@property (weak, nonatomic) IBOutlet UILabel *orderStatusLabel;

// 付款方式
@property (weak, nonatomic) IBOutlet UILabel *payMethodLabel;

// 货物信息
@property (weak, nonatomic) IBOutlet UITableView *orderTableView;

// ScrollView高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewHeight;

// 头部View高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headViewHeight;

// 货物信息TableView高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *orderTableViewHeight;

// 尾部View高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tailViewHeight;

// 附件View高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *attachmentViewHeight;

// 审核View高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *auditViewHeight;

// 货物信息
@property (strong, nonatomic) NSMutableArray *arrGoods;

// 采购总额
@property (weak, nonatomic) IBOutlet UILabel *LOTTABLE06;

// 销售总额
@property (weak, nonatomic) IBOutlet UILabel *nowPriceLabel;

// 总毛利
@property (weak, nonatomic) IBOutlet UILabel *TotalGrossProfit;

// 总毛利率
@property (weak, nonatomic) IBOutlet UILabel *TotalGrossProfitRate;


// 备注
@property (weak, nonatomic) IBOutlet UILabel *reMarkLabel;

// 图片1
@property (weak, nonatomic) IBOutlet UIImageView *attachmentImageView;

// 图片2
@property (weak, nonatomic) IBOutlet UIImageView *TO_IMAGE1;

// 图片3
@property (weak, nonatomic) IBOutlet UIImageView *TO_IMAGE2;

// 图片4
@property (weak, nonatomic) IBOutlet UIImageView *TO_IMAGE3;

// 无图片提示
@property (weak, nonatomic) IBOutlet UILabel *NoPicturePromptLabel;

// 提示6
@property (weak, nonatomic) IBOutlet UIView *promptLabel6View;

// 图片路径数组
@property (strong, nonatomic) NSMutableArray *imagesPath;

// 图片数组
@property (strong, nonatomic) NSMutableArray *imagess;

// 提示6，没审核权限不显示
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *promptLabel6ViewHeight;

// 审核View
@property (weak, nonatomic) IBOutlet UIView *auditView;

// 打回原因
@property (weak, nonatomic) IBOutlet UITextView *refuseReasonTextV;

// 打回原因 提示
@property (weak, nonatomic) IBOutlet UILabel *refuseReasonPromptLabel;

// 查看物流信息
- (IBAction)checkTransportinfoOnclick:(UIButton *)sender;

// 获取物流信息
@property (strong, nonatomic) TransportInformationService *transortService;

// Bottom，查看物流信息按钮
@property (weak, nonatomic) IBOutlet UIView *bottomView;

//
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tailViewHeight_orderMsg;

@property (strong, nonatomic) AuditService *service_audit;

@property (strong, nonatomic) AppDelegate *app;

// 审核状态 通过 或 打回
@property (assign, nonatomic) NSUInteger auditType;

// 客户名称 距下高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *customerName_Bottom;

// 客户地址 距下高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *customerAddress_Bottom;
@property (weak, nonatomic) IBOutlet UIView *xxx;

// 第一次调用 updateViewConstraints
@property (assign, nonatomic) BOOL updateViewConstraints_First;

// headView 高度，由于updateViewConstraints会执行多次，所以记录下来
@property (assign, nonatomic) CGFloat headViewHeightConstant;

// Cell高度 户与业务不显示毛利率和毛利 为100，反则115
@property (assign, nonatomic) CGFloat CellHeight;

// 总进货价
@property (assign, nonatomic) CGFloat total_LOTTABLE06;

@end

// 显示毛利率和毛利
#define kCellHeightOne 115.0

// 客户与业务不显示毛利率和毛利
#define kCellHeightTwo 100.0


// 审核状态 通过 或 打回
typedef enum _LMAuditType {
    LMAuditTypePass  = 0,  // 通过
    LMAuditTypeRefuse      // 打回
} LMAuditType;


@implementation OrderDetailViewController

- (instancetype)init {
    
    if(self = [super init]) {
        
        _arrGoods = [[NSMutableArray alloc] init];
        _transortService = [[TransportInformationService alloc] init];
        _transortService.delegate = self;
        _service_audit = [[AuditService alloc] init];
        _service_audit.delegate = self;
        _app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        _updateViewConstraints_First = NO;
        _imagesPath = [[NSMutableArray alloc] init];
        _imagess = [[NSMutableArray alloc] init];
        
        // 客户与业务 不能看毛利率和毛利
        if([_app.user.USER_TYPE isEqualToString:kPARTY] || [_app.user.USER_TYPE isEqualToString:kBUSINESS]) {
            
            _CellHeight = kCellHeightTwo;
        } else {
            
            _CellHeight = kCellHeightOne;
        }
        _total_LOTTABLE06 = 0;
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"订单详情";
    
    [self dealWithData];
    
    // 计算进货总价
    [self Calculation_total_LOTTABLE06];
    
    [self initUI];
    
    [self fullData];
    
    [self registerCell];
    
    [self dealWithImage];
    
    //    [self addAnimationForLabel];
}


- (void)dealWithImage {
    
    if(![_order.TO_IMAGE isEqualToString:@""]) {
        
        [_imagesPath addObject:[self fd:_order.TO_IMAGE]];
        [_imagess addObject:@""];
    }
    if(![_order.TO_IMAGE1 isEqualToString:@""]) {
        
        [_imagesPath addObject:[self fd:_order.TO_IMAGE1]];
        [_imagess addObject:@""];
    }
    if(![_order.TO_IMAGE2 isEqualToString:@""]) {
        
        [_imagesPath addObject:[self fd:_order.TO_IMAGE2]];
        [_imagess addObject:@""];
    }
    if(![_order.TO_IMAGE3 isEqualToString:@""]) {
        
        [_imagesPath addObject:[self fd:_order.TO_IMAGE3]];
        [_imagess addObject:@""];
    }
    
    for (int i = 0; i < _imagesPath.count; i++) {
        
        UIImage *defaultImage = [UIImage imageNamed:@"ic_add_image"];
        
        if(i == 0) {
            
            [_attachmentImageView sd_setImageWithURL:_imagesPath[i] placeholderImage:defaultImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                [_imagess replaceObjectAtIndex:i withObject:_attachmentImageView.image];
                [_attachmentImageView setHidden:NO];
            }];
        } else if(i == 1) {
            
            [_TO_IMAGE1 sd_setImageWithURL:_imagesPath[i] placeholderImage:defaultImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                [_imagess replaceObjectAtIndex:i withObject:_TO_IMAGE1.image];
                [_TO_IMAGE1 setHidden:NO];
            }];
        } else if(i == 2) {
            
            [_TO_IMAGE2 sd_setImageWithURL:_imagesPath[i] placeholderImage:defaultImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                [_imagess replaceObjectAtIndex:i withObject:_TO_IMAGE2.image];
                [_TO_IMAGE2 setHidden:NO];
            }];
        } else if(i == 3) {
            
            [_TO_IMAGE3 sd_setImageWithURL:_imagesPath[i] placeholderImage:defaultImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                [_imagess replaceObjectAtIndex:i withObject:_TO_IMAGE3.image];
                [_TO_IMAGE3 setHidden:NO];
            }];
        }
    }
    NSLog(@"");
}


- (NSURL *)fd:(NSString *)path {
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@", API_ServerAddress, kGetAutographDir, path]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)updateViewConstraints {
    
    [super updateViewConstraints];
    
    // 第一次执行 updateViewConstraints 记录高度
    if(!_updateViewConstraints_First) {
        
        _headViewHeightConstant = _headViewHeight.constant;
        _updateViewConstraints_First = YES;
    }
    
    // 客户名称 距下高度
    CGFloat OneLineHeight = [Tools getHeightOfString:@"fds" fontSize:13.0 andWidth:99.9];
    
    // 容器宽度
    CGFloat contentWidth = ScreenWidth - 8 - 66.5;
    
    // 客户名称 溢出高度
    CGFloat ORD_TO_NAME_overflowHeight = [Tools getHeightOfString:_order.ORD_TO_NAME fontSize:13.0 andWidth:contentWidth] - OneLineHeight;
    
    if(ORD_TO_NAME_overflowHeight > 0) {
        
        _customerName_Bottom.constant = ORD_TO_NAME_overflowHeight + 5;
    }
    
    // 客户地址 溢出高度
    CGFloat ORD_TO_ADDRESS_overflowHeight = [Tools getHeightOfString:_order.ORD_TO_ADDRESS fontSize:13.0 andWidth:contentWidth] - OneLineHeight;
    
    if(ORD_TO_ADDRESS_overflowHeight > 0) {
        
        _customerAddress_Bottom.constant = ORD_TO_ADDRESS_overflowHeight;
    }
    
    // 给 客户名称与客户地址 的父视图增加高度
    if(ORD_TO_NAME_overflowHeight > 0 || ORD_TO_ADDRESS_overflowHeight > 0) {
        
        _headViewHeight.constant = _headViewHeightConstant + ORD_TO_NAME_overflowHeight + ORD_TO_ADDRESS_overflowHeight;
    }
    
    _orderTableViewHeight.constant = _CellHeight * _arrGoods.count;
    
    if([_order.TO_IMAGE isEqualToString:@""] && [_order.TO_IMAGE1 isEqualToString:@""] && [_order.TO_IMAGE2 isEqualToString:@""]  && [_order.TO_IMAGE3 isEqualToString:@""] ) {
        
        _attachmentViewHeight.constant = 37;
        [_NoPicturePromptLabel setHidden:NO];
    }
    
    // 备注信息换行
    CGFloat width = ScreenWidth - 71.5 - 15;
    
    OneLineHeight = [Tools getHeightOfString:@"org" fontSize:14.0 andWidth:999.0];
    
    CGFloat MultiLineHeight = [Tools getHeightOfString:_order.ORD_REMARK_CONSIGNEE fontSize:14.0 andWidth:width];
    
    CGFloat height = MultiLineHeight - OneLineHeight;
    
    if([Tools getHeightOfString:_order.ORD_REMARK_CONSIGNEE fontSize:14.0 andWidth:height]) {
        
        if(CGRectGetWidth(_reMarkLabel.frame) != 1000) {
            
            _tailViewHeight.constant += height;
        }
    }
    
    // 审核权限 （三种情况下有审核界面   1、是未审核进来的经理，并且工作状态是已确认   2、是已审核进来的管理员   3、超级管理员）
    if(
       
       
       // 情况1
       ((_popClass == [OrderingViewController class]) && [_app.user.USER_TYPE isEqualToString:kMANAGER] && [_order.ORD_WORKFLOW isEqualToString:@"已确认"])
       
       
       ||
       
       
       // 情况2
       ((_popClass == [OrderOneAuditViewController class]) && [_app.user.USER_TYPE isEqualToString:kADMIN])
       
       
       ||
       
       
       // 情况3
       ((_popClass == [OrderingViewController class]) && [_app.user.USER_TYPE isEqualToString:kALL] && [_order.ORD_WORKFLOW isEqualToString:@"已确认"])
       ||
       ((_popClass == [OrderOneAuditViewController class]) && [_app.user.USER_TYPE isEqualToString:kALL])
       
       
       ) {
        
        // 显示审核界面
    } else {
        
        // 不显示审核界面
        _promptLabel6ViewHeight.constant = 0;
        _auditViewHeight.constant = 0;
        [_promptLabel6View setHidden:YES];
        [_auditView setHidden:YES];
    }
    
    // 4个提示 + 订单信息 + 货物信息 + 其它信息 + 附件 + 审核
    _scrollViewHeight.constant = 30 * 4 + _headViewHeight.constant + _orderTableViewHeight.constant + _tailViewHeight.constant + _attachmentViewHeight.constant + _promptLabel6ViewHeight.constant + _auditViewHeight.constant;
}


#pragma mark - 手势

// 查看图片1
- (IBAction)checkPicture1:(UITapGestureRecognizer *)sender {
    
    [self localImageShow:0];
}

// 查看图片2
- (IBAction)checkPicture2:(UITapGestureRecognizer *)sender {
    
    [self localImageShow:1];
}

// 查看图片3
- (IBAction)checkPicture3:(UITapGestureRecognizer *)sender {
    
    [self localImageShow:2];
}

// 查看图片4
- (IBAction)checkPicture4:(UITapGestureRecognizer *)sender {
    
    [self localImageShow:3];
}


#pragma mark - 事件


// 查看物流信息
- (IBAction)checkTransportinfoOnclick:(UIButton *)sender {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_transortService getTransInformationData:_order.IDX];
}


// 审核通过
- (IBAction)auditPassOnclick:(UIButton *)sender {
    
    _auditType = LMAuditTypePass;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_service_audit UpdateAudit:_order.IDX andstrUserName:_app.user.USER_NAME];
}


// 审核打回
- (IBAction)auditRefuseOnclick:(UIButton *)sender {
    
    _auditType = LMAuditTypeRefuse;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_service_audit RuturnAudit:_order.IDX andstrUserName:_app.user.USER_NAME andstrReason:_refuseReasonTextV.text];
}


#pragma mark - 功能函数

// 初始化UI
- (void)initUI {
    
    if([_order.ORD_STATE isEqualToString:@"PENDING"] == YES) {
        _bottomView.hidden = YES;
        _tailViewHeight_orderMsg.constant = 0;
    }
}


// 处理数据
- (void)dealWithData {
    
    for(int i = 0; i < _order.OrderDetails.count; i++) {
        OrderDetailModel *m = _order.OrderDetails[i];
        if([m.PRODUCT_TYPE isEqualToString:@"NR"]) {
            [_arrGoods addObject:m];
        }
    }
}


// 填充数据
- (void)fullData {
    _orderNoLabel.text = _order.ORD_NO;
    _createTimeLabel.text = _order.ORD_DATE_ADD;
    _customerNameLabel.text = _order.ORD_TO_NAME;
    _customerAddressLabel.text = _order.ORD_TO_ADDRESS;
    _beginAddressLabel.text = _order.ORD_FROM_NAME;
    _USER_NAME.text = _order.USER_NAME;
    _ORD_TO_CNAME.text = _order.ORD_TO_CNAME;
    _TO_CTEL.text = _order.TO_CTEL;
    _orderNumberLabel.text = [NSString stringWithFormat:@"%.1f台", _order.ORD_QTY];
    _orderTotalWeigthLabel.text = [NSString stringWithFormat:@"%@吨", _order.ORD_WEIGHT];
    _orderVolumeLabel.text = [NSString stringWithFormat:@"%@m³", _order.ORD_VOLUME];
    _orderProcessLabel.text = _order.ORD_WORKFLOW;
    _orderStatusLabel.text = [Tools getOrderStatus:_order.ORD_STATE];
    _payMethodLabel.text = [Tools getPaymentType:_order.PAYMENT_TYPE];
    _nowPriceLabel.text = [NSString stringWithFormat:@"￥%.1f", _order.ACT_PRICE];
    
    // 进货价
    _LOTTABLE06.text = [NSString stringWithFormat:@"￥%.1f", _total_LOTTABLE06];
    
    // 毛利润=收入-成本   毛利率=（不含税售价－不含税进价）/不含税售价×100%
    
    // 总毛利润
    _TotalGrossProfit.text = [NSString stringWithFormat:@"￥%.1f", _order.ACT_PRICE - _total_LOTTABLE06];
    
    // 总毛利润
    CGFloat TotalGrossProfitRate_a = ((_order.ACT_PRICE - _total_LOTTABLE06) / _order.ACT_PRICE) * 100.0;
    _TotalGrossProfitRate.text = TotalGrossProfitRate_a ? [NSString stringWithFormat:@"%.1f%%", TotalGrossProfitRate_a] : @"0%";
    
    _reMarkLabel.text = [_order.ORD_REMARK_CONSIGNEE isEqualToString:@""] ? @"无" : _order.ORD_REMARK_CONSIGNEE;
}


// 注册Cell
- (void)registerCell {
    
    [_orderTableView registerNib:[UINib nibWithNibName:@"OrderDetailTableViewCell" bundle:nil] forCellReuseIdentifier:@"OrderDetailTableViewCell"];
    _orderTableView.separatorStyle = NO;
}


// 给Label添加走马灯动画
- (void)addAnimationForLabel {
    
    // 给客户名称添加走马灯
    [_customerNameLabel sizeToFit];
    CGFloat overflowWidth = _customerNameLabel.frame.size.width - (ScreenWidth - (15 + 70));
    if(overflowWidth > 0) {
        [Tools msgChange:overflowWidth andLabel:_customerNameLabel andBeginAnimations:@"OrderDetailViewController.m1"];
    }
    
    // 给客户地址添加走马灯
    [_customerAddressLabel sizeToFit];
    overflowWidth = _customerAddressLabel.frame.size.width - (ScreenWidth - (15 + 70));
    if(overflowWidth > 0) {
        [Tools msgChange:overflowWidth andLabel:_customerAddressLabel andBeginAnimations:@"OrderDetailViewController.m2"];
    }
}


- (void)successOfAudit:(NSString *)msg {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Tools showAlert:self.view andTitle:msg];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSString *Ordering = [NSString stringWithFormat:@"k%@RequestNetwork", [OrderingViewController class]];
        NSString *OrderOneAudit = [NSString stringWithFormat:@"k%@RequestNetwork", [OrderOneAuditViewController class]];
        NSString *OrderFinish = [NSString stringWithFormat:@"k%@RequestNetwork", [OrderFinishViewController class]];
        
        
        // 审核成功后 根据用户角色刷新将要pop的TableView
        
        // 经理审核　　　　(通过刷新未审核、已审核)  (打回刷新未审核)
        // 管理员审核　　　(通过刷新已审核、已释放)  (打回刷新未审核、已审核)
        // 超级管理员审核　(通过刷新未审核、已审核、已释放)  (打回刷新未审核、已审核)
        if([_app.user.USER_TYPE isEqualToString:kMANAGER]) {
            
            if(_auditType == LMAuditTypePass) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:Ordering object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:OrderOneAudit object:nil];
            } else if(_auditType == LMAuditTypeRefuse) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:Ordering object:nil];
            }
        } else if([_app.user.USER_TYPE isEqualToString:kADMIN]) {
            
            if(_auditType == LMAuditTypePass) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:OrderOneAudit object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:OrderFinish object:nil];
            } else if(_auditType == LMAuditTypeRefuse) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:Ordering object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:OrderOneAudit object:nil];
            }
        } else if([_app.user.USER_TYPE isEqualToString:kALL]) {
            
            if(_auditType == LMAuditTypePass) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:Ordering object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:OrderOneAudit object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:OrderFinish object:nil];
            } else if(_auditType == LMAuditTypeRefuse) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:Ordering object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:OrderOneAudit object:nil];
            }
        }
        
        usleep(1700000);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.navigationController popViewControllerAnimated:YES];
        });
    });
}


- (void)localImageShow:(NSUInteger)index {
    
    if(_imagess.count == 0) {
        
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    [PhotoBroswerVC show:self type:PhotoBroswerVCTypeZoom index:index photoModelBlock:^NSArray *{
        
        NSArray *localImages = [_imagess copy];
        
        NSMutableArray *modelsM = [NSMutableArray arrayWithCapacity:localImages.count];
        for (NSUInteger i = 0; i < localImages.count; i++) {
            
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = i + 1;
            pbModel.image = localImages[i];
            
            //源frame
            UIImageView *imageV =(UIImageView *) weakSelf.xxx.subviews[i+1];
            pbModel.sourceImageView = imageV;
            
            [modelsM addObject:pbModel];
        }
        
        return modelsM;
    }];
}


// 计算进货总价
- (void)Calculation_total_LOTTABLE06 {
    
    for (int i = 0; i < _arrGoods.count; i++) {
        
        OrderDetailModel *m = _arrGoods[i];
        NSLog(@"ORDER_QTY:%f", m.ORDER_QTY);
        NSLog(@"ISSUE_QTY:%f", m.ISSUE_QTY);
        _total_LOTTABLE06 += ([m.LOTTABLE06 floatValue] * m.ORDER_QTY);
    }
}


#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(tableView.tag == 1001) {
        
        return _arrGoods.count;
    } else {
        
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //处理界面
    static NSString *cellID = @"OrderDetailTableViewCell";
    OrderDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    //处理数据
    OrderDetailModel *m = nil;
    if(tableView.tag == 1001) {
        
        m = _arrGoods[indexPath.row];
    }
    
    cell.orderDetailM = m;
    
    //返回Cell
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return _CellHeight;
}


#pragma mark - TransportInformationServiceDelegate

- (void)successOfTransportInformation:(OrderTmsModel *)product {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    TransportInformationViewController *vc = [[TransportInformationViewController alloc] init];
    vc.tmsInformtions = product;
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)failureOfTransportInformation:(NSString *)msg {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Tools showAlert:self.view andTitle:msg ? msg : @"获取信息失败"];
}


#pragma mark - AuditServiceDelegate

- (void)successOfAuditPass:(NSString *)msg {
    
    [self successOfAudit:msg];
}


- (void)failureOfAuditPass:(NSString *)msg {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Tools showAlert:self.view andTitle:msg];
}


- (void)successOfAuditRefuse:(NSString *)msg {
    
    [self successOfAudit:msg];
}


- (void)failureOfAuditRefuse:(NSString *)msg {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Tools showAlert:self.view andTitle:msg];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text {
    
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    if (![text isEqualToString:@""]) {
        
        _refuseReasonPromptLabel.hidden = YES;
    }
    
    if ([text isEqualToString:@""] && range.location == 0 && range.length == 1) {
        
        _refuseReasonPromptLabel.hidden = NO;
    }
    
    return YES;
}

@end
