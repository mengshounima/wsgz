//
//  UIImage+SJ.m
//  itrunWeibo
//
//  Created by Shen Jun on 14-9-24.
//  Copyright (c) 2014年 aiteyuan. All rights reserved.
//

#import "UIImage+SJ.h"

@implementation UIImage (SJ)

+ (UIImage *)imageWithName:(NSString *)name
{
//    if (iOS7)
//    {
//        NSString * newName = [name stringByAppendingString:@"_os7"];
//        UIImage * image = [UIImage imageNamed:newName];
//        if (image == nil)
//        {
//            // 没有_os7 的图片, 加载原图
//            image = [UIImage imageNamed:name];
//        }
//        return image;
//    }
//    // 非ios7
    return [UIImage imageNamed:name];
}

+ (UIImage *)resizedImageWithName:(NSString *)name
{
    return [self resizedImageWithName:name left:0.5 top:0.5];
}


+ (UIImage *)resizedImageWithName:(NSString *)name left:(CGFloat)left top:(CGFloat)top
{
    UIImage *image = [self imageWithName:name];
    return [image stretchableImageWithLeftCapWidth:image.size.width * left topCapHeight:image.size.width * top];
}

@end
