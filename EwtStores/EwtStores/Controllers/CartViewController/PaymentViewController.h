//
//  PaymentViewController.h
//  Shop
//
//  Created by Harry on 14-1-4.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "BaseViewController.h"

@interface PaymentViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSString  *purchaseType;


@end
