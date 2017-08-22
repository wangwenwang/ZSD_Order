//
//  Tools.h
//  YBDriver
//
//  Created by 凯东源 on 16/8/30.
//  Copyright © 2016年 凯东源. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ProductModel.h"
#import "ProductPolicyModel.h"
#import "PromotionOrderModel.h"
#import "PromotionDetailModel.h"
#import "AppDelegate.h"

@interface Tools : NSObject


/*!
 * @brief 把格式化的JSON格式的字符串转换成字典
 * @param jsonString JSON格式的字符串
 * @return 返回字典
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;


//请求API
//方式：POST
//类型：application/x-www-form-urlencoded
+ (NSString *)postAPI:(NSString *)urlStr andString:(NSString *)postStr;


/*!
 * @brief 把字典转换成JSON字符串
 * @param dict 字典
 * @return 返回JSON字符串
 */
+ (NSString *)JsonStringWithDictonary:(NSDictionary *)dict;


/// 提示  参数:View    NSString
+ (void)showAlert:(NSObject *)view andTitle:(NSString *)title;


/// 网络状态
+ (BOOL)isConnectionAvailable;


/**
 * 获取手机当前时间
 *
 * return 手机当前时间 "yyy-MM-dd HH:mm:ss"
 */
+ (NSString *)getCurrentDate;


/**
 *	@brief	浏览头像
 *
 *	@param 	oldImageView 	头像所在的imageView
 */
+(void)showImage:(UIImageView*)avatarImageView;


/// 筛选出最小的数
+ (NSInteger)getMinNumber:(NSInteger)a andB:(NSInteger)b;


/// 淡入效果的转场动画
+ (void)setRootViewControllerWithCrossDissolve:(UIWindow *)window andViewController:(UIViewController *)vc;


/// 从右翻转的转场动画
+ (void)setRootViewControllerWithFlipFromRight:(UIWindow *)window andViewController:(UIViewController *)vc;


/// 设置导航栏的Title颜色
+ (void)setNavigationControllerTitleColor:(UINavigationController *)nav;


/// 订单状态中英文转换(获取订单状态)
+ (NSString *)getOrderStatus:(NSString *)s;


/**
 工作流程
 
 @param s 服务器返回值
 
 @return  自定义值
 */
+ (NSString *)getOrderWorkflow:(NSString *)s;


/// 角色中英文转换
+ (NSString *)getRoleName:(NSString *)s;


/// 获取订单流程
+ (NSString *)getOrderState:(NSString *)s;


/// 获取付款方式
+ (NSString *)getPaymentType:(NSString *)s;


/// 产品模型转字典
+ (NSDictionary *)setProdictModel:(ProductModel *)m;


/// 产品政策转字典
+ (NSDictionary *)setProductPolicyModel:(ProductPolicyModel *)m;


/// 产品促销转字典
+ (NSDictionary *)setPromotionOrderModel:(PromotionOrderModel *)m;


/// 促销详情转字典
+ (NSDictionary *)setPromotionDetailModel:(PromotionDetailModel *)m;


/**
 * 根据支付类型英文字段获取显示的支付类型的中文字段
 *
 * @param key 英文字段
 * @return 字符类型中文字段
 */
+ (NSString *)getPayTypeText:(NSString *)key;


//将 Product 实体类转换成 PromotionDetail 实体类
+ (NSMutableArray *)ChangeProductToPromotionDetailUtil:(NSMutableArray *)pmds;


/// 保留2位小数
+ (double)getDouble:(double)d;


/// 时间格式转换 yyyy-MM-dd 转 yyyy-MM-dd HH:mm:ss
+ (NSString *)DateTransFrom:(NSString *)time;


/// 添加走马灯
+ (void)msgChange:(CGFloat)overflowWidth andLabel:(UILabel *)_goodsNameLabel andBeginAnimations:(NSString *)animationName;


/**
 图片转NSString 通过Base64

 @param image 图片

 @return 字符串
 */
+ (NSString *)convertImageToString:(UIImage *)image;



/**
 根据 Label width, 计算Label高度

 @param label Label
 @param width width

 @return Label高度
 */
+ (CGFloat)getHeightOfLabel:(UILabel *)label andWidth:(CGFloat)width;


/**
 根据 NSString width, 计算NSString高度

 @param text     文字
 @param fontSize 字体大小
 @param width    width

 @return NSString高度
 */
+ (CGFloat)getHeightOfString:(NSString *)text fontSize:(CGFloat)fontSize andWidth:(CGFloat)width;


/**
 是否有审核权限

 @param global 全局变量

 @return 审核权限
 */
+ (BOOL)audit:(AppDelegate *)global;


/**
 是否有下单权限
 
 @param global 全局变量
 
 @return 下单权限
 */
+ (BOOL)makeOrder:(AppDelegate *)global;


/**
 时间加法（负数为减法）

 @param second 秒

 @return 相加后时间 yyyy-MM-dd HH:mm:ss
 */
+ (NSString *)getCurrentBeforeDate:(NSTimeInterval)second;



/**
 清除 时 分 秒

 @param dateStr yyyy-MM-dd HH:mm:ss

 @return yyyy-MM-dd 00:00:00
 */
+ (NSString *)ClearHourMinuteSecond:(NSString *)dateStr;

@end
