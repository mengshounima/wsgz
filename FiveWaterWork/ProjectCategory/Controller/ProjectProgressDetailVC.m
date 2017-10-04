//
//  ProjectProgressDetailVC.m
//  FiveWaterWork
//
//  Created by 李 燕琴 on 2017/10/4.
//  Copyright © 2017年 aty. All rights reserved.
//

#import "ProjectProgressDetailVC.h"
#import <Masonry/Masonry.h>

@interface ProjectProgressDetailVC ()

@property (nonatomic, strong) NSString *progressId;

@property (nonatomic, strong) NSDictionary *detailData;

@property (nonatomic, strong) NSArray *items;

@end

@implementation ProjectProgressDetailVC

- (instancetype)initWithProgressId:(NSString *)progressId {
    if (self = [super init]) {
        _progressId = progressId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ProjectProgressDetail" ofType:@"plist"];
    self.items = [NSArray arrayWithContentsOfFile:path];
    
    [self fetchData];
}

- (void)fetchData {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    param[@"isMobile"] = @"1";
    param[@"projectProgressId"] = _progressId;
    
    __weak typeof(self) weakSelf = self;
    [SVProgressHUD show];
    [[HttpClient httpClient] requestWithPath:@"/queryProjectProgressById.action" method:TBHttpRequestPost parameters:param prepareExecute:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [SVProgressHUD dismiss];
        if ([[responseObject class] isSubclassOfClass:[NSDictionary class]]) {
            NSDictionary *dataDic = responseObject[@"data"];
            NSArray *rows = dataDic[@"rows"];
            if (rows.count > 0) {
                weakSelf.detailData = [rows firstObject];
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
        
        itemLabel.text = [NSString stringWithFormat:@"%@: %@",item[@"title"],content];
        lastLabel = itemLabel;
    }

}

- (NSString *)configureContentWithItem:(NSDictionary *)item {
    if ([item[@"key"] isEqualToString:@"progress"]) {
            return [NSString stringWithFormat:@"%@%%",self.detailData[item[@"key"]]];
    }
    return self.detailData[item[@"key"]];
}

@end
