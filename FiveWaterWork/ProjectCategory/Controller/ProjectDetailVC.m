//
//  ProjectDetailVC.m
//  FiveWaterWork
//
//  Created by 李 燕琴 on 2017/10/3.
//  Copyright © 2017年 aty. All rights reserved.
//

#import "ProjectDetailVC.h"
#import "ProjectPlanVC.h"
#import <Masonry/Masonry.h>

@interface ProjectDetailVC ()

@property (nonatomic, strong) NSString *policyManageId;

@property (nonatomic, strong) NSArray *items;

@property (nonatomic, strong) NSDictionary *data;

@end

@implementation ProjectDetailVC

- (instancetype)initWithPolicyManageId:(NSString *)manageId {
    if (self = [super init]) {
        _policyManageId = manageId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"项目详情";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"项目计划" style:UIBarButtonItemStylePlain target:self action:@selector(jumpToProjectPlan)];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ProjectDetail" ofType:@"plist"];
    self.items = [NSArray arrayWithContentsOfFile:path];
    [self setupData];
    
}

- (void)setupData {
    __weak typeof(self) weakSelf = self;
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    param[@"isMobile"] = @"1";
    param[@"policyManageId"] = _policyManageId;
    
    [SVProgressHUD show];
    [[HttpClient httpClient] requestWithPath:@"/queryPolicyManageById.action" method:TBHttpRequestPost parameters:param prepareExecute:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [SVProgressHUD dismiss];
        if ([[responseObject class] isSubclassOfClass:[NSDictionary class]]) {
            NSDictionary *data = responseObject[@"data"];
            NSArray *rows = data[@"rows"];
            if (rows.count > 0) {
                weakSelf.data = [rows firstObject];
                [weakSelf setupView];
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD dismiss];
        if (error.userInfo[@"name"]) {
            [SVProgressHUD showErrorWithStatus:error.userInfo[@"name"]];
        }
    }];
}

- (void)setupView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.scrollEnabled = YES;
    scrollView.showsVerticalScrollIndicator = YES;
    [self.view addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuide);
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
                make.top.mas_equalTo(20);
            }
            
        }];
        
        NSString *content = [self configureContentWithItem:item];
        
        itemLabel.text = [NSString stringWithFormat:@"%@: %@",item[@"title"],content];
        lastLabel = itemLabel;
    }
    [lastLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(contentView);
    }];
}

- (NSString *)configureContentWithItem:(NSDictionary *)item {
    if ([item[@"key"] isEqualToString:@"projectstatus"]) {
        //项目状态
        if([self.data[item[@"key"]] isEqualToString:@"1"]) {
            return @"规划中";
        }else if ([self.data[item[@"key"]] isEqualToString:@"2"]) {
            return @"立项中";
        }else if ([self.data[item[@"key"]] isEqualToString:@"3"]) {
            return @"建设中";
        }else {
            return @"已完成";
        }
    }else if([item[@"key"] isEqualToString:@"investmenttype"]) {
        if ([self.data[item[@"key"]] isEqualToString:@"1"]) {
            return @"政府投资";
        }else {
            return @"企业投资";
        }
    }else if([item[@"key"] isEqualToString:@"status"]) {
        NSNumber *status = self.data[item[@"key"]];
        if (status.integerValue == 0) {
            return @"未审核";
        }else if (status.integerValue == 1) {
            return @"启用";
        }else {
            return @"停用";
        }
    }else if([item[@"key"] isEqualToString:@"totalinvestment"]) {
        return [NSString stringWithFormat:@"%@ 万元",self.data[item[@"key"]]];
    }else {
        return NotNilObject(self.data[item[@"key"]]);
    }
}

#pragma mark - User Interantion

- (void)jumpToProjectPlan {
    ProjectPlanVC *projectPlanVC = [[ProjectPlanVC alloc] initWithPolicyManageId:_policyManageId];
    [self.navigationController pushViewController:projectPlanVC animated:YES];
}


@end
