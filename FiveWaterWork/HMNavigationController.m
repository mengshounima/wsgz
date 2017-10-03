//
//  HMNavigationController.m
//  黑马微博
//
//  Created by apple on 14-7-3.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "HMNavigationController.h"

@interface HMNavigationController ()

@end

@implementation HMNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
/**
 *  当导航控制器的view创建完毕就调用
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    
}

/**
 *  当第一次使用这个类的时候调用1次
 */
+ (void)initialize
{
    UINavigationBar *navigationBar = [UINavigationBar appearance];
    [navigationBar setBarTintColor:baseColor];//导航条
    [navigationBar setTintColor:[UIColor whiteColor]];//设置NavigationBarItem文字，图片的颜色
    
    NSShadow *shadow = [[NSShadow alloc]init];
    [shadow setShadowOffset:CGSizeZero];
    [navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                                            
                                            NSShadowAttributeName : shadow}];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];//设置样式
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];//去除返回按钮的文本
    
}


/**
 *  能拦截所有push进来的子控制器
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count > 0) { // 如果现在push的不是栈底控制器(最先push进来的那个控制器)
        viewController.hidesBottomBarWhenPushed = YES;
        
        // 设置导航栏按钮
        viewController.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImageName:@"返回-未选中" highImageName:@"返回-选中" target:self action:@selector(back)];
    }
    [super pushViewController:viewController animated:animated];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // 删除系统自带的tabBarButton
    for (UIView *tabBar in self.tabBarController.tabBar.subviews) {
        if ([tabBar isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            [tabBar removeFromSuperview];
        }
    }
}

- (void)back
{
    [self popViewControllerAnimated:YES];
}

@end
