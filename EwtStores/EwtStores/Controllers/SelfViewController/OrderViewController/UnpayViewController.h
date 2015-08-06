//
//  CartViewController.h
//  EwtStores
//
//  Created by Harry on 13-11-30.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "BaseRefreshTableViewController.h"

@interface UnpayViewController : BaseRefreshTableViewController<UIAlertViewDelegate>

@property (nonatomic, assign) BOOL  isRootNavC;    // 用来判断是rootNavC还是 别的视图push近来的

@end
