//
//  NewsListModel.m
//  ZSDOrder
//
//  Created by 凯东源 on 17/5/11.
//  Copyright © 2017年 凯东源. All rights reserved.
//

#import "NewsListModel.h"

NSString *const kNewsListModelADDDATE = @"ADD_DATE";
NSString *const kNewsListModelCONTENT = @"CONTENT";
NSString *const kNewsListModelIDX = @"IDX";
NSString *const kNewsListModelISREAD = @"ISREAD";
NSString *const kNewsListModelREADCOUNT = @"READCOUNT";
NSString *const kNewsListModelTITLE = @"TITLE";
NSString *const kNewsListModelUSERID = @"USERID";

@implementation NewsListModel

/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if(![dictionary[kNewsListModelADDDATE] isKindOfClass:[NSNull class]]){
        self.aDDDATE = dictionary[kNewsListModelADDDATE];
    }
    if(![dictionary[kNewsListModelCONTENT] isKindOfClass:[NSNull class]]){
        self.cONTENT = dictionary[kNewsListModelCONTENT];
    }
    if(![dictionary[kNewsListModelIDX] isKindOfClass:[NSNull class]]){
        self.iDX = dictionary[kNewsListModelIDX];
    }
    if(![dictionary[kNewsListModelISREAD] isKindOfClass:[NSNull class]]){
        self.iSREAD = dictionary[kNewsListModelISREAD];
    }
    if(![dictionary[kNewsListModelREADCOUNT] isKindOfClass:[NSNull class]]){
        self.rEADCOUNT = dictionary[kNewsListModelREADCOUNT];
    }
    if(![dictionary[kNewsListModelTITLE] isKindOfClass:[NSNull class]]){
        self.tITLE = dictionary[kNewsListModelTITLE];
    }
    if(![dictionary[kNewsListModelUSERID] isKindOfClass:[NSNull class]]){
        self.uSERID = dictionary[kNewsListModelUSERID];
    }
    return self;
}


/**
 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
 */
-(NSDictionary *)toDictionary
{
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
    if(self.aDDDATE != nil){
        dictionary[kNewsListModelADDDATE] = self.aDDDATE;
    }
    if(self.cONTENT != nil){
        dictionary[kNewsListModelCONTENT] = self.cONTENT;
    }
    if(self.iDX != nil){
        dictionary[kNewsListModelIDX] = self.iDX;
    }
    if(self.iSREAD != nil){
        dictionary[kNewsListModelISREAD] = self.iSREAD;
    }
    if(self.rEADCOUNT != nil){
        dictionary[kNewsListModelREADCOUNT] = self.rEADCOUNT;
    }
    if(self.tITLE != nil){
        dictionary[kNewsListModelTITLE] = self.tITLE;
    }
    if(self.uSERID != nil){
        dictionary[kNewsListModelUSERID] = self.uSERID;
    }
    return dictionary;
    
}

/**
 * Implementation of NSCoding encoding method
 */
/**
 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
 */
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    if(self.aDDDATE != nil){
        [aCoder encodeObject:self.aDDDATE forKey:kNewsListModelADDDATE];
    }
    if(self.cONTENT != nil){
        [aCoder encodeObject:self.cONTENT forKey:kNewsListModelCONTENT];
    }
    if(self.iDX != nil){
        [aCoder encodeObject:self.iDX forKey:kNewsListModelIDX];
    }
    if(self.iSREAD != nil){
        [aCoder encodeObject:self.iSREAD forKey:kNewsListModelISREAD];
    }
    if(self.rEADCOUNT != nil){
        [aCoder encodeObject:self.rEADCOUNT forKey:kNewsListModelREADCOUNT];
    }
    if(self.tITLE != nil){
        [aCoder encodeObject:self.tITLE forKey:kNewsListModelTITLE];
    }
    if(self.uSERID != nil){
        [aCoder encodeObject:self.uSERID forKey:kNewsListModelUSERID];
    }
    
}

/**
 * Implementation of NSCoding initWithCoder: method
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    self.aDDDATE = [aDecoder decodeObjectForKey:kNewsListModelADDDATE];
    self.cONTENT = [aDecoder decodeObjectForKey:kNewsListModelCONTENT];
    self.iDX = [aDecoder decodeObjectForKey:kNewsListModelIDX];
    self.iSREAD = [aDecoder decodeObjectForKey:kNewsListModelISREAD];
    self.rEADCOUNT = [aDecoder decodeObjectForKey:kNewsListModelREADCOUNT];
    self.tITLE = [aDecoder decodeObjectForKey:kNewsListModelTITLE];
    self.uSERID = [aDecoder decodeObjectForKey:kNewsListModelUSERID];
    return self;
    
}

/**
 * Implementation of NSCopying copyWithZone: method
 */
- (instancetype)copyWithZone:(NSZone *)zone
{
    NewsListModel *copy = [NewsListModel new];
    
    copy.aDDDATE = [self.aDDDATE copy];
    copy.cONTENT = [self.cONTENT copy];
    copy.iDX = [self.iDX copy];
    copy.iSREAD = [self.iSREAD copy];
    copy.rEADCOUNT = [self.rEADCOUNT copy];
    copy.tITLE = [self.tITLE copy];
    copy.uSERID = [self.uSERID copy];
    
    return copy;
}

@end
