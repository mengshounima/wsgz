//
//  UserInfo.h
//  CarNet
//
//  Created by aiteyuan on 15/12/16.
//  Copyright © 2015年 liyanqin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject
@property (weak,nonatomic) NSNumber *userID;
@property (weak,nonatomic) NSString *createDate;

@property (weak,nonatomic) NSNumber *deleted;
@property (weak,nonatomic) NSNumber *villageId;
@property (weak,nonatomic) NSNumber *townId;

@property (weak,nonatomic) NSString *userName;
@property (weak,nonatomic) NSString *userLoginName;
@property (weak,nonatomic) NSString *userPassword;


@property (weak,nonatomic) NSNumber *lastLat;//上一次定位点
@property (weak,nonatomic) NSNumber *lastLon;
@property (weak,nonatomic) NSNumber *orderNum;

@property (weak,nonatomic) NSNumber *isLeader;
//单例模式
+(UserInfo *)sharedInstance;
-(void)writeUploadData:(NSDictionary *)resultdic;
-(instancetype)ReadUploadData;
-(void)writeData:(NSDictionary *)resultdic;
-(instancetype)ReadData;
-(void)writeOrderNumber:(NSNumber *)orderNumber;
-(instancetype)ReadOrderNumber;
@end
