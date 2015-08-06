//
//  ProductCategory.m
//  Shop
//
//  Created by Harry on 14-1-9.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "ProductCategory.h"

#define CATEGORYIMG     @"categoryImg"
#define CATEGORYID      @"categoryId"
#define CATEGORYPID     @"categoryPId"
#define CATEGORYNAME    @"categotyName"

@implementation ProductCategory

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self != nil)
    {
        self.categoryImgUrl = [aDecoder decodeObjectForKey:CATEGORYIMG];
        self.cId            = [aDecoder decodeObjectForKey:CATEGORYID];
        self.cPId           = [aDecoder decodeObjectForKey:CATEGORYPID];
        self.categoryName   = [aDecoder decodeObjectForKey:CATEGORYNAME];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.categoryImgUrl    forKey:CATEGORYIMG];
    [aCoder encodeObject:self.cId               forKey:CATEGORYID];
    [aCoder encodeObject:self.cPId              forKey:CATEGORYPID];
    [aCoder encodeObject:self.categoryName      forKey:CATEGORYNAME];
}

@end
