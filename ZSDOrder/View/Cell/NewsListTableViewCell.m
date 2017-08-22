//
//  NewsListTableViewCell.m
//  ZSDOrder
//
//  Created by 凯东源 on 17/5/11.
//  Copyright © 2017年 凯东源. All rights reserved.
//

#import "NewsListTableViewCell.h"

@interface NewsListTableViewCell ()

// 标题
@property (weak, nonatomic) IBOutlet UILabel *TITLE;

// 日期
@property (weak, nonatomic) IBOutlet UILabel *ADD_DATE;

@end

@implementation NewsListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setNewsListM:(NewsListModel *)newsListM {
    
    _newsListM = newsListM;
    
    _TITLE.text = _newsListM.tITLE;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [formatter dateFromString:_newsListM.aDDDATE];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *a = [formatter stringFromDate:date];
    
    _ADD_DATE.text = a;
}

@end
