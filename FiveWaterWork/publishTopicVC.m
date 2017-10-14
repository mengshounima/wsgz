//
//  publishTopicVC.m
//  FiveWaterWork
//
//  Created by 李 燕琴 on 16/5/8.
//  Copyright © 2016年 aty. All rights reserved.
//

#import "publishTopicVC.h"

@interface publishTopicVC ()
@property (nonatomic,strong) UITextField *titleField;
@property (nonatomic,strong) UITextView *contentField;
@property (nonatomic,strong) UITapGestureRecognizer *tap;
@property (nonatomic,strong) UILabel *placeHolderLabel;
@end

@implementation publishTopicVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerForKeyboardNotifications];
    self.title = @"话题发布";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(send)];
    
    _titleField  = [[UITextField alloc] initWithFrame:CGRectMake(10, 84, SCREEN_WIDTH-20, 30)];
    [self.view addSubview:_titleField];
    _titleField.layer.cornerRadius = 6;
    _titleField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _titleField.layer.borderWidth = 1;
    _titleField.placeholder = @"请输入标题";
    
    float Y = CGRectGetMaxY(_titleField.frame)+10;
    _contentField = [[UITextView alloc] initWithFrame:CGRectMake(10, Y, SCREEN_WIDTH-20, SCREEN_HEIGHT-Y-10)];
 
    _contentField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _contentField.layer.borderWidth = 1;
    _contentField.layer.cornerRadius = 6;
    _contentField.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:_contentField];
    
    //其次在UITextView上面覆盖个UILable,UILable设置为全局变量。
    _placeHolderLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, Y, SCREEN_WIDTH-20, 32)];
    _placeHolderLabel.text = @"请输入详细内容...";
    _placeHolderLabel.enabled = NO;//lable必须设置为不可用
    _placeHolderLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_placeHolderLabel];
    
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickUIView)];

}


-(void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length == 0) {
        _placeHolderLabel.text = @"请输入详细内容...";
    }else{
        _placeHolderLabel.text = @"";
    }
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    // 1. 取出键盘弹出的动画时间
    CGFloat KybSecond = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // 取出键盘的Frame
    CGRect keyboardF = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // 执行动画
    [UIView animateWithDuration:KybSecond animations:^{
        
        CGFloat contentViewH = keyboardF.origin.y - _contentField.frame.origin.y - 10;
        
        CGRect contentViewRect = CGRectMake(_contentField.frame.origin.x, _contentField.frame.origin.y, _contentField.frame.size.width, contentViewH);
        
        _contentField.frame = contentViewRect;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    
    // 1. 取出键盘弹出的动画时间
    CGFloat KybSecond = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // 3. 执行动画
    [UIView animateWithDuration:KybSecond animations:^
     {
         CGRect contentViewRect = CGRectMake(_contentField.frame.origin.x, _contentField.frame.origin.y, _contentField.frame.size.width, SCREEN_HEIGHT-_contentField.frame.origin.y-10);
         _contentField.frame = contentViewRect;
     }];
}


//新建话题
-(void)send{
    if (ISNULLSTR(_titleField.text)||ISNULLSTR(_contentField.text)) {
        [SVProgressHUD showErrorWithStatus:@"信息填写不完整"];
        return;
    }
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setObject:_titleField.text forKey:@"topic.title"];
    [param setObject:_contentField.text forKey:@"topic.content"];
    [param setObject:[[UserInfo sharedInstance] ReadData].userID forKey:@"topic.createUser"];
    [param setObject:[NSString stringWithFormat:@"1"] forKey:@"isMobile"];
    [SVProgressHUD showWithStatus:@"发布中"];
    
    [[HttpClient httpClient] requestWithPath:@"/saveTopic.action" method:TBHttpRequestPost parameters:param prepareExecute:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSNumber *result = [responseObject objectForKey:@"success"];
        if (result.boolValue) {
            [SVProgressHUD showSuccessWithStatus:@"发布成功"];
            [self publishTopicSuccess];
                   }
        else
        {
            [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"message"]];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {

        [SVProgressHUD showErrorWithStatus:error.userInfo[@"name"]];;
    }];

}

-(void)publishTopicSuccess{
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate publishSuccessed];
}


//隐藏键盘
-(void)clickUIView{
    [_contentField resignFirstResponder];
}
-(void)addTap{
    [self.view addGestureRecognizer:_tap];
}
-(void)removeTap{
    [self.view removeGestureRecognizer:_tap];
    
}


-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addTap) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeTap) name:UIKeyboardDidHideNotification object:nil];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}


@end
