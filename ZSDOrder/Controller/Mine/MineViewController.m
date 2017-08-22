//
//  MineViewController.m
//  Order
//
//  Created by 凯东源 on 16/9/27.
//  Copyright © 2016年 凯东源. All rights reserved.
//

#import "MineViewController.h"
#import "MineTableViewCell.h"
#import "AppDelegate.h"
#import "Tools.h"
#import "AboutViewController.h"
#import "ChangePasswordViewController.h"
#import "LoginViewController.h"

@interface MineViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *myTableViewArrM;

@property (copy, nonatomic) NSString *cellID;

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property (strong, nonatomic) AppDelegate *app;

- (IBAction)changeAccountOnclick:(UIButton *)sender;

// 切换用户
@property (weak, nonatomic) IBOutlet UIButton *changeAccountBtn;

@end

@implementation MineViewController

- (instancetype)init {
    if(self = [super init]) {
        self.title = @"我的";
        self.tabBarItem.image = [UIImage imageNamed:@"menu_mine_unselected"];
        _myTableViewArrM = [[NSMutableArray alloc] init];
        _cellID = @"MineTableViewCell";
        _app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //获取Plist数据
    [self getPlistData];
    
    //注册Cell
    [self registerCell];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.topItem.title = @"我的";
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - 私有方法

- (void)getPlistData {
    NSString *dataPath = [[NSBundle mainBundle]pathForResource:@"MineTable.plist" ofType:nil];
    _myTableViewArrM = [NSMutableArray arrayWithContentsOfFile:dataPath];
}


- (void)registerCell {
    [self.myTableView registerNib:[UINib nibWithNibName:@"MineTableViewCell" bundle:nil] forCellReuseIdentifier:_cellID];
}


#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _myTableViewArrM.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"MineTableViewCell";
    MineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    cell.myImageView.image = [UIImage imageNamed:_myTableViewArrM[indexPath.row][@"imageName"]];
    cell.promptLabel.text = _myTableViewArrM[indexPath.row][@"title"];
    if(indexPath.row == 0) {
        cell.titleLabel.text = _app.user.USER_NAME;
    }else if(indexPath.row == 1) {
        cell.titleLabel.text = [Tools getRoleName:_app.user.USER_TYPE] ;
    }else if(indexPath.row == 2) {
        cell.titleLabel.text = _app.business.BUSINESS_NAME;
    }else if(indexPath.row == 3) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.titleLabel.text = @"";
    }else if(indexPath.row == 4) {
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        cell.titleLabel.text = [NSString stringWithFormat:@"V %@", version];
    }else if(indexPath.row == 5) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.titleLabel.text = @"";
    }else {
        cell.titleLabel.text = @"";
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.row == 3) {
        ChangePasswordViewController *cpVC = [[ChangePasswordViewController alloc] init];
        [self.navigationController pushViewController:cpVC animated:YES];
    }else if(indexPath.row == 5) {
        AboutViewController *aboutVC = [[AboutViewController alloc] init];
        [self.navigationController pushViewController:aboutVC animated:YES];
    }
}


- (IBAction)changeAccountOnclick:(UIButton *)sender {
    LoginViewController *vc = [[LoginViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [Tools setRootViewControllerWithCrossDissolve:_app.window andViewController:nav];
}

@end
