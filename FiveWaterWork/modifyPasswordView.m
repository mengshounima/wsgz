//
//  modifyPasswordView.m
//  WHTPWorkManager
//
//  Created by aiteyuan on 15/9/2.
//  Copyright (c) 2015年 ËâæÁâπËøú. All rights reserved.
//

#import "modifyPasswordView.h"

@implementation modifyPasswordView

+ (instancetype)modifyPasswordViewMethod
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"modifyPasswordView" owner:nil options:nil];
    return [nib lastObject];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _backView.layer.cornerRadius = 6;
    _OKBtn.layer.cornerRadius = 6;
    [_OKBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    _CancelBtn.layer.cornerRadius = 6;
    [_CancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    _oldPasswordField.secureTextEntry = YES;
    _NewPasswordField.secureTextEntry = YES;
    _repeatPasswordField.secureTextEntry = YES;
    
}
//点击背景立即消失
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    UIView *touchView = touch.view;
    if (touchView.tag == 2008) {
        [self dismisself];
    }
}

- (void)dismisself
{
    if ([self.delegate respondsToSelector:@selector(PasswordViewCancel)]) {
        [self.delegate PasswordViewCancel];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, self.height, 0, 0);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.width = SCREEN_WIDTH;
    self.height = SCREEN_HEIGHT;
}

- (IBAction)clickOK {
    [self dismisself];
    NSString *oldPasswordStr = _oldPasswordField.text;
    NSString *trimoldPasswordStr = [oldPasswordStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    _oldPasswordField.text = trimoldPasswordStr;
    if (ISNULLSTR(trimoldPasswordStr)) {
        [SVProgressHUD showErrorWithStatus:@"原密码不能为空!"];
        return;
    }
    
    
    NSString *newPasswordStr = _NewPasswordField.text;
    NSString *trimnewPasswordStr = [newPasswordStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    _NewPasswordField.text = trimnewPasswordStr;
    if (ISNULLSTR(trimnewPasswordStr)) {
        [SVProgressHUD showErrorWithStatus:@"新密码不能为空!"];
        return;
    }
    
    NSString *rerepeatPasswordStr = _repeatPasswordField.text;
    NSString *trimRepeatPasswordStrStr = [rerepeatPasswordStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    _repeatPasswordField.text = trimRepeatPasswordStrStr;
    if (ISNULLSTR(trimRepeatPasswordStrStr)) {
        [SVProgressHUD showErrorWithStatus:@"确认密码不能为空!"];
        return;
    }
    
    if (![trimnewPasswordStr isEqualToString:trimRepeatPasswordStrStr]) {
        [SVProgressHUD showErrorWithStatus:@"两次输入的密码不一致!"];
        return;
    }
    [_delegate resureAleterPasswordWithOldPassword:_oldPasswordField.text newPassword:_NewPasswordField.text];
    
}

- (IBAction)clickCancel {
     [self dismisself];
}
@end
