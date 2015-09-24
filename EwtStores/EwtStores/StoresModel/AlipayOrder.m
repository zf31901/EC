//
//  AlipayOrder.m
//  Shop
//
//  Created by ewt on 15/8/11.
//  Copyright (c) 2015年 Harry. All rights reserved.
//

#import "AlipayOrder.h"
#import "HTTPRequest.h"

@implementation AlipayOrder

- (id)init{
    self = [super init];
    if (self) {
        self.partner        = @"2088611479593247";
        self.seller         = @"zhifubao@fushifu.cn";
        self.privateKey     = @"MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAM/b3RgMVYoAF3UO8OFofCIY7igZD7GY7Ulhe4hO8TqpXjXTcE+z0DpPPWgtomZdbhb0GkbkmC9mF9QTjJV+ShBC1N6LceDzzrr2ZWm70QhUzC5zX6YGXbqnTN3GVs/Koz76hMrwGIAB/gTQMneiQmba3imd0OQxxqi9X+IYVC45AgMBAAECgYBqLtAAQ/TCnY9eHjbRf3XCWWf4Fe1ddVjqXqEjneg/ZlwZNR0vqhTaZLZi7MUEdAAUO7jctFRGCmprzVzI1Y3xWvOg+yQNGvaGAt+adH4JRAaV+avvXa4FLFC76BBDZ22lVyE7M42YP1d9KjnmT1WBGjPap64ROXRz/tiQWH5oMQJBAOeKq7Byxd9bFJpoIjj35sKgYpnCQJuMxO9Hje6x5XHQKTFhSxO0SncDVRXN47cwH+a/PYjqMbNH5+d0OOd/eo0CQQDl0MOF394bHWGbGX4jOU/NP+4DVdTcjHCerEvaNk/IAWjtwPh+vNWnu3+zu3JRPxkdVBzonUCl1OVwAp9D2Y1dAkEAo75amscgDkvwLx4TjawrIlqgQFKytA6COyGkSzi9pZZre0Nt/7pRqwbNRkU7lBJRjTKTht7wVPQ2GWYE1BpABQJAX5vfjBWbsIojrkQHzx2rzocXPTn7KZofzFN/5xOLU3kKr0cF2qwy8uo1cY+9OoHWr/XrZPbvC06r+VKN8ctTXQJBAJ6fICMcv51SBdt1zdpXNwRDU9A94FYr9T3Ae1/NRMRD3lnAq70QM2GF9zh3bLCK5TL4XhAWG44P+LMtS1ujgb8="; //商户方私钥
        self.notifyURL      = NotifyUrl;
        self.service        = @"mobile.securitypay.pay";
        self.paymentType    = @"1";
        self.inputCharset   = @"utf-8";
        self.itBPay         = @"30m";
        self.showUrl        = @"m.alipay.com";
        self.appScheme      = @"Shop";
    }
    return self;
}

- (NSString *)description {
    NSMutableString * discription = [NSMutableString string];
    if (self.partner) {
        [discription appendFormat:@"partner=\"%@\"", self.partner];
    }
    
    if (self.seller) {
        [discription appendFormat:@"&seller_id=\"%@\"", self.seller];
    }
    if (self.tradeNO) {
        [discription appendFormat:@"&out_trade_no=\"%@\"", self.tradeNO];
    }
    if (self.productName) {
        [discription appendFormat:@"&subject=\"%@\"", self.productName];
    }
    
    if (self.productDescription) {
        [discription appendFormat:@"&body=\"%@\"", self.productDescription];
    }
    if (self.amount) {
        [discription appendFormat:@"&total_fee=\"%@\"", self.amount];
    }
    if (self.notifyURL) {
        [discription appendFormat:@"&notify_url=\"%@\"", self.notifyURL];
    }
    
    if (self.service) {
        [discription appendFormat:@"&service=\"%@\"",self.service];//mobile.securitypay.pay
    }
    if (self.paymentType) {
        [discription appendFormat:@"&payment_type=\"%@\"",self.paymentType];//1
    }
    
    if (self.inputCharset) {
        [discription appendFormat:@"&_input_charset=\"%@\"",self.inputCharset];//utf-8
    }
    if (self.itBPay) {
        [discription appendFormat:@"&it_b_pay=\"%@\"",self.itBPay];//30m
    }
    if (self.showUrl) {
        [discription appendFormat:@"&show_url=\"%@\"",self.showUrl];//m.alipay.com
    }
    if (self.rsaDate) {
        [discription appendFormat:@"&sign_date=\"%@\"",self.rsaDate];
    }
    if (self.appID) {
        [discription appendFormat:@"&app_id=\"%@\"",self.appID];
    }
    for (NSString * key in [self.extraParams allKeys]) {
        [discription appendFormat:@"&%@=\"%@\"", key, [self.extraParams objectForKey:key]];
    }
    return discription;
}


@end
