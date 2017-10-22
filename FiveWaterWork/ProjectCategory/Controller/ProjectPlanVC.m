//
//  ProjectPlanVC.m
//  FiveWaterWork
//
//  Created by 李 燕琴 on 2017/10/3.
//  Copyright © 2017年 aty. All rights reserved.
//

#import "ProjectPlanVC.h"
#import "ProjectPlanCell.h"
#import "ProjectPlanDetailVC.h"
#import "LYQBlock.h"
#import <Masonry/Masonry.h>
#import <MJRefresh/MJRefresh.h>

static NSString *const KCellIdentifier = @"KCellIdentifier";

@interface ProjectPlanVC () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSString *policyManageId;

@property (nonatomic, strong) UISegmentedControl *segment;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *datas;

@end

@implementation ProjectPlanVC

- (instancetype)initWithPolicyManageId:(NSString *)policyManageId {
    if (self = [super init]) {
        _policyManageId = policyManageId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"项目计划";
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupView];
}

- (void)setupView {
    _segment = [[UISegmentedControl alloc] initWithItems:@[@"月计划",@"年计划"]];
    _segment.selectedSegmentIndex = 0;
    [self.view addSubview:_segment];
    [_segment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30);
        make.right.mas_equalTo(-30);
        make.top.equalTo(self.mas_topLayoutGuide).offset(20);
        make.height.mas_equalTo(40);
    }];
    [_segment addTarget:self action:@selector(segmentChange:) forControlEvents:UIControlEventValueChanged];
    
    _tableView = [[UITableView alloc] init];
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerClass:[ProjectPlanCell class] forCellReuseIdentifier:KCellIdentifier];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_segment.mas_bottom).offset(30);
        make.left.right.bottom.equalTo(self.view);
    }];
    __weak typeof(self) weakSelf = self;
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf setupDataIsRefresh:YES completion:^(id response) {
            [weakSelf.tableView.mj_header endRefreshing];
            [weakSelf.tableView.mj_footer resetNoMoreData];
        }];
    }];
    _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf setupDataIsRefresh:NO completion:^(id response) {
            NSDictionary *dataDic = response[@"data"];
            NSArray *rows = dataDic[@"rows"];
            if (rows.count > 0) {
                [weakSelf.tableView.mj_footer endRefreshing];
            }else {
                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            }

        }];
    }];
    [_tableView.mj_header beginRefreshing];
}

- (void)setupDataIsRefresh:(BOOL)isRefresh completion:(CompletionBlock)completion {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    param[@"isMobile"] = @"1";
    param[@"policyManageId"] = _policyManageId;
    param[@"planType"] = @(_segment.selectedSegmentIndex);
    if (isRefresh) {
        param[@"page"] = @"1";
    }else {
        if (_datas.count %20 == 0) {
            param[@"page"] = [NSString stringWithFormat:@"%lu",_datas.count/20+1];
        }else {
            param[@"page"] = [NSString stringWithFormat:@"%lu",_datas.count/20+2];
        }
    }
    param[@"rows"] = @"20";
    
    __weak typeof(self) weakSelf = self;
    [[HttpClient httpClient] requestWithPath:@"/queryAllProjectPlanById.action" method:TBHttpRequestPost parameters:param prepareExecute:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (isRefresh) {
            [weakSelf.datas removeAllObjects];
        }
        if ([[responseObject class] isSubclassOfClass:[NSDictionary class]]) {
            NSDictionary *dataDic = responseObject[@"data"];
            NSArray *rows = dataDic[@"rows"];
            [weakSelf.datas addObjectsFromArray:rows];
            [weakSelf.tableView reloadData];
        }
        if (completion) {
            completion(responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [weakSelf.tableView.mj_footer endRefreshing];
        [weakSelf.tableView.mj_header endRefreshing];
        if (error.userInfo[@"name"]) {
            [SVProgressHUD showErrorWithStatus:error.userInfo[@"name"]];
        }
    }];
}

#pragma mark - User Interaction

- (void)segmentChange:(UISegmentedControl *)segment {
    [self.tableView.mj_header beginRefreshing];
}


#pragma mark - tableview datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_datas.count > indexPath.row) {
        ProjectPlanCell *cell = [tableView dequeueReusableCellWithIdentifier:KCellIdentifier forIndexPath:indexPath];
       
        NSDictionary *item = _datas[indexPath.row];
        cell.nameLabel.text = item[@"projectname"];
        if (_segment.selectedSegmentIndex == 0) {
            //月计划
            cell.dateLabel.text = [NSString stringWithFormat:@"%@月",item[@"planmonth"]];
        }else {
            //年计划
            cell.dateLabel.text = [NSString stringWithFormat:@"%@年",item[@"planyear"]];
        }
        
        cell.moneyLabel.text = [NSString stringWithFormat:@"%@万元",item[@"investment"]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    return nil;
}

#pragma mark - tableview delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_datas.count > indexPath.row) {
        NSDictionary *item = _datas[indexPath.row];
        ProjectPlanDetailVC *projectPlanDetailVC = [[ProjectPlanDetailVC alloc] initWithData:item ];
        [self.navigationController pushViewController:projectPlanDetailVC animated:YES];
    }
}

#pragma mark - Setters and Getters

- (NSMutableArray *)datas {
    if (!_datas) {
        _datas = [[NSMutableArray alloc] init];
    }
    return _datas;
}

@end
