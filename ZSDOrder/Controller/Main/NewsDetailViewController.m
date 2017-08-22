//
//  NewsDetailViewController.m
//  ZSDOrder
//
//  Created by 凯东源 on 17/5/11.
//  Copyright © 2017年 凯东源. All rights reserved.
//

#import "NewsDetailViewController.h"
#import "Tools.h"
#import <Masonry.h>

@interface NewsDetailViewController ()

// 容器
@property (weak, nonatomic) IBOutlet UIView *ScrollContentView;

// 标题
@property (weak, nonatomic) IBOutlet UILabel *TitleLabel;

// 内容
@property (weak, nonatomic) IBOutlet UILabel *ContentLabel;

// 时间
@property (weak, nonatomic) IBOutlet UILabel *DateLabel;

// scrollView 高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollContentViewHeight;

// 标题Label 高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *TitleLabelHeight;

// 时间Label 高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *DateLabelHeight;

// 时间Label top
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *DateLabelTop;

@end

@implementation NewsDetailViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    
    self.title = @"资讯详情";
    
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[_newsListM.cONTENT dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    
    _ContentLabel.attributedText = attrStr;
    
    [_ContentLabel sizeToFit];
    
    _TitleLabel.text = _newsListM.tITLE;
    
    // 高度 = 标题 + 内容 + 日期距上 + 日期
    _scrollContentViewHeight.constant = _TitleLabelHeight.constant + CGRectGetHeight(_ContentLabel.frame) + _DateLabelTop.constant + _DateLabelHeight.constant ;
    
    _DateLabel.text = [NSString stringWithFormat:@"时间：%@", _newsListM.aDDDATE];
    
    // 日期 Label
    UILabel *dateLabel = [[UILabel alloc] init];
    [dateLabel setFont:[UIFont systemFontOfSize:13]];
    dateLabel.textAlignment = NSTextAlignmentRight;
    dateLabel.text = [NSString stringWithFormat:@"时间：%@", _newsListM.aDDDATE];
    
    // 内容高度小于屏高，日期置于底部
    if(_scrollContentViewHeight.constant < CGRectGetHeight(self.view.frame)) {
        
        [self.view addSubview:dateLabel];
        
        __weak typeof (self) weakSelf = self;
        [dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(20);
            make.left.equalTo(weakSelf.view).offset(15);
            make.right.equalTo(weakSelf.view).offset(-15);
            make.bottom.equalTo(weakSelf.view).offset(-5);
        }];
    }
    
    // 内容高度大于屏高，日期置于底部
    else {
        
        [_ScrollContentView addSubview:dateLabel];
        
        __weak typeof (self) weakSelf = self;
        [dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(20);
            make.left.equalTo(weakSelf.view).offset(10);
            make.right.equalTo(weakSelf.view).offset(-15);
            make.bottom.equalTo(_ScrollContentView).offset(-5);
        }];
    }
}


- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

@end
