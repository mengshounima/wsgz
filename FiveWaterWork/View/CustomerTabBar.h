//
//  CustomerTabBar.h
//  uHuoIOS
//
//  Created by Shen Jun on 15/8/8.
//  Copyright (c) 2015年 shenjunMac. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomerTabBar;

@protocol CustomerTabBarDelegate <NSObject>

- (void)customerTabBar:(CustomerTabBar *)tabBar didSelectedButtonFrom:(NSInteger)from to:(NSInteger)to;

@end

@interface CustomerTabBar : UIView

- (void)addTabBarBtnWithItem:(UITabBarItem *)item;

@property (weak, nonatomic) id<CustomerTabBarDelegate> customerTabBarDelegate;

@end
