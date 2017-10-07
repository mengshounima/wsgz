//
//  ProjectPlanDetailVC.m
//  FiveWaterWork
//
//  Created by 李 燕琴 on 2017/10/4.
//  Copyright © 2017年 aty. All rights reserved.
//

#import "ProjectPlanDetailVC.h"
#import "ProjectProgressVC.h"
#import <Masonry/Masonry.h>

@interface ProjectPlanDetailVC ()

@property (nonatomic, strong) NSDictionary *detailData;

@property (nonatomic, strong) NSArray *items;

@end

@implementation ProjectPlanDetailVC

- (instancetype)initWithData:(NSDictionary *)data {
    if (self = [super init]) {
        _detailData = data;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"计划详情";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"项目进度" style:UIBarButtonItemStylePlain target:self action:@selector(jumpToProjectProgress)];
    [self initData];
    [self setupView];
}

- (void)initData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ProjectPlanDetail" ofType:@"plist"];
    self.items = [NSArray arrayWithContentsOfFile:path];
}

- (void)setupView {
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.scrollEnabled = YES;
    scrollView.showsVerticalScrollIndicator = YES;
    [self.view addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    UIView *contentView = [[UIView alloc] init];
    [scrollView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(scrollView);
        make.bottom.mas_equalTo(-20);
        make.width.mas_equalTo(SCREEN_WIDTH);
    }];
    
    UILabel *lastLabel;
    for (NSDictionary *item in _items) {
        UILabel *itemLabel = [[UILabel alloc] init];
        itemLabel.textColor = [UIColor blackColor];
        itemLabel.font = [UIFont systemFontOfSize:14];
        itemLabel.textAlignment = NSTextAlignmentLeft;
        itemLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 40;
        [contentView addSubview:itemLabel];
        [itemLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.height.mas_lessThanOrEqualTo(100);
            make.right.mas_equalTo(-20);
            if (lastLabel) {
                make.top.equalTo(lastLabel.mas_bottom).offset(20);
            }else {
                make.top.equalTo(self.mas_topLayoutGuide).offset(20);
            }
            
        }];
        
        NSString *content = [self configureContentWithItem:item];
        
        itemLabel.text = content;
        lastLabel = itemLabel;
    }
 
}

- (NSString *)configureContentWithItem:(NSDictionary *)item {
    if ([item[@"key"] isEqualToString:@"plantype"]) {
        NSNumber *plantype = self.detailData[item[@"key"]];
        if ([plantype.stringValue isEqualToString:@"0"]) {
            return [NSString stringWithFormat:@"%@: 月计划",item[@"title"]];
        }else{
            return [NSString stringWithFormat:@"%@: 年计划",item[@"title"]];
        }
    }else if([item[@"key"] isEqualToString:@"investment"]) {
        return [NSString stringWithFormat:@"%@: %@万元",item[@"title"],self.detailData[item[@"key"]]];
    }else if([item[@"key"] isEqualToString:@"planmonth"]) {
        NSNumber *plantype = self.detailData[item[@"key"]];
        if ([plantype.stringValue isEqualToString:@"0"]) {
            return [NSString stringWithFormat:@"计划月份: %@",self.detailData[@"planmonth"]];
        }else{
            return [NSString stringWithFormat:@"计划年份: %@",self.detailData[@"planyear"]];
        }
    }else {
        return self.detailData[item[@"key"]];
    }
}

- (void)jumpToProjectProgress {
    ProjectProgressVC *projectProgressVC = [[ProjectProgressVC alloc] initWithPlanId:_detailData[@"id"]];
    [self.navigationController pushViewController:projectProgressVC animated:YES];
}

@end
