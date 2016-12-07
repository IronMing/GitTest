//
//  BM_NetAPIClicnet.m
//  LPBM
//
//  Created by gang.wang on 15/3/3.
//  Copyright (c) 2015年 BM. All rights reserved.
//

#import "BM_NetAPIClicnet.h"
//#import "NSObject+Common.h"
#import <CommonCrypto/CommonDigest.h>

#define DEF_NETPATH_BASEURL   @"https://www.baidu.com"

@implementation BM_NetAPIClicnet

+ (BM_NetAPIClicnet *)sharedJsonClient {
    static BM_NetAPIClicnet *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedClient = [[BM_NetAPIClicnet alloc] initWithBaseURL:[NSURL URLWithString:DEF_NETPATH_BASEURL]];
        
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/html", @"text/javascript", @"text/json", nil];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    self.securityPolicy.allowInvalidCertificates = YES;
    [self.requestSerializer setTimeoutInterval:30];
    return self;
}


- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary*)params
                 withMethodType:(int)NetworkMethod
                       andBlock:(void (^)(id responseData, NSError *error))block{
    //log请求数据
    DEF_DEBUG(@"\n===========request===========\n%@    \n%@", aPath, params);
//    aPath = [aPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [MBProgressHUD showMessage:DEF_ALERTMESSAGE toView:[[UIApplication sharedApplication].delegate window] ];
    //发起请求
    switch (NetworkMethod) {
        case Get:{
            [self GET:aPath parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [MBProgressHUD hideHUDForView:[[UIApplication sharedApplication].delegate window] animated:YES];
                DEF_DEBUG(@"\n===========response===========\n%@ \n%@ repMsg = %@", aPath, responseObject,[responseObject objectForKey:@"repMsg"]);
                id error = [self handleResponse:responseObject];
                if (error) {
                    block(nil, error);
                }else{
                    block(responseObject, nil);
                }

            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                DEF_DEBUG(@"\n===========response===========\n%@ \n%@", aPath, error);
                //                [self showError:error];
                [MBProgressHUD hideHUDForView:[[UIApplication sharedApplication].delegate window] animated:YES];
                [MBProgressHUD showError:@"网络异常"];
                block(nil, error);
            }];
            break;
        }
        case Post:{
            
            [self POST:aPath parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
            
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [MBProgressHUD hideHUD];
                DEF_DEBUG(@"\n===========response===========\n%@:\n%@", aPath, responseObject);
                id error = [self handleResponse:responseObject];
                if (!error) {
                    block(nil, error);
                }else{
                    block(responseObject, nil);
                }

            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                DEF_DEBUG(@"\n===========response===========\n%@:\n%@", aPath, error);
                [MBProgressHUD hideHUDForView];
                [MBProgressHUD showError:@"连接失败"];
                //                [self showError:error];
                block(nil, error);
            }];
            break;}
        case Put:{
 
            [self PUT:aPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                DEF_DEBUG(@"\n===========response===========\n%@:\n%@", aPath, responseObject);
                id error = [self handleResponse:responseObject];
                if (error) {
                    block(nil, error);
                }else{
                    block(responseObject, nil);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                DEF_DEBUG(@"\n===========response===========\n%@:\n%@", aPath, error);
                [self showError:error];
                block(nil, error);
            }];
 
            break;}
        case Delete:{
 
            [self DELETE:aPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                DEF_DEBUG(@"\n===========response===========\n%@:\n%@", aPath, responseObject);
                id error = [self handleResponse:responseObject];
                if (error) {
                    block(nil, error);
                }else{
                    block(responseObject, nil);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                DEF_DEBUG(@"\n===========response===========\n%@:\n%@", aPath, error);
//                [self showError:error];
                block(nil, error);
            }];}
 
            break;
        default:
            break;
    }
}

/*
//请求无菊花     照上面方法修改即可
- (void)requestJsonDataWithPathNoF:(NSString *)aPath
                        withParams:(NSDictionary*)params
                    withMethodType:(int)NetworkMethod
                          andBlock:(void (^)(id responseData, NSError *error))block{
    //log请求数据
    DEF_DEBUG(@"\n===========request===========\n%@    \n%@", aPath, params);
//    aPath = [aPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //发起请求
    switch (NetworkMethod) {
        case Get:{
            [self GET:aPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                DEF_DEBUG(@"\n===========response===========\n%@:\n%@", aPath, responseObject);
                id error = [self handleResponse:responseObject];
                if (error) {
                    block(nil, error);
                }else{
                    block(responseObject, nil);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                DEF_DEBUG(@"\n===========response===========\n%@:\n%@", aPath, error);
                block(nil, error);
            }];
            break;
        }
        case Post:{
            
            [self POST:aPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"responseJSON == %@",responseObject);
                    block(responseObject, nil);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                block(nil, error);
            }];
            break;}
        case Put:{
            [self PUT:aPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                DEF_DEBUG(@"\n===========response===========\n%@:\n%@", aPath, responseObject);
                id error = [self handleResponse:responseObject];
                if (error) {
                    block(nil, error);
                }else{
                    block(responseObject, nil);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                DEF_DEBUG(@"\n===========response===========\n%@:\n%@", aPath, error);
                [self showError:error];
                block(nil, error);
            }];
            break;}
        case Delete:{
            [self DELETE:aPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                DEF_DEBUG(@"\n===========response===========\n%@:\n%@", aPath, responseObject);
                id error = [self handleResponse:responseObject];
                if (error) {
                    block(nil, error);
                }else{
                    block(responseObject, nil);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                DEF_DEBUG(@"\n===========response===========\n%@:\n%@", aPath, error);
                //                [self showError:error];
                block(nil, error);
            }];}
        default:
            break;
    }
}
*/
#pragma mark上传图片
-(void)requestImageDataWithPath:(NSString *)aPath withParams:(NSDictionary*)params WithName:(NSString *)name fileName:(NSString *)fileName filePath:(NSString *)filePath_ withMethodType:(int)NetworkMetho
                       andBlock:(void (^)(id responseData, NSError *error))block{
    
    NSData *imageData = [NSData dataWithContentsOfFile:filePath_];
    
    [self POST:aPath parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:imageData name:name fileName:fileName mimeType:@"image/png"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        DEF_DEBUG(@"\n===========response===========\n%@:\n%@", aPath, responseObject);
        block(responseObject,nil);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        block(nil,error);
        NSLog(@"Error: %@", error);
    }];
    
}

#pragma mark上传多张图片
-(void)requestImagesDataWithPath:(NSString *)aPath withParams:(NSDictionary*)params WithName:(NSString *)name fileName:(NSString *)fileName filePath:(NSArray *)filePath_ withMethodType:(int)NetworkMetho
                       andBlock:(void (^)(id responseData, NSError *error))block{
    
    [self POST:aPath parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (int i=0; i < filePath_.count; i++) {
            NSData *imageData = [NSData dataWithContentsOfFile:filePath_[i]];
            [formData appendPartWithFileData:imageData name:name fileName:fileName mimeType:@"image/jpg"];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        DEF_DEBUG(@"\n===========response===========\n%@:\n%@", aPath, responseObject);
        block(responseObject,nil);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        block(nil,error);
        NSLog(@"Error: %@", error);
    }];
}



@end
