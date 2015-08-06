//
//  ProductSortViewController.h
//  Shop
//
//  Created by Harry on 13-12-20.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "BaseRefreshTableViewController.h"

typedef enum{
    SORT_SALE_DOWN = 1,
    SORT_SALE_UP,
    SORT_PRICE_DOWN,
    SORT_PRICE_UP,
    SORT_COMMENT_DOWN = 9,
    SORT_COMMENT_UP,
}SORT_STATUS;

@interface ProductSortViewController : BaseRefreshTableViewController<UISearchBarDelegate>

@property (nonatomic, strong) NSString  *brandId;       //显示品牌下的商品
@property (nonatomic, strong) NSString  *searchKey;     //关键字搜索
@property (nonatomic, strong) NSString  *cpId;          //二级商品分类向下分类时，通过二级的cpId来得到三级商品分类商品

@end
