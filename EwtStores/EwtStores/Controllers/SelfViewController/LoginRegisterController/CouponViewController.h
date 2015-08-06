//
//  CouponViewController.h
//  Shop
//
//  Created by Harry on 14-1-7.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "BaseViewController.h"

@interface CouponViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (nonatomic, strong) NSString  *orderPrice;            //订单的总价
@property (nonatomic, assign) BOOL      shouldUserCoupon;       //是否可以使用优惠券(来处理多次使用优惠券)
@property (nonatomic, strong) NSString  *fromPage;                //从哪个页面的优惠券过来的
@end
