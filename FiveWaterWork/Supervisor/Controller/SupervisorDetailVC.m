//
//  SupervisorDetailVC.m
//  FiveWaterWork
//
//  Created by 李 燕琴 on 2017/10/4.
//  Copyright © 2017年 aty. All rights reserved.
//

#import "SupervisorDetailVC.h"
#import <Masonry/Masonry.h>
#import <RadioButton/RadioButton.h>

@interface SupervisorDetailVC ()

@property (nonatomic, strong) NSArray *items;

@property (nonatomic, strong) NSDictionary *detailData;

@property (nonatomic, strong) NSArray *statusArray;

@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation SupervisorDetailVC

- (instancetype)initWithDetailData:(NSDictionary *)detailData {
    if (self = [super init]) {
        _detailData = detailData;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"督导详情";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确认修改状态" style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"SupervisorDetail" ofType:@"plist"];
    self.items = [NSArray arrayWithContentsOfFile:path];
    [self setupView];
}

- (void)setupView {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.scrollEnabled = YES;
    scrollView.showsVerticalScrollIndicator = YES;
    [self.view addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    UIView *contentView = [[UIView alloc] init];
    [scrollView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(scrollView);
        make.bottom.mas_equalTo(-20);
        make.width.mas_equalTo(SCREEN_WIDTH);
    }];
    
    UIView *lastLabel;
    for (NSDictionary *item in _items) {
        UILabel *itemLabel = [[UILabel alloc] init];
        itemLabel.textColor = [UIColor blackColor];
        itemLabel.font = [UIFont systemFontOfSize:14];
        itemLabel.textAlignment = NSTextAlignmentLeft;
        itemLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 40;
        [contentView addSubview:itemLabel];
        
        if ([item[@"type"] isEqualToString:@"radio"]) {
            //单选控件
            [itemLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(20);
            }];
            
            itemLabel.text = [NSString stringWithFormat:@"%@: ",item[@"title"]];
            
            UIView *containerView = [[UIView alloc] init];
            containerView.userInteractionEnabled = YES;
            [contentView addSubview:containerView];
            [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(itemLabel);
                make.top.equalTo(lastLabel.mas_bottom).offset(20);
                make.left.equalTo(itemLabel.mas_right).offset(20);
                make.right.equalTo(contentView);
            }];
            
            NSMutableArray* buttons = [NSMutableArray arrayWithCapacity:self.statusArray.count];
        
            RadioButton *lastButton;
            for (int i = 0; i<self.statusArray.count; i++) {
                NSString *optionTitle = self.statusArray[i];
                RadioButton* btn = [[RadioButton alloc] init];

                [btn setTitle:optionTitle forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
                btn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
                [btn setImage:[UIImage imageNamed:@"勾选-未选中"] forState:UIControlStateNormal];
                [btn setImage:[UIImage imageNamed:@"勾选-选中"] forState:UIControlStateSelected];
                btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                btn.tag = i;
                [btn addTarget:self action:@selector(radioButtonChange:) forControlEvents:UIControlEventTouchUpInside];
                [containerView addSubview:btn];
                [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(30);
                    make.width.mas_equalTo(100);
                    make.left.equalTo(containerView);
                    if (lastButton) {
                        make.top.equalTo(lastButton.mas_bottom).offset(5);
                    }else {
                        make.top.equalTo(containerView);
                    }
                }];
                lastButton = btn;
                [buttons addObject:btn];
            }
            
            [lastButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(containerView);
            }];
            
            [buttons[0] setGroupButtons:buttons];
            _selectedIndex = 0;
            //默认已选
            NSNumber *status = _detailData[item[@"key"]];
            if ([status.stringValue isEqualToString:@"0"]) {
                [buttons[0] setSelected:YES];
            }else if ([status.stringValue isEqualToString:@"1"]) {
                [buttons[1] setSelected:YES];
            }else if ([status.stringValue isEqualToString:@"2"]) {
                [buttons[2] setSelected:YES];
            }else if ([status.stringValue isEqualToString:@"3"]) {
                [buttons[3] setSelected:YES];
            }else {
                [buttons[4] setSelected:YES];
            }
            
            lastLabel = containerView;

        }else {
            [itemLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(20);
                make.height.mas_lessThanOrEqualTo(100);
                make.right.mas_equalTo(-20);
                if (lastLabel) {
                    make.top.equalTo(lastLabel.mas_bottom).offset(20);
                }else {
                    make.top.equalTo(self.mas_topLayoutGuide).offset(20);
                }
            }];
            
            NSString *content = [self configureContentWithItem:item];
            
            itemLabel.text = [NSString stringWithFormat:@"%@: %@",item[@"title"],content];
            lastLabel = itemLabel;
        }
        
    }
    
    [lastLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(contentView);
    }];
}

- (NSString *)configureContentWithItem:(NSDictionary *)item {
    if ([item[@"key"] isEqualToString:@"supervisionresource"]) {
        NSNumber *supervisionresource = _detailData[item[@"key"]];
        if ([supervisionresource.stringValue isEqualToString:@"1"]) {
            return @"巡查人员";
        }else {
            return @"领导批示";
        }
    }else {
        return _detailData[item[@"key"]];
    }
}

//确定修改状态
- (void)done {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    param[@"isMobile"] = @"1";
    param[@"steeringFeedbackId"] = _detailData[@"id"];
    param[@"status"] = @(_selectedIndex);
    
    [SVProgressHUD show];
    __weak typeof(self) weakSelf = self;
    [[HttpClient httpClient] requestWithPath:@"/updateSteeringFeedback.action" method:TBHttpRequestPost parameters:param prepareExecute:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [SVProgressHUD showSuccessWithStatus:@"修改成功"];
        if (weakSelf.completion) {
            weakSelf.completion(nil);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD dismiss];
        if (error.userInfo[@"name"]) {
            [SVProgressHUD showErrorWithStatus:error.userInfo[@"name"]];
        }
    }];
}

- (void)radioButtonChange:(RadioButton *)button {
    _selectedIndex = button.tag;
}

- (NSArray *)statusArray {
    if (!_statusArray) {
        _statusArray = @[@"未下发",@"已下发",@"处理中",@"已整改",@"已关闭"];
    }
    return _statusArray;
}


@end
