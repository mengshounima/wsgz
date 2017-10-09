//
//  DetailWorkOrderVC.m
//  FiveWaterWork
//
//  Created by aiteyuan on 16/2/22.
//  Copyright © 2016年 aty. All rights reserved.
//

#import "DetailWorkOrderVC.h"
#import "MJPhotoBrowser.h"
#import "selectPeopleView.h"
#import "progressView.h"
#import "AddFeedbackViewController.h"
#import "MMAlertView.h"
#import "FeedBackInfoView.h"
#import "Masonry.h"

#define WEAKSELF typeof(self) weakSelf = self;
#define STRONGSELF typeof(weakSelf) strongSelf = self;

@interface DetailWorkOrderVC ()<selectPeopleDelegate>

@property (strong,nonatomic) UIScrollView *backScrollerView;

@property (strong, nonatomic) UIImageView *ImageView1;
@property (strong, nonatomic) UIImageView *ImageView2;
@property (strong, nonatomic) UIImageView *ImageView3;
@property (strong, nonatomic) UIImageView *ImageView4;
@property (strong, nonatomic) UIImageView *ImageView5;

@property (nonatomic,strong) UIButton *signBtn;
@property (nonatomic,strong) UIButton *transferBtn;

@property (nonatomic,strong) NSArray *peopleArr;

@property (nonatomic,assign) NSNumber *selectId;

@property (nonatomic, strong) UIView *backView;

@property (nonatomic, strong) selectPeopleView *selectV;

@property (nonatomic, strong) NSArray *jtArray;

@property (nonatomic, strong) FeedBackInfoView *popView;

@property (nonatomic, strong) NSArray *items;

@end

@implementation DetailWorkOrderVC

#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"jobMore" ofType:@"plist"];
    self.items = [NSArray arrayWithContentsOfFile:path];
    
    [self initview];
    [self requestOrderDetail];
}

-(void)initview{
    self.title = @"工单详情";
    self.view.backgroundColor = [UIColor whiteColor];

    _backScrollerView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    _backScrollerView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_backScrollerView];
    
    //主题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, SCREEN_WIDTH-40, 30)];
    titleLabel.text = [NSString stringWithFormat:@"主题：%@",[_detailDic objectForKey:@"title"]];
    [_backScrollerView addSubview:titleLabel];
    
    float Y = CGRectGetMaxY(titleLabel.frame) + 10;
    
    //发起人
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, Y, SCREEN_WIDTH-40, 30)];
    nameLabel.text = [NSString stringWithFormat:@"发起人：%@",_detailDic[@"createdName"]];
    [_backScrollerView addSubview:nameLabel];
    
    Y = CGRectGetMaxY(nameLabel.frame) + 10;
    
    UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, Y, SCREEN_WIDTH-40, 30)];
    
    NSNumber *typeNum = [_detailDic objectForKey:@"type"];
    if (typeNum.integerValue==0) {
        typeLabel.text = @"类型：日常巡河";
    }
    else{
        typeLabel.text = @"类型：问题上报";
    }
    
    [_backScrollerView addSubview:typeLabel];
    
    Y = CGRectGetMaxY(typeLabel.frame) + 10;
    
    //时间
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, Y, SCREEN_WIDTH-40, 30)];
    
    NSString *time=[_detailDic objectForKey:@"createTime"];
    long floatString = [time longLongValue]/1000.0;
    NSDate *nd = [NSDate dateWithTimeIntervalSince1970:floatString];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    
    NSString *dateString = [dateFormat stringFromDate:nd];
    
    dateLabel.text = [NSString stringWithFormat:@"时间：%@",dateString];
    [_backScrollerView  addSubview:dateLabel];
    
    //内容
    UILabel *contentLabel = [[UILabel alloc] init];
    contentLabel.numberOfLines = 0;
    contentLabel.preferredMaxLayoutWidth = SCREEN_WIDTH-40;
    contentLabel.text = [NSString stringWithFormat:@"内容：%@",[_detailDic objectForKey:@"content"]];
    [_backScrollerView addSubview:contentLabel];
    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.right.lessThanOrEqualTo(@(-20));
        make.top.equalTo(dateLabel.mas_bottom).offset(10);
    }];
    
    //新增jobMore
    NSDictionary *jobMore = _detailDic[@"jobMore"];
    
    //_items 文档

    UILabel *lastL;
    for (NSDictionary *item in _items) {
        UILabel *tempL = [[UILabel alloc] init];
        tempL.numberOfLines = 2;
        tempL.preferredMaxLayoutWidth = SCREEN_WIDTH - 40;
        NSString *subKey = [item[@"key"] substringFromIndex:4];
        NSString *content = jobMore[subKey];
        tempL.text = [NSString stringWithFormat:@"%@： %@",item[@"title"],NotNilObject(content)];
        [_backScrollerView addSubview:tempL];
        [tempL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@20);
            make.right.equalTo(@(-20));
            if (lastL) {
                make.top.equalTo(lastL.mas_bottom).offset(10);
            }else {
                make.top.equalTo(contentLabel.mas_bottom).offset(20);
            }
        }];
        lastL = tempL;
    }
    
    
    [self.view layoutIfNeeded];
    
    Y =  CGRectGetMaxY(lastL.frame) +20;
    //添加图片
    int picWidth = (SCREEN_WIDTH-60)/2;
    _ImageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(20, Y, picWidth, picWidth)];
    _ImageView1.tag = 1;

    [_backScrollerView addSubview:_ImageView1];
    _ImageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(20+picWidth+20, Y, picWidth, picWidth)];
    _ImageView2.tag=2;

    [_backScrollerView addSubview:_ImageView2];
  
    
    Y =  CGRectGetMaxY(_ImageView1.frame) +20;
    _ImageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(20, Y, picWidth, picWidth)];
    _ImageView3.tag=3;
    [_backScrollerView addSubview:_ImageView3];
    _ImageView4 = [[UIImageView alloc] initWithFrame:CGRectMake(20+picWidth+20, Y, picWidth, picWidth)];
    _ImageView4.tag=4;

    [_backScrollerView addSubview:_ImageView4];
    
    Y =  CGRectGetMaxY(_ImageView3.frame) +20;
    _ImageView5 = [[UIImageView alloc] initWithFrame:CGRectMake(20, Y, picWidth, picWidth)];
    _ImageView5.tag=5;
    [_backScrollerView addSubview:_ImageView5];
    
    Y = CGRectGetMaxY(contentLabel.frame)+20;
    
    [_backScrollerView setContentSize:CGSizeMake(SCREEN_WIDTH, Y)];
    
     _ImageView1.userInteractionEnabled = NO;
     _ImageView2.userInteractionEnabled = NO;
     _ImageView3.userInteractionEnabled = NO;
     _ImageView4.userInteractionEnabled = NO;
     _ImageView5.userInteractionEnabled = NO;
    
    [_ImageView1 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pictureTap:)]];
    [_ImageView2 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pictureTap:)]];
    [_ImageView3 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pictureTap:)]];
    [_ImageView4 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pictureTap:)]];
    [_ImageView5 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pictureTap:)]];
    
    _signBtn = [[UIButton alloc] init];
    [_signBtn setTitle:@"签收" forState:UIControlStateNormal];
    [_signBtn setImage:[UIImage imageNamed:@"btn_qianshou"] forState:UIControlStateNormal];
    [_signBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_qianshou"] forState:UIControlStateNormal];
    [_signBtn addTarget:self action:@selector(clickSignBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_backScrollerView addSubview:_signBtn];
    
    _signBtn.frame = CGRectMake(20, Y, SCREEN_WIDTH/2-40, 30);
    
    _transferBtn = [[UIButton alloc] init];
    [_transferBtn setTitle:@"转发" forState:UIControlStateNormal];
    [_transferBtn setImage:[UIImage imageNamed:@"btn_zhuanfa"] forState:UIControlStateNormal];
    [_transferBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_zhuanfa"] forState:UIControlStateNormal];
    [_transferBtn addTarget:self action:@selector(clickTransferBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_backScrollerView addSubview:_transferBtn];
    _transferBtn.frame = CGRectMake(SCREEN_WIDTH/2+20, Y, SCREEN_WIDTH/2-40, 30);
    _signBtn.hidden = YES;
    _transferBtn.hidden = YES;
    
    //签收转发，完成显示
    NSNumber *stateNum = [_detailDic objectForKey:@"state"];
    NSNumber *isSelfNum = [_detailDic objectForKey:@"isSelf"];
    if (stateNum.integerValue == 1 && isSelfNum.integerValue == 1 ) {
        _signBtn.hidden = NO;
        _transferBtn.hidden = NO;
    }else if(stateNum.integerValue == 2 && isSelfNum.integerValue == 1) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(showAlertView:)];
    }else if(stateNum.integerValue == 3 && isSelfNum.integerValue == 0) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"反馈信息" style:UIBarButtonItemStylePlain target:self action:@selector(showFeedback:)];
    }
}

-(void)requestOrderDetail{
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setObject:[_detailDic objectForKey:@"id"] forKey:@"job.id"];
    [param setObject:[NSString stringWithFormat:@"1"] forKey:@"isMobile"];
    [param setObject:[_detailDic objectForKey:@"isSelf"] forKey:@"isSelf"];
    [param setObject:[_detailDic objectForKey:@"type"] forKey:@"job.type"];
    [SVProgressHUD show];
    WEAKSELF
    [[HttpClient httpClient] requestWithPath:@"/queryJobDetails.action" method:TBHttpRequestPost parameters:param prepareExecute:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        STRONGSELF
        NSNumber *result = [responseObject objectForKey:@"success"];
        if (result.boolValue) {
            [SVProgressHUD dismiss];
            NSDictionary *data = [responseObject objectForKey:@"data"];
            [strongSelf updateView:data];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"message"]];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [SVProgressHUD showErrorWithStatus:error.userInfo[@"name"]];
    }];
}

-(void)updateView:(NSDictionary *)data
{
    
    //工单详情图片
    NSArray *InfoArr = [data objectForKey:@"pics"];
    NSMutableArray *picPathArr = [NSMutableArray array];
    for (NSDictionary * dic in InfoArr) {
        NSString *picPath = [dic objectForKey:@"picPath"];
        [picPathArr addObject:picPath];
    }

    NSInteger i = 0;
    for (NSString *urlStr in picPathArr) {
        i++;
        NSString *urlLong = [NSString stringWithFormat:@"%@%@",BASEURlSTR,urlStr];
        NSURL *url = [NSURL URLWithString:urlLong];
        switch (i) {
            case 1:
                [_ImageView1 sd_setImageWithURL:url];
                
                _ImageView1.userInteractionEnabled = YES;
                
                float Y = CGRectGetMaxY(_ImageView1.frame)+20;//初始化为1个图片按钮
                if (!_signBtn.hidden) {
                    _signBtn.frame = CGRectMake(20, Y, SCREEN_WIDTH/2-40, 30);
                    _transferBtn.frame = CGRectMake(SCREEN_WIDTH/2+20, Y, SCREEN_WIDTH/2-40, 30);
                    [_backScrollerView setContentSize:CGSizeMake(SCREEN_WIDTH, Y+30)];
                }else{
                    [_backScrollerView setContentSize:CGSizeMake(SCREEN_WIDTH, Y)];
                }
                break;
            case 2:
                [_ImageView2 sd_setImageWithURL:url];
                
                _ImageView2.userInteractionEnabled = YES;
                break;
            case 3:
                [_ImageView3 sd_setImageWithURL:url];
                _ImageView3.userInteractionEnabled = YES;
                
                Y = CGRectGetMaxY(_ImageView3.frame)+20;//初始化为1个图片按钮
                if (!_signBtn.hidden) {
                    _signBtn.frame = CGRectMake(20, Y, SCREEN_WIDTH/2-40, 30);
                    _transferBtn.frame = CGRectMake(SCREEN_WIDTH/2+20, Y, SCREEN_WIDTH/2-40, 30);
                    [_backScrollerView setContentSize:CGSizeMake(SCREEN_WIDTH, Y+30)];
                }else{
                    [_backScrollerView setContentSize:CGSizeMake(SCREEN_WIDTH, Y)];
                }
                
                break;
            case 4:
                [_ImageView4 sd_setImageWithURL:url];
                _ImageView4.userInteractionEnabled = YES;
                
                break;
            case 5:
                [_ImageView5 sd_setImageWithURL:url];
                _ImageView5.userInteractionEnabled = YES;
                
                Y = CGRectGetMaxY(_ImageView5.frame)+20;//初始化为1个图片按钮
                if (!_signBtn.hidden) {
                    _signBtn.frame = CGRectMake(20, Y, SCREEN_WIDTH/2-40, 30);
                    _transferBtn.frame = CGRectMake(SCREEN_WIDTH/2+20, Y, SCREEN_WIDTH/2-40, 30);
                    [_backScrollerView setContentSize:CGSizeMake(SCREEN_WIDTH, Y+30)];
                }else{
                    [_backScrollerView setContentSize:CGSizeMake(SCREEN_WIDTH, Y)];
                }
                
                break;
            default:
                
                break;
        }
        
    }
    
    //转发列表
    _jtArray = [data objectForKey:@"jt"];
    NSNumber *isSelf = _detailDic[@"isSelf"];
    
    if (isSelf.integerValue == 0 && ![_jtArray isEqual:[NSNull null]]) {
        UIView *jtView = [[UIView alloc] init];
        [_backScrollerView addSubview:jtView];
        
        if (picPathArr.count == 0 ) {
            [jtView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@20);
                make.right.equalTo(@(-20));
                make.top.equalTo(_ImageView1);
                make.bottom.equalTo(_backScrollerView).offset(-20);
            }];
        }else {
            [jtView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@20);
                make.right.equalTo(@(-20));
                make.top.equalTo(_ImageView1.mas_top).offset((picPathArr.count +1)/2*(20+(SCREEN_WIDTH-60)/2));
                make.bottom.equalTo(_backScrollerView).offset(-20);
            }];
        }
        
        progressView *titleView = [[progressView alloc] init];
        titleView.backgroundColor = [UIColor lightGrayColor];
        titleView.leftTitleLabel.text = @"处理人";
        titleView.rightTitleLabel.text = @"处理状态";
        [jtView addSubview:titleView];
        [titleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(jtView);
        }];
        
        progressView *lastView;
        for (NSDictionary *jtTemp in _jtArray) {
            
            progressView *tempView = [[progressView alloc] init];
            tempView.leftTitleLabel.text = jtTemp[@"name"];
            NSNumber *state = jtTemp[@"jtState"];
            NSString *process;
            switch (state.integerValue) {
                case 1:
                    process = @"待处理";
                    break;
                case 2:
                    process = @"处理中";
                    break;
                case 3:
                    process = @"已完成";
                    break;
                case 4:
                    process = @"已转发";
                    break;
                    
                default:
                    break;
            }
            
            tempView.rightTitleLabel.text = process;
            [jtView addSubview:tempView];
            if (lastView) {
                [tempView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(lastView.mas_bottom);
                    make.left.right.equalTo(jtView);
                }];
            }else {
                [tempView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(titleView.mas_bottom);
                    make.left.right.equalTo(jtView);
                }];
            }
            
            lastView = tempView;
        }
        [lastView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(jtView);
        }];
        
    }
    
}


#pragma mark - User Interfaction

//签收
-(void)clickSignBtn:(UIButton *)button{
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setObject:[_detailDic objectForKey:@"jtid"] forKey:@"jobTransfer.id"];
    [param setObject:[NSString stringWithFormat:@"1"] forKey:@"isMobile"];
    [param setObject:[[UserInfo sharedInstance] ReadData].userID forKey:@"sysUserId"];
    [SVProgressHUD show];
    
    [[HttpClient httpClient] requestWithPath:@"/sign.action" method:TBHttpRequestPost parameters:param prepareExecute:nil success:^(NSURLSessionDataTask *task, id responseObject) {

        NSNumber *result = [responseObject objectForKey:@"success"];
        if (result.boolValue) {
            [SVProgressHUD dismiss];
            [self.navigationController popViewControllerAnimated:YES];
            if ([self.delegate respondsToSelector:@selector(detailDelegate)]) {
                [self.delegate performSelector:@selector(detailDelegate)];
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

//转发
-(void)clickTransferBtn:(UIButton *)button{
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setObject:[[UserInfo sharedInstance] ReadData].villageId forKey:@"user.villageId"];
    [param setObject:[[UserInfo sharedInstance] ReadData].townId  forKey:@"user.townId"];
    [param setObject:[NSNumber numberWithInteger:1]forKey:@"isMobile"];
    [param setObject:[NSNumber numberWithInteger:1] forKey:@"type"];
    
    [SVProgressHUD show];
    WEAKSELF
    [[HttpClient httpClient] requestWithPath:@"/querySignUser.action" method:TBHttpRequestPost parameters:param prepareExecute:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        STRONGSELF
        
        NSNumber *successNum = [responseObject objectForKey:@"success"];
        if (successNum.boolValue) {
            [SVProgressHUD dismiss];
            strongSelf.peopleArr = [responseObject objectForKey:@"data"];
            [self.view addSubview:strongSelf.backView];
            strongSelf.selectV = [[selectPeopleView alloc] initWithFrame:CGRectMake(20, SCREEN_HEIGHT, SCREEN_WIDTH-40, (SCREEN_HEIGHT-64)*0.9)];
            strongSelf.selectV.peopleArr = strongSelf.peopleArr;
            strongSelf.selectV.delegate = strongSelf;
            [self.view addSubview:strongSelf.selectV];
            
            [UIView animateWithDuration:0.2 animations:^{
                strongSelf.selectV.frame = CGRectMake(20, 64+(SCREEN_HEIGHT-64)*0.05, SCREEN_WIDTH-40, (SCREEN_HEIGHT-64)*0.9);
            }];
        }else
        {
            [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"message"]];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
    
        [SVProgressHUD showErrorWithStatus:error.userInfo[@"name"]];;
    }];
}


-(void)cancelSelectPeople{
    [_backView removeFromSuperview];
}

-(void)transferReal{
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setObject:[_detailDic objectForKey:@"jtid"] forKey:@"jobTransfer.id"];
    [param setObject:_selectId forKey:@"jobTransfer.jobSignUser"];
    [SVProgressHUD show];
    WEAKSELF
    [[HttpClient httpClient] requestWithPath:@"/transpond.action" method:TBHttpRequestPost parameters:param prepareExecute:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        STRONGSELF

        NSNumber *result = [responseObject objectForKey:@"success"];
        if (result.boolValue){
            [SVProgressHUD dismiss];
            [self.navigationController popViewControllerAnimated:YES];
            if ([strongSelf.delegate respondsToSelector:@selector(detailDelegate)]) {
                [strongSelf.delegate performSelector:@selector(detailDelegate)];
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


//完成工单
-(void)finished{
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setObject:[_detailDic objectForKey:@"jtid"] forKey:@"jobTransfer.id"];
    [param setObject:[NSString stringWithFormat:@"1"] forKey:@"isMobile"];
    [param setObject:[[UserInfo sharedInstance] ReadData].userID forKey:@"sysUserId"];
    [SVProgressHUD show];
    WEAKSELF
    [[HttpClient httpClient] requestWithPath:@"/done.action" method:TBHttpRequestPost parameters:param prepareExecute:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        STRONGSELF
        
        NSNumber *result = [responseObject objectForKey:@"success"];
        if (result.boolValue) {
            [SVProgressHUD dismiss];
            [strongSelf.navigationController popViewControllerAnimated:YES];
            if ([strongSelf.delegate respondsToSelector:@selector(detailDelegate)]) {
                [strongSelf.delegate performSelector:@selector(detailDelegate)];
            }

        }else {
            [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"message"]];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [SVProgressHUD showErrorWithStatus:error.userInfo[@"name"]];;
    }];
}

//添加反馈信息
- (void)showAlertView:(UIBarButtonItem *)button {
    MMPopupItemHandler block = ^(NSInteger index){
        switch (index) {
            case 0:
                //直接完成
                [self finished];
                break;
            case 1:
                //添加
                [self addFeedback];
                break;
                
            default:
                break;
        }
    };
    
    NSArray *items =
    @[MMItemMake(@"直接完成", MMItemTypeNormal, block),
      MMItemMake(@"添加", MMItemTypeHighlight, block)];
    
    MMAlertView *alertView = [[MMAlertView alloc] initWithTitle:@"提示"
                                                         detail:@"您可以添加反馈信息"
                                                          items:items];
    alertView.attachedView.mm_dimBackgroundBlurEnabled = NO;
    [alertView show];
}

//显示反馈信息
- (void)showFeedback:(UIBarButtonItem *)barButton {
    self.popView = [[FeedBackInfoView alloc] init];
    if (![_jtArray isEqual:[NSNull null]]) {
        for (NSDictionary *temp in _jtArray) {
            NSNumber *state = temp[@"jtState"];
            if (state.integerValue == 3) {
                self.popView.contentLabel.text = NotNilObject(temp[@"idea"]);
                NSString *urlLong = [NSString stringWithFormat:@"%@%@",BASEURlSTR,NotNilObject(temp[@"picURl"])];
                NSURL *url = [NSURL URLWithString:urlLong];
                [self.popView.imageView sd_setImageWithURL:url];
            }
        }
    }
        [self.popView show];
}

//添加反馈信息
- (void)addFeedback {
    AddFeedbackViewController *addFeedbackVC = [[AddFeedbackViewController alloc] initWithJtID:[_detailDic objectForKey:@"jtid"]];
    [self.navigationController pushViewController:addFeedbackVC animated:YES];
}


#pragma mark - 轻敲图片, 弹出图片浏览器

- (void)pictureTap:(UITapGestureRecognizer *)recongnizer
{
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:1];
    MJPhoto *photo = [[MJPhoto alloc] init];
    if (recongnizer.view.tag==1) {
        photo.image = _ImageView1.image;
        photo.srcImageView = _ImageView1;
    }
    else if (recongnizer.view.tag==2)
    {
        photo.image = _ImageView2.image;
        photo.srcImageView = _ImageView2;
    }
    else if (recongnizer.view.tag==3)
    {
        photo.image = _ImageView3.image;
        photo.srcImageView = _ImageView3;
    }
    
    else if (recongnizer.view.tag==4)
    {
        photo.image = _ImageView4.image;
        photo.srcImageView = _ImageView4;
    }
    else if (recongnizer.view.tag==5)
    {
        photo.image = _ImageView5.image;
        photo.srcImageView = _ImageView5;
    }
    
    [photos addObject:photo];
    
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = 0;
    browser.photos = photos;
    [browser show];
}

#pragma mark - AddFeedBack Delegate

-(void)finishedSelectPeople:(NSNumber *)jobSignID{
    [_backView removeFromSuperview];
    _selectId = jobSignID;
    [self transferReal];
}

- (void)done {
    [_backView removeFromSuperview];
}

#pragma mark - Setters and Getters

- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25];
        _backView.frame = [UIScreen mainScreen].bounds;
    }
    return _backView;
}

@end
