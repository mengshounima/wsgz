//
//  signInRecordCell.m
//  FiveWaterWork
//
//  Created by 李 燕琴 on 16/10/30.
//  Copyright © 2016年 aty. All rights reserved.
//

#import "signInRecordCell.h"
#import "Masonry.h"

@implementation signInRecordCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.font = [UIFont systemFontOfSize:14];
    _timeLabel.numberOfLines = 0;
    _timeLabel.text = @"签到时间";
    [self addSubview:_timeLabel];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@5);
        make.centerY.equalTo(self);
        make.height.greaterThanOrEqualTo(@30);
        make.width.equalTo(@(SCREEN_WIDTH/2-10));
    }];
    
    _addressLabel = [[UILabel alloc] init];
    _addressLabel.font = [UIFont systemFontOfSize:14];
    _addressLabel.numberOfLines = 0;
    _addressLabel.text = @"签到地点";
    [self addSubview:_addressLabel];
    [_addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.greaterThanOrEqualTo(@5);
        make.right.bottom.lessThanOrEqualTo(@(-5));
        make.height.greaterThanOrEqualTo(@30);
        make.width.equalTo(_timeLabel);
    }];
}
@end
