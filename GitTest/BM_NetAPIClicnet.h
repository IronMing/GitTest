//
//  BM_NetAPIClicnet.h
//  LPBM
//
//  Created by gang.wang on 15/3/3.
//  Copyright (c) 2015年 BM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef enum {
    Get = 0,
    Post,
    Put,
    Delete
} NetworkMethod;

@interface BM_NetAPIClicnet : AFHTTPSessionManager

+ (BM_NetAPIClicnet *)sharedJsonClient;

- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary*)params
                 withMethodType:(int)NetworkMethod
                       andBlock:(void (^)(id responseData, NSError *error))block;
- (void)requestJsonDataWithPathNoF:(NSString *)aPath
                     withParams:(NSDictionary*)params
                 withMethodType:(int)NetworkMethod
                       andBlock:(void (^)(id responseData, NSError *error))block;
#pragma mark上传图片
-(void)requestImageDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary*)params
                       WithName:(NSString *)name
                       fileName:(NSString *)fileName
                       filePath:(NSString *)filePath_
                 withMethodType:(int)NetworkMetho
                       andBlock:(void (^)(id responseData, NSError *error))block;
#pragma mark上传多张图片
-(void)requestImagesDataWithPath:(NSString *)aPath
                      withParams:(NSDictionary*)params
                        WithName:(NSString *)name
                        fileName:(NSString *)fileName
                        filePath:(NSArray *)filePath_
                  withMethodType:(int)NetworkMetho
                       andBlock:(void (^)(id responseData, NSError *error))block;
@end
