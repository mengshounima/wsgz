//
//  PathViewController.m
//  FiveWaterWork
//
//  Created by 李 燕琴 on 16/11/27.
//  Copyright © 2016年 aty. All rights reserved.
//

#import "PathViewController.h"
#import "TPolylineView.h"

#define WEAKSELF typeof(self) weakSelf = self;
#define STRONGSELF typeof(weakSelf) strongSelf = self;

@interface PathViewController () <TMapViewDelegate>

@property (nonatomic,strong) NSString *ID;

@property (nonatomic,strong) TMapView *tMapView;

@property (nonatomic, strong) NSArray *signInArray;

@end

@implementation PathViewController

- (instancetype)initWithCheckInID:(NSString *)ID {
    if (self = [super init]) {
        _ID = ID;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self setupData];
}

- (void)setupView {
    self.title = @"巡河轨迹";
    _tMapView = [[TMapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [_tMapView setVisibleMapRect:_tMapView.bounds  edgePadding:UIEdgeInsetsZero animated:NO];
    _tMapView.ShowPosition = NO;
    _tMapView.UserTrackMode = TUserTrackingModeNone;
    _tMapView.delegate = self;
    [_tMapView setMapScale:11];
    [self.view addSubview:_tMapView];
}

- (void)setupData {
    NSMutableDictionary *param = [NSMutableDictionary new];
    param[@"checkIns.id"] = _ID;
    
    WEAKSELF
    [[HttpClient httpClient] requestWithPath:@"/queryCheckGpsByCiId.action" method:TBHttpRequestPost parameters:param prepareExecute:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        STRONGSELF
        strongSelf.signInArray = responseObject[@"data"];
        [self AddOver];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.userInfo[@"name"]];
    }];
}

//画出轨迹
-(void)AddOver{
    CLLocationCoordinate2D nowPoint = CLLocationCoordinate2DMake(0, 0);
    NSInteger i = 0;
    CLLocationCoordinate2D arrPoint[_signInArray.count];
    for (NSDictionary *temp in _signInArray) {
        NSNumber *latitude =  [temp objectForKey:@"latitude"];
        NSNumber *longitude =  [temp objectForKey:@"longitude"];
        arrPoint[i] = CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue);
            if (i==0) {
                nowPoint = arrPoint[i];
            }
        i++;
    }
    TPolyline *line = [TPolyline polylineWithCoordinates:arrPoint count:_signInArray.count];
    [_tMapView addOverlay:line];
    [_tMapView setCenterCoordinate:nowPoint animated:NO];
    [_tMapView setMapScale:12];
    [_tMapView setNeedsDisplay];
}

#pragma mark - Tmap Delegate

//覆盖物回调
- (TOverlayView *)mapView:(TMapView *)mapView viewForOverlay:(id <TOverlay>)overlay {
    TPolylineView *lineview = [[TPolylineView alloc] initWithPolyline:overlay mapView:mapView];
    lineview.lineWidth = 4;
    lineview.strokeColor = [UIColor blueColor];
    return lineview;
}


@end
