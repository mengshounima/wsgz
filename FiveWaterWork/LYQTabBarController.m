//
//  LYQTabBarController.m
//  HaiyanJiaojin
//
//  Created by aiteyuan on 15/9/17.
//  Copyright (c) 2015年 liyanqin. All rights reserved.
//

#import "LYQTabBarController.h"
#import "ProjectCategoryVC.h"

@interface LYQTabBarController ()<CustomerTabBarDelegate>
@property (weak, nonatomic) CustomerTabBar *customerTabBar;
@end

@implementation LYQTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeTabBar) name:@"TabBarRemove" object:nil];
    // 初始化tabbar
    [self setupTabbar];
    
    // 初始化所有的子控制器
    [self setupAllChildViewControllers];
}
- (void)dealloc{//移除通知
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)removeTabBar
{
    // 删除系统自动生成的UITabBarButton
    for (UIView *child in self.tabBar.subviews) {
        if ([child isKindOfClass:[UIControl class]]) {
            [child removeFromSuperview];
        }
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    // 删除系统自动生成的UITabBarButton
    for (UIView *child in self.tabBar.subviews) {
        if ([child isKindOfClass:[UIControl class]]) {
            [child removeFromSuperview];
        }
    }
}
#pragma mark - 初始化tabbar
- (void)setupTabbar
{
    CustomerTabBar *myTabBar = [[CustomerTabBar alloc] init];
    myTabBar.frame = self.tabBar.bounds;
    
    UIImageView *backImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, myTabBar.frame.size.width, myTabBar.frame.size.height)];
    
    backImage.backgroundColor = [UIColor whiteColor];
//    [backImage setImage:[UIImage imageNamed:@"底栏背景"]];
    
    myTabBar.customerTabBarDelegate = self;
    [self.tabBar addSubview:backImage];
    [self.tabBar addSubview:myTabBar];
    _customerTabBar = myTabBar;
}
- (void)setupAllChildViewControllers
{
    NoticeRootVC *noticevc = [[NoticeRootVC alloc] init];
    [self addOneViewControllerName:noticevc title:@"公告" imageName:@"notice_btn_unselected" seletedImageName:@"notice_btn_selected"];
    
    //六大类
    ProjectCategoryVC *projectCategoryVC = [[ProjectCategoryVC alloc] init];
    [self addOneViewControllerName:projectCategoryVC title:@"六大类" imageName:@"notice_btn_unselected" seletedImageName:@"notice_btn_selected"];

    
    WorkOrderRootVC *workordervc = [[WorkOrderRootVC alloc] init];
    [self addOneViewControllerName:workordervc title:@"工单" imageName:@"form_btn_unselected" seletedImageName:@"form_btn_selected"];
    
    MapRootVC *mapvc = [[MapRootVC alloc] init];
    [self addOneViewControllerName:mapvc title:@"巡河" imageName:@"map_btn_unselected" seletedImageName:@"map_btn_selected"];

    AddressBookRootVC *addressvc = [[AddressBookRootVC alloc]init];
    [self addOneViewControllerName:addressvc title:@"通讯录" imageName:@"contacts_btn_unselected" seletedImageName:@"contacts_btn_selected"];
    
    TopicRootVC *topvc = [[TopicRootVC alloc]init];
    [self addOneViewControllerName:topvc title:@"话题" imageName:@"topic_btn_unselected" seletedImageName:@"topic_btn_selected"];
}
-(void)addOneViewControllerName:(UIViewController *)ViewController
                          title:(NSString *)title
                      imageName:(NSString *)imageName
               seletedImageName:(NSString *)selectedImageName
{
    HMNavigationController *nav = [[HMNavigationController alloc]init];//获取该storyboard的第一个界面
    nav.viewControllers = @[ViewController];//将ViewController压入控制器栈底
    
    nav.title = title;
    nav.tabBarItem.image = [UIImage imageNamed:imageName];
    UIImage *selectedImage = [UIImage imageNamed:selectedImageName];
    nav.tabBarItem.selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    [self addChildViewController:nav];
    
    [_customerTabBar addTabBarBtnWithItem:nav.tabBarItem];
}
- (void)addOneStoryBoardName:(NSString *)storyBoardName
                       title:(NSString *)title
                   imageName:(NSString *)imageName
           selectedImageName:(NSString *)selectedImageName
{
   
    UIStoryboard *schoolStoryBoard=[UIStoryboard storyboardWithName:storyBoardName bundle:nil];
     HMNavigationController *nav = [schoolStoryBoard instantiateInitialViewController];//获取该storyboard的第一个界面

    nav.title = title;
    nav.tabBarItem.image = [UIImage imageNamed:imageName];
    UIImage *selectedImage = [UIImage imageNamed:selectedImageName];
    nav.tabBarItem.selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    [self addChildViewController:nav];
    
    [_customerTabBar addTabBarBtnWithItem:nav.tabBarItem];//添加tabbar按钮
}
#pragma mark - CustomerTabBarDelegate
- (void)customerTabBar:(CustomerTabBar *)tabBar didSelectedButtonFrom:(NSInteger)from to:(NSInteger)to
{
    
    self.selectedIndex = to;
}

@end
