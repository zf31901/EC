//
//  ProductCategoryViewController.h
//  Shop
//
//  Created by Harry on 13-12-20.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "BaseViewController.h"

#import "RATreeView.h"

@interface ProductCategoryViewController : BaseViewController<RATreeViewDelegate,RATreeViewDataSource,UITableViewDelegate>
{
    RATreeView      *proListTView;
    
    NSMutableArray  *proCateArr;        //RATreeView 的数据
}

@property (nonatomic, strong) NSString  *categoryName;  //title
@property (nonatomic, strong) NSString  *cpId;          //一级商品分类向下分类时，通过一级的cpId来得到二级商品分类

@end
