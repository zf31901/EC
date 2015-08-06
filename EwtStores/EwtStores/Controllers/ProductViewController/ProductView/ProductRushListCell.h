//
//  ProductRushListCell.h
//  Shop
//
//  Created by Harry on 13-12-30.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProductObj;
#import "ProductRushCell.h"

@protocol ProductRushListCellDelegate <NSObject>

- (void)clickToRushProductDetail:(NSInteger)index;

@end

@interface ProductRushListCell : UITableViewCell <ProductRushCellDelegate>

@property (nonatomic, strong) ProductRushCell   *leftCell;
@property (nonatomic, strong) ProductRushCell   *rightCell;
@property (nonatomic, strong) id<ProductRushListCellDelegate> _delegate;

- (void)reuserTableViewLeftCell:(ProductObj *)leftObj
                        AtIndex:(NSInteger)index
                         AtType:(PRODUCT_TYPE)type;

- (void)reuserTableViewLeftCell:(ProductObj *)leftObj
                        AtIndex:(NSInteger)leftIndex
                   AndRightCell:(ProductObj *)rightObj
                        AtIndex:(NSInteger)rightIndex
                         AtType:(PRODUCT_TYPE)type;



@end
