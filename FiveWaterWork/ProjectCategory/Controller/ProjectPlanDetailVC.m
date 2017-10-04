//
//  ProjectPlanDetailVC.m
//  FiveWaterWork
//
//  Created by 李 燕琴 on 2017/10/4.
//  Copyright © 2017年 aty. All rights reserved.
//

#import "ProjectPlanDetailVC.h"

@interface ProjectPlanDetailVC ()

@property (nonatomic, strong) NSArray *items;

@end

@implementation ProjectPlanDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
}

- (void)initData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ProjectPlanDetail" ofType:@"plist"];
    self.items = [NSArray arrayWithContentsOfFile:path];
}

- (void)fetchData {
    
}

@end
