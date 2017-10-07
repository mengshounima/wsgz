//
//  HttpClient.h
//  beiying
//
//  Created by Shen Jun on 15/5/26.
//  Copyright (c) 2015年 沈骏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

//HTTP REQUEST METHOD TYPE
typedef NS_ENUM(NSInteger, RTHttpRequestType) {
    TBHttpRequestGet,
    TBHttpRequestPost,
    TBHttpRequestDelete,
    TBHttpRequestPut,
};

/**
 *  请求开始前预处理Block
 */
typedef void(^PrepareExecuteBlock)(void);

@interface HttpClient : NSObject

/**
 *  HTTP请求（GET、POST、DELETE、PUT）
 *
 *  @param path
 *  @param method     RESTFul请求类型
 *  @param parameters 请求参数
 *  @param prepare    请求前预处理块
 *  @param success    请求成功处理块
 *  @param failure    请求失败处理块
 */


- (void)requestWithPath:(NSString *)url
                 method:(NSInteger)method
             parameters:(id)parameters
         prepareExecute:(PrepareExecuteBlock) prepare
                success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

// 请求管理请求 (图片上传)
- (void)requestOperaionManageWithURl:(NSString *)urlStr
                          httpMethod:(NSInteger)method
                          parameters:(id)parameters
                            bodyData:(NSArray *)bodyData
                          DataNumber:(NSInteger)number
                             success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                             failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

//下载
- (void)downloadWithURl:(NSString *)urlStr httpMethod:(NSInteger)method bodyData:(NSData *)bodyData success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;



+ (instancetype)httpClient;

@property (assign, nonatomic) AFNetworkReachabilityStatus netWorkStaus;

@end
