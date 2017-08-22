//
//  ChartViewController.m
//  Order
//
//  Created by 凯东源 on 16/10/20.
//  Copyright © 2016年 凯东源. All rights reserved.
//

#import "ChartViewController.h"
#import "MyPNPieChart.h"
#import "CustomerChartModel.h"
#import <MBProgressHUD.h>
#import "ChartService.h"
#import "Tools.h"
#import "ProductChartModel.h"
#import "SelectGoodsService.h"
#import "ProductTbModel.h"


@interface TimeLabel : UILabel

@property (copy, nonatomic) NSString *time;

@end

@implementation TimeLabel



@end

@interface ChartViewController ()<ChartServiceDelegate, SelectGoodsServiceDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *picChartView;

///
@property (strong, nonatomic) MyPNPieChart *pieChartView;

@property (strong, nonatomic) NSMutableArray *pieItems;

//饼状图高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollContentViewHeight;

//选择报表类型点击事件
- (IBAction)headViewOnclick:(UITapGestureRecognizer *)sender;

@property (weak, nonatomic) IBOutlet UILabel *whatChartLabel;

@property (strong, nonatomic) ChartService *service;

@property (weak, nonatomic) IBOutlet UIView *barChartView;

//圆饼分析模式
- (IBAction)pieChartOnclick:(UIButton *)sender;

//条形统计模式
- (IBAction)barChartOnclick:(UIButton *)sender;

//条形图底部Lable
@property (strong, nonatomic) NSMutableArray *arrXLabels;

//条形图要显示的数据
@property (strong, nonatomic) NSMutableArray *arrYValues;

//当前显示报表类型
@property (copy, nonatomic) NSString *currentChartType;

//当前显示圆饼图还是条形图 1代表圆饼图 2代表条形图
@property (assign, nonatomic) int barOrPieChart;

@property (strong, nonatomic) NSMutableArray *colors;

//条形图View的宽度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *barChartScrollContentViewWidth;

//饼图可见区域大小
@property (weak, nonatomic) IBOutlet UIView *pieVisibleView;

//条形图可见区域大小
@property (weak, nonatomic) IBOutlet UIView *barvisibleView;

// 获取产品类型
@property (strong, nonatomic) SelectGoodsService *selectGoodsService;

// 产品类型
@property (strong, nonatomic) NSMutableArray *productTypes;

// 第一次请求，请求客户销量 和 产品类型
//@property (assign, nonatomic) BOOL firstRequest;

@property (strong, nonatomic)PNBarChart *barChart;

// 开始时间
@property (weak, nonatomic) IBOutlet TimeLabel *startDateLabel;

// 结束时间
@property (weak, nonatomic) IBOutlet TimeLabel *endDateLabel;

// 显示时间选择器控件
@property (strong, nonatomic) UIView *coView;

@property (strong, nonatomic) NSDateFormatter *formatter;

// 时间选择器是否弹出
@property (assign, nonatomic) BOOL isShowDatePicker;

// 已经选择的时间
@property (strong, nonatomic) NSDate *selectedDate;

// 客户数量总数
@property (assign, nonatomic) CGFloat CustomerTotalQTY;

// 产品数量总数
@property (assign, nonatomic) CGFloat ProductChartQTY;

@end

@implementation ChartViewController

- (instancetype)init {
    if(self = [super init]) {
        
        _pieItems = [[NSMutableArray alloc] init];
        _service = [[ChartService alloc] init];
        _service.delegate = self;
        
        _arrXLabels = [[NSMutableArray alloc] init];
        _arrYValues = [[NSMutableArray alloc] init];
        
        _currentChartType = mTagGetCustomerChartDataList;
        _barOrPieChart = 1;
        
        _colors = [[NSMutableArray alloc] init];
        
        _selectGoodsService = [[SelectGoodsService alloc] init];
        _selectGoodsService.delegate = self;
        
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        _selectedDate = [NSDate date];
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"查看报表";
    
    [self addColor];
    
    [self initUI];
}


- (void)updateViewConstraints {
    
    [super updateViewConstraints];
    
    // 客户名称，单行15高度
    CGFloat lineHeight = 0;
    
    if([_currentChartType isEqualToString:mTagGetCustomerChartDataList]) {
        for (int i = 0; i < _arrM.count; i++) {
            
            CustomerChartModel *customer = _arrM[i];
            
            NSString *des = [self GetCustomerChartDes:customer];
            
            lineHeight += [Tools getHeightOfString:des fontSize:12 andWidth:(ScreenWidth - 60)];
            NSLog(@"lineHeight：%f", lineHeight);
        }
    } else if([_currentChartType isEqualToString:mTagGetProductChartDataList]){
        
        for (int i = 0; i < _arrM.count; i++) {
            
            ProductChartModel *product = _arrM[i];
            
            NSString *des = [self GetProductChartDes:product];
            
            lineHeight += [Tools getHeightOfString:des fontSize:12 andWidth:(ScreenWidth - 60)];
            NSLog(@"lineHeight：%f", lineHeight);
        }
    }
    
    
    
    _scrollContentViewHeight.constant = ScreenWidth + 10 + lineHeight + 15;
    
    _barChartScrollContentViewWidth.constant = 60 + _arrM.count * 120;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}


- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    _CustomerTotalQTY = 0;
    _arrM = nil;
}


- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self requestCUSTOMER_CHART_DATA];
    _currentChartType = mTagGetCustomerChartDataList;
    
    [_selectGoodsService getProductTypesData];
}

- (void)initUI {
    
    _barvisibleView.hidden = YES;
    _startDateLabel.time = @"1980-08-26 00:00:00";
    _startDateLabel.text = @"1980-08-26";
    
    _endDateLabel.time = [Tools getCurrentDate];
    _endDateLabel.text = [[Tools getCurrentDate] substringToIndex:10];
}

- (void)addColor {
    
    [_colors addObject:[UIColor blueColor]];
    [_colors addObject:[UIColor cyanColor]];
    [_colors addObject:[UIColor greenColor]];
    [_colors addObject:[UIColor brownColor]];
    [_colors addObject:[UIColor redColor]];
    [_colors addObject:[UIColor yellowColor]];
    [_colors addObject:[UIColor purpleColor]];
    [_colors addObject:[UIColor orangeColor]];
    [_colors addObject:[UIColor magentaColor]];
    [_colors addObject:[UIColor colorWithRed:135 / 255.0 green:206 / 255.0 blue:235 / 255.0 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:255 / 255.0 green:235 / 2550. blue:205 / 255.0 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:220 / 255.0 green:220 / 255.0 blue:220 / 255.0 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:221 / 255.0 green:160 / 255.0 blue:221 / 255.0 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:255 / 255.0 green:99 / 255.0 blue:71 / 255.0 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:210 / 255.0 green:180 / 255.0 blue:140 / 255.0 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:61 / 255.0 green:89 / 255.0 blue:171 / 255.0 alpha:1.0]];
    
    //以下备用重复
    [_colors addObject:[UIColor colorWithRed:127 / 255.0 green:255 / 255.0 blue:0 / 255.0 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:192 / 255.0 green:192 / 255.0 blue:192 / 255.0 alpha:1.0]];
    [_colors addObject:[UIColor colorWithRed:255 / 255.0 green:192 / 255.0 blue:203 / 255.0 alpha:1.0]];
    [_colors addObject:[UIColor blueColor]];
    [_colors addObject:[UIColor cyanColor]];
    [_colors addObject:[UIColor greenColor]];
    [_colors addObject:[UIColor brownColor]];
    [_colors addObject:[UIColor redColor]];
    [_colors addObject:[UIColor yellowColor]];
    [_colors addObject:[UIColor purpleColor]];
    [_colors addObject:[UIColor orangeColor]];
    [_colors addObject:[UIColor magentaColor]];
}


// 处理数据
- (void)dealWithData:(NSString *)type  {
    
    [_arrXLabels removeAllObjects];
    [_arrYValues removeAllObjects];
    
    if([type isEqualToString:mTagGetCustomerChartDataList]) {
        
        for (int i = 0; i < _arrM.count; i++) {
            CustomerChartModel *model = _arrM[i];
            [_arrXLabels addObject:model.TO_CITY];
            [_arrYValues addObject:@(model.ORD_QTY)];
            [_arrYValues addObject:@(model.ORD_QTY)];
        }
    } else if ([type isEqualToString:mTagGetProductChartDataList]) {
        
        for (int i = 0; i < _arrM.count; i++) {
            ProductChartModel *model = _arrM[i];
            [_arrXLabels addObject:model.PRODUCT_NAME];
            [_arrYValues addObject:@([model.PO_QTY floatValue])];
        }
    }
}


- (void)addPieChartView:(NSString *)type {
    
    _pieVisibleView.hidden = NO;
    _barvisibleView.hidden = !_pieVisibleView.hidden;
    
    [_pieItems removeAllObjects];
    
    if([type isEqualToString:mTagGetCustomerChartDataList]) {
        
        for (int i = 0; i < _arrM.count; i++) {
            
            CustomerChartModel *m = _arrM[i];
            CGFloat value = 0;
            NSString *des = @"";
            value = (CGFloat)m.ORD_QTY;
            des = [self GetCustomerChartDes:m];
            
            @try {
                PNPieChartDataItem *item = [PNPieChartDataItem dataItemWithValue:value color:_colors[i] description:des];
                [_pieItems addObject:item];
            } @catch (NSException *exception) {
                
                [Tools showAlert:self.view andTitle:@"颜色值不够用"];
            }
        }
        
        NSArray *items = [_pieItems copy];
        
        [self addPieChart:items andCenterTitle:@"客户销量统计"];
    } else if([type isEqualToString:mTagGetProductChartDataList]) {
        
        for (int i = 0; i < _arrM.count; i++) {
            
            ProductChartModel *m = _arrM[i];
            CGFloat value = 0;
            NSString *des = @"";
            value = [m.PO_QTY floatValue];
            des = [self GetProductChartDes:m];
            
            @try {
                PNPieChartDataItem *item = [PNPieChartDataItem dataItemWithValue:value color:_colors[i] description:des];
                [_pieItems addObject:item];
            } @catch (NSException *exception) {
                [Tools showAlert:self.view andTitle:@"颜色值不够用"];
            }
        }
        
        NSArray *items = [_pieItems copy];
        
        [self addPieChart:items andCenterTitle:@"产品销量统计"];
    }
}


- (void)addPieChart:(NSArray *)items andCenterTitle:(NSString *)centerTitle {
    
    [self clearPieChart];
    
    //中心Label
    UILabel *centerLabel = nil;
    
    _pieChartView = [[MyPNPieChart alloc] initWithFrame:_picChartView.bounds items:items];
    
    centerLabel = [[UILabel alloc] init];
    centerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    centerLabel.numberOfLines = 0;
    centerLabel.textAlignment = NSTextAlignmentCenter;
    centerLabel.font = [UIFont systemFontOfSize:13];
    [centerLabel setBounds:CGRectMake(0, 0, _pieChartView.innerCircleRadius * 2 - 8, _pieChartView.innerCircleRadius * 2)];
    [centerLabel setCenter:CGPointMake(CGRectGetWidth(_picChartView.frame) / 2, CGRectGetHeight(_picChartView.frame) / 2)];
    centerLabel.text = centerTitle;
    
    _pieChartView.descriptionTextColor = [UIColor whiteColor];
    _pieChartView.descriptionTextFont  = [UIFont fontWithName:@"Avenir-Medium" size:12.0];
    _pieChartView.duration = 2.0;
    _pieChartView.showOnlyValues = YES;
    [_pieChartView strokeChart];
    [_pieChartView addSubview:centerLabel];
    [_picChartView addSubview:_pieChartView];
    
    _pieChartView.legendStyle = PNLegendItemStyleStacked;
    UIView *legend = [_pieChartView getLegendWithMaxWidth:ScreenWidth - 30];
    CGFloat legendW = CGRectGetWidth(legend.frame);
    CGFloat legendX = CGRectGetMinX(_pieChartView.frame);
    CGFloat legendY = CGRectGetMaxY(_pieChartView.frame) + 15;
    [legend setFrame:CGRectMake(legendX, legendY, legendW, CGRectGetHeight(legend.frame))];
    [_picChartView addSubview:legend];
}


- (void)addBarChart {
    
    _barvisibleView.hidden = NO;
    _pieVisibleView.hidden = !_barvisibleView.hidden;
    
    [self clearBarChart];
    
    //如果_arrYValues.count == 0，程序会崩溃
    if(_arrYValues.count == 0) {
        
        [Tools showAlert:self.view andTitle:@"没有数据"];
        return;
    }
    
    _barChart = [[PNBarChart alloc] initWithFrame:_barChartView.bounds];
    _barChart.yChartLabelWidth = 35.0;
    _barChart.chartMarginLeft = 45.0;
    _barChart.chartMarginRight = 10.0;
    _barChart.chartMarginTop = 7.0;
    _barChart.chartMarginBottom = 17.0;
    
    _barChart.yLabelFormatter = ^(CGFloat value) {
        
        return [NSString stringWithFormat:@"%zi", (NSUInteger)value];
    };
    
    _barChart.showChartBorder = YES;
    
    [_barChart setXLabels:_arrXLabels];
    [_barChart setYValues:_arrYValues];
    
    [_barChart strokeChart];
    [_barChartView addSubview:_barChart];
}


#pragma mark - 选择时间模块

- (void)createDatePicker:(NSUInteger)tag {
    
    if(_isShowDatePicker) return;
    
    if(tag == 0) {
        
        // 记住上次时间
        _selectedDate = [_formatter dateFromString:_startDateLabel.time];
    } else if(tag == 1) {
        
        // 记住上次时间
        _selectedDate = [_formatter dateFromString:_endDateLabel.time];
        
        // 分秒清零 例：2017-05-05 00:00:00   确定时间后 +23:59:59
        // 不能在这里加，因为滚动时间控件会使用时间分秒清零
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *currentDay = [formatter stringFromDate:_selectedDate];
        _selectedDate = [formatter dateFromString:currentDay];
    }
    
    CGFloat startX = 10;
    CGFloat width = self.view.frame.size.width - startX * 2;
    CGFloat height = width * 2 / 3;
    CGFloat startY = (ScreenHeight - height) / 2;
    CGFloat buttonHeight = 35;
    CGFloat buttonWidth = 100;
    CGFloat buttonSpan = (width-buttonWidth * 2) / 3;
    /// 添加背景
    _coView = [[UIView alloc] initWithFrame:CGRectMake(startX, startY, width, height + buttonHeight + 10)];
    _coView.backgroundColor = [UIColor lightGrayColor];
    [_coView setCenter:CGPointMake(ScreenWidth / 2, ScreenHeight / 2)];
    [self.view addSubview:_coView];
    
    // 添加取消按钮
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonSpan, height + 5, buttonWidth, buttonHeight)];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton setBackgroundColor:ZSDColor];
    cancelButton.layer.cornerRadius = 2.0;
    [cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_coView addSubview:cancelButton];
    
    // 添加确认按钮
    UIButton *sureButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonSpan * 2 + buttonWidth, height + 5, buttonWidth, buttonHeight)];
    sureButton.tag = tag;
    [sureButton setTitle:@"确定" forState:UIControlStateNormal];
    [sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sureButton setBackgroundColor:ZSDColor];
    sureButton.layer.cornerRadius = 2.0;
    [sureButton addTarget:self action:@selector(sureButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_coView addSubview:sureButton];
    
    //创建日期选择器
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    //将日期选择器区域设置为中文，则选择器日期显示为中文
    datePicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh_CN"];
    //设置样式，当前设为同时显示日期和时间
    datePicker.datePickerMode = UIDatePickerModeDate;
    
    datePicker.minimumDate = [_formatter dateFromString:@"1949-10-01"];
    datePicker.maximumDate = [NSDate date];
    
    // 设置默认时间
    datePicker.date = _selectedDate;
    
    //注意：action里面的方法名后面需要加个冒号“：”
    [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    [_coView addSubview:datePicker];
    
    _isShowDatePicker = YES;
}

- (void)sureButtonClick:(UIButton *)sender {
    
    // 移除UI
    [_coView removeFromSuperview];
    _isShowDatePicker = NO;
    
    // 根据tag 赋值Label
    if(sender.tag == 0) {
        
        _startDateLabel.time = [_formatter stringFromDate:_selectedDate];
        _startDateLabel.text = [[_formatter stringFromDate:_selectedDate] substringToIndex:10];
    } else if(sender.tag == 1) {
        
        // 结束时间 + 23小时59分59秒
        NSTimeInterval interval = 24 * 60 * 60 - 1;
        NSDate *dateLast = [[NSDate alloc] initWithTimeInterval:interval sinceDate:_selectedDate];
        NSString *timeLast = [_formatter stringFromDate:dateLast];
        _endDateLabel.time = timeLast;
        _endDateLabel.text = [timeLast substringToIndex:10];
    }
    
    // 请求数据
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if([_currentChartType isEqualToString:mTagGetCustomerChartDataList]) {
        
        [self requestCUSTOMER_CHART_DATA];
    } else if([_currentChartType isEqualToString:mTagGetProductChartDataList]) {
        
        [self requestPRODUCT_CHART_DATA:_whatChartLabel.text];
    }
}

- (void)cancelButtonClick {
    
    [_coView removeFromSuperview];
    _isShowDatePicker = NO;
}


// 日期选择器响应方法
- (void)dateChanged:(UIDatePicker *)datePicker {
    
    _selectedDate = datePicker.date;
}


#pragma mark - 手势

- (IBAction)timeOnclick:(UITapGestureRecognizer *)sender {
    
    CGPoint touchPoint = [sender locationInView:self.view];
    
    // calculate index
    NSInteger tapIndex = touchPoint.x / (self.view.frame.size.width / 2);
    
    if(tapIndex == 0) {
        
        // 起始时间
        
    } else if(tapIndex == 1) {
        
        // 结束时间
        
    }
    
    [self createDatePicker:tapIndex];
}


#pragma mark - 点击事件

// 点击选择报表类型
- (IBAction)headViewOnclick:(UITapGestureRecognizer *)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请选报表类型" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil];
    alert.delegate = self;
    
    [alert addButtonWithTitle:@"客户报表"];
    
    for(int i = 0; i < _productTypes.count; i++) {
        
        ProductTbModel *m = _productTypes[i];
        NSString *title = m.PRODUCT_TYPE;
        [alert addButtonWithTitle:title];
    }
    [alert show];
}

- (IBAction)pieChartOnclick:(UIButton *)sender {
    
    if(_arrM.count > 0) {
        
        [self addPieChartView:_currentChartType];
        
        //记录下来，我当前在看饼状图
        _barOrPieChart = 1;
    } else {
        [Tools showAlert:self.view andTitle:@"没有数据"];
    }
}


- (IBAction)barChartOnclick:(UIButton *)sender {
    
    [self dealWithData:_currentChartType];
    [self addBarChart];
    
    //记录下来，我当前在看条形图
    _barOrPieChart = 2;
}


#pragma mark - 功能函数

// 饼状图清屏
- (void)clearPieChart {
    
    NSUInteger count = _picChartView.subviews.count;
    for (int i = 0; i < count; i++) {
        
        UIView *v = _picChartView.subviews[0];
        [v removeFromSuperview];
    }
}


// 柱状图清屏
- (void)clearBarChart {
    
    if(_barChart) {
        
        [_barChart removeFromSuperview];
        _barChart = nil;
    }
}


/**
 降序排序
 
 @param array 排序前
 
 @return 排序后
 */
- (NSMutableArray *)SortAsc_CustomerChartModel:(NSMutableArray *)array {
    
    for (int  i = 0; i < [array count] - 1; i++) {
        
        for (int j = i + 1; j < [array count]; j++) {
            
            CustomerChartModel *iM = array[i];
            CustomerChartModel *jM = array[j];
            if (iM.ORD_QTY < jM.ORD_QTY) {
                
                //交换
                [array exchangeObjectAtIndex:i withObjectAtIndex:j];
            }
        }
    }
    return array;
}


/**
 降序排序
 
 @param array 排序前
 
 @return 排序后
 */
- (NSMutableArray *)SortAsc_ProductChartModel:(NSMutableArray *)array {
    
    for (int  i = 0; i < [array count] - 1; i++) {
        
        for (int j = i + 1; j < [array count]; j++) {
            
            ProductChartModel *iM = array[i];
            ProductChartModel *jM = array[j];
            if (iM.PO_QTY < jM.PO_QTY) {
                
                //交换
                [array exchangeObjectAtIndex:i withObjectAtIndex:j];
            }
        }
    }
    return array;
}


// 获取客户报表描述
- (NSString *)GetCustomerChartDes:(CustomerChartModel *)customer {
    
    return [NSString stringWithFormat:@"%@  数量:%.0f件  比重:%.1f%%", customer.TO_CITY, customer.ORD_QTY, (customer.ORD_QTY / _CustomerTotalQTY) * 100];
}


// 获取产品报表描述
- (NSString *)GetProductChartDes:(ProductChartModel *)product {
    
    return [NSString stringWithFormat:@"%@  数量:%@件  比重:%.1f%%", product.PRODUCT_NAME, product.PO_QTY, ([product.PO_QTY floatValue] / _ProductChartQTY) * 100];
}


#pragma mark - 网络请求

// 请求客户报表
- (void)requestCUSTOMER_CHART_DATA {
    
    [_service getChartDataList:API_GET_CUSTOMER_CHART_DATA andTag:mTagGetCustomerChartDataList andstrStDate:_startDateLabel.time andstrEdDate:_endDateLabel.time andstrProductType:@""];
}


// 请求产品报表
- (void)requestPRODUCT_CHART_DATA:(NSString *)productType {
    
    [_service getChartDataList:API_GET_PRODUCT_CHART_DATA andTag:mTagGetProductChartDataList andstrStDate:_startDateLabel.time andstrEdDate:_endDateLabel.time andstrProductType:productType];
}


#pragma mark - ChartServiceDelegate

//获取客户报表信息
- (void)successOfChartServiceWithCustomer:(NSMutableArray *)customerChart {
    
    _arrM = customerChart;
    
    [self SortAsc_CustomerChartModel:_arrM];
    
    [self updateViewConstraints];
    
    // 计算总数，方便求百分比
    for (int i = 0; i < _arrM.count; i++) {
        
        CustomerChartModel *CM = _arrM[i];
        _CustomerTotalQTY += CM.ORD_QTY;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        sleep(1);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if(_barOrPieChart == 1) {
                
                [self addPieChartView:mTagGetCustomerChartDataList];
            } else if (_barOrPieChart == 2) {
                
                [self dealWithData:mTagGetCustomerChartDataList];
                [self addBarChart];
            }
        });
    });
}


// 获取产品报表信息
- (void)successOfChartServiceWithProduct:(NSMutableArray *)productChart {
    
    _arrM = productChart;
    
    [self SortAsc_ProductChartModel:_arrM];
    
    [self updateViewConstraints];
    
    // 计算总数，方便求百分比
    for (int i = 0; i < _arrM.count; i++) {
        
        ProductChartModel *PM = _arrM[i];
        _ProductChartQTY += [PM.PO_QTY floatValue];
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        sleep(1);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if(_barOrPieChart == 1) {
                
                [self addPieChartView:mTagGetProductChartDataList];
            } else if (_barOrPieChart == 2) {
                
                [self dealWithData:mTagGetProductChartDataList];
                [self addBarChart];
            }
        });
    });
}


// 获取客户或产品报表信息失败
- (void)failureOfChartService:(NSString *)msg {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Tools showAlert:self.view andTitle:msg ? msg : @"获取报表数据失败！"];
    
    [_arrM removeAllObjects];
    
    [self clearPieChart];
    
    [self clearBarChart];
}


#pragma mark - SelectGoodsServiceDelegate

// 获取产品类型回调
- (void)successOfGetProductTypeData:(NSMutableArray *)productTypes {
    
    ProductTbModel *m = productTypes[0];
    m.PRODUCT_TYPE = @"产品报表";
    _productTypes = productTypes;
}

- (void)failureOfGetProductTypeData:(NSString *)msg {
    
    [Tools showAlert:self.view andTitle:msg ? msg : @"获取产品类型失败"];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSLog(@"buttonIndex:%ld", (long)buttonIndex);
    if(buttonIndex == 0) {
        
        nil;  //点击取消， 不操作
    } else if(buttonIndex == 1) {
        
        // 客户报表
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self requestCUSTOMER_CHART_DATA];
        
        _whatChartLabel.text = @"客户报表";
        _currentChartType = mTagGetCustomerChartDataList;
    } else {
        
        // 产品报表
        ProductTbModel *m = _productTypes[buttonIndex - 2];
        NSLog(@"%@", m.PRODUCT_TYPE);
        
        // buttonIndex为2时，查询全部产品报表
        NSString *productType = nil;
        if(buttonIndex == 2) {
            
            productType = @"";
        } else {
            
            productType = m.PRODUCT_TYPE;
        }
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self requestPRODUCT_CHART_DATA:productType];
        
        _whatChartLabel.text = m.PRODUCT_TYPE;
        _currentChartType = mTagGetProductChartDataList;
    }
}

@end
