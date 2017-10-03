//
//  NoticeCell.m
//  FiveWaterWork
//
//  Created by 李 燕琴 on 16/11/27.
//  Copyright © 2016年 aty. All rights reserved.
//

#import "NoticeCell.h"
#import "Masonry.h"

@implementation NoticeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    _imageV = [[UIImageView alloc] init];
    [self addSubview:_imageV];
    [_imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
        make.width.equalTo(@(SCREEN_WIDTH));
        make.height.equalTo(@(SCREEN_WIDTH*0.7));
    }];
}


@end
