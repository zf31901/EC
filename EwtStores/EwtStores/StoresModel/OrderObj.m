//
//  OrderObj.m
//  Shop
//
//  Created by Jacob on 14-1-6.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "OrderObj.h"

#define PRODUCTS    @"products"

@implementation OrderObj

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self != nil)
    {
        self.products   = [aDecoder decodeObjectForKey:PRODUCTS];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.products forKey:PRODUCTS];
}

@end
