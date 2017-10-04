//
//  ProjectPlanCell.m
//  FiveWaterWork
//
//  Created by 李 燕琴 on 2017/10/3.
//  Copyright © 2017年 aty. All rights reserved.
//

#import "ProjectPlanCell.h"
#import <Masonry/Masonry.h>

@implementation ProjectPlanCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.centerY.equalTo(self.contentView);
        make.width.mas_equalTo(150);
    }];
    
    _dateLabel = [[UILabel alloc] init];
    _dateLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_dateLabel];
    [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(180);
        make.centerY.equalTo(self.contentView);
    }];
    
    _moneyLabel = [[UILabel alloc] init];
    _moneyLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_moneyLabel];
    [_moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_dateLabel.mas_right);
        make.right.mas_equalTo(-20);
        make.centerY.equalTo(self.contentView);
        make.width.equalTo(_dateLabel.mas_width);
    }];
}

@end
