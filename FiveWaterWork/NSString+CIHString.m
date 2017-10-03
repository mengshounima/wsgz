//
//  NSString+CIHString.m
//  smartcar
//
//  Created by cihonMac on 13-12-17.
//  Copyright (c) 2013年 cihon. All rights reserved.
//

#import "NSString+CIHString.h"

@implementation NSString (CIHString)


//判断字符串是否有效
+(BOOL)isStringEffective:(NSString *)str
{
    BOOL retVal = YES;
    if([str isEqualToString:@"null"]||[str isEqualToString:@"(null)"]||[str isEqualToString:@""]||[str isEqualToString:@"NULL"]||[str isEqualToString:@"(NULL)"]||!str){
        retVal = NO;
    }
    return retVal;
}


//获取当前时间
+(NSString*)getCurrentTime:(NSString *)timeFormatterStr
{
    NSDate* date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    if(timeFormatterStr && ! [timeFormatterStr isEqualToString:@""])
    {
         [dateFormatter setDateFormat:timeFormatterStr];
    }else{
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    return  [dateFormatter stringFromDate:date];
}
//获取date
+(NSDate *)getDateTime:(NSString *)dateForamtterStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateForamtterStr];
    NSDate *date = [dateFormatter dateFromString:dateForamtterStr];
    return date;
}

//获取自1970时间间隔秒数
+(NSString*)getStandardTimeInterval:(NSString *)dateForamtterStr
{
    NSDate *time = [NSString getDateTime:dateForamtterStr];
    return [NSString stringWithFormat:@"%f",[time timeIntervalSince1970]];
}


+(NSString *)getTimeDescrip:(NSString*)sendTime
{
    NSString *timeDes = @"";
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    //当前时间
    NSDate *datenow = [NSDate date];

    NSString *nowtimeStr = [formatter stringFromDate:datenow];
    datenow = [formatter dateFromString:nowtimeStr];
    

    //比较时间
    NSDate *date2=[formatter dateFromString:sendTime];
    //间隔
    NSTimeInterval time = [datenow timeIntervalSinceDate:date2];
    
    int days=((int)time)/(3600*24);
    int hours=((int)time)%(3600*24)/3600;
    int minutes = ((int)time)%(3600)/60;
    
    if(days == 0 && hours == 0)
    {
        if(minutes <= 5)
        {
            timeDes = @"刚刚";
        }
        else{
            timeDes = [NSString stringWithFormat:@"%d分钟前",minutes];
        }
    }
    if(days == 0 && hours != 0)
    {
        timeDes = [NSString stringWithFormat:@"%d小时前",hours];
    }
    if(days != 0)
    {
        int year = days/365;
        if(year != 0)
        {
            return [NSString stringWithFormat:@"%d年前",year];
        }
        int week = days/7;
        if(week != 0)
        {
            timeDes = [NSString stringWithFormat:@"%d周前",week];
        }
        else{
            timeDes = [NSString stringWithFormat:@"%d天前",days];
        }
    }
    return timeDes;
}
+(NSString*)getyear{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy"];
    NSString *year = [formatter stringFromDate:date];
    return year;
}
+(NSString*)getmonth{
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MM"];
    NSString *month = [formatter stringFromDate:date];
    return month;
    
}

//四舍五入
+(float)changeFloat:(float)sourceFloat withPoint:(int)num
{
    int numPoint = pow(10, num);
    float afterFloat = roundf(sourceFloat*numPoint)/numPoint;
    return afterFloat;
}
+(float)changeString:(NSString*)sourceStr withPoint:(int)num
{
    return [self changeFloat:[sourceStr floatValue] withPoint:num];
}



@end
