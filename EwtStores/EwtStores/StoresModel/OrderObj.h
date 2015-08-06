//
//  OrderObj.h
//  Shop
//
//  Created by Jacob on 14-1-6.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

@interface OrderObj : BaseModel

@property (nonatomic, strong) NSString  *orderId;       //订单编号
@property (nonatomic, strong) NSString  *orderTime;     //订单时间
@property (nonatomic, retain) NSArray   *products;      //订单中的商品
@property (nonatomic, assign) int       deliverType;   //送货方式
@property (nonatomic, strong) NSString  *receiverId;    //收货人信息
@property (nonatomic, assign) int       payType;       //支付方式
@property (nonatomic, assign) float     totalPrice;    //商品总价
@property (nonatomic, assign) float     couponAmount;    //优惠券金额
@property (nonatomic, assign) float     giftsAmount;    //礼品卡金额
@property (nonatomic, assign) float     totalPayAmount;    //应付金额
@property (nonatomic, assign) int       status;    //订单状态
@property (nonatomic, strong) NSString  *recName;   //收货人
@property (nonatomic, strong) NSString  *recAddress;    //收货人地址
@property (nonatomic, strong) NSString  *recMobile;    //收货人手机号
@property (nonatomic, assign) float     fare;    //运费
@property (nonatomic, strong) NSString  *invoiceType;   //发票类型
@property (nonatomic, strong) NSString  *invoiceHead;    //发票抬头
@property (nonatomic, strong) NSString  *invoinceContent;    //发票内容
@property (nonatomic, strong) NSString  *remark;    //备注

//退换货
@property (nonatomic, assign) int       repType;    //返修类型:返修（1），退货（2），换货（3）

@end
