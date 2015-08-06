//
//  HoneViewController.h
//  EwtStores
//
//  Created by Harry on 13-11-30.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "BaseViewController.h"
#import "EGORefreshTableHeaderView.h"

typedef enum
{
    Activity_Status = 0,
    Charge_Status,
    Order_Status,
    GroupPurchase_Status,
}Activity_ImageView_Status;

@interface HomeViewController : BaseViewController <UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UIScrollViewDelegate,EGORefreshTableDelegate>
{
    EGORefreshTableHeaderView       *egoHeaderTable;
     BOOL                           _isLoading;
}

@property (nonatomic, strong) UISearchDisplayController *searchDC;
@property (nonatomic, strong) NSMutableArray            *searchDataArr;

@property (nonatomic, strong) UIScrollView              *mainSView;
@property (nonatomic, strong) UIScrollView              *bannerSView;
@property (nonatomic, strong) UIPageControl             *pageC;


@end
