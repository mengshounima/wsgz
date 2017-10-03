//
//  replyCell.h
//  FiveWaterWork
//
//  Created by 李 燕琴 on 16/5/10.
//  Copyright © 2016年 aty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface replyCell : UITableViewCell

@property (nonatomic ,strong) NSDictionary *replyDic;
@property (nonatomic ,strong) UILabel *nameLabel;
@property (nonatomic ,strong) UILabel *dateLabel;
@property (nonatomic ,strong) UILabel *contentLabel;

-(void)updateWithReplyDic:(NSDictionary *)replyDic;

@end
