//
//  selectPeopleView.m
//  FiveWaterWork
//
//  Created by 李 燕琴 on 16/5/28.
//  Copyright © 2016年 aty. All rights reserved.
//

#import "selectPeopleView.h"
#import "selectViewCell.h"

#define cellIdentifier @"cellSelect"

@implementation selectPeopleView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 8;
        [self setupView];
    }
    return self;
}

-(void)setupView{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.frame.size.width-10, 20)];
    titleLabel.text = @"请选择提交的联系人";
    titleLabel.textColor = choiceColor(74, 183, 227);
    [self addSubview:titleLabel];
    
    _mytable = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, self.frame.size.width, self.frame.size.height-20-50) style:UITableViewStylePlain];
    _mytable.dataSource = self;
    _mytable.delegate = self;
    [self addSubview:_mytable];
    
    float Y = CGRectGetMaxY(_mytable.frame);
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, Y, self.frame.size.width, 50)];
    [self addSubview:footer];
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 10, self.frame.size.width/2-40, 30)];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.layer.cornerRadius = 6;
    [cancelBtn setBackgroundColor:choiceColor(208, 208, 208)];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [footer addSubview:cancelBtn];
    [cancelBtn addTarget:self action:@selector(cancelClick:) forControlEvents:UIControlEventTouchUpInside ];
    
    UIButton *doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width/2+20, 10, self.frame.size.width/2-40, 30)];
    [doneBtn setTitle:@"确定" forState:UIControlStateNormal];
    doneBtn.layer.cornerRadius = 6;
    [doneBtn setBackgroundColor:choiceColor(208, 208, 208)];
    [doneBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(doneClick:) forControlEvents:UIControlEventTouchUpInside];
    [footer addSubview:doneBtn];

}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 2;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *lineV = [[UIView alloc] init];
    lineV.backgroundColor = choiceColor(74, 183, 227);
    return lineV;
}


-(void)cancelClick:(UIButton *)button{
    [self removeFromSuperview];
    [self.delegate cancelSelectPeople];
}

-(void)doneClick:(UIButton *)button{
    [self removeFromSuperview];
    [self.delegate finishedSelectPeople:_peopleArr[_selectRow][@"id"]];//回传id
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _peopleArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    selectViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell = [[selectViewCell alloc] initWithFrame:self.frame];
    }
    if (indexPath.row ==_selectRow) {
        [cell updateImage];
    }
    [cell updateCell:_peopleArr[indexPath.row][@"name"]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _selectRow = indexPath.row;
    [tableView reloadData];
}

@end
