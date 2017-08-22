//
//  NewsListViewController.m
//  ZSDOrder
//
//  Created by 凯东源 on 17/5/11.
//  Copyright © 2017年 凯东源. All rights reserved.
//

#import "NewsListViewController.h"
#import "NewsListTableViewCell.h"
#import "NewsListService.h"
#import <MBProgressHUD.h>
#import "NewsDetailViewController.h"

@interface NewsListViewController ()<UITableViewDelegate, UITableViewDataSource, NewsListServiceDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NewsListService *service;

@property (strong, nonatomic) NSArray *newsList;

@end

#define kCellName @"NewsListTableViewCell"

@implementation NewsListViewController


- (instancetype)init {
    
    if(self = [super init]) {
        
        _service = [[NewsListService alloc] init];
        _service.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"最新资讯";
    
    [self registerCell];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_service GetAppNews:1 andstrPageCount:100];
}


- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}


#pragma mark - 功能方法

- (void)registerCell {
    
    [_tableView registerNib:[UINib nibWithNibName:kCellName bundle:nil] forCellReuseIdentifier:kCellName];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _newsList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellId = kCellName;
    NewsListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    NewsListModel *m = _newsList[indexPath.row];
    cell.newsListM = m;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NewsDetailViewController *vc = [[NewsDetailViewController alloc] init];
    vc.newsListM = _newsList[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - NewsListServiceDelegate

- (void)successOfGetAppNews:(NSArray *)newsList {
    
    _newsList = newsList;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [_tableView reloadData];
}


- (void)successOfGetAppNewsNoData {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}


- (void)failureOfGetAppNews:(NSString *)msg {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

@end
