//
//  ProductSpecialListCell.h
//  Shop
//
//  Created by Harry on 13-12-31.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProductObj;
#import "ProductSpecialCell.h"

@protocol ProductSpecialListCellDelegate <NSObject>

- (void)clickToRushProductDetail:(NSInteger)index;

@end

@interface ProductSpecialListCell : UITableViewCell <ProductSpecialCellDelegate>

@property (nonatomic, strong) ProductSpecialCell   *leftCell;
@property (nonatomic, strong) ProductSpecialCell   *rightCell;
@property (nonatomic, strong) id<ProductSpecialListCellDelegate> _delegate;

- (void)reuserTableViewLeftCell:(ProductObj *)leftObj
                        AtIndex:(NSInteger)index;

- (void)reuserTableViewLeftCell:(ProductObj *)leftObj
                        AtIndex:(NSInteger)leftIndex
                   AndRightCell:(ProductObj *)rightObj
                        AtIndex:(NSInteger)rightIndex;

@end
