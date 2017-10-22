//
//  ProjectProgressVC.m
//  FiveWaterWork
//
//  Created by 李 燕琴 on 2017/10/4.
//  Copyright © 2017年 aty. All rights reserved.
//

#import "ProjectProgressVC.h"
#import "ListCell.h"
#import "ProjectProgressDetailVC.h"
#import "LYQBlock.h"
#import <MJRefresh/MJRefresh.h>

static NSString *const KCellIdentifier = @"KCellIdentifier";

@interface ProjectProgressVC ()

@property (nonatomic, strong) NSString *planId;

@property (nonatomic, strong) NSMutableArray *datas;

@end

@implementation ProjectProgressVC

- (instancetype)initWithPlanId:(NSString *)planId {
    if (self = [super init]) {
        _planId = planId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"项目进度";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.tableView registerClass:[ListCell class] forCellReuseIdentifier:KCellIdentifier];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    __weak typeof(self) weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf fetchDataIsRefresh:YES completion:^(id response) {
            [weakSelf.tableView.mj_header endRefreshing];
            [weakSelf.tableView.mj_footer resetNoMoreData];
        }];
    }];
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf fetchDataIsRefresh:NO completion:^(id response) {
            NSDictionary*dataDic = response[@"data"];
            NSArray *rows = dataDic[@"rows"];
            if (rows.count > 0) {
                [weakSelf.tableView.mj_footer endRefreshing];
            }else {
                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        }];
    }];
    
    [self.tableView.mj_header beginRefreshing];
}

- (void)fetchDataIsRefresh:(BOOL)isRefresh completion:(CompletionBlock)completion {
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    param[@"isMobile"] = @"1";
    param[@"planId"] = _planId;
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
    [[HttpClient httpClient] requestWithPath:@"/queryAllProjectProgressByPlanId.action" method:TBHttpRequestPost parameters:param prepareExecute:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (isRefresh) {
            [weakSelf.datas removeAllObjects];
        }
        NSDictionary*dataDic = responseObject[@"data"];
        NSArray *rows = dataDic[@"rows"];
        [weakSelf.datas addObjectsFromArray:rows];
        [weakSelf.tableView reloadData];
        if (completion) {
            completion(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView.mj_footer endRefreshing];
        if (error.userInfo[@"name"]) {
            [SVProgressHUD showErrorWithStatus:error.userInfo[@"name"]];
        }
    }];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _datas.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_datas.count > indexPath.row) {
        NSDictionary *item = _datas[indexPath.row];
        ListCell *cell = [tableView dequeueReusableCellWithIdentifier:KCellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = item[@"projectname"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%%",item[@"progress"]];
        return cell;
    }
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_datas.count > indexPath.row) {
        NSDictionary *item = _datas[indexPath.row];
        ProjectProgressDetailVC *detailVC = [[ProjectProgressDetailVC alloc] initWithProgressId:item[@"id"]];
        [self.navigationController pushViewController:detailVC animated:YES];
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
