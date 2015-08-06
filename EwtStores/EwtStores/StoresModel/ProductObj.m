//
//  ProductObj.m
//  Shop
//
//  Created by Harry on 13-12-25.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "ProductObj.h"

#define IMGURL      @"imgUrl"
#define NAME        @"name"
#define SALEPRICE   @"salePrice"
#define NUMBER      @"number"

@implementation ProductObj

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self != nil)
    {
        self.imgUrl     = [aDecoder decodeObjectForKey:IMGURL];
        self.name       = [aDecoder decodeObjectForKey:NAME];
        self.salePrice  = [aDecoder decodeObjectForKey:SALEPRICE];
        self.number     = [aDecoder decodeObjectForKey:NUMBER];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.imgUrl        forKey:IMGURL];
    [aCoder encodeObject:self.name          forKey:NAME];
    [aCoder encodeObject:self.salePrice     forKey:SALEPRICE];
    [aCoder encodeObject:self.number        forKey:NUMBER];
}

@end
 