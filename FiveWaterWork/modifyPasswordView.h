//
//  modifyPasswordView.h
//  WHTPWorkManager
//
//  Created by aiteyuan on 15/9/2.
//  Copyright (c) 2015年 ËâæÁâπËøú. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol modifyPasswordViewDelegate <NSObject>

- (void)PasswordViewCancel;
- (void)resureAleterPasswordWithOldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword;

@end
@interface modifyPasswordView : UIView

@property (strong, nonatomic) IBOutlet UITextField *oldPasswordField;
@property (nonatomic,weak)id<modifyPasswordViewDelegate>delegate;

@property (strong, nonatomic) IBOutlet UITextField *NewPasswordField;

@property (strong, nonatomic) IBOutlet UITextField *repeatPasswordField;
+ (instancetype)modifyPasswordViewMethod;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet UIButton *OKBtn;
@property (strong, nonatomic) IBOutlet UIButton *CancelBtn;
- (IBAction)clickOK;
- (IBAction)clickCancel;

@end
