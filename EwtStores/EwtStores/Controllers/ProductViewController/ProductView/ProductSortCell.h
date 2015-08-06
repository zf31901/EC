//
//  ProductSortCell.h
//  Shop
//
//  Created by Harry on 13-12-20.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EGOImageView.h"

@class ProductObj;

@interface ProductSortCell : UITableViewCell<EGOImageViewDelegate>

@property (nonatomic, strong) EGOImageView  *proImageView;
@property (nonatomic, strong) UILabel       *proNameLb;
@property (nonatomic, strong) UILabel       *proOldPriceLb;
@property (nonatomic, strong) UILabel       *oldLineLb;
@property (nonatomic, strong) UILabel       *proSalePriceLb;
@property (nonatomic, strong) UILabel       *saleMonthNumLb;
@property (nonatomic, strong) UILabel       *starNumLb;

- (void)reuserTableViewCell:(ProductObj *)obj AtIndex:(NSInteger)index;

@end
