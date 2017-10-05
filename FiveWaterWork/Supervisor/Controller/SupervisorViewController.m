//
//  SupervisorViewController.m
//  FiveWaterWork
//
//  Created by 李 燕琴 on 2017/10/4.
//  Copyright © 2017年 aty. All rights reserved.
//

#import "SupervisorViewController.h"
#import "ListCell.h"
#import "SupervisorDetailVC.h"
#import "MJRefresh.h"
#import "LYQBlock.h"

static NSString *const CellIdentifier = @"CellIdentifier";

@interface SupervisorViewController ()

@property (nonatomic, strong) NSMutableArray *datas;

@end

@implementation SupervisorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"督导";
    self.view.backgroundColor = [UIColor whiteColor];
    
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
    if (isrefresh) {
        [_datas removeAllObjects];
    }
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    param[@"isMobile"] = @"1";
    param[@"userId"] = [[UserInfo sharedInstance] ReadData].userID;
    if (_datas.count %20 == 0) {
        param[@"page"] = [NSString stringWithFormat:@"%lu",_datas.count/20+1];
    }else {
        param[@"page"] = [NSString stringWithFormat:@"%lu",_datas.count/20+2];
    }
    
    param[@"rows"] = @"20";
    
    __weak typeof(self) weakSelf = self;
    [[HttpClient httpClient] requestWithPath:@"/querySteeringFeedbackByUserId.action" method:TBHttpRequestPost parameters:param prepareExecute:nil success:^(NSURLSessionDataTask *task, id responseObject) {
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
        cell.textLabel.text = item[@"rectificationmsg"];
        
        NSNumber *status = item[@"status"];
        if ([status.stringValue isEqualToString:@"0"]) {
            cell.detailTextLabel.text = @"未下发";
        }else if ([status.stringValue isEqualToString:@"1"]) {
            cell.detailTextLabel.text = @"已下发";
        }else if ([status.stringValue isEqualToString:@"2"]) {
            cell.detailTextLabel.text = @"处理中";
        }else if ([status.stringValue isEqualToString:@"3"]) {
            cell.detailTextLabel.text = @"已整改";
        }else {
            cell.detailTextLabel.text = @"已关闭";
        }
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_datas.count > indexPath.row) {
        NSDictionary *item = _datas[indexPath.row];
        SupervisorDetailVC *supervisorDetailVC = [[SupervisorDetailVC alloc] initWithDetailData:item];
        [self.navigationController pushViewController:supervisorDetailVC animated:YES];
    }
}

- (NSMutableArray *)datas {
    if (!_datas) {
        _datas = [[NSMutableArray alloc] init];
    }
    return _datas;
}

@end
