//
//  ExchangeTypeViewController.h
//  Shop
//
//  Created by Jacob on 14-1-15.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "BaseViewController.h"

@interface ExchangeTypeViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSString  *exchangeType;

@end
