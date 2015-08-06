//
//  ActivityObj.m
//  Shop
//
//  Created by Harry on 13-12-30.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "ActivityObj.h"

#define ACTIVITYIMG     @"activityImg"
#define ACTIVITYID      @"activityId"
#define ACTIVUTYNAME    @"activityName"

@implementation ActivityObj

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self != nil)
    {
        self.activityImgUrl = [aDecoder decodeObjectForKey:ACTIVITYIMG];
        self.activityId     = [aDecoder decodeObjectForKey:ACTIVITYID];
        self.activityName   = [aDecoder decodeObjectForKey:ACTIVUTYNAME];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.activityImgUrl    forKey:ACTIVITYIMG];
    [aCoder encodeObject:self.activityId        forKey:ACTIVITYID];
    [aCoder encodeObject:self.activityName      forKey:ACTIVUTYNAME];
}

@end
