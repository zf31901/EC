//
//  ProductDetailViewController.h
//  Shop
//
//  Created by Harry on 13-12-26.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "BaseViewController.h"
#import "ProductObj.h"

#define BannerView_Height 145

@interface ProductDetailViewController : BaseViewController<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UIScrollView              *mainSView;
@property (nonatomic, strong) UIScrollView              *bannerSView;
@property (nonatomic, strong) UIPageControl             *pageC;

@property (nonatomic, strong) ProductObj                *obj;
@property (nonatomic, strong) UILabel                   *numLb;

@property (nonatomic, strong) NSString                  *productId; //商品的id

@end
