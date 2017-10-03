//
//  AddressBookRootVC.m
//  FiveWaterWork
//
//  Created by aiteyuan on 16/1/22.
//  Copyright © 2016年 aty. All rights reserved.
//

#import "AddressBookRootVC.h"
#import "MJRefresh.h"

@interface AddressBookRootVC ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
{
    UITableView *_addressTable;
    NSMutableArray *allAddressMutArr;
    NSMutableArray *showMutArr;
}
@property (nonatomic,strong) UISearchBar *searchBar;
@property (nonatomic,strong) UIButton *searchBtn;

@property (nonatomic,strong) UITapGestureRecognizer *tap;
@end

@implementation AddressBookRootVC

- (void)viewDidLoad {
    [super viewDidLoad];
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

//隐藏键盘
-(void)clickUIView{
    [_searchBar resignFirstResponder];
}
-(void)addTap{
    [self.view addGestureRecognizer:_tap];
}
-(void)removeTap{
    [self.view removeGestureRecognizer:_tap];
    
}

- (void)initview
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"通讯录";
    
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
    _addressTable = [[UITableView alloc] initWithFrame:CGRectMake(0, Y, SCREEN_WIDTH, SCREEN_HEIGHT-Y-49) style:UITableViewStylePlain];
    _addressTable.delegate = self;
    _addressTable.dataSource = self;
    _addressTable.tableFooterView = [[UIView alloc] init];
    _addressTable.tableFooterView = [[UIView alloc] init];

    _addressTable.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self refreshListData:2];
    }];
    [_addressTable.mj_header beginRefreshing];
    
    [self.view addSubview:_addressTable];
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickUIView)];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [_searchBar resignFirstResponder];
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
    for (NSDictionary *topicDic in allAddressMutArr)
    {
        NSString *namePinyinStr = [topicDic objectForKey:@"name"];
        NSString *postPinyinStr = [topicDic objectForKey:@"post"];
        if (!ISNULLSTR(namePinyinStr))
        {
            if ([namePinyinStr rangeOfString:searchKey].location != NSNotFound)
            {
                [showMutArr addObject:topicDic];
                continue;
            }
            else if ([postPinyinStr rangeOfString:searchKey].location != NSNotFound)
            {
                [showMutArr addObject:topicDic];
                continue;
            }
        }
    }
    [_addressTable reloadData];
}

-(void)refreshListData:(int)flag{
    //1 上拉加载  2 下拉刷新
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];

    [allAddressMutArr removeAllObjects];
    [param setObject:[NSNumber numberWithInt:0] forKey:@"page"];
    
    [param setObject:[NSNumber numberWithInt:0] forKey:@"rows"];
    if ([[[UserInfo sharedInstance] ReadData].userID isEqual:@"1"]) {
         [param setObject:[[UserInfo sharedInstance] ReadData].userID forKey:@"userId"];
    }
    
    [param setObject:[[UserInfo sharedInstance] ReadData].userID forKey:@"sysUserId"];
    [param setObject:[NSString stringWithFormat:@"1"] forKey:@"isMobile"];
    
    [[HttpClient httpClient] requestWithPath:@"/getContacts.action" method:TBHttpRequestPost parameters:param prepareExecute:nil success:^(NSURLSessionDataTask *task, id responseObject) {

        NSNumber *result = [responseObject objectForKey:@"success"];
        if (result.boolValue) {
            NSDictionary *dic  = [responseObject objectForKey:@"data"];
            NSMutableArray *moreArr = [[NSMutableArray alloc] initWithArray:[dic objectForKey:@"rows"]];
                //下拉刷新
                if (moreArr.count>0) {
                    allAddressMutArr  = [NSMutableArray arrayWithArray:moreArr];
                }
                showMutArr = [allAddressMutArr mutableCopy];
                [_addressTable reloadData];
                [_addressTable.mj_header endRefreshing];
            
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"message"]];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.userInfo[@"name"]];
        [_addressTable.mj_header endRefreshing];
    }];
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return showMutArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"addressCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    cell.textLabel.text  = [NSString stringWithFormat:@"%@            %@",[showMutArr[indexPath.row] objectForKey:@"name"],[showMutArr[indexPath.row] objectForKey:@"phone"]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"职位:%@",[showMutArr[indexPath.row] objectForKey:@"post"]];
    UIImageView *callImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"拨号"]];
    callImage.tag = indexPath.row;
    UIGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(call:)];
    [callImage addGestureRecognizer:tap];
    callImage.userInteractionEnabled = YES;
    cell.accessoryView = callImage;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - User Interaction

- (void)call:(UIGestureRecognizer *)gestureRecognizer {
    UIImageView *imageView = (UIImageView *)gestureRecognizer.view;
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", [showMutArr[imageView.tag] objectForKey:@"phone"]]]];
}

@end
