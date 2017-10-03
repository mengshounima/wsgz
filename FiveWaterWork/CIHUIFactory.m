//
//  CIHFactory.m
//  smartcar
//
//  Created by cihonMac on 13-12-17.
//  Copyright (c) 2013年 cihon. All rights reserved.
//

#import "CIHUIFactory.h"

@implementation CIHUIFactory

+(UIBarButtonItem*)makeBarButtonItem:(CGRect)frame imageName:(NSString *)aImageName title:(NSString*)aTitle target:(id)aTarget action:(SEL)aMethod
{
    UIButton *btn =  [self makeButton:frame imageName:aImageName title:aTitle font:15 backColor:nil target:aTarget action:aMethod];
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    return [barBtn autorelease];
}

+(UIButton*)makeButton:(CGRect)frame imageName:(NSString*)aImageName title:(NSString*)aTitle font:(float)aFont  backColor:(UIColor*)aBackColor  target:(id)aTarget action:(SEL)aMethod
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame ;
    btn.backgroundColor = aBackColor;
    btn.titleLabel.font = [UIFont systemFontOfSize:aFont];
    [btn setTitle:aTitle forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:aImageName] forState:UIControlStateNormal];
    [btn addTarget:aTarget action:aMethod forControlEvents:UIControlEventTouchUpInside];
    return  btn;
}

+(UIImageView *)makeImageView:(CGRect)frame imageName:(NSString*)aImageName
{
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.userInteractionEnabled = YES;
    [imageView setImage:[UIImage imageNamed:aImageName]];
    return [imageView autorelease];
}
+(UILabel*)makeLabel:(CGRect)frame text:(NSString*)aText textColor:(UIColor*)aColor font:(float)aFont backColor:(UIColor*)aBackColor alignment:(NSTextAlignment)aTextAlignment
{
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    label.text = aText;
    label.textAlignment = aTextAlignment;
    label.backgroundColor = aBackColor;
    label.textColor = aColor;
    label.font = [UIFont systemFontOfSize:aFont];
    return [label autorelease];
}

+(UIView*)makeView:(CGRect)frame imageName:(NSString*)aImageName textColor:(UIColor*)
color
{
    UIImageView *imageView = [self makeImageView:CGRectMake(0, 0, frame.size.width, frame.size.height) imageName:aImageName];
    UIView *view = [[UIView alloc]initWithFrame:frame];
    view.backgroundColor = color;
    [view addSubview:imageView];
    return [view autorelease];
}

+(UITextField *) makeTextField:(CGRect)frame TextColor:(UIColor *)color textHolder:(NSString *)placeHolder keyBoardType:(UIKeyboardType)keyBoard clearBtn:(UITextFieldViewMode)clearBtnMode textFieldDelegate:(id<UITextFieldDelegate>)tDelegate;
{
    UITextField *text = [[UITextField alloc] initWithFrame:frame];
    text.delegate = tDelegate;
    text.placeholder = placeHolder;
    text.borderStyle = UITextBorderStyleNone;
    text.keyboardType = keyBoard;
    text.clearButtonMode = clearBtnMode;
    text.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:@"login_text_bg.png"]];
    text.textColor = color;
    text.textAlignment = NSTextAlignmentCenter;
    text.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    text.returnKeyType = UIReturnKeyDone;
    return [text autorelease];
}

+(void)showMessage:(NSString*)message
{
    [UIAlertView showAlertWithTitle:nil message:message customizationBlock:nil completionBlock:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
}
+(void)showMessage:(NSString*)title msg:(NSString*)message
{
     [UIAlertView showAlertWithTitle:title message:message customizationBlock:nil completionBlock:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
}


@end
