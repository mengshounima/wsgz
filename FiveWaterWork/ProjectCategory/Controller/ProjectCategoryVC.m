//
//  ProjectCategoryVC.m
//  FiveWaterWork
//
//  Created by 李 燕琴 on 2017/10/3.
//  Copyright © 2017年 aty. All rights reserved.
//

#import "ProjectCategoryVC.h"
#import "ListCell.h"
#import "ProjectDetailVC.h"
#import "MJRefresh.h"
#import "LYQBlock.h"

static NSString *const CellIdentifier = @"CellIdentifier";

@interface ProjectCategoryVC ()

@property (nonatomic, strong) NSMutableArray *datas;

@end

@implementation ProjectCategoryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"六大类";
    
    [self setupView];
}

- (void)setupView {
    [self.tableView registerClass:[ListCell class] forCellReuseIdentifier:CellIdentifier];
    self.tableView.tableFooterView = [[UIView alloc] init];
    __weak typeof(self) weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf setupDataIsRefresh:YES completion:^(id response) {
            [weakSelf.tableView.mj_header endRefreshing];
            [weakSelf.tableView.mj_footer resetNoMoreData];
        }];
    }];
    
    self.tableView.mj_footer = [MJRefreshAutoGifFooter footerWithRefreshingBlock:^{
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
    
    [self.tableView.mj_header beginRefreshing];
}

- (void)setupDataIsRefresh:(BOOL)isrefresh completion:(CompletionBlock)completion {
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    param[@"isMobile"] = @"1";
    if (isrefresh) {
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
    [[HttpClient httpClient] requestWithPath:@"/queryAllPolicyManage.action" method:TBHttpRequestPost parameters:param prepareExecute:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (isrefresh) {
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
        ListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = item[@"name"];
        cell.detailTextLabel.text = item[@"mainclassname"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }

    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.datas.count > indexPath.row) {
        NSDictionary *item = self.datas[indexPath.row];
        ProjectDetailVC *detailVC = [[ProjectDetailVC alloc] initWithPolicyManageId:item[@"id"]];
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
