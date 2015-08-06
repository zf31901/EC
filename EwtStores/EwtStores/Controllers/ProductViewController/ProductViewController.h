//
//  ProductViewController.h
//  EwtStores
//
//  Created by Harry on 13-11-30.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "BaseViewController.h"

@interface ProductViewController : BaseViewController<UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
{
    UISearchDisplayController       *searchDC;
    NSMutableArray                  *searchArr;
    
    UITableView                     *proTableView;
    NSMutableArray                  *productNameArr;
}

@end
