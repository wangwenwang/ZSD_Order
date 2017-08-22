//
//  ConfirmOrderViewController.m
//  Order
//
//  Created by 凯东源 on 16/10/21.
//  Copyright © 2016年 凯东源. All rights reserved.
//

#import "ConfirmOrderViewController.h"
#import "ConfirmOrderTableViewCell.h"
#import "ProductModel.h"
#import "PromotionDetailModel.h"
#import "Tools.h"
#import "AppDelegate.h"
#import "AddGiftsViewController.h"
#import "AddGiftsService.h"
#import "MBProgressHUD.h"
#import "OrderGiftModel.h"
#import "ConfirmOrderGiftsTableViewCell.h"
#import "NSString+Trim.h"
#import "OrderConfirmService.h"
#import "LM_alert.h"
#import "UIImage+Compress.h"
#import "PhotoBroswerVC.h"

@interface ConfirmOrderViewController ()<UITableViewDelegate, UITableViewDataSource, ConfirmOrderTableViewCellDelegate, AddGiftsServiceDelegate, OrderConfirmServiceDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIAlertViewDelegate, UIActionSheetDelegate> {
    
    UIImagePickerController *pickerController;
}

#define ProductTableViewCellHeight 69
#define GiftTableViewCellHeight 69

//订单TableView
@property (weak, nonatomic) IBOutlet UITableView *orderTableView;

//订单TableView的高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *orderTableViewHeight;

//提示无赠品
@property (weak, nonatomic) IBOutlet UILabel *noGiftPromptLabel;

//赠品TableView
@property (weak, nonatomic) IBOutlet UITableView *giftTableView;

//添加赠品
@property (weak, nonatomic) IBOutlet UIButton *addGiftButton;

//根据有无产品策略，确定Cell高度
@property (assign, nonatomic) CGFloat productCellHeight;

//已选择的赠品
@property (strong, nonatomic) NSMutableArray *selectedGifts;

//自定义价格视图
@property (weak, nonatomic) IBOutlet UIView *customizePriceView;

//价格上限
@property (weak, nonatomic) IBOutlet UILabel *upperLimi;

//价格下限
@property (weak, nonatomic) IBOutlet UILabel *lowerLimi;

//自定义价格输入框
@property (weak, nonatomic) IBOutlet UITextField *customizePriceF;

//取消自定义价格
- (IBAction)cancelCustomizePriceOnclick:(UIButton *)sender;

//确定自定义价格
- (IBAction)confirmCustomizePriceOnclick:(UIButton *)sender;

//当前弹出自定义价格框的indexRow
@property (assign, nonatomic) NSInteger customizePriceIndexRow;

//遮罩视图
@property (weak, nonatomic) IBOutlet UIView *coverView;

//产品总数
@property (weak, nonatomic) IBOutlet UILabel *totalCountLabel;

//产品原价
@property (weak, nonatomic) IBOutlet UILabel *orgPriceLabel;

//付款方式
@property (weak, nonatomic) IBOutlet UILabel *payTypeLabel;

//促销策略提示
@property (weak, nonatomic) IBOutlet UILabel *promotionPromptLabel;

//促销策略
@property (weak, nonatomic) IBOutlet UILabel *promotionLabel;

//满减总计提示
@property (weak, nonatomic) IBOutlet UILabel *mjTotalPromptLabel;

//满减总计
@property (weak, nonatomic) IBOutlet UILabel *mjTotalLabel;

//实际付款
@property (weak, nonatomic) IBOutlet UILabel *actPriceLabel;

@property (strong, nonatomic) AppDelegate *app;

//备注
@property (weak, nonatomic) IBOutlet UITextView *remarkTextV;

@property (strong, nonatomic) AddGiftsService *addGiftsService;

//scrollView里的视图高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollContentViewHeight;

//赠品TableView高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *giftsTableViewHeight;

/// 赠品(PromotionDetailModel)，从下个界面获取
//@property (strong, nonatomic) NSMutableArray *gifts;

// 收货地址的placeholder
@property (weak, nonatomic) IBOutlet UILabel *adressPlaceholderLabel;

// 备注的placeholder
@property (weak, nonatomic) IBOutlet UILabel *remarkPlaceholderLabel;

/// 显示时间选择器控件
@property (strong, nonatomic) UIView *coView;

///时间选择器是否弹出
@property (assign, nonatomic) BOOL isShowDatePicker;

@property (strong, nonatomic) NSDateFormatter *formatter;

/// 送货时间
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

///// 已经选择的时间
//@property (copy, nonatomic) NSString *selectedTime;

/// 已经选择的时间
@property (strong, nonatomic) NSDate *selectedDate;

/// 是否点击了时间的确定按钮。如果没点击，代表用户没选择时间，即使selectedDate有值也不使用
@property (assign, nonatomic) BOOL isOnclickDateSure;

//选择时间事件
- (IBAction)timeOnclick:(UITapGestureRecognizer *)sender;

//订单确认服务
@property (strong, nonatomic) OrderConfirmService *orderConfirmService;

- (IBAction)confirmOnclick:(UIButton *)sender;


// 收货人姓名
@property (weak, nonatomic) IBOutlet UITextField *nameF;

// 收货人电话
@property (weak, nonatomic) IBOutlet UITextField *telF;

// 收货人地址
@property (weak, nonatomic) IBOutlet UITextView *addressTextV;

// 附件_按钮
@property (weak, nonatomic) IBOutlet UIButton *attachmentBtn;

// 判断键盘状态（弹出与收回）
@property(nonatomic,assign) BOOL keyBoardlsVisible;

// 图片1
@property (weak, nonatomic) IBOutlet UIImageView *picture1ImageView;

// 图片2
@property (weak, nonatomic) IBOutlet UIImageView *picture2ImageView;

// 图片3
@property (weak, nonatomic) IBOutlet UIImageView *picture3ImageView;

// 图片4
@property (weak, nonatomic) IBOutlet UIImageView *picture4ImageView;

// 删除图片1
@property (weak, nonatomic) IBOutlet UIButton *delete1Btn;

// 删除图片2
@property (weak, nonatomic) IBOutlet UIButton *delete2Btn;

// 删除图片3
@property (weak, nonatomic) IBOutlet UIButton *delete3Btn;

// 删除图片4
@property (weak, nonatomic) IBOutlet UIButton *delete4Btn;

// 当前图片类型
@property (assign, nonatomic) NSUInteger currentPictureType;

@property (weak, nonatomic) IBOutlet UIView *xxx1;

@property (weak, nonatomic) IBOutlet UIView *xxx2;

@end

#define KVO_TAG @"tag"

// 照片类型
typedef enum _PictureType {
    
    Picture_TYPE_1  = 0,
    Picture_TYPE_2,
    Picture_TYPE_3,
    Picture_TYPE_4
} PictureType;

@implementation ConfirmOrderViewController

- (instancetype)init {
    
    if(self = [super init]) {
        
        _selectedGifts = [[NSMutableArray alloc] init];
        _customizePriceIndexRow = 0;
        _app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        _addGiftsService = [[AddGiftsService alloc] init];
        _addGiftsService.delegate = self;
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"yyyy-MM-dd"];
        _selectedDate = [NSDate date];
        _orderConfirmService = [[OrderConfirmService alloc] init];
        _orderConfirmService.delegate = self;
        _isOnclickDateSure = NO;
        _keyBoardlsVisible = NO;
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"订单确认";
    
    [self registerCell];
    
    [self dealWithData];
    
    [self createData];
    
    [self addKVO];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self initUI];
    
    [self addNotification];
}


- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}


- (void)updateViewConstraints {
    
    [super updateViewConstraints];
    
    //设置产品TableView高度
    _orderTableViewHeight.constant = _productCellHeight  * _promotionDetailsOfServer.count;
    
    //设置赠品TableView高度
    _giftsTableViewHeight.constant = GiftTableViewCellHeight * _selectedGifts.count;
    
    _scrollContentViewHeight.constant = 785 + _orderTableViewHeight.constant + (_giftTableView.hidden ? 0 : _giftsTableViewHeight.constant);
}


- (void)dealloc {
    
    NSLog(@"%s", __func__);
    [self removeNotification];
    [self removeKVO];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {//相机
        
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            NSLog(@"支持相机");
            [self makePhoto];
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"message:@"请在设置-->隐私-->相机，中开启本应用的相机访问权限！！"delegate:self cancelButtonTitle:@"取消"otherButtonTitles:@"我知道了",nil];
            [alert show];
        }
    } else if (buttonIndex == 1) {//相片
        
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            
            NSLog(@"支持相册");
            [self choosePicture];
        }else{
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"message:@"请在设置-->隐私-->照片，中开启本应用的相机访问权限！！"delegate:self cancelButtonTitle:@"取消"otherButtonTitles:@"我知道了",nil];
            [alert show];
        }
    } else if (buttonIndex == 2) {//图册
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
            
            NSLog(@"支持图库");
            [self pictureLibrary];
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"message:@"请在设置-->隐私-->照片，中开启本应用的相机访问权限！！"delegate:self cancelButtonTitle:@"取消"otherButtonTitles:@"我知道了",nil];
            [alert show];
        }
    }
}


#pragma mark - 手势

- (IBAction)picture1Onclick:(UITapGestureRecognizer *)sender {
    
    _currentPictureType = Picture_TYPE_1;
    
    if(_picture1ImageView.tag) {
        
        [self checkPicture:_picture1ImageView.image andIndex:Picture_TYPE_1];
    } else {
        
        [self addPicture_deal];
    }
}

- (void)addPicture_deal {
    
    // 如果键盘已弹出，等收回后再调用 addPicture 函数
    if(_keyBoardlsVisible) {
        
        [self.view endEditing:NO];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            usleep(600000);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self addPicture];
            });
        });
    } else {
        
        [self addPicture];
    }
}


- (IBAction)picture2Onclick:(UITapGestureRecognizer *)sender {
    
    _currentPictureType = Picture_TYPE_2;
    
    if(_picture2ImageView.tag) {
        
        [self checkPicture:_picture2ImageView.image andIndex:Picture_TYPE_2];
    } else {
        
        [self addPicture_deal];
    }
}


- (IBAction)picture3Onclick:(UITapGestureRecognizer *)sender {
    
    _currentPictureType = Picture_TYPE_3;
    
    if(_picture3ImageView.tag) {
        
        [self checkPicture:_picture3ImageView.image andIndex:Picture_TYPE_3];
    } else {
        
        [self addPicture_deal];
    }
}


- (IBAction)picture4Onclick:(UITapGestureRecognizer *)sender {
    
    _currentPictureType = Picture_TYPE_4;
    
    if(_picture4ImageView.tag) {
        
        [self checkPicture:_picture4ImageView.image andIndex:Picture_TYPE_4];
    } else {
        
        [self addPicture_deal];
    }
}


#pragma mark - KVO

- (void)addKVO {
    
    [_picture1ImageView addObserver:self forKeyPath:KVO_TAG options:NSKeyValueObservingOptionNew context:nil];
    [_picture2ImageView addObserver:self forKeyPath:KVO_TAG options:NSKeyValueObservingOptionNew context:nil];
    [_picture3ImageView addObserver:self forKeyPath:KVO_TAG options:NSKeyValueObservingOptionNew context:nil];
    [_picture4ImageView addObserver:self forKeyPath:KVO_TAG options:NSKeyValueObservingOptionNew context:nil];
}


- (void)removeKVO {
    
    [_picture1ImageView removeObserver:self forKeyPath:KVO_TAG];
    [_picture2ImageView removeObserver:self forKeyPath:KVO_TAG];
    [_picture3ImageView removeObserver:self forKeyPath:KVO_TAG];
    [_picture4ImageView removeObserver:self forKeyPath:KVO_TAG];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([object isKindOfClass:[UIImageView class]]  && [keyPath isEqualToString:KVO_TAG]) {
        
        NSUInteger old = [change[@"old"] integerValue];
        NSUInteger new = [change[@"new"] integerValue];
        NSLog(@"old:%lu, new:%lu", (unsigned long)old, (unsigned long)new);
        
        if(new == 1) {
            
            switch (_currentPictureType) {
                    
                case Picture_TYPE_1:
                    
                    [_delete1Btn setHidden:NO];
                    break;
                    
                case Picture_TYPE_2:
                    
                    [_delete2Btn setHidden:NO];
                    break;
                    
                case Picture_TYPE_3:
                    
                    [_delete3Btn setHidden:NO];
                    break;
                    
                case Picture_TYPE_4:
                    
                    [_delete4Btn setHidden:NO];
                    break;
                    
                default:
                    break;
            }
        } else {
            
            switch (_currentPictureType) {
                    
                case Picture_TYPE_1:
                    
                    [_delete1Btn setHidden:YES];
                    break;
                    
                case Picture_TYPE_2:
                    
                    [_delete2Btn setHidden:YES];
                    break;
                    
                case Picture_TYPE_3:
                    
                    [_delete3Btn setHidden:YES];
                    break;
                    
                case Picture_TYPE_4:
                    
                    [_delete4Btn setHidden:YES];
                    break;
                    
                default:
                    break;
            }
        }
        
        NSLog(@"new:%lu", (unsigned long)new);
    } else {
        
        
    }
}


#pragma mark - 功能函数

- (void)dealWithData {
    
    for (int i = 0; i < _promotionDetailsOfServer.count; i++) {
        
        PromotionDetailModel *m = _promotionDetailsOfServer[i];
        _productCellHeight = ProductTableViewCellHeight + ([m.SALE_REMARK isEqualToString:@""] ? 0 : 15);
    }
}


- (void)addNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshGifts:) name:kConfirmOrderViewControllerRefreshGifts object:nil];
    
    // 监听键盘状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide) name:UIKeyboardWillHideNotification object:nil];
}


- (void)removeNotification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kConfirmOrderViewControllerRefreshGifts object:nil];
    
    // 注销键盘状态
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}


- (void)refreshGifts:(NSNotification *)aNotification {
    
    _selectedGifts = aNotification.userInfo[@"gifts"];
}


- (void)initUI {
    
    //没有赠品
    _noGiftPromptLabel.hidden = _selectedGifts.count;
    
    _giftTableView.hidden = !_selectedGifts.count;
    
    _customizePriceView.hidden = YES;
    _coverView.hidden = YES;
    
    //设置添加赠品按钮是否可见
    NSString *bussinessCode = _app.business.BUSINESS_CODE;
    if([bussinessCode rangeOfString:@"QH"].length > 0 && [_promotionOrder.HAVE_GIFT isEqualToString:@"Y"]) {
        //  if([bussinessName isEqualToString:@"凯东源前海项目"] && [_promotionOrder.HAVE_GIFT isEqualToString:@"Y"]) {
        
        _addGiftButton.hidden = NO;
    } else {
        
        _addGiftButton.hidden = YES;
    }
    
    [self refreshCollectDada];
    
    [_orderTableView reloadData];
    [_giftTableView reloadData];
}


//结算，汇总信息
- (void)refreshCollectDada {
    long long totalCount = 0;
    double orgPrice = 0;
    double actPrice = 0;
    for(int i = 0; i < _promotionDetailsOfServer.count; i++) {
        PromotionDetailModel *m = _promotionDetailsOfServer[i];
        totalCount += m.PO_QTY;
        orgPrice += m.ORG_PRICE * m.PO_QTY;
        actPrice += m.ACT_PRICE * m.PO_QTY;
    }
    _promotionOrder.ACT_PRICE = actPrice;
    for(int i = 0; i < _selectedGifts.count; i++) {
        PromotionDetailModel *m = _selectedGifts[i];
        totalCount += m.PO_QTY;
    }
    _promotionOrder.TOTAL_QTY = totalCount;
    
    //总数
    _totalCountLabel.text = [NSString stringWithFormat:@"%lld", _promotionOrder.TOTAL_QTY];
    
    //原价
    _orgPriceLabel.text = [NSString stringWithFormat:@"￥%.1f", orgPrice];
    
    //付款方式
    _payTypeLabel.text = [Tools getPaymentType:_orderPayType];
    if(_selectedGifts.count > 0) {
        [_addGiftButton setTitle:@"重新添加" forState:UIControlStateNormal];
    } else {
        [_addGiftButton setTitle:@"添加赠品" forState:UIControlStateNormal];
    }
    if([_promotionOrder.MJ_REMARK isEqualToString:@""] || [_promotionOrder.MJ_REMARK isEqualToString:@"+|+"]) {
        _promotionPromptLabel.text = nil;
        _mjTotalPromptLabel.text = nil;
        _promotionLabel.text = nil;
        _mjTotalLabel.text = nil;
        _actPriceLabel.text = [NSString stringWithFormat:@"￥%.1f", _promotionOrder.ACT_PRICE];
    } else {
        _promotionPromptLabel.text = @"促销策略：";
        _mjTotalPromptLabel.text = @"满减总计：";
        _promotionLabel.text = _promotionOrder.MJ_REMARK;
        _mjTotalLabel.text = [NSString stringWithFormat:@"￥%.1f", _promotionOrder.MJ_PRICE];
        _actPriceLabel.text = [NSString stringWithFormat:@"￥%.1f", _promotionOrder.ACT_PRICE - _promotionOrder.MJ_PRICE];
    }
    
}


- (void)registerCell {
    [_orderTableView registerNib:[UINib nibWithNibName:@"ConfirmOrderTableViewCell" bundle:nil] forCellReuseIdentifier:@"ConfirmOrderTableViewCell"];
    _orderTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [_giftTableView registerNib:[UINib nibWithNibName:@"ConfirmOrderGiftsTableViewCell" bundle:nil] forCellReuseIdentifier:@"ConfirmOrderGiftsTableViewCell"];
    _giftTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}


- (void)setNewPrice:(PromotionDetailModel *)m andPrice:(CGFloat)price {
    m.ACT_PRICE = price;
    for (int i = 0; i < _productsOfLocal.count; i++) {
        ProductModel *product = _productsOfLocal[i];
        if(m.PRODUCT_IDX == product.IDX) {
            product.PRODUCT_CURRENT_PRICE += 0.1;
        }
    }
    [_orderTableView reloadData];
}


- (void)checkPicture:(UIImage *)image andIndex:(NSUInteger)index {
    
    [PhotoBroswerVC show:self type:PhotoBroswerVCTypeZoom index:0 photoModelBlock:^NSArray *{
        
        NSArray *localImages = @[image];
        
        NSMutableArray *modelsM = [NSMutableArray arrayWithCapacity:localImages.count];
        for (NSUInteger i = 0; i< localImages.count; i++) {
            
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = i + 1;
            pbModel.image = localImages[i];
            
            //源frame
            UIImageView *imageV = nil;
            if(index == 3) {
                
                imageV = (UIImageView *) _xxx2.subviews[0];
            } else {
                
                imageV = (UIImageView *) _xxx1.subviews[index];
            }
            pbModel.sourceImageView = imageV;
            
            [modelsM addObject:pbModel];
        }
        
        return modelsM;
    }];
}


#pragma mark - 相机

- (void)addPicture {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册",@"图库",nil];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}


- (void)createData {
    
    // 初始化pickerController
    pickerController = [[UIImagePickerController alloc] init];
    pickerController.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    pickerController.delegate = self;
}


// 跳转到imagePicker里
- (void)makePhoto {
    
    pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:pickerController animated:YES completion:nil];
}


// 跳转到相册
- (void)choosePicture {
    
    pickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:pickerController animated:YES completion:nil];
}


// 跳转图库
- (void)pictureLibrary {
    
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:pickerController animated:YES completion:nil];
}


#pragma mark - 点击事件


- (IBAction)addGiftOnclick:(UIButton *)sender {
    
    if([_promotionOrder.HAVE_GIFT isEqualToString:@"Y"] && _promotionOrder.OrderDetails.count > 0) {
        if(_promotionOrder.GiftClasses.count > 0) {
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            OrderGiftModel *m = _promotionOrder.GiftClasses[0];
            [_addGiftsService getAddGiftsData:_app.business.BUSINESS_IDX andPartyIdx:_partyId andPartyAddressIdx:_orderAddressIdx andProductName:m.TYPE_NAME];
        } else {
            
            [Tools showAlert:self.view andTitle:@"没有可用产品类别"];
        }
    }
}


// 获取选择赠品开始的 LINE_NO
- (int)getPromotionNumber {
    
    @try {
        
        int lineNumber = 0;
        
        for(int i = 0; i < _promotionOrder.OrderDetails.count; i++) {
            
            PromotionDetailModel *m = _promotionOrder.OrderDetails[i];
            if(m.LINE_NO > lineNumber) {
                
                lineNumber = (int)m.LINE_NO;
            }
        }
        return lineNumber;
    } @catch (NSException *exception) {
        
        return 0;
    }
}


- (IBAction)confirmCustomizePriceOnclick:(UIButton *)sender {
    
    double price = [_customizePriceF.text doubleValue];
    price = [Tools getDouble:price];
    PromotionDetailModel *m = _promotionDetailsOfServer[_customizePriceIndexRow];
    
    if([Tools getDouble:price] <= 99999.9) {
        
        if([Tools getDouble:price] >= 0) {
            
            [self.view endEditing:YES];
            _customizePriceView.hidden = YES;
            _coverView.hidden = YES;
            
            [self setNewPrice:m andPrice:price];
            [self refreshCollectDada];
        } else {
            
            [Tools showAlert:self.view andTitle:@"价格超出下限"];
        }
    } else {
        
        [Tools showAlert:self.view andTitle:@"价格超出上限"];
    }
}


- (IBAction)cancelCustomizePriceOnclick:(UIButton *)sender {
    
    [self.view endEditing:YES];
    _customizePriceView.hidden = YES;
    _coverView.hidden = YES;
}


// 选择时间
- (IBAction)timeOnclick:(UITapGestureRecognizer *)sender {
    
    [self createDatePicker];
}


// 确认订单，最后一步提交到服务器
- (IBAction)confirmOnclick:(UIButton *)sender {
    
    [self.view endEditing:YES];
    
    NSString *remark = [_remarkTextV.text trim];
    NSDate *date = _isOnclickDateSure ? _selectedDate : nil;
    
    NSString *name = [_nameF.text trim];
    NSString *tel = [_telF.text trim];
    NSString *address = [_addressTextV.text trim];
    NSString *TO_IMAGE = _picture1ImageView.tag ? [Tools convertImageToString:_picture1ImageView.image] : @"";
    NSString *TO_IMAGE1 = _picture2ImageView.tag ? [Tools convertImageToString:_picture2ImageView.image] : @"";
    NSString *TO_IMAGE2 = _picture3ImageView.tag ? [Tools convertImageToString:_picture3ImageView.image] : @"";
    NSString *TO_IMAGE3 = _picture4ImageView.tag ? [Tools convertImageToString:_picture4ImageView.image] : @"";
    
    // 图片位置排序
    NSMutableArray *imageBase64 = [[NSMutableArray alloc] init];
    if(![TO_IMAGE isEqualToString:@""]) {
        
        [imageBase64 addObject:TO_IMAGE];
    }
    if(![TO_IMAGE1 isEqualToString:@""]) {
        
        [imageBase64 addObject:TO_IMAGE1];
    }
    if(![TO_IMAGE2 isEqualToString:@""]) {
        
        [imageBase64 addObject:TO_IMAGE2];
    }
    if(![TO_IMAGE3 isEqualToString:@""]) {
        
        [imageBase64 addObject:TO_IMAGE3];
    }
    
    TO_IMAGE = @"";
    TO_IMAGE1 = @"";
    TO_IMAGE2 = @"";
    TO_IMAGE3 = @"";
    
    for (int i = 0; i < imageBase64.count; i++) {
        
        if(i == 0) {
            
            TO_IMAGE = imageBase64[i];
        } else if(i == 1) {
            
            TO_IMAGE1 = imageBase64[i];
        } else if(i == 2) {
            
            TO_IMAGE2 = imageBase64[i];
        } else if(i == 3) {
            
            TO_IMAGE3 = imageBase64[i];
        }
    }
    
    // 姓名  电话  地址，这三个字段要么全填，要么不填
    if(([name isEqualToString:@""] && [tel isEqualToString:@""] && [address isEqualToString:@""]) || (![name isEqualToString:@""] && ![tel isEqualToString:@""] && ![address isEqualToString:@""])) {
        
        _promotionOrder.TO_CNAME = name ? name : @"";
        _promotionOrder.TO_CTEL = tel ? tel : @"";
        _promotionOrder.TO_ADDRESS = address ? address : @"";
        _promotionOrder.TO_IMAGE = TO_IMAGE ? TO_IMAGE : @"";
        _promotionOrder.TO_IMAGE1 = TO_IMAGE1 ? TO_IMAGE1 : @"";
        _promotionOrder.TO_IMAGE2 = TO_IMAGE2 ? TO_IMAGE2 : @"";
        _promotionOrder.TO_IMAGE3 = TO_IMAGE3 ? TO_IMAGE3 : @"";
        
        [_orderConfirmService setConfirmData:_selectedGifts andProducts:_productsOfLocal andTempTotalQTY:_promotionOrder.TOTAL_QTY andDate:date andRemark:remark andPromotionOrder:_promotionOrder andSelectPronotionDetails:_promotionDetailsOfServer andTO_CNAME:name andTO_ADDRESS:address andTO_CTEL:tel andTO_ZIP:TO_IMAGE];
        
        NSString *promotionOrderStr = [self promotionOrderModelTransfromNSString:_promotionOrder];
        
        if([promotionOrderStr isEqualToString:@""]) {
            
            [Tools showAlert:self.view andTitle:@"订单处理异常"];
        } else {
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [_orderConfirmService confirm:promotionOrderStr];
        }
    } else {
        
        if([name isEqualToString:@""] || [tel isEqualToString:@""] || [address isEqualToString:@""]) {
            
            [Tools showAlert:self.view andTitle:@"姓名 电话 地址要填写完整哦"];
            return;
        }
    }
}


- (NSString *)promotionOrderModelTransfromNSString:(PromotionOrderModel *)p {
    
    NSMutableArray *OrderDetails = [self promotionDetailModelTransfromNSString:p.OrderDetails];
    NSMutableArray *GiftClasses = [self GiftClassesModelTransfromNSString:p.GiftClasses];
    
    @try {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @(p.ACT_PRICE), @"ACT_PRICE",
                              p.ADD_DATE, @"ADD_DATE",
                              p.BUSINESS_IDX, @"BUSINESS_IDX",
                              @(p.BUSINESS_TYPE), @"BUSINESS_TYPE",
                              p.CONSIGNEE_REMARK, @"CONSIGNEE_REMARK",
                              p.EDIT_DATE, @"EDIT_DATE",
                              @(p.ENT_IDX), @"ENT_IDX",
                              p.FROM_ADDRESS, @"FROM_ADDRESS",
                              p.FROM_CITY, @"FROM_CITY",
                              p.FROM_CNAME, @"FROM_CNAME",
                              p.FROM_CODE, @"FROM_CODE",
                              p.FROM_COUNTRY, @"FROM_COUNTRY",
                              p.FROM_CSMS, @"FROM_CSMS",
                              p.FROM_CTEL, @"FROM_CTEL",
                              @(p.FROM_IDX), @"FROM_IDX",
                              p.FROM_NAME, @"FROM_NAME",
                              p.FROM_PROPERTY, @"FROM_PROPERTY",
                              p.FROM_PROVINCE, @"FROM_PROVINCE",
                              p.FROM_REGION, @"FROM_REGION",
                              p.FROM_ZIP, @"FROM_ZIP",
                              p.GROUP_NO, @"GROUP_NO",
                              GiftClasses, @"GiftClasses",
                              p.HAVE_GIFT, @"HAVE_GIFT",
                              @(p.IDX), @"IDX",
                              @(p.MJ_PRICE), @"MJ_PRICE",
                              p.MJ_REMARK, @"MJ_REMARK",
                              @(p.OPERATOR_IDX), @"OPERATOR_IDX",
                              p.ORD_NO, @"ORD_NO",
                              p.ORD_NO_CLIENT, @"ORD_NO_CLIENT",
                              p.ORD_NO_CONSIGNEE, @"ORD_NO_CONSIGNEE",
                              p.ORD_STATE, @"ORD_STATE",
                              @(p.ORG_IDX), @"ORG_IDX",
                              @(p.ORG_PRICE), @"ORG_PRICE",
                              OrderDetails, @"OrderDetails",
                              p.PARTY_IDX, @"PARTY_IDX",
                              p.PAYMENT_TYPE, @"PAYMENT_TYPE",
                              p.REQUEST_DELIVERY, @"REQUEST_DELIVERY",
                              p.REQUEST_ISSUE, @"REQUEST_ISSUE",
                              @(p.TOTAL_QTY), @"TOTAL_QTY",
                              @(p.TOTAL_VOLUME), @"TOTAL_VOLUME",
                              @(p.TOTAL_WEIGHT), @"TOTAL_WEIGHT",
                              p.TO_ADDRESS, @"TO_ADDRESS",
                              p.TO_CITY, @"TO_CITY",
                              p.TO_CNAME, @"TO_CNAME",
                              p.TO_CODE, @"TO_CODE",
                              p.TO_COUNTRY, @"TO_COUNTRY",
                              p.TO_CSMS, @"TO_CSMS",
                              p.TO_CTEL, @"TO_CTEL",
                              @(p.TO_IDX), @"TO_IDX",
                              p.TO_NAME, @"TO_NAME",
                              p.TO_PROPERTY, @"TO_PROPERTY",
                              p.TO_PROVINCE, @"TO_PROVINCE",
                              p.TO_REGION, @"TO_REGION",
                              p.TO_ZIP, @"TO_ZIP",
                              p.TO_IMAGE, @"TO_IMAGE",
                              p.TO_IMAGE1, @"TO_IMAGE1",
                              p.TO_IMAGE2, @"TO_IMAGE2",
                              p.TO_IMAGE3, @"TO_IMAGE3",
                              nil];
        
        // 与 Tools JsonStringWithDictonary 方法不同，这个方法可以去掉\r\n
        NSString *s = [self JsonStringWithDictonary:dict];
        
        return s;
    } @catch (NSException *exception) {
        return @"";
    }
}


- (NSString *)JsonStringWithDictonary:(NSDictionary *)dict {
    
    //    NSString *jsonString = @"";
    //    if ([NSJSONSerialization isValidJSONObject:dict]){
    //        NSError *error;
    //        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    //        jsonString =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    //    }
    //    return jsonString;
    
    
    
    
    NSString *jsonString = [[NSString alloc]init];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@""];
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
    //    NSRange range = {0,jsonString.length};
    //    [mutStr replaceOccurrencesOfString:@" "withString:@""options:NSLiteralSearch range:range];
    
    NSRange range2 = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\n"withString:@""options:NSLiteralSearch range:range2];
    
    NSRange range3 = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\\"withString:@""options:NSLiteralSearch range:range3];
    
    NSRange range4 = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\r"withString:@""options:NSLiteralSearch range:range4];
    
    NSRange range5 = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\t"withString:@""options:NSLiteralSearch range:range5];
    
    NSRange range6 = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\r\n"withString:@""options:NSLiteralSearch range:range6];
    
    NSRange range7 = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\r\t"withString:@""options:NSLiteralSearch range:range7];
    
    NSString *fff = [mutStr stringByReplacingOccurrencesOfString:@"\"{" withString:@"{"];
    
    fff = [fff stringByReplacingOccurrencesOfString:@"}\"" withString:@"}"];
    
    return fff;
}


- (NSMutableArray *)GiftClassesModelTransfromNSString:(NSMutableArray *)ms {
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    @try {
        for(int i = 0; i < ms.count; i++) {
            OrderGiftModel *m = ms[i];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @(m.isChecked), @"isChecked",
                                  @(m.choiceCount), @"choiceCount",
                                  @(m.PRICE), @"PRICE",
                                  @(m.QTY), @"QTY",
                                  m.TYPE_NAME, @"TYPE_NAME",
                                  nil];
            NSString *s = [Tools JsonStringWithDictonary:dict];
            [array addObject:s];
        }
    } @catch (NSException *exception) {
        return [[NSMutableArray alloc] init];
    }
    
    return array;
}


- (NSMutableArray *)promotionDetailModelTransfromNSString:(NSMutableArray *)ps {
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    @try {
        for(int i = 0; i < ps.count; i++) {
            PromotionDetailModel *p = ps[i];
            NSDictionary *dict = nil;
            if([p.PRODUCT_TYPE isEqualToString:@"NR"]) {
                dict = [NSDictionary dictionaryWithObjectsAndKeys:
                        @(p.ACT_PRICE), @"ACT_PRICE",
                        p.ADD_DATE, @"ADD_DATE",
                        p.EDIT_DATE, @"EDIT_DATE",
                        @(p.ENT_IDX), @"ENT_IDX",
                        @(p.IDX), @"IDX",
                        @(p.LINE_NO), @"LINE_NO",
                        p.LOTTABLE01, @"LOTTABLE01",
                        p.LOTTABLE02, @"LOTTABLE02",
                        p.LOTTABLE03, @"LOTTABLE03",
                        p.LOTTABLE04, @"LOTTABLE04",
                        p.LOTTABLE05, @"LOTTABLE05",
                        @"", @"LOTTABLE06",
                        p.LOTTABLE07, @"LOTTABLE07",
                        p.LOTTABLE08, @"LOTTABLE08",
                        p.LOTTABLE09, @"LOTTABLE09",
                        p.LOTTABLE10, @"LOTTABLE10",
                        @(p.LOTTABLE11), @"LOTTABLE11",
                        @(p.LOTTABLE12), @"LOTTABLE12",
                        @(p.LOTTABLE13), @"LOTTABLE13",
                        @(p.MJ_PRICE), @"MJ_PRICE",
                        p.MJ_REMARK, @"MJ_REMARK",
                        @(p.OPERATOR_IDX), @"OPERATOR_IDX",
                        @(p.ORDER_IDX), @"ORDER_IDX",
                        @(p.ORG_PRICE), @"ORG_PRICE",
                        @(p.PO_QTY), @"PO_QTY",
                        p.PO_UOM, @"PO_UOM",
                        @(p.PO_VOLUME), @"PO_VOLUME",
                        @(p.PO_WEIGHT), @"PO_WEIGHT",
                        @(p.PRODUCT_IDX), @"PRODUCT_IDX",
                        p.PRODUCT_NAME, @"PRODUCT_NAME",
                        p.PRODUCT_NO, @"PRODUCT_NO",
                        p.PRODUCT_TYPE, @"PRODUCT_TYPE",
                        p.PRODUCT_URL, @"PRODUCT_URL",
                        p.SALE_REMARK, @"SALE_REMARK",
                        nil];
            } else if([p.PRODUCT_TYPE isEqualToString:@"GF"]) {
                dict = [NSDictionary dictionaryWithObjectsAndKeys:
                        @(p.ACT_PRICE), @"ACT_PRICE",
                        @(p.ENT_IDX), @"ENT_IDX",
                        @(p.IDX), @"IDX",
                        @(p.LINE_NO), @"LINE_NO",
                        p.LOTTABLE02, @"LOTTABLE02",
                        @"", @"LOTTABLE06",
                        p.LOTTABLE09, @"LOTTABLE09",
                        @(p.LOTTABLE11), @"LOTTABLE11",
                        @(p.LOTTABLE12), @"LOTTABLE12",
                        @(p.LOTTABLE13), @"LOTTABLE13",
                        @(p.MJ_PRICE), @"MJ_PRICE",
                        @(p.OPERATOR_IDX), @"OPERATOR_IDX",
                        @(p.ORDER_IDX), @"ORDER_IDX",
                        @(p.ORG_PRICE), @"ORG_PRICE",
                        @(p.PO_QTY), @"PO_QTY",
                        @(p.PO_VOLUME), @"PO_VOLUME",
                        @(p.PO_WEIGHT), @"PO_WEIGHT",
                        @(p.PRODUCT_IDX), @"PRODUCT_IDX",
                        p.PRODUCT_NAME, @"PRODUCT_NAME",
                        p.PRODUCT_NO, @"PRODUCT_NO",
                        p.PRODUCT_TYPE, @"PRODUCT_TYPE",
                        p.SALE_REMARK, @"SALE_REMARK",
                        nil];
            } else {
                dict = [[NSDictionary alloc] init];
            }
            
            NSString *s = [Tools JsonStringWithDictonary:dict];
            [array addObject:s];
        }
    } @catch (NSException *exception) {
        return [[NSMutableArray alloc] init];
    }
    
    return array;
}


- (IBAction)deletePicture1Onclick:(UIButton *)sender {
    
    _currentPictureType = sender.tag;
    
    [LM_alert showLMAlertViewWithTitle:@"" message:@"确定删除此照片吗？" cancleButtonTitle:@"取消" okButtonTitle:@"确定" okClickHandle:^{
        switch (sender.tag) {
                
            case Picture_TYPE_1:
                
                _picture1ImageView.tag = 0;
                _picture1ImageView.image = [UIImage imageNamed:@"ic_add_image"];
                break;
                
            case Picture_TYPE_2:
                
                _picture2ImageView.tag = 0;
                _picture2ImageView.image = [UIImage imageNamed:@"ic_add_image"];
                break;
                
            case Picture_TYPE_3:
                
                _picture3ImageView.tag = 0;
                _picture3ImageView.image = [UIImage imageNamed:@"ic_add_image"];
                break;
                
            case Picture_TYPE_4:
                
                _picture4ImageView.tag = 0;
                _picture4ImageView.image = [UIImage imageNamed:@"ic_add_image"];
                break;
                
            default:
                break;
        }
    } cancelClickHandle:nil];
    
}


#pragma mark - OrderConfirmServiceDelegate

- (void)successOfOrderConfirmWithCommit {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Tools showAlert:self.view andTitle:@"提交成功!"];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        sleep(2);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    });
}


- (void)failureOfOrderConfirmWithCommit:(NSString *)msg {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Tools showAlert:self.view andTitle:msg ? msg : @"提交失败"];
}


#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(tableView.tag == 1001) {
        
        return _promotionDetailsOfServer.count;
    } else if(tableView.tag == 1002) {
        
        return _selectedGifts.count;
    } else {
        
        return 0;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView.tag == 1001) {
        
        return GiftTableViewCellHeight;
    } else if(tableView.tag == 1002) {
        
        return _productCellHeight;
    } else {
        
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView.tag == 1001) {
        
        //界面处理
        static NSString *cellId = @"ConfirmOrderTableViewCell";
        ConfirmOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
        cell.tag = indexPath.row;
        cell.delegate = self;
        
        //获取数据
        PromotionDetailModel *m = _promotionDetailsOfServer[indexPath.row];
        
        //填充数据
        cell.nameLabel.text = m.PRODUCT_NAME;
        cell.promotionNameLabel.text = [m.SALE_REMARK isEqualToString:@""] ? nil : m.SALE_REMARK;
        cell.originalPriceLabel.text = [NSString stringWithFormat:@"%.1f", m.ORG_PRICE];
        [cell.nowPriceButton setTitle:[NSString stringWithFormat:@"%.1f", m.ACT_PRICE] forState:UIControlStateNormal];
        cell.numberLabel.text = [NSString stringWithFormat:@"%lld", m.PO_QTY];
        
        cell.addButtonWidth.constant = 30;
        cell.delButtonWidth.constant = 30;
        
        
        //返回Cell
        return cell;
        
    } else if(tableView.tag == 1002) {
        
        //界面处理
        static NSString *cellId = @"ConfirmOrderGiftsTableViewCell";
        ConfirmOrderGiftsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
        cell.tag = indexPath.row;
        
        //获取数据
        PromotionDetailModel *m = _selectedGifts[indexPath.row];
        
        //填充数据
        cell.name1Label.text = m.PRODUCT_NAME;
        if([[m.SALE_REMARK trim] isEqualToString:@""]) {
            cell.name2Label.text = nil;
        } else {
            cell.name2Label.text = m.SALE_REMARK;
        }
        cell.orgPriceLabel.text = [NSString stringWithFormat:@"%.1f", m.ORG_PRICE];
        cell.actPriceLabel.text = [NSString stringWithFormat:@"%.1f", m.ACT_PRICE];
        cell.numberLabel.text = [NSString stringWithFormat:@"%lld", m.PO_QTY];
        
        //返回Cell
        return cell;
    } else {
        
        return [[UITableViewCell alloc] init];
    }
}


#pragma mark - ConfirmOrderTableViewCellDelegate

- (void)delOnclickOfConfirmOrderTableViewCell:(NSInteger)indexRow {
    
    PromotionDetailModel *m = _promotionDetailsOfServer[indexRow];
    double price = m.ACT_PRICE - 0.1;
    if([Tools getDouble:price] >= 0) {
        [self setNewPrice:m andPrice:price];
        [self refreshCollectDada];
    } else {
        
        [Tools showAlert:self.view andTitle:@"价格超出下限"];
    }
}


- (void)addOnclickOfConfirmOrderTableViewCell:(NSInteger)indexRow {
    
    PromotionDetailModel *m = _promotionDetailsOfServer[indexRow];
    CGFloat price = m.ACT_PRICE + 0.1;
    
    if([Tools getDouble:price] <= 99999.9) {
        [self setNewPrice:m andPrice:price];
        [_orderTableView reloadData];
        [self refreshCollectDada];
    } else {
        
        [Tools showAlert:self.view andTitle:@"价格超出上限"];
    }
}


- (void)customizePriceOfConfirmOrderTableViewCell:(NSInteger)indexRow {
    
    PromotionDetailModel *m = _promotionDetailsOfServer[indexRow];
    
    //    if([m.LOTTABLE06 isEqualToString:@"Y"]) {
    
    _upperLimi.text = [NSString stringWithFormat:@"99999.9"];
    _lowerLimi.text = [NSString stringWithFormat:@"0"];
    _customizePriceView.hidden = NO;
    _coverView.hidden = NO;
    _customizePriceIndexRow = indexRow;
    _customizePriceF.text = @"";
    [_customizePriceF becomeFirstResponder];
    //    } else {
    //
    //    }
    
}


#pragma mark - UITextFieldDelegate

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text {
    
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    if (![text isEqualToString:@""]) {
        
        if(textView.tag == 1001) {
            
            _adressPlaceholderLabel.hidden = YES;
        } else if(textView.tag == 1002) {
            
            _remarkPlaceholderLabel.hidden = YES;
        }
    }
    
    if ([text isEqualToString:@""] && range.location == 0 && range.length == 1) {
        
        if(textView.tag == 1001) {
            
            _adressPlaceholderLabel.hidden = NO;
        } else if(textView.tag == 1002) {
            
            _remarkPlaceholderLabel.hidden = NO;
        }
    }
    
    return YES;
}


#pragma mark - AddGiftsServiceDelegate

- (void)successOfAddGifts:(NSMutableArray *)promotionDetails {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    //防止变量被下个控制器修改
    NSMutableArray *giftsType = [[NSMutableArray alloc] init];
    for(int i = 0; i < _promotionOrder.GiftClasses.count; i++) {
        OrderGiftModel *m1 = [_promotionOrder.GiftClasses[i] copy];
        [giftsType addObject:m1];
    }
    
    if(giftsType.count > 0) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:promotionDetails forKey:@(0)];
        
        AddGiftsViewController *vc = [[AddGiftsViewController alloc] init];
        vc.partyId = _partyId;
        vc.addressIdx = _orderAddressIdx;
        vc.beginLine = [self getPromotionNumber];
        vc.giftTypes = giftsType;
        //    vc.orderDetails = _promotionOrder.OrderDetails;
        vc.dictPromotionDetails = dict;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [Tools showAlert:self.view andTitle:@"无赠品可添加"];
    }
}


- (void)failureOfAddGifts:(NSString *)msg {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Tools showAlert:self.view andTitle:@"获取赠品失败"];
}


#pragma mark - 选择时间模块

- (void)createDatePicker {
    if(_isShowDatePicker) return;
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
    [self.view addSubview:_coView];
    
    /// 添加取消按钮
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonSpan, height + 5, buttonWidth, buttonHeight)];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton setBackgroundColor:ZSDColor];
    cancelButton.layer.cornerRadius = 2.0;
    [cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_coView addSubview:cancelButton];
    
    /// 添加确认按钮
    UIButton *sureButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonSpan * 2 + buttonWidth, height + 5, buttonWidth, buttonHeight)];
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
    
    //加一年
    //    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    //    NSDateComponents *comps = nil;
    //    comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    //    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    //    [adcomps setYear:1];
    //    NSDate *newdate = [calendar dateByAddingComponents:adcomps toDate:[NSDate date] options:0];
    
    datePicker.minimumDate = [NSDate date];
    datePicker.maximumDate = [_formatter dateFromString:@"2066-11-24"];
    
    // 设置默认时间
    datePicker.date = [NSDate date];
    
    //注意：action里面的方法名后面需要加个冒号“：”
    [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    [_coView addSubview:datePicker];
    
    _isShowDatePicker = YES;
}


// 日期选择器响应方法
- (void)dateChanged:(UIDatePicker *)datePicker {
    NSDate *date = datePicker.date;
    //    _selectedTime = [_formatter stringFromDate:date];
    _selectedDate = date;
}


// 时间选择器点击取消按钮
- (void)cancelButtonClick:(UIButton *)sender {
    [_coView removeFromSuperview];
    _isShowDatePicker = NO;
}


// 时间选择器点击了确定按钮
- (void)sureButtonClick:(UIButton *)sender {
    [_coView removeFromSuperview];
    _isShowDatePicker = NO;
    _timeLabel.text = [_formatter stringFromDate:_selectedDate];
    _isOnclickDateSure = YES;
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = info[UIImagePickerControllerEditedImage];
    
    if(!image) {
        
        image = info[UIImagePickerControllerOriginalImage];
    }
    
    if(image) {
        
        NSData *data = [image compressImage:image andMaxLength:1024*100];
        
        if(data) {
            
            image = [UIImage imageWithData:data];
        }
    }
    
    switch (_currentPictureType) {
            
        case Picture_TYPE_1:
            
            _picture1ImageView.image = image;
            _picture1ImageView.tag = 1;
            break;
            
        case Picture_TYPE_2:
            
            _picture2ImageView.image = image;
            _picture2ImageView.tag = 1;
            break;
            
        case Picture_TYPE_3:
            
            _picture3ImageView.image = image;
            _picture3ImageView.tag = 1;
            break;
            
        case Picture_TYPE_4:
            
            _picture4ImageView.image = image;
            _picture4ImageView.tag = 1;
            break;
            
        default:
            break;
    }
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - KVO监听

- (void)keyboardDidShow {
    
    _keyBoardlsVisible = YES;
}


- (void)keyboardDidHide {
    
    _keyBoardlsVisible = NO;
}

@end
