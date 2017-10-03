//
//  SQLmemoTool.h
//  WHTPWorkManager
//
//  Created by aiteyuan on 15/12/7.
//  Copyright © 2015年 ËâæÁâπËøú. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MemoModel.h"
@class MemoModel;
@interface SQLmemoTool : NSObject

+ (SQLmemoTool *)shareInstance;
/**
 *  添加日志
 *
 *  @param newmemo 需要添加的日志
 */
+ (BOOL)addNewMemo:(MemoModel *)newMemo;

/**
 *  获得所有的日子
 *
 *  @return 数组中装着都是SQLmemoTool模型
 */
+ (NSArray *)Memos;

//删除日志
+(BOOL)deletememo:(MemoModel *)memo;

//修改日志
//+(BOOL)updatememo:(MemoModel *)memo isread:(int)isread;

//查询今天是否有备忘录
//+ (NSArray *)selectTodaymemo:(NSString *)todaydate isread:(int)isread;

@end
