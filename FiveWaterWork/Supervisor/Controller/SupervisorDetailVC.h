//
//  SupervisorDetailVC.h
//  FiveWaterWork
//
//  Created by 李 燕琴 on 2017/10/4.
//  Copyright © 2017年 aty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYQBlock.h"

@interface SupervisorDetailVC : UIViewController

@property (nonatomic,strong) CompletionBlock completion;

- (instancetype)initWithDetailData:(NSDictionary *)detailData;

@end
