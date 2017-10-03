//
//  publishTopicVC.h
//  FiveWaterWork
//
//  Created by 李 燕琴 on 16/5/8.
//  Copyright © 2016年 aty. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol publishTopicVCDelegate <NSObject>
-(void)publishSuccessed;
@end


@interface publishTopicVC : UIViewController
@property (weak,nonatomic) id<publishTopicVCDelegate> delegate;
@end

//@interface AppDelegate : UIResponder <UIApplicationDelegate, UITextViewDelegate>
//@end