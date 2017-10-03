//
//  AddFeedbackViewController.m
//  FiveWaterWork
//
//  Created by 李 燕琴 on 16/11/12.
//  Copyright © 2016年 aty. All rights reserved.
//

#import "AddFeedbackViewController.h"
#import "Masonry.h"

#define WEAKSELF typeof(self) weakSelf = self;
#define STRONGSELF typeof(weakSelf) strongSelf = self;

@interface AddFeedbackViewController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate>

@property (nonatomic, strong) UITextField *contentTextField;

@property (nonatomic, strong) UIButton *imageButton;

@property (nonatomic, copy) NSString *JtID;

@property (nonatomic, strong) NSArray *imageDataArray;


@end

@implementation AddFeedbackViewController

#pragma lifecycle

- (instancetype)initWithJtID:(NSString *)ID {
    if (self = [super init]) {
        self.JtID = ID;
    }
    return self;
}

#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

- (void)setupView {
    self.title = @"意见反馈";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(finish:)];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"内容:";
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.width.equalTo(@45);
        make.top.equalTo(self.mas_topLayoutGuide).offset(20);
    }];
    
    _contentTextField = [[UITextField alloc] init];
    _contentTextField.layer.cornerRadius = 5;
    _contentTextField.layer.borderWidth = 0.5;
    _contentTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.view addSubview:_contentTextField];
    [_contentTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLabel.mas_right).offset(10);
        make.right.equalTo(@(-10));
        make.bottom.equalTo(titleLabel);
        make.height.equalTo(@30);
    }];
    
    _imageButton = [[UIButton alloc] init];
    [_imageButton setBackgroundImage:[UIImage imageNamed:@"添加-未选中"] forState:UIControlStateNormal];
    [self.view addSubview:_imageButton];
    [_imageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLabel);
        make.top.equalTo(titleLabel.mas_bottom).offset(20);
        make.width.height.equalTo(@120);
    }];
    [_imageButton addTarget:self action:@selector(addPicture:) forControlEvents:UIControlEventTouchUpInside];
}

    
#pragma mark - user interface

- (void)finish:(UIBarButtonItem *)barButton {
    [_contentTextField resignFirstResponder];
    if (ISNULLSTR(_contentTextField.text)) {
        [SVProgressHUD showErrorWithStatus:@"反馈内容不能为空"];
        return;
    }
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    //转发记录id
    [param setObject:_JtID forKey:@"jobTransfer.id"];
    [param setObject:_contentTextField.text forKey:@"jobTransfer.idea"];
    [SVProgressHUD show];
    WEAKSELF
    [[HttpClient httpClient] requestOperaionManageWithURl:@"/done.action" httpMethod:TBHttpRequestPost parameters:param bodyData:_imageDataArray DataNumber:_imageDataArray.count success:^(NSURLSessionDataTask *task, id responseObject) {
        
        STRONGSELF
        NSNumber *result = [responseObject objectForKey:@"success"];
        if (result.boolValue) {
            [SVProgressHUD dismiss];
            [strongSelf.navigationController popToRootViewControllerAnimated:NO];
            //发通知，刷新列表
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AddFeedbackCompletion" object:nil];
            
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"message"]];
        }

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.userInfo[@"name"]];
    }];
}

- (void)addPicture:(UIButton *)button {
    [_contentTextField resignFirstResponder];
  
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
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType = sourceType;
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
        [_imageButton setImage:image forState:UIControlStateNormal];
        
        NSData *data;
        data = UIImageJPEGRepresentation(image, 0.5);
        _imageDataArray = [NSArray arrayWithObject:data];
     }];
     
}


@end
