//
//  settingTableVC.m
//  FiveWaterWork
//
//  Created by 李 燕琴 on 16/5/8.
//  Copyright © 2016年 aty. All rights reserved.
//

#import "settingTableVC.h"
#import "modifyPasswordView.h"
#import "UIImageView+WebCache.h"

#define WEAKSELF typeof(self) weakSelf = self;
#define STRONGSELF typeof(weakSelf) strongSelf = self;

@interface settingTableVC ()<modifyPasswordViewDelegate>
@property (strong, nonatomic) UIView *backView;
@property (strong, nonatomic) modifyPasswordView *modifyView;
@property (strong, nonatomic) NSDictionary *resultDictionary;

@end

@implementation settingTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self getData];
}

-(void)getData{
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setObject:[[UserInfo sharedInstance] ReadData].userID forKey:@"user.id"];
    [param setObject:[NSString stringWithFormat:@"1"] forKey:@"isMobile"];
    [param setObject:[[UserInfo sharedInstance] ReadData].userID forKey:@"sysUserId"];
    
    WEAKSELF
    [[HttpClient httpClient] requestWithPath:@"/settingView.action" method:TBHttpRequestPost parameters:param prepareExecute:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        STRONGSELF
        NSNumber *successNum = [responseObject objectForKey:@"success"];
        if (successNum.boolValue) {
            NSDictionary *dic = [responseObject objectForKey:@"data"];
            if (!ISNULL(dic)) {
                strongSelf.resultDictionary = dic;
                [strongSelf.tableView reloadData];
            }
        }else{
            [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"message"]];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.userInfo[@"name"]];;
    }];
}

#pragma mark - Table view datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"setVCIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    if (indexPath.row==0) {
        cell.textLabel.text = @"用户名";
        cell.detailTextLabel.text = [[UserInfo sharedInstance] ReadData].userName;
    }
    
    else if (indexPath.row==1) {
        cell.textLabel.text = @"工单数量";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",_resultDictionary[@"job"]];
    }
    else if (indexPath.row==2) {
        cell.textLabel.text = @"话题数量";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",_resultDictionary[@"topic"]];
    }
    else{
        cell.textLabel.text = @"修改密码";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Tableview Delagate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==3) {
        //修改密码
        if (_backView == nil) {
            _backView = [[UIView alloc] init];
            _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
            _backView.frame = [UIScreen mainScreen].bounds;
        }
        
        if (_modifyView == nil) {
            _modifyView = [modifyPasswordView modifyPasswordViewMethod];
            _modifyView.delegate = self;
            _modifyView.frame = CGRectMake(0, SCREEN_HEIGHT, 0, 0);
        }
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:_backView];//加上第一个蒙版
        [window addSubview:_modifyView];
        [UIView animateWithDuration:0.3 animations:^{
            _modifyView.frame = CGRectMake(0, 0, 0, 0);
            _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.35];
        } completion:^(BOOL finished) {
        }];

    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return 150;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 200)];
//    
//    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, SCREEN_WIDTH, 30)];
//    titleLabel.font = [UIFont systemFontOfSize:17];
//    titleLabel.textAlignment = NSTextAlignmentCenter;
//    titleLabel.text = @"扫描下载APP";
//    [footerView addSubview:titleLabel];
//    float Y = CGRectGetMaxY(titleLabel.frame);
//    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-150)/2, Y+10, 150, 150)];
//    NSString *url = [NSString stringWithFormat:@"%@%@",BASEURlSTR,_resultDictionary[@"url"]];
//    
//    [imageView sd_setImageWithURL:[NSURL URLWithString:url]];
//    [footerView addSubview:imageView];
//    return footerView;
//    
//}

#pragma mark - AlterPasswordDelegate

- (void)resureAleterPasswordWithOldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword
{
    [self editPasswordWith:oldPassword new:newPassword];
}

//修改密码
- (void)editPasswordWith:(NSString *)old new:(NSString *)new
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:[[UserInfo sharedInstance] ReadData].userID forKey:@"user.id"];
    [param setObject:old forKey:@"user.password"];
    [param setObject:new forKey:@"newPass"];
    
    [param setObject:[NSString stringWithFormat:@"1"] forKey:@"isMobile"];
    [param setObject:[[UserInfo sharedInstance] ReadData].userID forKey:@"sysUserId"];
    [SVProgressHUD show];
    [[HttpClient httpClient] requestWithPath:@"/updatePassword.action" method:TBHttpRequestPost parameters:param prepareExecute:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSNumber *successNum = [responseObject objectForKey:@"success"];
        if (successNum.boolValue) {
            [SVProgressHUD showSuccessWithStatus:@"修改成功，重新登录后有效"];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"message"]];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.userInfo[@"name"]];;
    }];

}

- (void)PasswordViewCancel
{
    [UIView animateWithDuration:0.3 animations:^{
        _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        
    } completion:^(BOOL finished) {
        [_backView removeFromSuperview];
    }];
}

@end
