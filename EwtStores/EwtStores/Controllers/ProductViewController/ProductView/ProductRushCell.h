//
//  ProductRushCell.h
//  Shop
//
//  Created by Harry on 13-12-30.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

// 抢购和banner商品的cell

#import <UIKit/UIKit.h>

typedef enum
{
    RUSH_PRODUCT,
    BANNER_PRODUCT,
}PRODUCT_TYPE;

@protocol ProductRushCellDelegate <NSObject>

- (void)clickToProductDetail:(NSInteger)index;

@end

@class EGOImageView;
@class ProductObj;

@interface ProductRushCell : UITableViewCell
{
    NSInteger       rushHour;
    NSInteger       rushMinute;
    NSInteger       rushSecond;
    NSTimer         *timer;
}

@property (nonatomic, strong) EGOImageView  *proImageView;
@property (nonatomic, strong) UILabel       *proNameLb;
@property (nonatomic, strong) UILabel       *proOldPriceLb;
@property (nonatomic, strong) UILabel       *oldLineLb;
@property (nonatomic, strong) UILabel       *proSalePriceLb;
@property (nonatomic, strong) UILabel       *proTypeLb;
@property (nonatomic, strong) UIButton      *startRushBt;
@property (nonatomic, strong) UILabel       *timeLb;

@property (nonatomic, assign) id<ProductRushCellDelegate> _delegate;

- (void)reuserTableViewCell:(ProductObj *)obj AtIndex:(NSInteger)index AtType:(PRODUCT_TYPE)productType;

@end
