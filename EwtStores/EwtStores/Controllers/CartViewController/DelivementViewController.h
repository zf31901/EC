//
//  DelivementViewController.h
//  Shop
//
//  Created by Harry on 14-1-14.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "BaseViewController.h"

@interface DelivementViewController : BaseViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSString  *devideType;        //运输方式

@end
