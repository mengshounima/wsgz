//
//  SignInRecordTableVC.m
//  FiveWaterWork
//
//  Created by 李 燕琴 on 16/10/30.
//  Copyright © 2016年 aty. All rights reserved.
//

#import "signInRecordCell.h"
#import "SignInRecordTableVC.h"
#import "PathViewController.h"
#import "Masonry.h"
#import "MJRefresh.h"

#define WeakSelf typeof(self) weakSelf = self;
#define StrongSelf typeof(weakSelf) strongSelf = weakSelf;

static NSString * const KCellIdentifier = @"KCellIdentifier";

static const NSInteger rows = 20;

@interface SignInRecordTableVC ()

@property (nonatomic, strong) NSMutableArray *signRecordsArray;

@end

@implementation SignInRecordTableVC

#pragma mark - View LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

- (void)setupView {
    self.title = @"签到记录";
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.estimatedSectionHeaderHeight = 30;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerClass:[signInRecordCell class] forCellReuseIdentifier:KCellIdentifier];
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self fetchRecords:YES];
    }];
    self.tableView.mj_header = header;
    
    MJRefreshAutoStateFooter *footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
        [self fetchRecords:NO];
    }];
    self.tableView.mj_footer = footer;
    [self.tableView.mj_header beginRefreshing];
}

- (void)fetchRecords:(BOOL)isRefresh {
    NSMutableDictionary *param = [NSMutableDictionary new];
    
    if (isRefresh) {
        param[@"page"] = @"1";
    }else {
        if (self.signRecordsArray.count %20 == 0) {
            param[@"page"] = [NSString stringWithFormat:@"%lu",_signRecordsArray.count/20+1];
        }else {
            param[@"page"] = [NSString stringWithFormat:@"%lu",_signRecordsArray.count/20+2];
        }
    }
    
    param[@"rows"] =  [NSString stringWithFormat:@"%li",(long)rows];
    param[@"isMobile"] = @"1";
    param[@"checkIns.userId"] = [[UserInfo sharedInstance] ReadData].userID;
    
    WeakSelf
    [[HttpClient httpClient] requestWithPath:@"/querySignInRecord.action" method:TBHttpRequestPost parameters:param prepareExecute:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        StrongSelf
        if (isRefresh) {
            [strongSelf.signRecordsArray removeAllObjects];
        }
        NSArray *datas = responseObject[@"rows"];
        [strongSelf.signRecordsArray addObjectsFromArray:datas];
        
        if (isRefresh) {
            [strongSelf.tableView.mj_header endRefreshing];
            [strongSelf.tableView.mj_footer resetNoMoreData];
        }
        
        if (datas.count==rows) {
            [strongSelf.tableView.mj_footer endRefreshing];
        }else {
            [strongSelf.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        [strongSelf.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.userInfo[@"name"]];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _signRecordsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    signInRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:KCellIdentifier forIndexPath:indexPath];
    if (_signRecordsArray.count>indexPath.row) {
        cell.timeLabel.text = NotNilObject(_signRecordsArray[indexPath.row][@"sign_time"]);
        cell.addressLabel.text = NotNilObject(_signRecordsArray[indexPath.row][@"addr"]);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
   return cell;
}

#pragma mark - Tableview delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = _signRecordsArray[indexPath.row];
    PathViewController *pathVC = [[PathViewController alloc] initWithCheckInID:dic[@"id"]];
    [self.navigationController pushViewController:pathVC animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView  = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor whiteColor];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.text = @"签到时间";
    timeLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:timeLabel];
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(headerView);
        make.height.equalTo(@30);
        make.width.equalTo(@(SCREEN_WIDTH/2));
    }];
    
    UILabel *addressLabel = [[UILabel alloc] init];
    addressLabel.text = @"签到地点";
    addressLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:addressLabel];
    [addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(headerView);
        make.size.equalTo(timeLabel);
    }];
    
    return headerView;
}

#pragma mark - Setters And Getters

- (NSMutableArray *)signRecordsArray {
    if (!_signRecordsArray) {
        _signRecordsArray = [[NSMutableArray alloc] init];
    }
    return _signRecordsArray;
}

@end
