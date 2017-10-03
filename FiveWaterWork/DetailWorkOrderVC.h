//
//  DetailWorkOrderVC.h
//  FiveWaterWork
//
//  Created by aiteyuan on 16/2/22.
//  Copyright © 2016年 aty. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DetailWorkOrderDelegate<NSObject>

-(void)detailDelegate;

@end

@interface DetailWorkOrderVC : UIViewController
@property (nonatomic,weak) NSDictionary *detailDic;

@property (weak,nonatomic)  id<DetailWorkOrderDelegate> delegate;

@end
