//
//  LoginViewController.m
//  Order
//
//  Created by 凯东源 on 16/9/26.
//  Copyright © 2016年 凯东源. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginService.h"
#import "NSString+Trim.h"
#import "Tools.h"
#import <MBProgressHUD.h>
#import "MainViewController.h"
#import "MakeOrderViewController.h"
#import "MineViewController.h"
#import "AppDelegate.h"
#import "WMPageController.h"
#import "OrderingViewController.h"
#import "OrderOneAuditViewController.h"
#import "OrderFinishViewController.h"
#import "OrderCancelViewController.h"
#import "ConfirmOrderViewController.h"





@interface IB_UITextField : UITextField
@property (nonatomic, assign)IBInspectable CGFloat cornerRadius;
@property (nonatomic, assign)IBInspectable CGFloat Padding;
@end

IB_DESIGNABLE
@implementation IB_UITextField

- (void)setCornerRadius:(CGFloat)cornerRadius{
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = _cornerRadius;
    self.layer.masksToBounds = YES;
}

-(CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, _Padding, _Padding);
}

-(CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}
@end



@interface LoginViewController ()<LoginServiceDelegate, UIAlertViewDelegate>

//帐号
@property (weak, nonatomic) IBOutlet UITextField *userNameT;

//密码
@property (weak, nonatomic) IBOutlet UITextField *pswT;

/// 网络操作层
@property (strong, nonatomic) LoginService *service;

/// 全局变量
@property (strong, nonatomic) AppDelegate *app;

@property (strong, nonatomic) NSMutableArray *business;

- (IBAction)loginOnclick:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@end


@implementation LoginViewController

#pragma mark - 生命周期

- (instancetype)init {
    self = [super init];
    if (self) {
        _service = [[LoginService alloc] init];
        _service.delegate = self;
        _app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        _business = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"登录";
    
    //填充上一次登录成功的帐号密码
    [self setUserNameAndPassword];
    
    // forces layout early  强制提前执行layout
    [self.view layoutIfNeeded];
    
    // 帐号
    UIImageView *uImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetHeight(_userNameT.frame), CGRectGetHeight(_userNameT.frame))];
    uImage.image = [UIImage imageNamed:@"user"];
    _userNameT.leftViewMode = UITextFieldViewModeAlways;
    _userNameT.leftView = uImage;
    
    // 密码
    UIImageView *pswImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetHeight(_pswT.frame), CGRectGetHeight(_pswT.frame))];
    pswImage.image = [UIImage imageNamed:@"lock"];
    _pswT.leftViewMode = UITextFieldViewModeAlways;
    _pswT.leftView = pswImage;
}


- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}


#pragma mark - 点击事件

// 登录
- (IBAction)loginOnclick:(UIButton *)sender {
    
    [self.view endEditing:YES];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        // 暂时没有多业务，不延迟
        //        usleep(300000);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            NSString *userName = [_userNameT.text trim];
            NSString *pwd = [_pswT.text trim];
            
            if(![userName isEmpty]) {
                if(![pwd isEmpty]) {
                    if([Tools isConnectionAvailable]) {
                        [self.view endEditing:YES];
                        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                        [_service login:userName andPsw:pwd];
                    }else {
                        [Tools showAlert:self.view andTitle:@"网络不可用"];
                    }
                }else {
                    [Tools showAlert:self.view andTitle:@"请输入密码"];
                }
            }else {
                [Tools showAlert:self.view andTitle:@"请输入用户名"];
            }
        });
    });
}


#pragma mark - 私有方法

// 填充上一次登录成功的帐号密码
- (void)setUserNameAndPassword {
    
    //有时NSUserDefaults有值却没填充
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *a = [[NSUserDefaults standardUserDefaults] objectForKey:udUserName];
        NSString *b = [[NSUserDefaults standardUserDefaults] objectForKey:udPassWord];
        if(a && b) {
            _userNameT.text = a;
            _pswT.text = b;
        }
    });
}


- (WMPageController *)p_defaultController {
    
    NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
    NSMutableArray *titles = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 4; i++) {
        Class vcClass;
        NSString *title;
        switch (i) {
            case 0:
                vcClass = [OrderingViewController class];
                title = @"未审核";
                break;
            case 1:
                vcClass = [OrderOneAuditViewController class];
                title = @"已审核";
                break;
            case 2:
                vcClass = [OrderFinishViewController class];
                title = @"已释放";
                break;
            case 3:
                vcClass = [OrderCancelViewController class];
                title = @"已取消";
                break;
            default:
                break;
        }
        
        [viewControllers addObject:vcClass];
        [titles addObject:title];
    }
    
    // 客户业务屏蔽已审核界面
    if([_app.user.USER_TYPE isEqualToString:kPARTY] || [_app.user.USER_TYPE isEqualToString:kBUSINESS]) {
        
        [viewControllers removeObject:[OrderOneAuditViewController class]];
        [titles removeObject:@"已审核"];
    } else {
        
        nil;
    }
    
    WMPageController *pageVC = [[WMPageController alloc] initWithViewControllerClasses:viewControllers andTheirTitles:titles];
    
    pageVC.menuItemWidth = 85;
    pageVC.menuHeight = CheckOrderViewControllerMenuHeight;
    pageVC.postNotification = YES;
    pageVC.bounces = YES;
    return pageVC;
}


#pragma mark - LoginServiceDelegate

- (void)successOfLogin {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    //4个子控制器
    MainViewController *mainVC =[[MainViewController alloc] init];
    MakeOrderViewController *makeVC = [[MakeOrderViewController alloc] init];
    WMPageController *pageController = [self p_defaultController];
    // 下划线
    pageController.menuViewStyle = WMMenuViewStyleLine;
    pageController.titleSizeSelected = 15;
    pageController.selectIndex = 0;
    MineViewController *mineVC = [[MineViewController alloc] init];
    
    // 下单权限
    UITabBarController *tbc = [[UITabBarController alloc] init];
    tbc.tabBar.tintColor = ZSDColor;
    if([Tools makeOrder:_app]) {
        
        tbc.viewControllers = @[mainVC, makeVC, pageController, mineVC];
    } else {
        
        tbc.viewControllers = @[mainVC, pageController, mineVC];
    }
    
    //导航控制器
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tbc];
    
    //切换根控制器
    [Tools setRootViewControllerWithFlipFromRight:_app.window andViewController:nav];
}


- (void)successOfLoginSelectBusinss:(NSMutableArray *)business {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    _business = business;
    
    if(business.count == 1) {
        
        [self saveBusiness:business[0]];
    } else if(business.count > 1) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请选择业务类型" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil];
        alert.delegate = self;
        
        for(int i = 0; i < business.count; i++) {
            NSDictionary *dict = business[i];
            NSString *title = dict[@"BUSINESS_NAME"];
            [alert addButtonWithTitle:title];
        }
        [alert show];
    }else {
        
        [Tools showAlert:self.view andTitle:@"没有业务哦"];
    }
}


- (void)failureOfLogin:(NSString *)msg {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Tools showAlert:self.view andTitle:msg];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"buttonIndex:%ld", (long)buttonIndex);
    if(buttonIndex == 0) {
        nil;  //点击取消， 不操作
    }else {
        NSDictionary *dict;
        if(_business.count > 1) {
            dict = _business[buttonIndex - 1];
        }
        [self saveBusiness:dict];
    }
}


- (void)saveBusiness:(NSDictionary *)dict {
    _app.business.BUSINESS_IDX = dict[@"BUSINESS_IDX"];
    _app.business.BUSINESS_CODE = dict[@"BUSINESS_CODE"];
    _app.business.BUSINESS_NAME = dict[@"BUSINESS_NAME"];
    
    [self successOfLogin];
}

@end
