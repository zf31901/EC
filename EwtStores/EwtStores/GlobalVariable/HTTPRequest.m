//
//  HTTPRequest.m
//  Shop
//
//  Created by Harry on 13-12-25.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "HTTPRequest.h"
#import "EGOCache.h"
#import "Util.h"

@implementation HTTPRequest

+ (instancetype)shareInstance
{
    return [[self alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/",BaseDemain]]];
}

+ (instancetype)shareInstance_myapi
{
    return [[self alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/",MemberBaseDemain]]];
}

+ (NetworkStatus )getNetworkStatus
{
    return [[Reachability reachabilityWithHostName:@"http://bhapi.ewt.cc"] currentReachabilityStatus];
}

+ (NSUInteger)getCacheData
{
    return [[NSURLCache sharedURLCache] currentMemoryUsage];
}

+ (void)clearAllCacheData
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (NSMutableURLRequest *)setCacheMechanismWith:(NSMutableURLRequest *)request
{
    NSURLCache *cache = [NSURLCache sharedURLCache];
    NSCachedURLResponse *response = [cache cachedResponseForRequest:request];
    if(response){
        DLog(@"该请求有缓存");
        [request setCachePolicy:NSURLRequestReturnCacheDataDontLoad];
    }else{
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    }
    
    return request;
}

+ (NSString *)getFileCachePath
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]];
}

+ (NSUInteger)getFileCacheData
{
    NSUInteger dataSize = (NSUInteger)[Util folderSizeAtPath3:[self getFileCachePath]];
    
    return dataSize;
}

+ (void)clearAllFileCacheData
{
    NSString *fileCachePath = [self getFileCachePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:fileCachePath error:nil];
    
    [[EGOCache globalCache] clearCache];
}


//GET
- (void)GETURLString:(NSString *)URLString
          parameters:(NSDictionary *)parameters
             success:(void (^)(AFHTTPRequestOperation *operation,id responseObj))success
             failure:(void (^)(AFHTTPRequestOperation *operation,NSError *error))failure
{
    [self GETURLString:URLString
           withTimeOut:DefineTimeout
            parameters:parameters
               success:success
               failure:failure];
}

- (void)GETURLString:(NSString *)URLString
         withTimeOut:(CGFloat )timeout
          parameters:(NSDictionary *)parameters
             success:(void (^)(AFHTTPRequestOperation *operation,id responseObj))success
             failure:(void (^)(AFHTTPRequestOperation *operation,NSError *error))failure
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:parameters];
    dic = [self appendRoutineParameterTo:dic];
    
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:dic];
    [request setTimeoutInterval:timeout];
    request = [self setCacheMechanismWith:request];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self.operationQueue addOperation:operation];
    NSLog(@"GET:%@",request.URL);
}

- (void)GETURLString:(NSString *)URLString
           userCache:(BOOL)isCache
          parameters:(NSDictionary *)parameters
             success:(void (^)(AFHTTPRequestOperation *operation,id responseObj))success
             failure:(void (^)(AFHTTPRequestOperation *operation,NSError *error))failure
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:parameters];
    dic = [self appendRoutineParameterTo:dic];
    
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:dic];
    [request setTimeoutInterval:DefineTimeout];
    //使用缓存
    if(isCache){
        request = [self setCacheMechanismWith:request];
    }
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self.operationQueue addOperation:operation];
    NSLog(@"%@",request.URL);
    NSLog(@"GET:%@",[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString]);
}

//POST
- (void)POSTURLString:(NSString *)URLString
           parameters:(NSDictionary *)parameters
              success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [self POSTURLString:URLString
            withTimeout:DefineTimeout
             parameters:parameters
                success:success
                failure:failure];
}

- (void)POSTURLString:(NSString *)URLString
          withTimeout:(CGFloat )timeout
           parameters:(NSDictionary *)parameters
              success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:parameters];
    dic = [self appendRoutineParameterTo:dic];
    
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:dic];
    [request setTimeoutInterval:timeout];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self.operationQueue addOperation:operation];
    
    NSLog(@"POST:%@",[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString]);
}

- (void)POSTURLString:(NSString *)URLString
           parameters:(NSDictionary *)parameters
            imageData:(NSData *)data
              success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:parameters];
    dic = [self appendRoutineParameterTo:dic];
    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:@"file" fileName:@"ebsIcon.png" mimeType:@"image/png"];
    }];
    
    [request setTimeoutInterval:60];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self.operationQueue addOperation:operation];
    
    NSLog(@"POST:%@",[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString]);
   
}

- (void)POSTURLString:(NSString *)URLString
           parameters:(NSDictionary *)parameters
            imageData:(NSData *)data
    completionHandler:(void (^)(NSURLResponse *, NSData *, NSError *))handler{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:parameters];
    dic = [self appendRoutineParameterTo:dic];
    NSString *TWITTERFON_FORM_BOUNDARY = @"0xKhTmLbOuNdArY";
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URLString relativeToURL:self.baseURL]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:60];
    
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
    
    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
    
    //http body
    NSMutableString *body=[[NSMutableString alloc]init];
    
    NSArray *keys= [dic allKeys];
    
    
    for(int i=0;i<[keys count];i++)
    {
        
        NSString *key=[keys objectAtIndex:i];
        
        //body 拼装
        [body appendFormat:@"%@\r\n",MPboundary];
        
        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
        
        [body appendFormat:@"%@\r\n",[dic objectForKey:key]];
        
    }
    
    
    [body appendFormat:@"%@\r\n",MPboundary];
    //表单
    [body appendFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"ebsIcon.png\"\r\n"];
    
    [body appendFormat:@"Content-Type: image/png\r\n\r\n"];
    
    
    NSString *end=[[NSString alloc]initWithFormat:@"\r\n%@",endMPboundary];
    
    NSMutableData *myRequestData=[NSMutableData data];
    //将body字符串转化为UTF8格式的二进制
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    //将image的data加入
    [myRequestData appendData:data];
    
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    //设置HTTPHeader中Content-Type的值
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
    //设置HTTPHeader
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%d",[myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    //设置http body
    [request setHTTPBody:myRequestData];
    
    [request setHTTPMethod:@"POST"];
    
    
    NSOperationQueue *queue=[NSOperationQueue mainQueue];
    //异步Block请求
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:handler];
}

//PUT
- (void )PUTURLString:(NSString *)URLString
           parameters:(NSDictionary *)parameters
              success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [self PUTURLString:URLString
           withTimeout:DefineTimeout
            parameters:parameters
               success:success
               failure:failure];
}

- (void )PUTURLString:(NSString *)URLString
          withTimeout:(CGFloat )timeout
           parameters:(NSDictionary *)parameters
              success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:parameters];
    dic = [self appendRoutineParameterTo:dic];
    
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"PUT" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:dic];
    [request setTimeoutInterval:timeout];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self.operationQueue addOperation:operation];
    
    NSLog(@"PUT:%@",[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString]);
}

//DELETE
- (void )DELETEURLString:(NSString *)URLString
              parameters:(NSDictionary *)parameters
                 success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [self DELETEURLString:URLString
              withTimeout:DefineTimeout
               parameters:parameters
                  success:success
                  failure:failure];
}

- (void )DELETEURLString:(NSString *)URLString
             withTimeout:(CGFloat )timeout
              parameters:(NSDictionary *)parameters
                 success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:parameters];
    dic = [self appendRoutineParameterTo:dic];
    
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"DELETE" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:dic];
    [request setTimeoutInterval:timeout];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self.operationQueue addOperation:operation];
    
    NSLog(@"DELETE:%@",[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString]);
}

- (NSMutableDictionary *)appendRoutineParameterTo:(NSMutableDictionary *)dic
{
    if ([self.baseURL isEqual:[NSURL URLWithString:[NSString stringWithFormat:@"%@/",BaseDemain]]]) {
        [dic setObject:ApiKey forKey:@"apikey"];
    }else{
        [dic setObject:MemberApikey forKey:@"apikey"];
    }
    
    return dic;
}

@end
