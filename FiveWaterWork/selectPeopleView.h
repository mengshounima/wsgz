//
//  selectPeopleView.h
//  FiveWaterWork
//
//  Created by 李 燕琴 on 16/5/28.
//  Copyright © 2016年 aty. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol selectPeopleDelegate <NSObject>

-(void)finishedSelectPeople:(NSNumber *)jobSignID;
-(void)cancelSelectPeople;

@end

@interface selectPeopleView : UIView<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,copy) NSArray *peopleArr;

@property (nonatomic,assign) NSUInteger selectRow;

@property (nonatomic,strong) UITableView *mytable;

@property (nonatomic,weak) id<selectPeopleDelegate> delegate;
@end
