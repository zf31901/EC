//
//  AlipayViewController.h
//  Shop
//
//  Created by ewt on 15/8/11.
//  Copyright (c) 2015年 Harry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "AlipayOrder.h"

@interface AlipayViewController : BaseViewController

@property (nonatomic,strong) AlipayOrder *alipayOrder;

- (id)init;

@end
