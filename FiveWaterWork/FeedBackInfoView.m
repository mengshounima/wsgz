//
//  FeedBackInfoView.m
//  FiveWaterWork
//
//  Created by 李 燕琴 on 16/11/12.
//  Copyright © 2016年 aty. All rights reserved.
//

#import "FeedBackInfoView.h"
#import "Masonry.h"

@implementation FeedBackInfoView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(SCREEN_WIDTH-40));
            make.height.equalTo(@(SCREEN_HEIGHT*0.6));
        }];
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.layer.cornerRadius = 8;
    self.backgroundColor = [UIColor whiteColor];
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    [self addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(SCREEN_WIDTH-40));
        make.edges.equalTo(scrollView);
    }];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:17];
    titleLabel.text = @"反馈信息";
    [contentView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView).offset(10);
        make.centerX.equalTo(contentView);
    }];
    
    _contentLabel = [[UILabel alloc] init];
    _contentLabel.numberOfLines = 0;
    [contentView addSubview:_contentLabel];
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.top.equalTo(titleLabel.mas_bottom).offset(20);
        make.right.lessThanOrEqualTo(@(-20));
    }];
    
    _imageView = [[UIImageView alloc] init];
    [contentView addSubview:_imageView];
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_contentLabel.mas_bottom).offset(20);
        make.left.equalTo(@40);
        make.right.equalTo(@(-40));
        make.height.equalTo(_imageView.mas_width);
    }];
    
    UIButton *closeButton = [[UIButton alloc] init];
    closeButton.clipsToBounds = YES;
    closeButton.layer.cornerRadius = 6;
    [closeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    closeButton.backgroundColor = [UIColor lightGrayColor];
    [closeButton setTitle:@"确定" forState:UIControlStateNormal];
    [contentView addSubview:closeButton];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_imageView.mas_bottom).offset(10);
        make.left.equalTo(@20);
        make.bottom.right.equalTo(@(-20));
        make.height.equalTo(@40);
    }];
    [closeButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)close:(UIButton *)button {
    [self hide];
}

@end
