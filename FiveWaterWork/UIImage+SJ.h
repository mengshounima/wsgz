//
//  UIImage+SJ.h
//  itrunWeibo
//
//  Created by Shen Jun on 14-9-24.
//  Copyright (c) 2014年 aiteyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (SJ)

/**
 *	加载图片
 *
 *	@param 	name 	图片名
 *
 */
+ (UIImage *)imageWithName:(NSString *)name;

/**
 *	返回一张自由拉伸的图片
 */
+ (UIImage *)resizedImageWithName:(NSString *)name;

+ (UIImage *)resizedImageWithName:(NSString *)name left:(CGFloat)left top:(CGFloat)top;

@end
