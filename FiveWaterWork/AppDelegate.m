//
//  AppDelegate.m
//  FiveWaterWork
//
//  Created by aiteyuan on 16/1/21.
//  Copyright © 2016年 aty. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (nonatomic, unsafe_unretained) UIBackgroundTaskIdentifier bgTask;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    LoginVC *loginvc = [[LoginVC alloc]init];
    self.window.rootViewController = loginvc;
    
    UIDevice *device = [UIDevice currentDevice];
    if (![[device model] isEqualToString:@"iPhone Simulator"]) {
        // 开始保存日志文件
        [self redirectNSlogToDocumentFolder];
    }
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    //后台开启定位
    NSLog(@"进入后台");
    BOOL backgroundAccepted = [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{ [self backgroundHandler]; }];
    
    if (backgroundAccepted)
        
    {
        NSLog(@"backgrounding accepted");
    }
    
    [self backgroundHandler];
}

- (void)backgroundHandler {
    
    UIApplication* app = [UIApplication sharedApplication];
    
    _bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        
        [app endBackgroundTask:_bgTask];
        _bgTask = UIBackgroundTaskInvalid;
        
    }];
    
    // Start the long-running task
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

        NSDictionary *dict = [[NSDictionary alloc]init];

        [nc postNotificationName:@"LocationTheme" object:self userInfo:dict];
        
    });}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"进入前台");
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// 将NSlog打印信息保存到Document目录下的文件中
- (void)redirectNSlogToDocumentFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"dr.log"];// 注意不是NSData!
    NSString *logFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
    // 先删除已经存在的文件
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    [defaultManager removeItemAtPath:logFilePath error:nil];
    
    // 将log输入到文件
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
}

@end
