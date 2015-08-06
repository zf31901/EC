//
//  SettleViewController.h
//  Shop
//
//  Created by Harry on 14-1-3.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "BaseViewController.h"

@interface SettleViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) NSString  *purchaseType;      //支付方式
@property (nonatomic, strong) NSString  *devideType;        //运输方式

@property (nonatomic, strong) NSString  *billId;            //发票信息
@property (nonatomic, strong) NSString  *billTitle;         //发票抬头
@property (nonatomic, strong) NSString  *billContent;       //发票内容
@property (nonatomic, strong) NSString  *billCompamyName;   //发票单位

@property (nonatomic, strong) NSString  *shouldNotif;       //是否送货前通知

@property (nonatomic, strong) NSString  *couponPrice;       //优惠券面值
@property (nonatomic, strong) NSString  *couponID;          //优惠券的编号

@property (nonatomic, strong) NSArray   *productObjArr;     //购物车中的商品

@end
