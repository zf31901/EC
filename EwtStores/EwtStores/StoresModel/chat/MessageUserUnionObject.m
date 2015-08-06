//
//  WCMessageUserUnionObject.m
//  微信
//
//  Created by Reese on 13-8-15.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "MessageUserUnionObject.h"

@implementation MessageUserUnionObject
@synthesize message,user;


+(MessageUserUnionObject *)unionWithMessage:(MessageObject *)aMessage andUser:(id)aUser
{
    MessageUserUnionObject *unionObject=[[MessageUserUnionObject alloc]init];
    [unionObject setUser:aUser];
    [unionObject setMessage:aMessage];
    return unionObject;
}



@end
