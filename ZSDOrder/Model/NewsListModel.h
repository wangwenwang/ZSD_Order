//
//  NewsListModel.h
//  ZSDOrder
//
//  Created by 凯东源 on 17/5/11.
//  Copyright © 2017年 凯东源. All rights reserved.
//

#import <Foundation/Foundation.h>


//{
//    "ISREAD" : "",
//    "USERID" : "",
//    "TITLE" : "第一页",
//    "READCOUNT" : "",
//    "IDX" : "12",
//    "CONTENT" : "test啊萨达萨达撒fsd",
//    "ADD_DATE" : "2017/5/9 15:37:49"
//}

@interface NewsListModel : NSObject

@property (nonatomic, strong) NSString * aDDDATE;
@property (nonatomic, strong) NSString * cONTENT;
@property (nonatomic, strong) NSString * iDX;
@property (nonatomic, strong) NSString * iSREAD;
@property (nonatomic, strong) NSString * rEADCOUNT;
@property (nonatomic, strong) NSString * tITLE;
@property (nonatomic, strong) NSString * uSERID;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

-(NSDictionary *)toDictionary;

@end
