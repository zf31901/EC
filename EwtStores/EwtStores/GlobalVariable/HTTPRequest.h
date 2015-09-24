//
//  HTTPRequest.h
//  Shop
//
//  Created by Harry on 13-12-25.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

/************************************************************************************************************
 *  1.继承AFHTTPRequestOperationManager，能获取他的属性和方法；
 *
 *  2.网络请求类，有标准得GET POST PUT DELETE；
 *
 *  3.可以在 GET POST PUT DELETE 中的timeout方法中设置request的一些属性，比如缓存策略，缓存地址，http头部等等。。。
 *
 *  4.可以通过设置 OfficialEnvironment 的值来切换网络环境；
 *
 *  5.每次请求都包含了例行请求数据，比如 mac地址，请求时间戳，token等等。。。
 *
 *  6.所有请求都是异步处理，若要实现同步，则需要实现线程堵塞处理
 *
 *  7.快速的到项目缓存数据及清空缓存，快速的到当前网络状态
 ************************************************************************************************************/

#import "AFHTTPRequestOperationManager.h"
#import "AFNetworkReachabilityManager.h"
#import "Reachability.h"

/**
 * 产品环境:    http://ecapi.aixinland.cn
               http://myapi.aixinland.cn
 * 测试环境:    http://ecapi.aixinland.cn    本地DNS设置为172.17.1.142
               http://myapi.aixinland.cn    本地DNS设置为172.17.1.142
 * 正式环境:    http://ecapi.aixinland.cn
               http://myapi.aixinland.cn    //会员中心
 
 **/

#define OfficialEnvironment

#ifdef OfficialEnvironment
#define BaseDemain          @"http://ecapi.aixinland.cn"
#define MemberBaseDemain    @"http://myapi.aixinland.cn"
#define ApiKey              @"800000001"
#define MemberApikey        @"900000001"
//#define NotifyUrl           @"http://ec.aixinland.cn/webaspxpage/alipay/app_notify_url.aspx"
#define NotifyUrl           @"http://lan.ecmall.ewt.cc/webaspxpage/alipay/app_notify_url.aspx"
//#define UUPAY_CODE          @"00"       //正式环境
#else
#define BaseDemain          @"http://bhapi.ewt.cc"
#define MemberBaseDemain    @"http://myapi.ewt.cc"
#define ApiKey              @"100000001"
#define MemberApikey        @"100000001"
#define NotifyUrl           @"http://ec.aixinland.cn/webaspxpage/alipay/app_notify_url.aspx"
//#define UUPAY_CODE          @"01"       //开发环境
#endif

#define DefineTimeout           20.0


@interface HTTPRequest : AFHTTPRequestOperationManager

+ (instancetype)shareInstance;
+ (instancetype)shareInstance_myapi;
+ (NetworkStatus)getNetworkStatus;

//内存缓存：默认为4M，可以提高url加载速度，但是当内存过大时，会提高运行速度
+ (NSUInteger)getCacheData;
+ (void)clearAllCacheData;

//文件缓存：对图片进行缓存，使用egoCache进行缓存
+ (NSString *)getFileCachePath; 
+ (NSUInteger)getFileCacheData;
+ (void)clearAllFileCacheData;

// GET： timeout默认为10秒 ,默认有缓存
- (void)GETURLString:(NSString *)URLString
          parameters:(NSDictionary *)parameters
             success:(void (^)(AFHTTPRequestOperation *operation,id responseObj))success
             failure:(void (^)(AFHTTPRequestOperation *operation,NSError *error))failure;

// GET： timeout自定义设置，也可以在方法实现中设置request（比如缓存策略）,默认有缓存
- (void)GETURLString:(NSString *)URLString
         withTimeOut:(CGFloat )timeout
          parameters:(NSDictionary *)parameters
             success:(void (^)(AFHTTPRequestOperation *operation,id responseObj))success
             failure:(void (^)(AFHTTPRequestOperation *operation,NSError *error))failure;

// GET： timeout自定义设置，也可以在方法实现中设置request（比如缓存策略）,默认无缓存
- (void)GETURLString:(NSString *)URLString
           userCache:(BOOL)isCache
          parameters:(NSDictionary *)parameters
             success:(void (^)(AFHTTPRequestOperation *operation,id responseObj))success
             failure:(void (^)(AFHTTPRequestOperation *operation,NSError *error))failure;

//POST
- (void)POSTURLString:(NSString *)URLString
           parameters:(NSDictionary *)parameters
              success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)POSTURLString:(NSString *)URLString
          withTimeout:(CGFloat )timeout
           parameters:(NSDictionary *)parameters
              success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)POSTURLString:(NSString *)URLString
           parameters:(NSDictionary *)parameters
            imageData:(NSData *)data
              success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)POSTURLString:(NSString *)URLString
           parameters:(NSDictionary *)parameters
            imageData:(NSData *)data
    completionHandler:(void (^)(NSURLResponse* response, NSData* data, NSError *connectionError))handler;

//PUT
- (void )PUTURLString:(NSString *)URLString
           parameters:(NSDictionary *)parameters
              success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void )PUTURLString:(NSString *)URLString
          withTimeout:(CGFloat )timeout
           parameters:(NSDictionary *)parameters
              success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

//DELETE
- (void )DELETEURLString:(NSString *)URLString
              parameters:(NSDictionary *)parameters
                 success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void )DELETEURLString:(NSString *)URLString
             withTimeout:(CGFloat )timeout
              parameters:(NSDictionary *)parameters
                 success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
