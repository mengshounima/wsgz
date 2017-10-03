//
//  UserInfo.m
//  CarNet
//
//  Created by aiteyuan on 15/12/16.
//  Copyright © 2015年 liyanqin. All rights reserved.
//

#import "UserInfo.h"
#define USER @"userInfo"
#define LASTLOCATION @"lastlocation"
#define ORDERNUMBER @"ordernumber"
@implementation UserInfo
+(UserInfo *)sharedInstance{
    static UserInfo *sharedUserInfoInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedUserInfoInstance = [[self alloc] init];
    });
    return sharedUserInfoInstance;
    
}

-(void)writeData:(NSDictionary *)resultdic
{
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
    if (!ISNULL(resultdic)) {
    NSNumber *idStr = [resultdic objectForKey:@"id"];
    if (!ISNULL(idStr)) {
        [tempDic setObject:idStr forKey:@"id"];//用户id
    }
    else{
        [tempDic setObject:@"" forKey:@"id"];//用户id
    }

    NSString *nameStr = [resultdic objectForKey:@"name"];
    if (!ISNULLSTR(nameStr)) {
        [tempDic setObject:nameStr forKey:@"name"];//用户名

    }
    NSString *loginName = [resultdic objectForKey:@"loginName"];
    if (!ISNULLSTR(loginName)) {
        [tempDic setObject: loginName forKey:@"loginName"];//登录名
        
    }
    
    NSString *password =[resultdic objectForKey:@"password"];
    if (!ISNULLSTR(password)) {
        [tempDic setObject:password forKey:@"userPassword"];//密码
    }
    
    NSNumber *deleted = [resultdic objectForKey:@"deleted"];
    if (!ISNULL(deleted)) {
        [tempDic setObject:deleted forKey:@"deleted"];//用户id
    }
    else{
        [tempDic setObject:@"" forKey:@"deleted"];//用户id
    }
        
    NSNumber *villageId = [resultdic objectForKey:@"villageId"];
        if (!ISNULL(villageId)) {
            [tempDic setObject:villageId forKey:@"villageId"];//用户id
        }
        else{
            [tempDic setObject:@"" forKey:@"villageId"];//用户id
        }
        
    NSNumber *townId = [resultdic objectForKey:@"townId"];
        if (!ISNULL(townId)) {
            [tempDic setObject:townId forKey:@"townId"];//用户id
        }
        else{
            [tempDic setObject:@"" forKey:@"townId"];//用户id
        }

        
    NSString *createDate = [resultdic objectForKey:@"createDate"];
        if (!ISNULLSTR(createDate)) {
            [tempDic setObject:createDate forKey:@"createDate"];
        }
        else{
            [tempDic setObject:@"" forKey:@"createDate"];
        }
        
        
    NSNumber *isLeader = [resultdic objectForKey:@"isLeader"];
        if (!ISNULL(isLeader)) {
            [tempDic setObject:isLeader forKey:@"isLeader"];
        }
        else{
            [tempDic setObject:@"" forKey:@"isLeader"];
        }

    [USERDEFAULTS setObject:tempDic forKey:USER];
    [USERDEFAULTS synchronize];
    }else{
        [USERDEFAULTS setObject:tempDic forKey:USER];
        [USERDEFAULTS synchronize];
    }
}
//上次记录的定位信息点
-(void)writeUploadData:(NSDictionary *)resultdic{
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
    [tempDic setObject:[resultdic objectForKey:@"lastLat"] forKey:@"lastLat"];//
    [tempDic setObject:[resultdic objectForKey:@"lastLon"] forKey:@"lastLon"];//
    [USERDEFAULTS setObject:tempDic forKey:LASTLOCATION];
    [USERDEFAULTS synchronize];

}
-(instancetype)ReadUploadData{
    id valueData = [USERDEFAULTS objectForKey:LASTLOCATION];
    UserInfo *info = [[UserInfo alloc] init];
    info.lastLat = [valueData objectForKey:@"lastLat"];
    info.lastLon = [valueData objectForKey:@"lastLon"];
    return info;
}

-(instancetype)ReadData
{
    id valueData = [USERDEFAULTS objectForKey:USER];
    UserInfo *info = [[UserInfo alloc] init];
    
    info.userID = [valueData objectForKey:@"id"];
    info.deleted = [valueData objectForKey:@"deleted"];
    info.villageId = [valueData objectForKey:@"villageId"];
    info.townId = [valueData objectForKey:@"townId"];
    info.userName = [valueData objectForKey:@"name"];
    info.userLoginName = [valueData objectForKey:@"loginName"];
    info.userPassword = [valueData objectForKey:@"userPassword"];
    info.isLeader = [valueData objectForKey:@"isLeader"];
    
    return info;
}

//记录当前工单的单号
-(void)writeOrderNumber:(NSNumber *)orderNumber
{
    NSNumber *orderID = orderNumber;
    [USERDEFAULTS setObject:orderID forKey:ORDERNUMBER];
    [USERDEFAULTS synchronize];
}

-(instancetype)ReadOrderNumber
{
    id valueData = [USERDEFAULTS objectForKey:ORDERNUMBER];
    UserInfo *info = [[UserInfo alloc] init];
    info.orderNum = valueData;
    
    return info;
}

@end
