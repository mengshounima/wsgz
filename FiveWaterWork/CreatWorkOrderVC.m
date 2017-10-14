//
//  CreatWorkOrderVC.m
//  FiveWaterWork
//
//  Created by 李 燕琴 on 16/5/15.
//  Copyright © 2016年 aty. All rights reserved.
//

#import "CreatWorkOrderVC.h"
#import "selectPeopleView.h"
#import "SSCheckBoxView/SSCheckBoxView.h"
#import <Masonry/Masonry.h>
#import <objc/runtime.h>

static NSString *const content_key;

@interface CreatWorkOrderVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIScrollViewDelegate,selectPeopleDelegate>
@property (strong,nonatomic) UIScrollView *backScrollerView;

@property (strong,nonatomic) UITextField *titleField;

@property (strong, nonatomic) UITextField *dateField;

@property (strong,nonatomic) UITextView *contentView;

@property (strong,nonatomic) UIButton *customButton;

@property (strong,nonatomic) UIButton *problemUpButton;

@property (strong,nonatomic) UIView *UIPicView;

@property (strong,nonatomic) UIButton *firstBtn;

@property (strong,nonatomic) UIButton *secondBtn;

@property (strong,nonatomic) UIButton *thirdBtn;

@property (strong,nonatomic) UIButton *fourthBtn;

@property (strong,nonatomic) UIButton *fifthBtn;

@property (assign,nonatomic) NSInteger imageNumber;

@property (assign,nonatomic)  NSInteger selectedBtnTag;

@property (nonatomic,strong) NSMutableArray *imageArr;

@property (nonatomic,strong) NSArray *peopleArr;

@property (nonatomic,assign) NSNumber *selectId;

@property (nonatomic, strong) UIView *backView;

@property (nonatomic, strong)selectPeopleView *selectV;

//morejob

@property (nonatomic, strong) NSMutableArray *items;

@property (nonatomic, strong) NSMutableArray *allCheckboxes;

@property (nonatomic, strong) UIDatePicker *datePicker;

@property (nonatomic, strong) NSString *lastDate;

@end

@implementation CreatWorkOrderVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"工单录入";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(clickDone:)];
    [self initdata];
    [self setupSubviews];
}
-(void)initdata{
    _imageNumber = 0;
    _imageArr = [[NSMutableArray alloc] init];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"jobMore" ofType:@"plist"];
    NSArray *tempArr = [NSArray arrayWithContentsOfFile:path];
    
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    for (NSDictionary *group in tempArr) {
        NSMutableDictionary *mutGroup = [[NSMutableDictionary alloc] initWithDictionary:group];
        
        NSMutableArray *groupData = [[NSMutableArray alloc] init];
        
        for (NSDictionary *oneItem in group[@"data"]) {
            NSMutableDictionary *resultOneSelect = [[NSMutableDictionary alloc] initWithDictionary:oneItem];
            [groupData addObject:resultOneSelect];
        }
        [mutGroup setObject:groupData forKey:@"data"];
        [groups addObject:mutGroup];
    }
    
    self.items = groups;
}
-(void)setupSubviews{
    _backScrollerView = [[UIScrollView alloc] init];
    _backScrollerView.delegate = self;
    [self.view addSubview:_backScrollerView];
    [_backScrollerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    UIView *containerV = [[UIView alloc] init];
    [_backScrollerView addSubview:containerV];
    [containerV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.edges.equalTo(_backScrollerView);
    }];
    
    UILabel *titlelabel = [[UILabel alloc] init];
    titlelabel.font = [UIFont systemFontOfSize:14];
    titlelabel.text = @"主题:";
    [containerV addSubview:titlelabel];
    [titlelabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.top.mas_equalTo(20);
    }];
    
    _titleField = [[UITextField alloc] init];
    _titleField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _titleField.layer.cornerRadius = 6;
    _titleField.font = [UIFont systemFontOfSize:14];
    _titleField.layer.borderWidth = 1;
    [containerV addSubview:_titleField];
    [_titleField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(titlelabel);
        make.left.equalTo(titlelabel.mas_right).offset(10);
        make.right.mas_equalTo(-10);
        make.height.mas_equalTo(30);
    }];
    
    UILabel *contentlabel = [[UILabel alloc] init];
    contentlabel.font = [UIFont systemFontOfSize:14];
    contentlabel.text = @"内容:";
    [containerV addSubview:contentlabel];
    [contentlabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titlelabel);
        make.top.equalTo(_titleField.mas_bottom).offset(10);
    }];
    
    _contentView = [[UITextView alloc] init];
    _contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _contentView.layer.cornerRadius = 6;
    _contentView.font = [UIFont systemFontOfSize:14];
    _contentView.layer.borderWidth = 1;
    [containerV addSubview:_contentView];
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentlabel);
        make.left.equalTo(contentlabel.mas_right).offset(10);
        make.right.mas_equalTo(-10);
        make.height.mas_equalTo(200);
    }];
    
    _customButton = [[UIButton alloc] init];
    [_customButton setImage:[UIImage imageNamed:@"勾选-选中"] forState:UIControlStateNormal];
    [_customButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_customButton setTitle:@"日常巡河" forState:UIControlStateNormal];
    _customButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_customButton addTarget:self action:@selector(clickCustomBtn:) forControlEvents:UIControlEventTouchUpInside];
    [containerV addSubview:_customButton];
    [_customButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.equalTo(_contentView.mas_bottom).offset(10);
        make.width.mas_equalTo((SCREEN_WIDTH-60)/2);
        make.height.mas_equalTo(30);

    }];
    _customButton.selected = YES;
    
    _problemUpButton = [[UIButton alloc] init];
    [_problemUpButton setImage:[UIImage imageNamed:@"勾选-未选中"] forState:UIControlStateNormal];
    _problemUpButton.titleLabel.font = [UIFont systemFontOfSize:14];
    NSNumber *isLeader = [[UserInfo sharedInstance] ReadData].isLeader;
    if (isLeader.integerValue==1) {
        [_problemUpButton setTitle:@"问题交办" forState:UIControlStateNormal];
    }
    else{
        [_problemUpButton setTitle:@"问题上报" forState:UIControlStateNormal];
    }
    
    [_problemUpButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
     [_problemUpButton addTarget:self action:@selector(clickProblemBtn:) forControlEvents:UIControlEventTouchUpInside];
    [containerV addSubview:_problemUpButton];
    [_problemUpButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_customButton.mas_right).offset(20);
        make.centerY.equalTo(_customButton);
        make.width.mas_equalTo((SCREEN_WIDTH-60)/2);
        make.height.mas_equalTo(30);
    }];
    _problemUpButton.selected = NO;
    
    //最迟解决时间
    UILabel *datelabel = [[UILabel alloc] init];
    datelabel.font = [UIFont systemFontOfSize:14];
    datelabel.text = @"最迟解决时间:";
    [containerV addSubview:datelabel];
    [datelabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_problemUpButton.mas_bottom).offset(10);
        make.left.mas_equalTo(10);
    }];
    
    _dateField = [[UITextField alloc] init];
    _dateField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _dateField.layer.cornerRadius = 6;
    _dateField.font = [UIFont systemFontOfSize:14];
    _dateField.layer.borderWidth = 1;
    [containerV addSubview:_dateField];
    [_dateField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(datelabel);
        make.left.equalTo(datelabel.mas_right).offset(10);
        make.right.mas_equalTo(-10);
        make.height.mas_equalTo(30);
    }];
    _datePicker = [[UIDatePicker alloc] init];
    _datePicker.frame = CGRectMake(0, SCREEN_HEIGHT-124, SCREEN_WIDTH, 124); // 设置显示的位置和大小
    _datePicker.date = [NSDate date]; // 设置初始时间
    _datePicker.timeZone = [NSTimeZone timeZoneWithName:@"GTM+8"]; // 设置时区，中国在东八区
    _datePicker.datePickerMode = UIDatePickerModeDate; // 设置样式
    _dateField.inputView = _datePicker;
    
    //添加工具栏
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    UIBarButtonItem *emptyItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(doneDateSelect)];
    toolbar.items = @[emptyItem,doneItem];
    _dateField.inputAccessoryView = toolbar;
    [containerV layoutSubviews];
    [_dateField setNeedsLayout];
    [_dateField layoutIfNeeded];
    
    //多选jobMore
    float Y =  CGRectGetMaxY(datelabel.frame) +10;
    //多选jobMore
    
    UIView *lastGroupView = nil;
    for (int i = 0;i < _items.count;i++) {
        
        NSDictionary *item = _items[i];
        NSArray *selections = item[@"data"];
        
        UIView *groupView = [[UIView alloc] initWithFrame:CGRectMake(0, Y, SCREEN_WIDTH, 36*selections.count)];
        [_backScrollerView addSubview:groupView];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = [NSString stringWithFormat:@"%@:",item[@"title"]];
        titleLabel.preferredMaxLayoutWidth = 80;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [titleLabel setFont:[UIFont systemFontOfSize:14]];
        titleLabel.numberOfLines = 2;
        [groupView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.centerY.equalTo(groupView);
        }];
        
        NSMutableArray *checkboxs = [[NSMutableArray alloc] init];
        SSCheckBoxView *lastBoxV = nil;;
        
        for (int j = 0;j<selections.count;j++) {
            
            NSDictionary *selectItem = selections[j];
            NSString *isSelect = selectItem[@"selected"];
            SSCheckBoxView *cbv = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(90, 36*j, 240, 36)
                                                                  style:kSSCheckBoxViewStyleGlossy
                                                                checked:isSelect.boolValue];
            
            [cbv setText:selectItem[@"title"]];
            [cbv setStateChangedBlock:^(SSCheckBoxView *v) {
                [self checkBoxSelectChange:v];
            }];
            cbv.tag = j;//组内
            objc_setAssociatedObject(cbv, &content_key, [NSNumber numberWithInt:i], OBJC_ASSOCIATION_RETAIN);
            
            [groupView addSubview:cbv];
            [checkboxs addObject:cbv];
            lastBoxV = cbv;
        }
        [self.allCheckboxes addObject:checkboxs];
        
        Y = CGRectGetMaxY(groupView.frame) + 10;
        lastGroupView = groupView;
    }
    
    
    //添加图片
    int picWidth = (SCREEN_WIDTH-60)/2;
    _firstBtn = [[UIButton alloc] init];
    _firstBtn.tag = 1;
    _firstBtn.hidden = NO;
    [containerV addSubview:_firstBtn];
    [_firstBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(lastGroupView.mas_bottom).offset(10);
        make.width.height.mas_equalTo(picWidth);
    }];
    _secondBtn = [[UIButton alloc] init];
    _secondBtn.tag=2;
    _secondBtn.hidden = YES;
    [containerV addSubview:_secondBtn];
    [_secondBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20+picWidth+20);
        make.top.equalTo(_firstBtn);
        make.width.height.mas_equalTo(picWidth);
    }];
    [_firstBtn setBackgroundImage:[UIImage imageNamed:@"添加-未选中"] forState:UIControlStateNormal];
    [_secondBtn setBackgroundImage:[UIImage imageNamed:@"添加-未选中"] forState:UIControlStateNormal];
    
    _thirdBtn = [[UIButton alloc] init];
    _thirdBtn.tag=3;
    _thirdBtn.hidden = YES;
    [containerV addSubview:_thirdBtn];
    [_thirdBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(_secondBtn.mas_bottom).offset(20);
        make.width.height.mas_equalTo(picWidth);
    }];
    
    _fourthBtn = [[UIButton alloc] init];
    _fourthBtn.tag=4;
    _fourthBtn.hidden = YES;
    [containerV addSubview:_fourthBtn];
    [_fourthBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20+picWidth+20);
        make.top.equalTo(_thirdBtn);
        make.width.height.mas_equalTo(picWidth);

    }];
    [_thirdBtn setBackgroundImage:[UIImage imageNamed:@"添加-未选中"] forState:UIControlStateNormal];
    [_fourthBtn setBackgroundImage:[UIImage imageNamed:@"添加-未选中"] forState:UIControlStateNormal];
    
    _fifthBtn = [[UIButton alloc] init];
    _fifthBtn.tag=5;
    _fifthBtn.hidden = YES;
    [containerV addSubview:_fifthBtn];
    [_fifthBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(_fourthBtn.mas_bottom).offset(20);
        make.width.height.mas_equalTo(picWidth);
    }];
    [_fifthBtn setBackgroundImage:[UIImage imageNamed:@"添加-未选中"] forState:UIControlStateNormal];
    
    [_firstBtn addTarget:self action:@selector(AddPic:) forControlEvents:UIControlEventTouchUpInside];
    [_secondBtn addTarget:self action:@selector(AddPic:) forControlEvents:UIControlEventTouchUpInside];
    [_thirdBtn addTarget:self action:@selector(AddPic:) forControlEvents:UIControlEventTouchUpInside];
    [_fourthBtn addTarget:self action:@selector(AddPic:) forControlEvents:UIControlEventTouchUpInside];
    [_fifthBtn addTarget:self action:@selector(AddPic:) forControlEvents:UIControlEventTouchUpInside];
    
    //初始化为1个图片按钮
    [_firstBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-20);
    }];
    
}

#pragma mark - User Interaction

//点击多选框
- (void)checkBoxSelectChange:(SSCheckBoxView *)checkBoxView {
    BOOL checked = checkBoxView.checked;//点击后结果
    NSNumber *group = objc_getAssociatedObject(checkBoxView,&content_key);
    NSArray *checkBoxs = _allCheckboxes[group.integerValue];
    
    NSMutableDictionary *item = _items[group.integerValue];
    NSMutableArray *datas = item[@"data"];//组内选项
    NSMutableDictionary *selecting = datas[checkBoxView.tag];
    [selecting setObject:[NSNumber numberWithBool:checked] forKey:@"selected"];
    NSNumber *against = selecting[@"against"];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (int i=0;i<datas.count;i++) {
        NSMutableDictionary *selectItem = datas[i];
        NSNumber *itemAgainst = selectItem[@"against"];
        if (against.boolValue) {
            ////
            //排除自己
            if ([selectItem[@"code"] isEqualToString:selecting[@"code"]]) {
                [result addObject:selectItem];
                continue;
            }
            
            
            if (!(itemAgainst.boolValue == against.boolValue)) {
                [selectItem setObject:[NSNumber numberWithBool:!checked] forKey:@"selected"];
                [result addObject:selectItem];
                SSCheckBoxView *checkBoxV = checkBoxs[i];
                [checkBoxV setChecked:!checked];
            }else {
                [result addObject:selectItem];
            }

            ////
        }else {
            if (checked) {
                //勾选
                //排除自己
                if ([selectItem[@"code"] isEqualToString:selecting[@"code"]]) {
                    [result addObject:selectItem];
                    continue;
                }
                
                
                if (!(itemAgainst.boolValue == against.boolValue)) {
                    [selectItem setObject:[NSNumber numberWithBool:!checked] forKey:@"selected"];
                    [result addObject:selectItem];
                    SSCheckBoxView *checkBoxV = checkBoxs[i];
                    [checkBoxV setChecked:!checked];
                }else {
                    [result addObject:selectItem];
                }

            }else {
                //取消勾选,需要判断消极选项是否都被取消勾选
                BOOL flag = YES;
                for (NSMutableDictionary *selectItem in datas) {
                    NSNumber *selected = selectItem[@"selected"];
                    if (selected.boolValue) {
                        flag = NO;
                    }
                }
                if (flag) {
                    //排除自己
                    if ([selectItem[@"code"] isEqualToString:selecting[@"code"]]) {
                        [result addObject:selectItem];
                        continue;
                    }
                    
                    
                    if (!(itemAgainst.boolValue == against.boolValue)) {
                        [selectItem setObject:[NSNumber numberWithBool:!checked] forKey:@"selected"];
                        [result addObject:selectItem];
                        SSCheckBoxView *checkBoxV = checkBoxs[i];
                        [checkBoxV setChecked:!checked];
                    }else {
                        [result addObject:selectItem];
                    }
                }else {
                    [result addObject:selectItem];
                }
            }
        }
        
        
            }
    item[@"data"] = result;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_titleField resignFirstResponder];
    [_contentView resignFirstResponder];
}

//日期选择结束
- (void)doneDateSelect {
    NSDate *select = _datePicker.date; // 获取被选中的时间
    NSDateFormatter *selectDateFormatter = [[NSDateFormatter alloc] init];
    selectDateFormatter.dateFormat = @"yyyy-MM-dd";
    _lastDate = [selectDateFormatter stringFromDate:select];
    [_dateField resignFirstResponder];
}

-(void)AddPic:(UIButton *)button
{
    [_titleField resignFirstResponder];
    [_contentView resignFirstResponder];
    
    _selectedBtnTag = button.tag;
    UIActionSheet * sheet;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        sheet = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"拍照", @"从相册", nil];
    }
    else
    {
        sheet = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"从相册", nil];
    }
    [sheet showInView:self.view];
}

-(void)clickCustomBtn:(UIButton *)btn
{
    _customButton.selected = YES;
    _problemUpButton.selected = NO;
    [_customButton setImage:[UIImage imageNamed:@"勾选-选中"] forState:UIControlStateNormal];
    [_problemUpButton setImage:[UIImage imageNamed:@"勾选-未选中"] forState:UIControlStateNormal];
}

-(void)clickProblemBtn:(UIButton *)btn
{
    _problemUpButton.selected = YES;
    _customButton.selected = NO;
    
    [_problemUpButton setImage:[UIImage imageNamed:@"勾选-选中"] forState:UIControlStateNormal];
    [_customButton setImage:[UIImage imageNamed:@"勾选-未选中"] forState:UIControlStateNormal];
    
}

-(void)clickDone:(UIBarButtonItem *)btn{
    [_titleField resignFirstResponder];
    [_contentView resignFirstResponder];
    
    if (ISNULLSTR(_titleField.text)) {
        [SVProgressHUD showErrorWithStatus:@"主题不能为空"];
        return;
    }
    if (ISNULLSTR(_contentView.text)) {
        [SVProgressHUD showErrorWithStatus:@"内容不能为空"];
        return;
    }
    //是否为问题上报
    if (_customButton.selected) {
        [self doneReal:@"0"];//常规
    }else{
        if (!_lastDate) {
            [SVProgressHUD showErrorWithStatus:@"最迟解决时间不能为空"];
            return;
        }
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        
        [param setObject:[[UserInfo sharedInstance] ReadData].villageId forKey:@"user.villageId"];
        [param setObject:[[UserInfo sharedInstance] ReadData].townId  forKey:@"user.townId"];
        [param setObject:[NSNumber numberWithInteger:1] forKey:@"isMobile"];
        [param setObject:[NSNumber numberWithInteger:0] forKey:@"type"];
        
        [SVProgressHUD show];
        [[HttpClient httpClient] requestWithPath:@"/querySignUser.action" method:TBHttpRequestPost parameters:param prepareExecute:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            
            NSNumber *successNum = [responseObject objectForKey:@"success"];
            if (successNum.boolValue) {
                [SVProgressHUD dismiss];
                _peopleArr = [responseObject objectForKey:@"data"];
                _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
                [self.view addSubview:_backView];
                _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25];
                
                _selectV = [[selectPeopleView alloc] initWithFrame:CGRectMake(20, SCREEN_HEIGHT, SCREEN_WIDTH-40, (SCREEN_HEIGHT-64)*0.9)];
                _selectV.peopleArr = _peopleArr;
                _selectV.delegate = self;
                [self.view addSubview:_selectV];
                
                [UIView animateWithDuration:0.2 animations:^{
                    _selectV.frame = CGRectMake(20, 64+(SCREEN_HEIGHT-64)*0.05, SCREEN_WIDTH-40, (SCREEN_HEIGHT-64)*0.9);
                }];
                
                
            }else{
                [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"message"]];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [SVProgressHUD showErrorWithStatus:error.userInfo[@"name"]];
        }];
    }
    
}

- (void)doneReal:(NSString *)flagStr {
    
    NSMutableDictionary *param =[[NSMutableDictionary alloc] init];
    [param setObject:_titleField.text forKey:@"job.title"];
    [param setObject:_contentView.text forKey:@"job.content"];
    if (_customButton.selected) {
        [param setObject:@"0" forKey:@"job.type"];
    }else{
        //问题上报
        [param setObject:@"1" forKey:@"job.type"];
        [param setObject:_selectId forKey:@"jobTransfer.jobSignUser"];
        param[@"job.solveEndTime"] = _lastDate;
    }
    
    [param setObject:[[UserInfo sharedInstance] ReadOrderNumber].orderNum forKey:@"job.checkId"];
    [param setObject:[[UserInfo sharedInstance] ReadData].userID forKey:@"job.createUserId"];
    //jobMore
    for (NSMutableDictionary *group in _items) {
        NSArray *datas = group[@"data"];
        NSMutableString *paramStr;
        for (NSMutableDictionary *oneitem in datas) {
            NSNumber *selected = oneitem[@"selected"];
            if (selected.boolValue) {
                if (paramStr.length > 0) {
                    [paramStr appendString:[NSString stringWithFormat:@";%@",oneitem[@"code"]]];
                }else {
                    paramStr = [[NSMutableString alloc] init];
                    [paramStr appendString:oneitem[@"code"]];
                }
            }
        }
        param[group[@"key"]] = [paramStr copy];
    }
    
    [SVProgressHUD showWithStatus:@"上传中"];
    
    [[HttpClient httpClient] requestOperaionManageWithURl:@"/saveJob2.action" httpMethod:TBHttpRequestPost parameters:param bodyData:_imageArr DataNumber:_imageArr.count success:^(NSURLSessionDataTask *task, id responseObject) {
        NSNumber *result = [(NSDictionary *)responseObject objectForKey:@"success"];
        if (result.boolValue) {
            [SVProgressHUD showSuccessWithStatus:@"上传成功"];
            //返回到主页
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"message"]];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.userInfo[@"name"]];
    }];
    
}

-(void)cancelSelectPeople{
    [_backView removeFromSuperview];
}

-(void)finishedSelectPeople:(NSNumber *)jobSignID{
    [_backView removeFromSuperview];
    
    _selectId = jobSignID;
    [self doneReal:@"1"];
}


#pragma mark - 实现ActionSheet delegate事件
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    NSUInteger sourceType = 0;
    
    // 判断是否支持相机
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        switch (buttonIndex)
        {
            case 0:
                return;// 取消
            case 1:
                sourceType = UIImagePickerControllerSourceTypeCamera; // 相机
                break;
            case 2:
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary; // 相册
                break;
            default:
                break;
        }
    }
    else
    {
        if (buttonIndex == 0)
        {
            return;
        }
        else
        {
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary; // 相册
        }
    }
    // 跳转到相机或相册页面
    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self; // 设置代理
    imagePicker.allowsEditing = YES; // 允许编辑
    imagePicker.sourceType = sourceType; // 设置图片源
    [[imagePicker navigationBar] setTintColor:[UIColor whiteColor]];
    [self presentViewController:imagePicker animated:YES completion:^{
    }];
}


#pragma mark - 实现ImagePicker delegate 事件 添加完图片就调用这个方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // 获取图片
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        _imageNumber++;
        NSData *data;
        
        data = UIImageJPEGRepresentation(image, 0.5);
        
        [_imageArr addObject:data];
        switch (_selectedBtnTag) {
            case 1:
                [_firstBtn setBackgroundImage:image forState:UIControlStateNormal];
                _secondBtn.hidden = NO;
                _firstBtn.userInteractionEnabled = NO;
                break;
                
            case 2:
                [_secondBtn setBackgroundImage:image forState:UIControlStateNormal];
                _thirdBtn.hidden = NO;
                _secondBtn.userInteractionEnabled = NO;
                float Y = CGRectGetMaxY(_thirdBtn.frame)+20;//初始化为1个图片按钮
                [_backScrollerView setContentSize:CGSizeMake(SCREEN_WIDTH, Y)];
                break;
                
            case 3:
                [_thirdBtn setBackgroundImage:image forState:UIControlStateNormal];
                _fourthBtn.hidden = NO;
                _thirdBtn.userInteractionEnabled = NO;
                
                break;
            case 4:
                [_fourthBtn setBackgroundImage:image forState:UIControlStateNormal];
                _fifthBtn.hidden = NO;
                _fourthBtn.userInteractionEnabled = NO;
                 Y = CGRectGetMaxY(_fifthBtn.frame)+20;//初始化为1个图片按钮
                [_backScrollerView setContentSize:CGSizeMake(SCREEN_WIDTH, Y)];
                
                break;
            case 5:
                [_fifthBtn setBackgroundImage:image forState:UIControlStateNormal];
                _fifthBtn.userInteractionEnabled = NO;
                break;
            default:
                break;
        }
    }];
}

#pragma mark - Setters and Getters

- (NSMutableArray *)allCheckboxes {
    if (!_allCheckboxes) {
        _allCheckboxes = [[NSMutableArray alloc] init];
    }
    return _allCheckboxes;
}

- (NSMutableArray *)items {
    if (!_items) {
        _items = [[NSMutableArray alloc] init];
    }
    return _items;
}

@end
