//
//  NoticeRootVC.m
//  FiveWaterWork
//
//  Created by aiteyuan on 16/1/22.
//  Copyright © 2016年 aty. All rights reserved.
//

#import "NoticeRootVC.h"
#import "NoticeDetailVC.h"
#import "MJRefresh.h"
#import "MMAlertView.h"

static NSString *const APPID = @"1116706405";

@interface NoticeRootVC ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_noticeTable;
    int page;
    int rows;
    NSMutableArray *noticMutArr;
}
@end

@implementation NoticeRootVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initdata];
    [self initview];
    [self getList];
    //版本检查
//    [self versionCheck];
    
}

- (void)versionCheck {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
    
    // 获取appStore版本号  最后一串数字就是当前app在AppStore上面的唯一id
    NSString *url = [[NSString alloc] initWithFormat:@"http://itunes.apple.com/lookup?id=%@",APPID];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *array = responseObject[@"results"];
        NSDictionary *dict = [array lastObject];
        NSLog(@"当前版本为：%@",dict[@"version"] );
        if (![dict[@"version"] isEqualToString:currentVersion]) {
            MMAlertView *alertView = [[MMAlertView alloc] initWithConfirmTitle:@"提示" detail:@"当前有新版本可更新"];
            alertView.attachedView = self.view;
            [alertView show];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    }];
}

- (void)initdata{
    page = 1;
    rows = 20;
}

- (void)initview
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"公告";
    
    _noticeTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 5, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
    _noticeTable.delegate = self;
    _noticeTable.dataSource = self;
    _noticeTable.tableFooterView = [[UIView alloc]init];;
    [self.view addSubview:_noticeTable];
    _noticeTable.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block
        [self getMoreList];
    }];
}

//获取公告数据
- (void)getList
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:[NSNumber numberWithInt:page] forKey:@"page"];//传string类型
    [param setObject:[NSNumber numberWithInt:rows]forKey:@"rows"];//传string类型
    [SVProgressHUD show];
    [[HttpClient httpClient] requestWithPath:@"/queryAllNotice.action" method:TBHttpRequestPost parameters:param prepareExecute:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [SVProgressHUD dismiss];
        noticMutArr = [[NSMutableArray alloc] initWithArray:responseObject[@"rows"]];
        if (noticMutArr.count>0) {
            [_noticeTable reloadData];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.userInfo[@"name"]];;
    }];

}

//获取更多数据
- (void)getMoreList
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    page++;
    [param setObject:[NSNumber numberWithInt:page] forKey:@"page"];//传string类型
    [param setObject:[NSNumber numberWithInt:rows]forKey:@"rows"];//传string类型
    [[HttpClient httpClient] requestWithPath:@"/queryAllNotice.action" method:TBHttpRequestPost parameters:param prepareExecute:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *listDic = [responseObject objectForKey:@"data"];
        NSArray *moreArr = [listDic objectForKey:@"rows"];
        if (moreArr.count>0) {
            [noticMutArr addObjectsFromArray:moreArr];
            [_noticeTable reloadData];
            [_noticeTable.mj_footer endRefreshing];
        } else{
            [_noticeTable.mj_footer endRefreshingWithNoMoreData];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [_noticeTable.mj_footer endRefreshing];
        [SVProgressHUD showErrorWithStatus:error.userInfo[@"name"]];;
    }];
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return noticMutArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"NoticeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    cell.textLabel.text = [noticMutArr[indexPath.row] objectForKey:@"title"];
    cell.detailTextLabel.text = [noticMutArr[indexPath.row] objectForKey:@"createDate"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    NoticeDetailVC *noticeD = [[NoticeDetailVC alloc] init];
    noticeD.detailContentDic = noticMutArr[indexPath.row];
    [self.navigationController pushViewController:noticeD animated:YES];
}

@end
