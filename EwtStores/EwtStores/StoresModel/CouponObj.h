//
//  CouponObj.h
//  Shop
//
//  Created by Harry on 14-1-20.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "BaseModel.h"

@interface CouponObj : BaseModel

@property (nonatomic, strong) NSString  *couponId;
@property (nonatomic, strong) NSString  *couponAmount;      //面值
@property (nonatomic, strong) NSString  *limmitAmount;      //满足多少才能使用
@property (nonatomic, strong) NSString  *beginTime;         //开始时间
@property (nonatomic, strong) NSString  *endTime;           //结束时间



@property (nonatomic, assign)   int     result;
//请求结果  1-	核对绑定成功 2卡号和密码不存在 3优惠券不存在 4 不在有效期 5 已锁定,不能使用  6 已被使用
@property (nonatomic, strong) NSString  *serialnumber;      //券号
@property (nonatomic, assign) float     balance;           //余额
@property (nonatomic, assign) float     amount;            //面值
@property (nonatomic, assign)   int     UC_CouponType;     //优惠券类别(1表示可以使用多张，2表示只能使用一张，1和2不能混合使用)

@end
