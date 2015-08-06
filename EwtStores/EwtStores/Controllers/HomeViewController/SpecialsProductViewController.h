//
//  SpecialsProductViewController.h
//  Shop
//
//  Created by Harry on 13-12-31.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "BaseRefreshTableViewController.h"

/************************************************
 * 特价商品列表，热卖商品列表，新品商品列表，疯狂抢购列表
 ************************************************/
typedef enum{
    PRODUCT_SPECIAL = 0,
    PRODUCT_HOT,
    PRODUCT_NEW,
    PRODUCT_CRAZY,
}PRODUCT_ATTRIBUTE;

@interface SpecialsProductViewController : BaseRefreshTableViewController

@property (nonatomic, assign) PRODUCT_ATTRIBUTE  product_attribute;

@end
