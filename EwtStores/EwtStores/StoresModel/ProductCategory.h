//
//  ProductCategory.h
//  Shop
//
//  Created by Harry on 14-1-9.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "BaseModel.h"

@interface ProductCategory : BaseModel

@property (nonatomic, strong) NSURL         *categoryImgUrl;    //商品分类图片
@property (nonatomic, strong) NSString      *cId;               //商品分类Id
@property (nonatomic, strong) NSString      *cPId;              //商品分类父类Id
@property (nonatomic, strong) NSString      *categoryName;      //商品分类名称

@end
