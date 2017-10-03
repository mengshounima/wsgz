//
//  NSString+CIHString.h
//  smartcar
//
//  Created by cihonMac on 13-12-17.
//  Copyright (c) 2013年 cihon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CIHString)

//如果是@"",null,(null),NULL,(NULL),就返回NO
+(BOOL)isStringEffective:(NSString *)str;

//得到特定格式的时间
+(NSString*)getCurrentTime:(NSString *)timeFormatterStr;

//得到特定格式的NSDate
+(NSDate *)getDateTime:(NSString *)dateForamtterStr;

//得到自1970年的秒数
+(NSString*)getStandardTimeInterval:(NSString *)dateForamtterStr;

//时间和当前时间的描述，如一周前，2个小时前
+(NSString *)getTimeDescrip:(NSString*)sendTime;

+(NSString*)getyear;
+(NSString*)getmonth;
//四舍五入
+(float)changeFloat:(float)sourceFloat withPoint:(int)num;

+(float)changeString:(NSString*)sourceStr withPoint:(int)num;



@end


















