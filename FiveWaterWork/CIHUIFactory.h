//
//  CIHFactory.h
//  smartcar
//
//  Created by cihonMac on 13-12-17.
//  Copyright (c) 2013年 cihon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CIHUIFactory : NSObject

//创建导航栏按钮
+(UIBarButtonItem*)makeBarButtonItem:(CGRect)frame imageName:(NSString *)aImageName title:(NSString*)aTitle target:(id)aTarget action:(SEL)aMethod;

//创建一个ImageView
+(UIImageView *)makeImageView:(CGRect)frame imageName:(NSString*)aImageName;

//创建一个button，
+(UIButton*)makeButton:(CGRect)frame imageName:(NSString*)aImageName title:(NSString*)aTitle font:(float)aFont  backColor:(UIColor*)aBackColor  target:(id)aTarget action:(SEL)aMethod;
//创建一个label
+(UILabel*)makeLabel:(CGRect)frame text:(NSString*)aText textColor:(UIColor*)aColor font:(float)aFont backColor:(UIColor*)aBackColor alignment:(NSTextAlignment)aTextAlignment;

//创建一个带背景图片，或颜色背景的，UIView
+(UIView*)makeView:(CGRect)frame imageName:(NSString*)aImageName textColor:(UIColor*)
color;

//创建一个输入框
+(UITextField *) makeTextField:(CGRect)frame TextColor:(UIColor *)color textHolder:(NSString *)placeHolder keyBoardType:(UIKeyboardType)keyBoard clearBtn:(UITextFieldViewMode)clearBtnMode textFieldDelegate:(id<UITextFieldDelegate>)tDelegate;

//提示框
+(void)showMessage:(NSString*)message;

+(void)showMessage:(NSString*)title msg:(NSString*)message;


@end
