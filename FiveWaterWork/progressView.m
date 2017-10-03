//
//  progressVIew.m
//  FiveWaterWork
//
//  Created by 李 燕琴 on 16/11/13.
//  Copyright © 2016年 aty. All rights reserved.
//

#import "progressView.h"
#import "Masonry.h"

@implementation progressView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 1;
        [self setupView];
    }
    return self;
}

- (void)setupView {
    
    
    _leftTitleLabel = [[UILabel alloc] init];
    _leftTitleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_leftTitleLabel];
    [_leftTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self);
        make.height.equalTo(@30);
        make.width.equalTo(@((SCREEN_WIDTH-40)/2));
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor blackColor];
    [self addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@1);
        make.left.equalTo(_leftTitleLabel.mas_right);
        make.top.bottom.equalTo(_leftTitleLabel);
    }];
    
    _rightTitleLabel = [[UILabel alloc] init];
    _rightTitleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_rightTitleLabel];
    [_rightTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.top.equalTo(self);
        make.left.equalTo(_leftTitleLabel.mas_right);
        make.height.equalTo(@30);
        make.width.equalTo(_leftTitleLabel);
    }];

}

@end
