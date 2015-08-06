//
//  WCMessageUserUnionObject.h
//  微信
//
//  Created by Reese on 13-8-15.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageObject.h"

@interface MessageUserUnionObject : NSObject
@property (nonatomic,retain) MessageObject* message;
@property (nonatomic,retain) id user;

+(MessageUserUnionObject *)unionWithMessage:(MessageObject *)aMessage andUser:(id)aUser;
@end
