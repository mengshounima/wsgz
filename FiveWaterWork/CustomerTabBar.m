//
//  CustomerTabBar.m
//  uHuoIOS
//
//  Created by Shen Jun on 15/8/8.
//  Copyright (c) 2015年 shenjunMac. All rights reserved.
//

#import "CustomerTabBar.h"
#import "CustomerTabBarBtn.h"

@interface CustomerTabBar()

{
   // int i ;
}
@property (weak, nonatomic) CustomerTabBarBtn *selectedBtn;

@property (nonatomic, strong) NSMutableArray *tabBarButtons;

@end

@implementation CustomerTabBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}
//每个tabbar的btn设置
- (void)addTabBarBtnWithItem:(UITabBarItem *)item
{
    static int i = 0;//只初始化一次
    CustomerTabBarBtn *btn = [CustomerTabBarBtn buttonWithType:UIButtonTypeCustom];
    
    [self insertSubview:btn atIndex:i];
    [btn setTitle:item.title forState:UIControlStateNormal];
    [btn setImage:item.image forState:UIControlStateNormal];
    [btn setImage:item.selectedImage forState:UIControlStateSelected];
    
    // 3.监听按钮点击
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchDown];
    
    // 4.默认选中第0个按钮
    if (i == 0) {
        [self btnClick:btn];
    }
    i++;
}

- (void)btnClick:(CustomerTabBarBtn *)btn
{
    // 2.设置按钮的状态
    self.selectedBtn.selected = NO;
    btn.selected = YES;
    self.selectedBtn = btn;
    

    if ([self.customerTabBarDelegate respondsToSelector:@selector(customerTabBar:didSelectedButtonFrom:to:)]) {
        [self.customerTabBarDelegate customerTabBar:self didSelectedButtonFrom:self.selectedBtn.tag to:btn.tag];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat btnH = self.frame.size.height;
    CGFloat btnW = self.frame.size.width/5;
    CGFloat btnY = 0;
    CGFloat btnX = 0;
    for (int i = 0; i < self.subviews.count; i++) {
        CustomerTabBarBtn *btn = self.subviews[i];

        btnX = i*btnW;
        
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
        btn.tag = i;
    }
}

@end
