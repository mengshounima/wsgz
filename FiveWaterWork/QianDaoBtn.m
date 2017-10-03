//
//  QianDaoBtn.m
//  FiveWaterWork
//
//  Created by aiteyuan on 16/2/3.
//  Copyright © 2016年 aty. All rights reserved.
//

#import "QianDaoBtn.h"

#define CustomerTabBarBtnImageRatio 0.8
@implementation QianDaoBtn

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 图标居中
        self.imageView.contentMode = UIViewContentModeCenter;
        // 文字居中
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        // 字体大小
        self.titleLabel.font = [UIFont systemFontOfSize:18];
        // 文字颜色
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    }
    return self;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat imageX = contentRect.size.width/5;
    CGFloat imageY = contentRect.size.height*0.1;
    CGFloat imageW = contentRect.size.height*CustomerTabBarBtnImageRatio;
    CGFloat imageH = contentRect.size.height*CustomerTabBarBtnImageRatio;
    return CGRectMake(imageX, imageY, imageW, imageH);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat titleX = contentRect.size.width/2;
    CGFloat titleY = contentRect.size.height*0.1;
    CGFloat titleW = contentRect.size.width/2;
    CGFloat titleH = contentRect.size.height*CustomerTabBarBtnImageRatio;
    return CGRectMake(titleX, titleY, titleW, titleH);
}
// 重写去掉高亮状态
- (void)setHighlighted:(BOOL)highlighted {}

@end
