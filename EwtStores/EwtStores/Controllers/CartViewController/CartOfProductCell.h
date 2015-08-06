//
//  CartOfProductCell.h
//  Shop
//
//  Created by Harry on 14-1-2.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EGOImageView.h"
@class ProductObj;

@protocol CartOfProductCellDelegate <NSObject>

@optional
- (void)editProductAtIndex:(NSInteger)index AndEditStatus:(BOOL)isEdit AndCurrentNum:(NSInteger)num; //二期放弃
- (void)removeProductAtIndex:(NSInteger)index; //二期放弃
- (void)editProductAtIndex:(NSInteger)index AndCurrentNum:(NSInteger)num andIsChoicedTap:(BOOL)isChoiceTap; //二期使用

@end

@interface CartOfProductCell : UITableViewCell

@property (nonatomic, strong) UIView        *leftView;
@property (nonatomic, strong) UIView        *rightView;

@property (nonatomic, strong) UILabel       *priceLb;
@property (nonatomic, strong) UIButton      *statusBt;
@property (nonatomic, strong) UIButton      *editBt;
@property (nonatomic, strong) EGOImageView  *productImgView;
@property (nonatomic, strong) UILabel       *nameLb;
@property (nonatomic, strong) UILabel       *numLb;
@property (nonatomic, strong) UILabel       *colorLb;
@property (nonatomic, strong) UILabel       *choiceNumLb;
@property (nonatomic, strong) UILabel       *currentPriceLb;
@property (nonatomic, strong) UIButton      *removeBt;

@property (nonatomic, strong) id<CartOfProductCellDelegate> _delegate;
@property (nonatomic, assign) BOOL          isEditStatus;
@property (nonatomic, assign) NSInteger     totalNum;   //商品库存
@property (nonatomic, assign) NSInteger     productNum; //选择的商品个数
@property (nonatomic, assign) NSInteger     currentIndex; //列表的第几个商品
@property (nonatomic, strong) ProductObj    *currentObj;

- (void)reuserTableViewCell:(ProductObj *)obj AtIndex:(NSInteger)index;

@end
