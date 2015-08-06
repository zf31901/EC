//
//  BillInfoViewController.h
//  Shop
//
//  Created by Harry on 14-1-14.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "BaseViewController.h"

typedef enum{
    PERSONAL = 0,
    UNITS = 1,
}BILL_TITLE;

typedef enum{
    DETAIL = 0,
    OFFICE,
    COMPUTER,
    CONSUMABLE,
}BILL_CONTENT;

@interface BillInfoViewController : BaseViewController

@property (nonatomic, assign) BILL_TITLE    billTitle;
@property (nonatomic, assign) BILL_CONTENT  content;

@end
