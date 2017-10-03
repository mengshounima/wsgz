//
//  selectViewCell.h
//  FiveWaterWork
//
//  Created by 李 燕琴 on 16/5/28.
//  Copyright © 2016年 aty. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface selectViewCell : UITableViewCell

@property (nonatomic,strong) UILabel *nameLabel;

@property (nonatomic,strong) UIImageView *checkImageV;

-(void)updateCell:(NSString *)nameStr;

-(void)updateImage;
@end
