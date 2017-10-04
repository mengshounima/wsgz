//
//  MapBarBtnItem.m
//  FiveWaterWork
//
//  Created by aiteyuan on 16/1/28.
//  Copyright © 2016年 aty. All rights reserved.
//

#import "MapBarBtnItem.h"

#define CustomerTabBarBtnImageRatio 0.7
@implementation MapBarBtnItem

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 图标居中
        self.imageView.contentMode = UIViewContentModeCenter;
        // 文字居中
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        // 字体大小
        self.titleLabel.font = [UIFont systemFontOfSize:12];
        // 文字颜色
        [self setTitleColor:choiceColor(128, 128, 128) forState:UIControlStateNormal];
        [self setTitleColor:choiceColor(52, 107, 164) forState:UIControlStateSelected];
    }
    return self;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat imageW = contentRect.size.width;
    CGFloat imageH = contentRect.size.height*CustomerTabBarBtnImageRatio;
    return CGRectMake(0, 3, imageW, imageH);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat titleY = contentRect.size.height*CustomerTabBarBtnImageRatio;
    CGFloat titleW = contentRect.size.width;
    CGFloat titleH = contentRect.size.height - titleY;
    return CGRectMake(0, titleY, titleW, titleH);
}

// 重写去掉高亮状态
//- (void)setHighlighted:(BOOL)highlighted {}

@end
