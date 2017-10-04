//
//  ProjectPlanDetailVC.m
//  FiveWaterWork
//
//  Created by 李 燕琴 on 2017/10/4.
//  Copyright © 2017年 aty. All rights reserved.
//

#import "ProjectPlanDetailVC.h"
#import <Masonry/Masonry.h>

@interface ProjectPlanDetailVC ()

@property (nonatomic, strong) NSString *planId;

@property (nonatomic, strong) NSString *planType;

@property (nonatomic, strong) NSDictionary *detailData;

@property (nonatomic, strong) NSArray *items;

@end

@implementation ProjectPlanDetailVC

- (instancetype)initWithPlanId:(NSString *)planId planType:(NSString *)planType {
    if (self = [super init]) {
        _planId = planId;
        _planType = planType;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self fetchData];
}

- (void)initData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ProjectPlanDetailMonth" ofType:@"plist"];
    self.items = [NSArray arrayWithContentsOfFile:path];
}

- (void)fetchData {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    param[@"isMobile"] = @"1";
    param[@"planId"] = _planId;
    
    [SVProgressHUD show];
    __weak typeof(self) weakSelf = self;
    [[HttpClient httpClient] requestWithPath:@"/queryAllProjectPlanById.action" method:TBHttpRequestPost parameters:param prepareExecute:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [SVProgressHUD dismiss];
        
        if ([[responseObject class] isSubclassOfClass:[NSDictionary class]]) {
            NSDictionary *dataDic = responseObject[@"data"];
            NSArray *rows = dataDic[@"rows"];
            if (rows.count > 0) {
                weakSelf.detailData = [rows firstObject];
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
        if ([self.detailData[item[@"key"]] isEqualToString:@"0"]) {
            return [NSString stringWithFormat:@"%@: 月计划",item[@"title"]];
        }else{
            return [NSString stringWithFormat:@"%@: 年计划",item[@"title"]];
        }
    }else if([item[@"key"] isEqualToString:@"investment"]) {
        return [NSString stringWithFormat:@"%@: %@万元",item[@"title"],self.detailData[item[@"key"]]];
    }else if([item[@"key"] isEqualToString:@"planmonth"]) {
        if ([_planType isEqualToString:@"0"]) {
            return [NSString stringWithFormat:@"计划月份: %@",self.detailData[@"planmonth"]];
        }else{
            return [NSString stringWithFormat:@"计划年份: %@",self.detailData[@"planyear"]];
        }
    }else {
        return self.detailData[item[@"key"]];
    }
}

@end
