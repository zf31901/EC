//
//  ProductSpecialCell.h
//  Shop
//
//  Created by Harry on 13-12-31.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProductSpecialCellDelegate <NSObject>

- (void)clickToProductDetail:(NSInteger)index;

@end

@class EGOImageView;
@class ProductObj;

@interface ProductSpecialCell : UITableViewCell

@property (nonatomic, strong) EGOImageView  *proImageView;
@property (nonatomic, strong) UILabel       *proNameLb;
@property (nonatomic, strong) UILabel       *proOldPriceLb;
@property (nonatomic, strong) UILabel       *oldLineLb;
@property (nonatomic, strong) UILabel       *proSalePriceLb;

@property (nonatomic, assign) id<ProductSpecialCellDelegate> _delegate;

- (void)reuserTableViewCell:(ProductObj *)obj AtIndex:(NSInteger)index;

@end
