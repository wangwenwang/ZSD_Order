//
//  MainViewController.m
//  Order
//
//  Created by 凯东源 on 16/9/27.
//  Copyright © 2016年 凯东源. All rights reserved.
//

#import "MainViewController.h"
#import "SDCycleScrollView.h"
#import "MaincollectionViewCell.h"
#import "SearchOrderPathViewController.h"
#import "NewsListViewController.h"
#import "HotProductViewController.h"
#import "ChartService.h"
#import "ChartViewController.h"
#import <MBProgressHUD.h>
#import "Tools.h"
#import "AppDelegate.h"

@interface MainViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ChartServiceDelegate>

// Cell ID
@property (copy, nonatomic) NSString *cellID;

// myCollectionView 数据
@property (strong, nonatomic) NSMutableArray *myCollectionDataArrM;

@property (weak, nonatomic) IBOutlet SDCycleScrollView *cycleScrollView;

@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;

@property (strong, nonatomic) ChartService *chartService;

@property (strong, nonatomic) AppDelegate *app;

@end


@implementation MainViewController

- (instancetype)init {
    
    if(self = [super init]) {
        
        self.title = @"首页";
        self.tabBarItem.image = [UIImage imageNamed:@"menu_index_unselected"];
        _cellID = @"myCollectionViewCellID";
        _myCollectionDataArrM = [[NSMutableArray alloc] init];
        _chartService = [[ChartService alloc] init];
        
        _chartService.delegate = self;
        _app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
    return self;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // 获取plist数据
    [self getPlistData];
    
    // 注册Cell
    [self registerCell];
}


- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    // 添加广告轮播
    [self addCycleScrollView];
}


- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.topItem.title = @"首页";
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
}


- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}


#pragma mark - 私有方法

- (void)addCycleScrollView {
    
    NSArray *images = nil;
    
    images = [NSArray arrayWithObjects:@"ad_pic_0.jpg", @"ad_pic_1.jpg", @"ad_pic_2.jpg", @"ad_pic_3.jpg", nil];
    
    
    // 本地加载图片的轮播器
    SDCycleScrollView *_cycleScrollView1 = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, ScreenWidth, CGRectGetHeight(_cycleScrollView.frame)) imageNamesGroup:images];
    [self.view addSubview:_cycleScrollView1];
}


- (void)registerCell {
    [self.myCollectionView registerNib:[UINib nibWithNibName:@"MainCollectionViewCell"bundle:nil]forCellWithReuseIdentifier:_cellID];
}


- (void)getPlistData {
    NSString *dataPath = [[NSBundle mainBundle]pathForResource:@"MainCollection.plist" ofType:nil];
    _myCollectionDataArrM = [NSMutableArray arrayWithContentsOfFile:dataPath];
}


#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _myCollectionDataArrM.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MainCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_cellID forIndexPath:indexPath];
    //    NSLog(@"%ld, %ld", (long)indexPath.row, (long)indexPath.section);
    cell.titleLabel.text = _myCollectionDataArrM[indexPath.row][@"title"];
    cell.imageView.image = [UIImage imageNamed:_myCollectionDataArrM[indexPath.row][@"imageName"]];
    return cell;
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellW = (ScreenWidth - 2) / 3;
    return CGSizeMake(cellW, cellW);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *title = _myCollectionDataArrM[indexPath.row][@"title"];
    
    if([title isEqualToString:@"查看路线"]) {
        
        SearchOrderPathViewController *sopVC = [[SearchOrderPathViewController alloc] init];
        [self.navigationController pushViewController:sopVC animated:YES];
    }else if([title isEqualToString:@"最新资讯"]) {
        
        NewsListViewController *newsVC = [[NewsListViewController alloc] init];
        [self.navigationController pushViewController:newsVC animated:YES];
    }else if([title isEqualToString:@"热销产品"]) {
        
        HotProductViewController *hotVC = [[HotProductViewController alloc] init];
        [self.navigationController pushViewController:hotVC animated:YES];
    }else if([title isEqualToString:@"查看报表"]) {
        
        ChartViewController *vc = [[ChartViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if([title isEqualToString:@"查看订单"]) {
        
        if([Tools makeOrder:_app]) {
            
            self.tabBarController.selectedIndex = 2;
        } else {
            
            self.tabBarController.selectedIndex = 1;
        }
    }
}

@end
