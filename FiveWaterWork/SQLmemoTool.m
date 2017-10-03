//
//  SQLmemoTool.m
//  WHTPWorkManager
//
//  Created by aiteyuan on 15/12/7.
//  Copyright © 2015年 ËâæÁâπËøú. All rights reserved.
//

#import "SQLmemoTool.h"
#import <sqlite3.h>

@implementation SQLmemoTool
static sqlite3 *_db;


//数据库单例实现
+ (SQLmemoTool *)shareInstance
{
    //当第一次执行的时候会产生一个空指针
    static SQLmemoTool *handler = nil;
    
    //对指针进行判断, 当第一次执行的时候创建一个对象
    if (handler == nil) {
        
        handler = [[SQLmemoTool alloc] init];
        
    }
    
    //无论是创建的和已经存在的, 都在这里直接return出去
    return handler;
}

+ (void)initialize
{
    // 0.获得沙盒中的数据库文件名
    NSString *filename = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"timer.sqlite"];
    
    // 1.创建(打开)数据库（如果数据库文件不存在，会自动创建）
    int result = sqlite3_open(filename.UTF8String, &_db);
    if (result == SQLITE_OK) {
        NSLog(@"成功打开数据库");
        
        // 2.创表
        const char *sql = "create table if not exists p_studytime1 (timerid integer primary key autoincrement, classid text, starttime text, usetime integer);";
        char *errorMesg = NULL;
        int result = sqlite3_exec(_db, sql, NULL, NULL, &errorMesg);
        if (result == SQLITE_OK) {
            NSLog(@"成功创建p_memobook表");
        } else {
            NSLog(@"创建p_memobook表失败:%s", errorMesg);
        }
    } else {
        NSLog(@"打开数据库失败");
    }
}

+ (BOOL)addNewMemo:(MemoModel *)newMemo
{
    NSString *sql = [NSString stringWithFormat:@"insert into p_studytime1 (classid,starttime,usetime) values('%@', '%@',%d);", newMemo.classid, newMemo.starttime,newMemo.usetime];
    
    char *errorMesg = NULL;
    int result = sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &errorMesg);
    if (result == SQLITE_OK) {
        NSLog(@"成功添加数据");
    } else {
        NSLog(@"创建p_memobook表失败:%s", errorMesg);
    }
    return result == SQLITE_OK;
}

+ (BOOL)deletememo:(MemoModel *)memo
{
    NSString *sql = [NSString stringWithFormat:@"delete from p_studytime1 ;"];
    
    char *errorMesg = NULL;
    int result = sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &errorMesg);
    
    return result == SQLITE_OK;
}

//+ (BOOL)updatememo:(MemoModel *)memo isread:(int)isread
//{
//    NSString *sql = [NSString stringWithFormat:@"update p_studytime set memodate = '%@',memocontent = '%@',memoisread = %d where memoid = %d ;", memo.memodate,memo.memocontent,isread,memo.memoid];
//    
//    char *errorMesg = NULL;
//    int result = sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &errorMesg);
//    
//    return result == SQLITE_OK;
//}

+ (NSArray *)Memos
{
    // 0.定义数组
    NSMutableArray *memos = nil;
    
    // 1.定义sql语句
    NSString *sql = [NSString stringWithFormat:@"select * from p_studytime1;"] ;
    
    // 2.定义一个stmt存放结果集
    sqlite3_stmt *stmt = NULL;
    
    // 3.检测SQL语句的合法性
    int result = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
    if (result == SQLITE_OK) {
        NSLog(@"查询语句是合法的");
        memos = [NSMutableArray array];
        
        // 4.执行SQL语句，从结果集中取出数据
        while (sqlite3_step(stmt) == SQLITE_ROW) { // 真的查询到一行数据
            // 获得这行对应的数据
            
            MemoModel *memo = [[MemoModel alloc] init];
            
            //第0列timerid不用取
            // 获得第1列的id
            const unsigned char *mclassid = sqlite3_column_text(stmt, 1);
            memo.classid = [NSString stringWithUTF8String:(const char *)mclassid];
            
            // 获得第2列的日期
            const unsigned char *mstartt = sqlite3_column_text(stmt, 2);
            memo.starttime = [NSString stringWithUTF8String:(const char *)mstartt];
            
            // 获得第3列的内容
            memo.usetime = sqlite3_column_int(stmt, 3);
            
            // 添加到数组
            [memos addObject:memo];
        }
    } else {
        NSLog(@"查询语句非合法");
    }
    
    return memos;
}

//+ (NSArray *)selectTodaymemo:(NSString *)todaydate isread:(int)isread
//{
//    // 0.定义数组
//    NSMutableArray *memos = nil;
//    
//    // 1.定义sql语句
//    NSString *sql = [NSString stringWithFormat:@"select * from p_memobook1 where memodate = '%@' and memoisread = %d;", todaydate,isread];
//    
//    // 2.定义一个stmt存放结果集
//    sqlite3_stmt *stmt = NULL;
//    
//    // 3.检测SQL语句的合法性
//    int result = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
//    if (result == SQLITE_OK) {
//        NSLog(@"查询语句是合法的");
//        memos = [NSMutableArray array];
//        
//        // 4.执行SQL语句，从结果集中取出数据
//        while (sqlite3_step(stmt) == SQLITE_ROW) { // 真的查询到一行数据
//            // 获得这行对应的数据
//            
//            MemoModel *memo = [[MemoModel alloc] init];
//            
//            // 获得第0列的id
//            memo.memoid = sqlite3_column_int(stmt, 0);
//            
//            // 获得第1列的日期
//            const unsigned char *mdate = sqlite3_column_text(stmt, 1);
//            memo.memodate = [NSString stringWithUTF8String:(const char *)mdate];
//            
//            // 获得第2列的内容
//            const unsigned char *mcontent = sqlite3_column_text(stmt, 2);
//            memo.memocontent = [NSString stringWithUTF8String:(const char *)mcontent];
//            
//            // 添加到数组
//            [memos addObject:memo];
//        }
//    } else {
//        NSLog(@"查询语句非合法");
//    }
//    
//    return memos;
//}


@end
