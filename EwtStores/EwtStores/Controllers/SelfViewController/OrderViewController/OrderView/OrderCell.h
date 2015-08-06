//
//  CartOfProductCell.h
//  Shop
//
//  Created by Harry on 14-1-2.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderObj.h"
#import "EGOImageView.h"
@class ProductObj;

@protocol OrderCellDelegate <NSObject>

- (void)editProductAtIndex:(NSInteger)index AndEditStatus:(BOOL)isEdit;
- (void)removeProductAtIndex:(NSInteger)index;

@end

@interface OrderCell : UITableViewCell

@property (nonatomic, strong) UIView        *leftView;
@property (nonatomic, strong) UIView        *rightView;

@property (nonatomic, strong) UILabel       *orderId;
@property (nonatomic, strong) UILabel       *orderTime;
@property (nonatomic, strong) UILabel       *orderState;
/*
@property (nonatomic, strong) UILabel       *priceLb;
@property (nonatomic, strong) EGOImageView  *productImgView;
@property (nonatomic, strong) UILabel       *nameLb;
@property (nonatomic, strong) UILabel       *numLb;
@property (nonatomic, strong) UILabel       *colorLb;
@property (nonatomic, strong) UILabel       *choiceNumLb;
*/
@property (nonatomic, strong) id<OrderCellDelegate> _delegate;
@property (nonatomic, assign) BOOL          isEditStatus;
@property (nonatomic, assign) NSInteger     productNum;

- (void)reuserTableViewCell:(OrderObj *)obj AtIndex:(NSInteger)index;

@end
