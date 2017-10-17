//
//  WorkOrderRootVC.m
//  FiveWaterWork
//
//  Created by aiteyuan on 16/1/22.
//  Copyright © 2016年 aty. All rights reserved.
//

#import "WorkOrderRootVC.h"

#import "DetailWorkOrderVC.h"
#import "MJRefresh.h"

#define ROWS 20
@interface WorkOrderRootVC ()<UITableViewDataSource,UITableViewDelegate,DetailWorkOrderDelegate>
{
    UITableView *_orderTable;
    
    TUserLocation *_userLoc;
    
    int qiantuiflag;
    int qiandaoflag;
    NSMutableArray *_allOrdersArr;
    
    NSNumber *_total;
    int page;
}

@end

@implementation WorkOrderRootVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initdata];
    [self initview];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detailDelegate) name:@"AddFeedbackCompletion" object:nil];
}

- (void)initdata
{
    page = 0;
    _userLoc = [[TUserLocation alloc]init];
}

- (void)initview
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"工单";

    _orderTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 5, SCREEN_WIDTH, SCREEN_HEIGHT -44-40) style:UITableViewStylePlain];
    _orderTable.delegate = self;
    _orderTable.dataSource = self;
    _orderTable.tableFooterView = [[UIView alloc] init];
    _orderTable.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self refreshListData:1];
    }];
    
    _orderTable.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self refreshListData:2];
    }];
    [self.view addSubview:_orderTable];
    [_orderTable.mj_header beginRefreshing];
    
}

-(void)refreshListData:(int)flag{
    //1 上拉加载  2 下拉刷新
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    if (flag==1) {
        page++;
        [param setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    }
    else{
        [_orderTable.mj_footer resetNoMoreData];
        [_allOrdersArr removeAllObjects];
        page = 1;
        [param setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    }
    
    [param setObject:[NSNumber numberWithInt:ROWS] forKey:@"rows"];
    [param setObject:[[UserInfo sharedInstance] ReadData].userID forKey:@"job.createUserId"];
    [param setObject:[NSString stringWithFormat:@"1"] forKey:@"isMobile"];
    
    [[HttpClient httpClient] requestWithPath:@"/queryJobList.action" method:TBHttpRequestPost parameters:param prepareExecute:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"%@",responseObject);
        NSNumber *result = [responseObject objectForKey:@"success"];
        if (result.boolValue) {
            NSDictionary *data = [responseObject objectForKey:@"data"];
            _total = [data objectForKey:@"total"];
            NSArray *moreArr =  [data objectForKey:@"rows"];
            if (flag==1) {
                //上拉加载
                if (moreArr.count>0) {
                    [_allOrdersArr addObjectsFromArray:moreArr];
                    [_orderTable reloadData];
                    [_orderTable.mj_footer endRefreshing];
                }
                else{
                    [_orderTable.mj_footer endRefreshingWithNoMoreData];
                }
            }
            else{
                [_orderTable.mj_header endRefreshing];
                //下拉刷新
                if (moreArr.count>0) {
                    _allOrdersArr = [NSMutableArray arrayWithArray:moreArr];
                }
                [_orderTable reloadData];
                
            }
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"message"]];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.userInfo[@"name"]];;
         if (flag==1) {
             [_orderTable.mj_footer endRefreshing];
         }
         else{
             [_orderTable.mj_header endRefreshing];
         }
    }];

}
-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _allOrdersArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_allOrdersArr.count > indexPath.row) {
        static NSString *ID = @"NoticeCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (cell==nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        }
        NSDictionary *oneorder = _allOrdersArr[indexPath.row];
        cell.textLabel.text = [oneorder objectForKey:@"title"];
        
        NSNumber *timeNum = [oneorder objectForKey:@"createTime"];
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeNum.integerValue/1000];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *dateString = [dateFormat stringFromDate:date];
        
        cell.detailTextLabel.text = dateString;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 44)];
        label.textColor = [UIColor lightGrayColor];
        label.font = [UIFont systemFontOfSize:12];
        NSNumber *state = [oneorder objectForKey:@"state"];
        if (!ISNULL(state)) {
            switch (state.integerValue) {
                case 1:
                    label.text = @"待处理";
                    break;
                case 2:
                    label.text = @"处理中";
                    break;
                case 3:
                    label.text = @"已完成";
                    break;
                    
                case 4:
                    label.text = @"已转发";
                    break;
                    
                default:
                    break;
            }
            
        }
        
        NSNumber *isSelf = [oneorder objectForKey:@"isSelf"];
        if (isSelf.integerValue == 0) {
            label.textColor = [UIColor redColor];
        }
        cell.accessoryView = label;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    DetailWorkOrderVC *detailWorkvc = [[DetailWorkOrderVC alloc] init];
    detailWorkvc.delegate = self;
    detailWorkvc.detailDic  = _allOrdersArr[indexPath.row];
    [self.navigationController pushViewController:detailWorkvc animated:YES];
}

#pragma mark - delegate

-(void)detailDelegate{
    [_orderTable.mj_header beginRefreshing];
}

@end
