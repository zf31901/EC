//
//  UserObject.h
//
//  Created by Reese on 13-8-11.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kUSER_ID @"userId"
#define kUSER_PASSWORD @"password"
#define kUSER_NICKNAME @"userNickname"
#define kUSER_ONLINE @"onLine"
#define kUSER_DESCRIPTION @"userDescription"
#define kUSER_USERHEAD @"userHead"
#define kUSER_MARK @"mark"
#define kUSER_FRIEND_FLAG @"friendFlag"


@interface UserObject : NSObject
@property (nonatomic,retain) NSString* userId;
@property (nonatomic,retain) NSString* userNickname;
@property (nonatomic,retain) NSNumber* onLine; //是否在线
@property (nonatomic,retain) NSString* userDescription;
@property (nonatomic,retain) NSString* userHead;
@property (nonatomic,retain) NSString* mark;  //名称备注
@property (nonatomic,retain) NSNumber* friendFlag;

@property (nonatomic,retain) NSString* city; //所在城市




//数据库增删改查
+(BOOL)saveNewUser:(UserObject*)aUser;
+(BOOL)deleteUserById:(NSNumber*)userId;
+(BOOL)updateUser:(UserObject*)newUser;
+(BOOL)haveSaveUserById:(NSString*)userId;

+(NSMutableArray*)fetchAllFriendsFromLocal;

//将对象转换为字典
-(NSDictionary*)toDictionary;
+(UserObject*)userFromDictionary:(NSDictionary*)aDic;
//查询好友名称
+(NSString*)userNameById:(NSString*)userId;

@end
