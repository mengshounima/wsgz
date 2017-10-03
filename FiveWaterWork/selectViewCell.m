//
//  selectViewCell.m
//  FiveWaterWork
//
//  Created by 李 燕琴 on 16/5/28.
//  Copyright © 2016年 aty. All rights reserved.
//

#import "selectViewCell.h"

@implementation selectViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

-(void)setupView{
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH-90, 40)];
    _nameLabel.textColor = [UIColor blackColor];
    [self addSubview:_nameLabel];
    
    _checkImageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"勾选-未选中"]];
    _checkImageV.frame = CGRectMake(SCREEN_WIDTH-80, 10, 20, 20);
    [self addSubview:_checkImageV];
}

-(void)updateCell:(NSString *)nameStr{
     _nameLabel.text = nameStr;
}

-(void)updateImage{
    _checkImageV.image = [UIImage imageNamed:@"勾选-选中"];
}
@end
