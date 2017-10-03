//
//  replyCell.m
//  FiveWaterWork
//
//  Created by 李 燕琴 on 16/5/10.
//  Copyright © 2016年 aty. All rights reserved.
//

#import "replyCell.h"

@implementation replyCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupsubViews];
    }
    return  self;
}

-(void)setupsubViews{
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, (SCREEN_WIDTH-20)/2, 20)];
    _nameLabel.textColor = [UIColor lightGrayColor];
    _nameLabel.font = [UIFont systemFontOfSize:12];
    _nameLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_nameLabel];
    
    _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, 20, (SCREEN_WIDTH-20)/2, 20)];
    _dateLabel.textColor = [UIColor lightGrayColor];
    _dateLabel.font = [UIFont systemFontOfSize:12];
    _dateLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_dateLabel];

    float Y = CGRectGetMaxY(_nameLabel.frame);
    _contentLabel = [[UILabel alloc] init];
    _contentLabel.numberOfLines = 0;
    _contentLabel.font = [UIFont systemFontOfSize:14];
    _contentLabel.frame = CGRectMake(10, Y+10,SCREEN_WIDTH-20, 30);
    [self.contentView addSubview:_contentLabel];

    
}

-(void)updateWithReplyDic:(NSDictionary *)replyDic{
    _replyDic = replyDic;

    _nameLabel.text = [_replyDic objectForKey:@"name"];
    
    //时间戳转日期
    NSDateFormatter *dateformater = [[NSDateFormatter alloc] init];
    dateformater.dateFormat = [NSString stringWithFormat:@"yyyy-MM-dd"];
    NSNumber *IntervalNum = [_replyDic objectForKey:@"create_time"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:(IntervalNum.integerValue)/1000];
    _dateLabel.text = [dateformater stringFromDate:date];
    
    NSString *contentStr = [_replyDic objectForKey:@"content"];
    _contentLabel.text = contentStr;
    CGSize size = [self sizeWithText:contentStr font:_contentLabel.font maxSize:CGSizeMake(SCREEN_WIDTH-20, MAXFLOAT)];
    CGRect contentRect =  _contentLabel.frame;
    contentRect.size.width = size.width;
    contentRect.size.height = size.height;
    
    _contentLabel.frame = contentRect;
    
    int Height = CGRectGetMaxY(_contentLabel.frame)+20;
    CGRect frame = self.frame;
    frame.size.height = Height;
    
    self.frame = frame;
}

#pragma mark - 计算文本尺寸
- (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font maxSize: (CGSize)maxSize
{
    NSDictionary *attrs = @{NSFontAttributeName : font};
    
    return [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

@end
