//
//  ExchangeViewController.h
//  Shop
//
//  Created by Jacob on 14-1-15.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "BaseViewController.h"
#import "OrderObj.h"

@interface ExchangeViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate>

@property (nonatomic, strong) NSString  *exchangeType;      //退换货方式
@property(nonatomic,retain) OrderObj    *order;             //订单

@end
