//
//  MapRootVC.m
//  FiveWaterWork
//
//  Created by aiteyuan on 16/1/22.
//  Copyright © 2016年 aty. All rights reserved.
//

#import "MapRootVC.h"
#import "CreatWorkOrderVC.h"
#import "settingTableVC.h"
#import "SignInRecordTableVC.h"
#import "WebViewController.h"
#import "TPolyline.h"
#import "TPolylineView.h"
#import "MyAnnotation.h"
#import "Masonry.h"
#import "TAddressComponent.h"

#define MYBUNDLE_NAME @ "TMapKitBundle.bundle"
#define MYBUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: MYBUNDLE_NAME]
#define XINJIANT @"btn_plus"

static NSString *CellIdentifier = @"centerPoi";

#define WEAKSELF typeof(self) weakSelf = self;
#define STRONGSELF typeof(weakSelf) strongSelf = self;

@interface MapRootVC ()<UISearchBarDelegate,CLLocationManagerDelegate,TMapViewDelegate,TAddressComponentdelegate>

@property (nonatomic,strong)  QianDaoBtn *qiandaoV;

@property (nonatomic,strong) QianDaoBtn *qiantuiV;

@property (nonatomic,strong) QianDaoBtn *xinjianV;

@property (nonatomic,strong) TMapView *tMapView;

@property (nonatomic,strong) NSNumber *ordernumber;

@property (nonatomic,strong) NSArray *allRiversArr;

@property (nonatomic,strong) UISearchBar *searchBar;

@property (nonatomic,strong) UIButton *searchBtn;

@property (nonatomic,assign) int index;

@property (nonatomic,assign) BOOL qiaodao_state;

@property (nonatomic,strong) UITapGestureRecognizer *tap;

@property (nonatomic,strong) TAddressComponent *addresssComponent;

@property (nonatomic, strong) NSString *addressResult;

@property (nonatomic, assign) CLLocationCoordinate2D lastPoint;

@end

@implementation MapRootVC
#define MYBUNDLE [NSBundle bundleWithPath: MYBUNDLE_PATH]

#pragma mark - View Lifecycle

-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addTap) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeTap) name:UIKeyboardDidHideNotification object:nil];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initview];
    [self queryAllRivers];
}

- (void)initData {
    _qiaodao_state = NO;
    //测试签到用
//    _ordernumber = @(11068);
//    [[UserInfo sharedInstance] writeOrderNumber:_ordernumber];
}

-(void)initview
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"巡河";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"签到记录" style:UIBarButtonItemStylePlain target:self action:@selector(jumpToSignInRecord)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"设置"] style:UIBarButtonItemStylePlain target:self action:@selector(settingAction)];

    _tMapView = [[TMapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [_tMapView setVisibleMapRect:_tMapView.bounds  edgePadding:UIEdgeInsetsZero animated:NO];
    // 显示用户位置
    _tMapView.ShowPosition = YES;
    // 当前跟踪模式,跟踪状态
    _tMapView.UserTrackMode = TUserTrackingModeNone;
    _tMapView.delegate = self;
    [_tMapView setMapScale:11];
    [self.view addSubview:_tMapView];
    [_tMapView StartGetPosition];
    
    _qiandaoV = [[QianDaoBtn alloc] initWithFrame:CGRectMake(10, SCREEN_HEIGHT - 44 -50, SCREEN_WIDTH/2 -15, 40)];
    [_qiandaoV setBackgroundColor:choiceColor(153, 204, 51)];
    [_qiandaoV setTitle:@"签到" forState:UIControlStateNormal];
    [_qiandaoV setImage:[UIImage imageNamed:@"签到"] forState:UIControlStateNormal];
    _qiandaoV.layer.cornerRadius = 5;
    [_tMapView addSubview:_qiandaoV];
    [_qiandaoV addTarget:self action:@selector(signInAction) forControlEvents:UIControlEventTouchUpInside];
    
    _qiantuiV = [[QianDaoBtn alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 + 5, SCREEN_HEIGHT -44 -50, SCREEN_WIDTH/2 - 15, 40)];
    [_qiantuiV setBackgroundColor:choiceColor(153, 204, 51)];
    [_qiantuiV setTitle:@"签退" forState:UIControlStateNormal];
    [_qiantuiV setImage:[UIImage imageNamed:@"签退"] forState:UIControlStateNormal];
    _qiantuiV.layer.cornerRadius = 5;
    [self.view addSubview:_qiantuiV];
    [_qiantuiV addTarget:self action:@selector(signOutAction) forControlEvents:UIControlEventTouchUpInside];
    _qiantuiV.enabled = NO;
    
    _xinjianV = [[QianDaoBtn alloc] initWithFrame:CGRectMake(10, SCREEN_HEIGHT - 44 -50, SCREEN_WIDTH/2 -15, 40)];
    [_xinjianV setBackgroundColor:choiceColor(153, 204, 51)];
    [_xinjianV setTitle:@"新建" forState:UIControlStateNormal];
    [_xinjianV setImage:[UIImage imageNamed:XINJIANT] forState:UIControlStateNormal];
    _xinjianV.layer.cornerRadius = 5;
    [self.view addSubview:_xinjianV];
    _xinjianV.hidden = YES;
    [_xinjianV addTarget:self action:@selector(newWorkOrder) forControlEvents:UIControlEventTouchUpInside];
    
    //搜索框
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(5, 74, SCREEN_WIDTH-10-5-60, 35)];
    _searchBar.placeholder = @"请输入河段名称";
    _searchBar.delegate = self;
    [self.view addSubview:_searchBar];
    
    float X = CGRectGetMaxX(_searchBar.frame) + 5;
    _searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(X, 74, 60, 35)];
    [_searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    [_searchBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_searchBtn setBackgroundColor:[UIColor lightGrayColor]];
    _searchBtn.layer.cornerRadius = 6;
    
    //屏蔽搜索功能
    [_searchBtn addTarget:self action:@selector(clickSearchBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_searchBtn];

    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickUIView)];
}

// 查找方法,搜索名字
- (void)searchDataWithStr:(NSString *)searchKey
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:[NSString stringWithFormat:@"1"] forKey:@"isMobile"];
    [param setObject:[[UserInfo sharedInstance] ReadData].userID forKey:@"sysUserId"];
    [param setObject:searchKey forKey:@"key"];
    [SVProgressHUD show];
    [[HttpClient httpClient] requestWithPath:@"/queryRiverByKey.action" method:TBHttpRequestPost parameters:param prepareExecute:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSNumber *successNum = [responseObject objectForKey:@"success"];
        if (successNum.boolValue) {
            [SVProgressHUD dismiss];
            _allRiversArr =  [responseObject objectForKey:@"data"];
            if (_allRiversArr.count>0) {
                _index = 0;
                [self AddOver];
            }
            else
            {
                [_tMapView setNeedsDisplay];
            }
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"message"]];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.userInfo[@"name"]];;
    }];

}

- (void)queryAllRivers{
    _index = 0;
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    
    [param setObject:[NSString stringWithFormat:@"1"] forKey:@"isMobile"];
    [param setObject:[[UserInfo sharedInstance] ReadData].userID forKey:@"sysUserId"];
    [param setObject:[[UserInfo sharedInstance] ReadData].userID forKey:@"userId"];
    [[HttpClient httpClient] requestWithPath:@"/queryRiverByUser.action" method:TBHttpRequestPost parameters:param prepareExecute:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSNumber *successNum = [responseObject objectForKey:@"success"];
        if (successNum.boolValue) {
           _allRiversArr =  [responseObject objectForKey:@"data"];
            if (_allRiversArr.count>0) {
                [self AddOver];
            }
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"message"]];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.userInfo[@"name"]];;
    }];
}

//画出河流
-(void)AddOver{
    CLLocationCoordinate2D nowPoint = CLLocationCoordinate2DMake(0, 0);
    for (NSDictionary *temp in _allRiversArr) {
        
        NSArray *locationArr = [temp objectForKey:@"gps"];
        
         CLLocationCoordinate2D arrPoints[locationArr.count];
        
        for (int i = 0; i<locationArr.count; i++) {
            NSNumber *latitude =  [locationArr[i] objectForKey:@"latitude"];
            arrPoints[i].latitude = latitude.doubleValue;
            
            NSNumber *longitude =  [locationArr[i] objectForKey:@"longitude"];
            arrPoints[i].longitude = longitude.doubleValue;
            if (i==0) {
                nowPoint = arrPoints[i];
            }
        }
    
        TPolyline *line = [TPolyline polylineWithCoordinates:arrPoints count:locationArr.count];
        [_tMapView addOverlay:line];
        
    }
    [_tMapView setCenterCoordinate:nowPoint animated:NO];
    [_tMapView setMapScale:12];
    [_tMapView setNeedsDisplay];
}

#pragma mark - TMapView Delagate

- (void)mapView:(TMapView *)mapView didUpdateUserLocation:(TUserLocation *)userLocation {
    NSLog(@"有位置跟新咯");
    if (_qiaodao_state) {
        if (self.lastPoint.latitude == 0) {
            [self uploadGPS];
        }else {
            NSInteger distance = [self Distance:self.lastPoint currentPoint:userLocation.coordinate];
            if ((distance <=50) && (distance!=0)) {
                [self uploadGPS];
            }
        }
        self.lastPoint = userLocation.coordinate;
    }
}

- (void)mapView:(TMapView *)mapView didSelectAnnotationView:(TAnnotationView *)view {
    NSArray *arrSelect = mapView.selectedAnnotations;
    for (int i = 0; i < arrSelect.count; i++) {
        id <TAnnotation> ann = [arrSelect objectAtIndex:i];
        if (ann != view.annotation) {
            [mapView deselectAnnotation:ann animated:YES];
        }
    }
}


- (TAnnotationView *)mapView:(TMapView *)mapView viewForAnnotation:(id <TAnnotation>)annotation {

    
    NSBundle *bundle = MYBUNDLE;
    if (([annotation.title rangeOfString:@"我的位置"].location == 0) || ([annotation.title isEqualToString:@"正在获取当前位置"]))
    {
        NSString *strFile = [[bundle resourcePath] stringByAppendingPathComponent:@"location_off.png"];
        
        TAnnotationView *annotationView = [[TAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:CellIdentifier];
        
        annotationView.image = [UIImage imageWithContentsOfFile:strFile];
        annotationView.selectImage = [UIImage imageWithContentsOfFile:strFile];
        annotationView.canShowCallout = FALSE;
        annotationView.draggable = NO;
        return annotationView;
    }
    else    {
        NSString *strFile = [[bundle resourcePath] stringByAppendingPathComponent:@"da_marker_green.png"];
        NSString *strFileClick = [[bundle resourcePath] stringByAppendingPathComponent:@"da_marker_red.png"];
    
        TAnnotationView *annotationView = [[TAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:CellIdentifier];
    
        annotationView.image = [UIImage imageWithContentsOfFile:strFile];
        annotationView.selectImage = [UIImage imageWithContentsOfFile:strFileClick];
        annotationView.canShowCallout = TRUE;
        annotationView.draggable = NO;
        
        CGPoint ptoffset = CGPointMake(annotationView.image.size.width / 2, 0-10);
        annotationView.calloutOffset = ptoffset;
        ptoffset = CGPointMake(0, -(annotationView.image.size.height / 2));
        annotationView.centerOffset = ptoffset;

    
        UIView *calloutV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-80, 20*9)];
        calloutV.backgroundColor = choiceColor(238, 238, 238);
        calloutV.layer.borderColor = [UIColor darkGrayColor].CGColor;
        calloutV.layer.borderWidth = 1;
        calloutV.layer.cornerRadius = 6;
        
        NSArray *StrArr = [annotation.title componentsSeparatedByString:@","];
        UIButton *docButton;
        UILabel *lastLabel;
        for (NSString *subTitle in StrArr) {
            if ([subTitle isEqualToString:[StrArr firstObject]]) {
                if (subTitle.length > 0) {
                    docButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH-80, 20)];
                    [docButton setTitle:subTitle forState:UIControlStateNormal];
                    [docButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                    [docButton addTarget:self action:@selector(showFile:) forControlEvents:UIControlEventTouchUpInside];
                    [calloutV addSubview:docButton];
                }
                continue;
            }
            
            float maxY = 0;
            if (docButton) {
                maxY = CGRectGetMaxY(docButton.frame);
                docButton = nil;
            }else if(lastLabel){
                maxY = CGRectGetMaxY(lastLabel.frame);
            }else {
               maxY = 0;
            }
            
             UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, maxY, SCREEN_WIDTH-80, 20)];

            label.text = subTitle;
            [calloutV addSubview:label];
            lastLabel = label;
        }
        
        annotationView.CalloutView = calloutV;
        return annotationView;
        }
}

//覆盖物回调
- (TOverlayView *)mapView:(TMapView *)mapView viewForOverlay:(id <TOverlay>)overlay {
    TPolylineView *lineview = [[TPolylineView alloc] initWithPolyline:overlay mapView:mapView];
    lineview.lineWidth = 4;
    NSDictionary *temp  =  _allRiversArr[_index];
        
    NSDictionary *riverDic = [temp objectForKey:@"river"];
    NSArray *managerArr = [temp objectForKey:@"manager"];
    lineview.strokeColor = [UIColor blueColor];
    NSArray *gpsArr = [temp objectForKey:@"gps"];
    
    //文件下载
    NSString *fileName = [temp objectForKey:@"fileName"];
    
    //显示数据准备
    NSString *rivernameStr = [NSString stringWithFormat:@"名称:%@",[riverDic objectForKey:@"rivername"]];
    NSString *ManagerStr = @"河长:";
    NSString *manegerFirm = @"单位:";
    int i = 0;
    for (NSDictionary *tempDic in managerArr) {
        i++;
        NSString *test1 = [tempDic objectForKey:@"name"];
        if(!ISNULLSTR(test1))
        {
            if(i>1)
            {
                ManagerStr = [ManagerStr stringByAppendingString:@" "];
            }
            ManagerStr = [ManagerStr stringByAppendingString:test1];
        }

        NSString *test2 = [tempDic objectForKey:@"org"];
        if (i==1 && !ISNULLSTR(test2)) {
            manegerFirm = [manegerFirm stringByAppendingString:test2];
        }
    }
    
    NSString *policeStr = [NSString stringWithFormat:@"警长:%@",NotNilObject([temp objectForKey:@"police"])];
    NSString *waterDescStr =  [NSString stringWithFormat:@"水质:%@",NotNilObject([temp objectForKey:@"waterDesc"])];
    NSString *perExponentStr = [NSString stringWithFormat:@"高锰酸盐指数:%@",NotNilObject([temp objectForKey:@"perExponent"])];
    NSString *aNStr = [NSString stringWithFormat:@"氨氮:%@",NotNilObject([temp objectForKey:@"aN"])];
    NSString *totalPStr = [NSString stringWithFormat:@"总磷:%@",NotNilObject([temp objectForKey:@"totalP"])];

    
    
    //添加 起点终点两个气泡
    if (!ISNULLARR(gpsArr)) {
        MyAnnotation *annoOrigion = [[MyAnnotation alloc] init];
        MyAnnotation *annoDest = [[MyAnnotation alloc] init];
        NSString *riveroo = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@",fileName,rivernameStr,ManagerStr,manegerFirm,policeStr,waterDescStr,perExponentStr,aNStr,totalPStr];
        annoOrigion.title = riveroo;
        annoDest.title = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@",fileName,rivernameStr,ManagerStr,manegerFirm,policeStr,waterDescStr,perExponentStr,aNStr,totalPStr];
        
        NSNumber *latitude = [gpsArr[0] objectForKey:@"latitude"];//只在起点添加标注
        NSNumber *longitude  = [gpsArr[0] objectForKey:@"longitude"];
        CLLocationCoordinate2D point = CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue);
        
        NSNumber *latitudeDest = [[gpsArr lastObject] objectForKey:@"latitude"];//只在起点添加标注
        NSNumber *longitudeDest  = [[gpsArr lastObject] objectForKey:@"longitude"];
        CLLocationCoordinate2D pointDest = CLLocationCoordinate2DMake(latitudeDest.doubleValue, longitudeDest.doubleValue);
        
        annoOrigion.coordinate = point;
        annoDest.coordinate = pointDest;
        [_tMapView addAnnotation:annoOrigion];
        [_tMapView addAnnotation:annoDest];

    }
   _index++;
    return lineview;
}

#pragma mark - TAddressComponent Delegate

- (void)SearchOver:(TAddressComponent *)result {
    if (result.isHaseResult) {
        _addressResult = result.strAdministrative;

        NSLog(@"签到地址：%@",_addressResult);
    }
}

- (void)AddressComponent:(TAddressComponent *)address error:(NSError *)error {
    
}

#pragma mark - UIsearchBar Delegate

//搜索,有文本
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [_searchBar resignFirstResponder];
    _allRiversArr = nil;
    //去除所有河流
    [_tMapView removeOverlays:_tMapView.overlays];
    
    long iSize = [_tMapView.annotations count];
    if (iSize) {
        for (long i = iSize - 1; i >= 0; --i) {
            id item = [_tMapView.annotations objectAtIndex:i];
            [_tMapView removeAnnotation:item];
        }
    }
    
    
    [_tMapView reloadInputViews];
    
    NSString *searchStr = _searchBar.text;
    
    [self searchDataWithStr:[searchStr lowercaseString]];
}


#pragma mark - User Interantion

- (void)showFile:(UIButton *)button {
    
    [[HttpClient httpClient] downloadWithURl:button.titleLabel.text httpMethod:TBHttpRequestPost bodyData:nil success:^(id responseObject) {
        WebViewController *webVC = [[WebViewController alloc] initWithRequest:(NSURLRequest*)responseObject];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webVC];
        [self presentViewController:nav animated:YES completion:nil];
        
    } failure:^(NSError *error) {
        
    }];
}

//点击搜索按钮
-(void)clickSearchBtn:(UIButton *)button{
    [_searchBar resignFirstResponder];
    _allRiversArr = nil;
    //去除所有河流
    [_tMapView removeOverlays:_tMapView.overlays];
    long iSize = [_tMapView.annotations count];
    if (iSize) {
        for (long i = iSize - 1; i >= 0; --i) {
            id item = [_tMapView.annotations objectAtIndex:i];
            [_tMapView removeAnnotation:item];
        }
    }
    
    [_tMapView reloadInputViews];
    
    NSString *searchStr = _searchBar.text;
    
    if (ISNULLSTR(searchStr)) {
        [self queryAllRivers];
    }
    else{
        [self searchDataWithStr:[searchStr lowercaseString]];
    }
}

- (void)jumpToSignInRecord {
    SignInRecordTableVC *signInRecordTableVC = [[SignInRecordTableVC alloc] init];
    [self.navigationController pushViewController:signInRecordTableVC animated:YES];
}

- (void)settingAction {
    //模拟开单
//    CreatWorkOrderVC *addVC = [[CreatWorkOrderVC alloc] init];
//    [self.navigationController pushViewController:addVC animated:YES];
    
    settingTableVC *setVC = [[settingTableVC alloc] init];
    [self.navigationController pushViewController:setVC animated:YES];
}

- (void)signInAction {
    //获取地理反编码位置
    _addresssComponent = [[TAddressComponent alloc] init];
    _addresssComponent.delegate = self;
    
    BOOL flag = [_addresssComponent StartSearch:self.tMapView.userLocation.coordinate];
    if (flag) {
        [self signInRequest];
    }
}

- (void)signInRequest {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:[[UserInfo sharedInstance] ReadData].userID forKey:@"checkIns.userId"];
    //模拟签到河边  latitude = "30.5265";longitude = "120.69075";
    
    [param setObject:[NSString stringWithFormat:@"1"] forKey:@"isMobile"];
    [param setObject:[NSNumber numberWithDouble:self.tMapView.userLocation.coordinate.longitude] forKey:@"checkGps.longitude"];
    [param setObject:[NSNumber numberWithDouble:self.tMapView.userLocation.coordinate.latitude] forKey:@"checkGps.latitude"];
    if (_addressResult) {
         [param setObject:_addressResult  forKey:@"checkGps.addr"];
    }else {
         [param setObject:@"" forKey:@"checkGps.addr"];
    }
    [SVProgressHUD show];
    WEAKSELF
    [[HttpClient httpClient] requestWithPath:@"/checkIn.action" method:TBHttpRequestPost parameters:param prepareExecute:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        STRONGSELF
        NSNumber *successNum = [responseObject objectForKey:@"success"];
        if (successNum.boolValue) {
            NSLog(@"签到成功");
            [SVProgressHUD showSuccessWithStatus:@"签到成功"];
            strongSelf.qiaodao_state = YES;
            strongSelf.qiandaoV.hidden = YES;
            strongSelf.qiantuiV.enabled = YES;
            strongSelf.xinjianV.hidden = NO;
            [strongSelf.qiantuiV setTitle:@"签退" forState:UIControlStateNormal];
            [strongSelf.qiantuiV setImage:[UIImage imageNamed:@"签退"] forState:UIControlStateNormal];
            strongSelf.ordernumber = [responseObject objectForKey:@"data"];
            [[UserInfo sharedInstance] writeOrderNumber:strongSelf.ordernumber];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"message"]];
            
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
      
        [SVProgressHUD showErrorWithStatus:error.userInfo[@"name"]];
    }];
}

/**
 签退
 */
-(void)signOutAction
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setObject:_ordernumber forKey:@"checkIns.id"];
    [param setObject:[NSString stringWithFormat:@"1"] forKey:@"isMobile"];
    [param setObject:[[UserInfo sharedInstance] ReadData].userID forKey:@"sysUserId"];
    
    [SVProgressHUD show];
    WEAKSELF
    [[HttpClient httpClient] requestWithPath:@"/chekcOut.action" method:TBHttpRequestPost parameters:param prepareExecute:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        STRONGSELF
        NSNumber *successNum = [responseObject objectForKey:@"success"];
        if (successNum.boolValue) {
            NSLog(@"签退成功");
            [SVProgressHUD showSuccessWithStatus:@"签退成功"];
            strongSelf.qiaodao_state = NO;
            strongSelf.qiandaoV.hidden = NO;
            strongSelf.qiantuiV.enabled = NO;
            strongSelf.xinjianV.hidden = YES;
            [strongSelf.qiantuiV setImage:[UIImage imageNamed:@"签退-已签"] forState:UIControlStateNormal];
            [strongSelf.qiantuiV setTitle:@"已签退" forState:UIControlStateNormal];
        }else{
            [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"message"]];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
       
        [SVProgressHUD showErrorWithStatus:error.userInfo[@"name"]];;
    }];
}

/**
 新建工单
 */
- (void)newWorkOrder {
    CreatWorkOrderVC *creatWorkVC = [[CreatWorkOrderVC alloc] init];
    [self.navigationController pushViewController:creatWorkVC animated:YES];
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

#pragma mark - Internal helpers

//上传位置
- (void)uploadGPS {
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setObject:[[UserInfo sharedInstance] ReadOrderNumber].orderNum forKey:@"riverGps.riverId"];
    
    if (_ordernumber >0)
    {
        [param setObject:_ordernumber forKey:@"checkGps.checkId"];
        
        [param setObject:[NSNumber numberWithDouble:self.tMapView.userLocation.coordinate.longitude] forKey:@"checkGps.longitude"];
        [param setObject:[NSNumber numberWithDouble:self.tMapView.userLocation.coordinate.latitude]  forKey:@"checkGps.latitude"];
        
        [param setObject:[NSString stringWithFormat:@"1"] forKey:@"isMobile"];
        [param setObject:[[UserInfo sharedInstance] ReadData].userID forKey:@"sysUserId"];
        WEAKSELF
        [[HttpClient httpClient] requestWithPath:@"/uploadCheckGps.action" method:TBHttpRequestPost parameters:param prepareExecute:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            STRONGSELF
            NSNumber *successNum = [responseObject objectForKey:@"success"];
            if (successNum.boolValue) {
//                [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"上传成功 经度：%f 维度：%f",self.tMapView.userLocation.coordinate.longitude,self.tMapView.userLocation.coordinate.latitude]];
                NSLog(@"上传成功 经度：%f 维度：%f",strongSelf.tMapView.userLocation.coordinate.longitude,strongSelf.tMapView.userLocation.coordinate.latitude);
                
            }else{
                [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"message"]];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
         
            [SVProgressHUD showErrorWithStatus:error.userInfo[@"name"]];
        }];
    }
}

//计算两点间距离
- (NSInteger)Distance:(CLLocationCoordinate2D)lastPoint currentPoint:(CLLocationCoordinate2D)currentPoint {
    
    double lat1 = (M_PI/180)*lastPoint.latitude;
    double lat2 = (M_PI /180)*currentPoint.latitude;
    
    double lon1 = (M_PI /180)*lastPoint.longitude;
    double lon2 = (M_PI /180)*currentPoint.longitude;
    //地球半径
    double R = 6371;
    //两点间距离 km，如果想要米的话，结果*1000就可以了
    double d = acos(sin(lat1)*sin(lat2)+cos(lat1)*cos(lat2)*cos(lon2-lon1))*R;
    NSLog(@"距离：%fm",d*1000);
    return (NSInteger)(d*1000);
}

@end
