//
//  LoginVC.m
//  FiveWaterWork
//
//  Created by aiteyuan on 16/1/25.
//  Copyright © 2016年 aty. All rights reserved.
//

#import "LoginVC.h"
#import "Masonry.h"

@interface LoginVC ()<UITextFieldDelegate>
{
    UIView *nameView;
    UIView *passwdView;
    BOOL _tipsStr;
}
@property (strong,nonatomic) UIButton *rememberBtn;
@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initview];
}

- (void)initview
{
    self.view.backgroundColor = choiceColor(22, 64, 104);
    UIImageView *iconImageView = [[UIImageView alloc] init];
    iconImageView.frame = CGRectMake((SCREEN_WIDTH-110)/2, 40, 110, 110);
    iconImageView.image = [UIImage imageNamed:@"五水共治-透明_220"];
    [self.view addSubview:iconImageView];
    
    
    float Y = CGRectGetMaxY(iconImageView.frame);
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, Y+20, SCREEN_WIDTH, 30);
    label.text = @"潮乡智慧河长";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:30];
    [self.view addSubview:label];
    
    Y = CGRectGetMaxY(label.frame);
    UIView *Bigview = [[UIView alloc] initWithFrame:CGRectMake(20, Y+20, SCREEN_WIDTH-40, 140)];
    Bigview.backgroundColor = [UIColor whiteColor];
    Bigview.layer.cornerRadius = 8;
    [self.view addSubview:Bigview];
    // 用户名View
    nameView = [[UIView alloc] initWithFrame:CGRectMake(20, Y+20, SCREEN_WIDTH-40, 70)];
    nameView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:nameView];
    
    UILabel *userNamelabel = [[UILabel alloc] init];
    userNamelabel.frame = CGRectMake(10, 20, 60, 30);
    userNamelabel.text = @"用户名:";
    [nameView addSubview:userNamelabel];
    
    _userNameField = [[UITextField alloc] initWithFrame:CGRectMake(80, 20, SCREEN_WIDTH-10-80, 30)];
    _userNameField.backgroundColor = [UIColor clearColor];
    _userNameField.font = [UIFont boldSystemFontOfSize:16];
    UIColor *color = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.8];
    _userNameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入用户账号" attributes:@{NSForegroundColorAttributeName:color }];
    _userNameField.delegate = self;
    _userNameField.tag = 0;
    [nameView addSubview:_userNameField];
    
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, 70, SCREEN_WIDTH-60, 1)];
    line.backgroundColor = [UIColor lightGrayColor];
    [Bigview addSubview:line];
    
    // 密码View
    CGFloat passwdViewY = CGRectGetMaxY(nameView.frame);
    passwdView = [[UIView alloc] initWithFrame:CGRectMake(20, passwdViewY, SCREEN_WIDTH-40, 70)];
    passwdView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:passwdView];
    
    UILabel *userPasswdlabel = [[UILabel alloc] init];
    userPasswdlabel.frame = CGRectMake(10, 20, 60, 30);
    userPasswdlabel.text = @"密码:";
    [passwdView addSubview:userPasswdlabel];
    
    _passWordField = [[UITextField alloc] initWithFrame:CGRectMake(80, 20, SCREEN_WIDTH-10-80, 30)];
    _passWordField.backgroundColor = [UIColor clearColor];
    _passWordField.font = [UIFont boldSystemFontOfSize:16];
    [_passWordField setSecureTextEntry:YES];
    //设置placeholder属性
    _passWordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入用户密码" attributes:@{NSForegroundColorAttributeName:color }];
    [passwdView addSubview:_passWordField];
    _passWordField.delegate = self;
    _passWordField.tag = 1;
    
    CGFloat loginButtonY = CGRectGetMaxY(passwdView.frame) + 28;
    //记住密码
    _rememberBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, loginButtonY, 120, 40)];
    [_rememberBtn setTitle:@"记住密码" forState:UIControlStateNormal];
    [_rememberBtn setImage:[UIImage imageNamed:@"勾选-未选中"] forState:UIControlStateNormal];
    [_rememberBtn setImage:[UIImage imageNamed:@"勾选-选中"] forState:UIControlStateSelected];
    [_rememberBtn addTarget:self action:@selector(rememberedPass:) forControlEvents:UIControlEventTouchUpInside];
    _rememberBtn.selected = YES;
    [self.view addSubview:_rememberBtn];
    
    
    // 登录按钮
    
    _loginButton = [[UIButton alloc] initWithFrame:CGRectMake(140, loginButtonY, SCREEN_WIDTH-140-20, 40)];
    [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [_loginButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_loginButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [_loginButton setBackgroundColor:[UIColor whiteColor]];
    _loginButton.layer.cornerRadius = 6;
    _loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [_loginButton addTarget:self action:@selector(loginBtnAticon:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loginButton];
    
    NSNumber *isRemenberNum =  [[NSUserDefaults standardUserDefaults] objectForKey:@"IsRemember"];
    if (isRemenberNum.boolValue) {
        _userNameField.text = [[UserInfo sharedInstance] ReadData].userLoginName;
        _passWordField.text = [[UserInfo sharedInstance] ReadData].userPassword;
    }
    
}

-(void)rememberedPass:(UIButton *)button{
    button.selected = !button.selected;
    
}

-(void)loginBtnAticon:(id)sender
{
    [SVProgressHUD showInfoWithStatus:@"登录中"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_userNameField.text forKey:@"user.loginName"];//传string类型
    [param setObject:_passWordField.text forKey:@"user.password"];//传string类型
    [param setObject:@"1" forKey:@"isMobile"];

    [[HttpClient httpClient] requestWithPath:@"/login.action" method:TBHttpRequestPost parameters:param prepareExecute:nil success:^(NSURLSessionDataTask *task, id responseObject) {

        NSNumber *successNum = [responseObject objectForKey:@"success"];
        if (successNum.boolValue) {
            [SVProgressHUD dismiss];
            if (_rememberBtn.selected) {
                //记住密码
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"IsRemember"];
            }

            NSDictionary *userDataDic = [responseObject objectForKey:@"data"];
            NSMutableDictionary *dicMut = [NSMutableDictionary dictionaryWithDictionary:userDataDic];
            if (!ISNULL(_passWordField.text)) {
                [dicMut setObject:_passWordField.text forKey:@"password"];
                userDataDic = [dicMut copy];
            }
            NSLog(@"返回的登录信息：%@",userDataDic);
            [[UserInfo sharedInstance] writeData:userDataDic];
                LYQTabBarController *tabbar = [[LYQTabBarController alloc]init];
                [self presentViewController:tabbar animated:YES completion:^{
                }];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"message"]];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.userInfo[@"name"]];;
    }];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [_userNameField resignFirstResponder];
    [_passWordField resignFirstResponder];
}

@end
