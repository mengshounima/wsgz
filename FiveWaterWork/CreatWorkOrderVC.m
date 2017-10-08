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
    _backScrollerView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    _backScrollerView.delegate = self;
    [self.view addSubview:_backScrollerView];
    
    UILabel *titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 40, 30)];
    titlelabel.font = [UIFont systemFontOfSize:15];
    titlelabel.text = @"主题";
    [_backScrollerView addSubview:titlelabel];
    
    _titleField = [[UITextField alloc] initWithFrame:CGRectMake(50, 20, SCREEN_WIDTH-60, 30)];
    _titleField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _titleField.layer.cornerRadius = 6;
    _titleField.font = [UIFont systemFontOfSize:13];
    _titleField.layer.borderWidth = 1;
    [_backScrollerView addSubview:_titleField];
    
    float Y =  CGRectGetMaxY(titlelabel.frame) +10;
    UILabel *contentlabel = [[UILabel alloc] initWithFrame:CGRectMake(10, Y, 40, 30)];
    contentlabel.font = [UIFont systemFontOfSize:15];
    contentlabel.text = @"内容";
    [_backScrollerView addSubview:contentlabel];
    
    _contentView = [[UITextView alloc] initWithFrame:CGRectMake(50, Y, SCREEN_WIDTH-60, 200)];
    _contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _contentView.layer.cornerRadius = 6;
    _contentView.font = [UIFont systemFontOfSize:13];
    _contentView.layer.borderWidth = 1;
    [_backScrollerView addSubview:_contentView];
    
    Y =  CGRectGetMaxY(_contentView.frame) +10;
    
    _customButton = [[UIButton alloc] initWithFrame:CGRectMake(20, Y, (SCREEN_WIDTH-60)/2, 30)];
    [_customButton setImage:[UIImage imageNamed:@"勾选-选中"] forState:UIControlStateNormal];
    [_customButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_customButton setTitle:@"日常巡河" forState:UIControlStateNormal];
    [_customButton addTarget:self action:@selector(clickCustomBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_backScrollerView addSubview:_customButton];
    _customButton.selected = YES;
    
    _problemUpButton = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-60)/2 + 40, Y, (SCREEN_WIDTH-60)/2, 30)];
    [_problemUpButton setImage:[UIImage imageNamed:@"勾选-未选中"] forState:UIControlStateNormal];
    
    NSNumber *isLeader = [[UserInfo sharedInstance] ReadData].isLeader;
    if (isLeader.integerValue==1) {
        [_problemUpButton setTitle:@"问题交办" forState:UIControlStateNormal];
    }
    else{
        [_problemUpButton setTitle:@"问题上报" forState:UIControlStateNormal];
    }
    
    [_problemUpButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
     [_problemUpButton addTarget:self action:@selector(clickProblemBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_backScrollerView addSubview:_problemUpButton];
    _problemUpButton.selected = NO;
    
    Y =  CGRectGetMaxY(_problemUpButton.frame) +10;
    
    //多选jobMore
    
    UIView *lastGroupView = nil;
    for (int i = 0;i < _items.count;i++) {
        
        NSDictionary *item = _items[i];
        NSArray *selections = item[@"data"];
        
        UIView *groupView = [[UIView alloc] initWithFrame:CGRectMake(0, Y, SCREEN_WIDTH, 36*selections.count)];
        [_backScrollerView addSubview:groupView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 36 * selections.count/2, 100, 30)];
        titlelabel.font = [UIFont systemFontOfSize:15];
        titleLabel.text = item[@"title"];
        [groupView addSubview:titleLabel];
        
        NSMutableArray *checkboxs = [[NSMutableArray alloc] init];
        SSCheckBoxView *lastBoxV = nil;;

        for (int j = 0;j<selections.count;j++) {
            
            NSDictionary *selectItem = selections[j];
            NSString *isSelect = selectItem[@"selected"];
            SSCheckBoxView *cbv = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(130, 36*j, 240, 30)
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
    
    Y = CGRectGetMaxY(lastGroupView.frame) + 10;
    
    //添加图片
    int picWidth = (SCREEN_WIDTH-60)/2;
    _firstBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, Y, picWidth, picWidth)];
    _firstBtn.tag = 1;
    _firstBtn.hidden = NO;
    [_backScrollerView addSubview:_firstBtn];
    _secondBtn = [[UIButton alloc] initWithFrame:CGRectMake(20+picWidth+20, Y, picWidth, picWidth)];
    _secondBtn.tag=2;
    _secondBtn.hidden = YES;
    [_backScrollerView addSubview:_secondBtn];
    [_firstBtn setBackgroundImage:[UIImage imageNamed:@"添加-未选中"] forState:UIControlStateNormal];
    [_secondBtn setBackgroundImage:[UIImage imageNamed:@"添加-未选中"] forState:UIControlStateNormal];
    
     Y =  CGRectGetMaxY(_firstBtn.frame) +20;
    _thirdBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, Y, picWidth, picWidth)];
    _thirdBtn.tag=3;
    _thirdBtn.hidden = YES;
    [_backScrollerView addSubview:_thirdBtn];
    _fourthBtn = [[UIButton alloc] initWithFrame:CGRectMake(20+picWidth+20, Y, picWidth, picWidth)];
    _fourthBtn.tag=4;
    _fourthBtn.hidden = YES;
    [_backScrollerView addSubview:_fourthBtn];
    [_thirdBtn setBackgroundImage:[UIImage imageNamed:@"添加-未选中"] forState:UIControlStateNormal];
    [_fourthBtn setBackgroundImage:[UIImage imageNamed:@"添加-未选中"] forState:UIControlStateNormal];
    
     Y =  CGRectGetMaxY(_fourthBtn.frame) +20;
    _fifthBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, Y, picWidth, picWidth)];
    _fifthBtn.tag=5;
    _fifthBtn.hidden = YES;
    [_backScrollerView addSubview:_fifthBtn];
    [_fifthBtn setBackgroundImage:[UIImage imageNamed:@"添加-未选中"] forState:UIControlStateNormal];
    
    [_firstBtn addTarget:self action:@selector(AddPic:) forControlEvents:UIControlEventTouchUpInside];
    [_secondBtn addTarget:self action:@selector(AddPic:) forControlEvents:UIControlEventTouchUpInside];
    [_thirdBtn addTarget:self action:@selector(AddPic:) forControlEvents:UIControlEventTouchUpInside];
    [_fourthBtn addTarget:self action:@selector(AddPic:) forControlEvents:UIControlEventTouchUpInside];
    [_fifthBtn addTarget:self action:@selector(AddPic:) forControlEvents:UIControlEventTouchUpInside];
    
    Y = CGRectGetMaxY(_firstBtn.frame)+20;//初始化为1个图片按钮
    
    [_backScrollerView setContentSize:CGSizeMake(SCREEN_WIDTH, Y)];
    
}
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
    }
    item[@"data"] = result;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_titleField resignFirstResponder];
    [_contentView resignFirstResponder];
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
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
        
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
        [param setObject:@"1" forKey:@"job.type"];
        [param setObject:_selectId forKey:@"jobTransfer.jobSignUser"];
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
