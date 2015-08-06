//
//  BrandsObj.m
//  Shop
//
//  Created by Harry on 14-1-10.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "BrandsObj.h"

#define BRANDNAME   @"brandName"
#define BRANDID     @"brandId"
#define BRANDIMG    @"brandImg"
#define BRANDBEGIN  @"brandBegin"
#define BRANDEND    @"brandEnd"
#define BRANDLINK   @"brandLink"

@implementation BrandsObj

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self != nil)
    {
        self.name       = [aDecoder decodeObjectForKey:BRANDNAME];
        self.brandsId   = [aDecoder decodeObjectForKey:BRANDID];
        self.imageUrl   = [aDecoder decodeObjectForKey:BRANDIMG];
        self.beginTime  = [aDecoder decodeObjectForKey:BRANDBEGIN];
        self.endTime    = [aDecoder decodeObjectForKey:BRANDEND];
        self.linkUrl    = [aDecoder decodeObjectForKey:BRANDLINK];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name      forKey:BRANDNAME];
    [aCoder encodeObject:self.brandsId  forKey:BRANDID];
    [aCoder encodeObject:self.imageUrl  forKey:BRANDIMG];
    [aCoder encodeObject:self.beginTime forKey:BRANDBEGIN];
    [aCoder encodeObject:self.endTime   forKey:BRANDEND];
    [aCoder encodeObject:self.linkUrl   forKey:BRANDLINK];
}

@end
