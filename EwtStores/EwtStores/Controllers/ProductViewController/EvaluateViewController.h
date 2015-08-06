//
//  EvaluateViewController.h
//  Shop
//
//  Created by Harry on 13-12-27.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "BaseRefreshTableViewController.h"

@class XYPieChart;
@class ProductObj;

@interface EvaluateViewController : BaseRefreshTableViewController

@property (nonatomic, strong) XYPieChart    *niceChart;
@property (nonatomic, strong) XYPieChart    *middleChart;
@property (nonatomic, strong) XYPieChart    *badChart;

@property (nonatomic, strong) ProductObj    *productObj;

@end
