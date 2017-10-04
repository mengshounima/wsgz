//
//  TopicRootVC.m
//  FiveWaterWork
//
//  Created by aiteyuan on 16/1/22.
//  Copyright © 2016年 aty. All rights reserved.
//

#import "TopicRootVC.h"
#import "MJRefresh.h"
#import "publishTopicVC.h"
#import "topicDetailVC.h"
#define ROWS 20
@interface TopicRootVC ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,publishTopicVCDelegate>
{
    UITableView *_topicTable;
    NSMutableArray *allTopicMutArr;
    NSMutableArray *showMutArr;
    int page;
    
}
@property (nonatomic,strong) UISearchBar *searchBar;
@property (nonatomic,strong) UIButton *searchBtn;
@property (nonatomic,strong) UITapGestureRecognizer *tap;

@end

@implementation TopicRootVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initdata];
    [self initview];
}
-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addTap) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeTap) name:UIKeyboardDidHideNotification object:nil];

}
-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}
- (void)initdata
{
    page = 0;
}
- (void)initview
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"话题";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStylePlain target:self action:@selector(publishTopic)];
    //搜索框
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(5, 74, SCREEN_WIDTH-10-5-60, 35)];
    _searchBar.placeholder = @"请输入名字";
    _searchBar.delegate = self;
    [self.view addSubview:_searchBar];
    
    float X = CGRectGetMaxX(_searchBar.frame) + 5;
    _searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(X, 74, 60, 35)];
    [_searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    [_searchBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_searchBtn setBackgroundColor:[UIColor lightGrayColor]];
    _searchBtn.layer.cornerRadius = 6;
    _searchBtn.enabled = NO;
    [_searchBtn addTarget:self action:@selector(clickSearchBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_searchBtn];
    
    float Y =  CGRectGetMaxY(_searchBar.frame) + 5;
    _topicTable = [[UITableView alloc] initWithFrame:CGRectMake(0, Y, SCREEN_WIDTH, SCREEN_HEIGHT-Y) style:UITableViewStylePlain];
    _topicTable.delegate = self;
    _topicTable.dataSource = self;
    _topicTable.tableFooterView = [[UIView alloc] init];
    _topicTable.tableFooterView = [[UIView alloc] init];
    _topicTable.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self refreshListData:1];
    }];
    _topicTable.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self refreshListData:2];
    }];
    
    [_topicTable .mj_header beginRefreshing];
    [self.view addSubview:_topicTable];
    
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickUIView)];
    
}
-(void)publishTopic{
    publishTopicVC *publichVC = [[publishTopicVC alloc] init];
    publichVC.delegate = self;
    [self.navigationController pushViewController:publichVC animated:YES];
}
//发布成功代理
-(void)publishSuccessed{
    [_topicTable.mj_header beginRefreshing];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (!ISNULLSTR(searchText)) {
        _searchBtn.enabled = YES;
    }else{
        [self refreshListData:2];
        _searchBtn.enabled = NO;
    }
}

//搜索
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [_searchBar resignFirstResponder];
    NSString *searchStr = _searchBar.text;
    [self searchDataWithStr:[searchStr lowercaseString]];
}

//隐藏键盘
-(void)clickUIView{
    [_searchBar resignFirstResponder];
}


//点击搜索按钮
-(void)clickSearchBtn:(UIButton *)button{
    [_searchBar resignFirstResponder];
    NSString *searchStr = _searchBar.text;
    [self searchDataWithStr:[searchStr lowercaseString]];
}

// 查找方法,搜索名字
- (void)searchDataWithStr:(NSString *)searchKey
{
    [showMutArr removeAllObjects];
    for (NSDictionary *topicDic in allTopicMutArr)
    {
        NSString *namePinyinStr = [topicDic objectForKey:@"name"];
        if (!ISNULLSTR(namePinyinStr))
        {
            if ([namePinyinStr rangeOfString:searchKey].location != NSNotFound)
            {
                [showMutArr addObject:topicDic];
                continue;
            }
        }
    }
    [_topicTable reloadData];
}

-(void)refreshListData:(int)flag{
    //1 上拉加载  2 下拉刷新
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    if (flag==1) {
        page++;
        [param setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    }
    else{
        [_topicTable.mj_footer resetNoMoreData];
        page = 1;
        [param setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    }
    
    [param setObject:[NSNumber numberWithInt:ROWS] forKey:@"rows"];
    [param setObject:[[UserInfo sharedInstance] ReadData].userID forKey:@"sysUserId"];
    [param setObject:[NSString stringWithFormat:@"1"] forKey:@"isMobile"];
    
    [[HttpClient httpClient] requestWithPath:@"/queryTopicList.action" method:TBHttpRequestPost parameters:param prepareExecute:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSNumber *result = [responseObject objectForKey:@"success"];
        if (result.boolValue) {
            NSDictionary *data = [responseObject objectForKey:@"data"];
            NSArray *moreArr =  [data objectForKey:@"rows"];
            if (flag==1) {
                //上拉加载
                if (moreArr.count>0) {
                    [allTopicMutArr addObjectsFromArray:moreArr];
                    showMutArr = [allTopicMutArr mutableCopy];
                    [_topicTable reloadData];
                    [_topicTable.mj_footer endRefreshing];
                }
                else{
                    [_topicTable.mj_footer endRefreshingWithNoMoreData];
                }
                
                
            }
            else{
                //下拉刷新
                [allTopicMutArr removeAllObjects];
                if (moreArr.count>0) {
                    allTopicMutArr = [NSMutableArray arrayWithArray:moreArr];;
                }
                showMutArr = [allTopicMutArr mutableCopy];
                [_topicTable reloadData];
                [_topicTable.mj_header endRefreshing];
                
            }
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"message"]];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.userInfo[@"name"]];
        if (flag==1) {
            [_topicTable.mj_footer endRefreshing];
        }
        else{
            [_topicTable.mj_header endRefreshing];
        }
    }];
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return showMutArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"NoticeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    NSString *titleStr = [showMutArr[indexPath.row] objectForKey:@"title"];
    if (!ISNULLSTR(titleStr)) {
        cell.textLabel.text = titleStr;
    }
    NSString *nameStr = [showMutArr[indexPath.row] objectForKey:@"name"];
    if (!ISNULLSTR(nameStr)) {
        cell.detailTextLabel.text = nameStr;
    }
    
    UILabel *AccessoryV = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 44)];
    AccessoryV.textColor = [UIColor lightGrayColor];
    AccessoryV.font = [UIFont systemFontOfSize:11];
 
    
    NSString *time=[showMutArr[indexPath.row] objectForKey:@"create_time"];
    long floatString = [time longLongValue]/1000.0;
    NSDate *nd = [NSDate dateWithTimeIntervalSince1970:floatString];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormat stringFromDate:nd];
    //NSLog(@"date: %@", dateString);

    
    //时间戳转日期
    //NSDateFormatter *dateformater = [[NSDateFormatter alloc] init];
    //dateformater.dateFormat = [NSString stringWithFormat:@"yyyy-MM-dd"];
    //NSNumber *IntervalNum = [showMutArr[indexPath.row] objectForKey:@"create_time"];
    //NSDate *date = [NSDate dateWithTimeIntervalSinceNow:(IntervalNum.integerValue)/1000];
    //AccessoryV.text = [dateformater stringFromDate:date];

    AccessoryV.text = dateString;
    cell.accessoryView = AccessoryV;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    topicDetailVC *topicdetailvc = [[topicDetailVC alloc] init];
    topicdetailvc.detailDic = showMutArr[indexPath.row];
    [self.navigationController pushViewController:topicdetailvc animated:YES];
    
    
}

-(void)addTap{
    [self.view addGestureRecognizer:_tap];
}
-(void)removeTap{
    [self.view removeGestureRecognizer:_tap];
    
}

@end
