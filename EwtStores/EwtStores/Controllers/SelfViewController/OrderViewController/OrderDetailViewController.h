//
//  OrderDetailViewController.h
//  Shop
//
//  Created by Jacob on 14-1-6.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "BaseRefreshTableViewController.h"
#import "OrderObj.h"

@interface OrderDetailViewController : BaseRefreshTableViewController<UIAlertViewDelegate,UIActionSheetDelegate>

@property(nonatomic,retain) OrderObj *order;

@end
