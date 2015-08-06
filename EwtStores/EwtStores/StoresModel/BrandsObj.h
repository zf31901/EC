//
//  BrandsObj.h
//  Shop
//
//  Created by Harry on 14-1-10.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "BaseModel.h"

@interface BrandsObj : BaseModel

@property (nonatomic, strong) NSString      *name;
@property (nonatomic, strong) NSString      *brandsId;
@property (nonatomic, strong) NSURL         *imageUrl;
@property (nonatomic, strong) NSString      *beginTime;
@property (nonatomic, strong) NSString      *endTime;
@property (nonatomic, strong) NSString      *linkUrl;
@property (nonatomic, assign) BOOL          isChoice;   //依照品牌筛选商品时，标志其是否被选中

@end
