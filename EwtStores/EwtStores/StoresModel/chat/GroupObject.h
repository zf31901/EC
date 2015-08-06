//
//  GroupObject.h
//  IM
//
//  Created by Jacob on 13-11-18.
//  Copyright (c) 2013年 entcom. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kGROUP_ID @"groupId"
#define kGROUP_NAME @"groupName"
#define kGROUP_USERID @"userId"
#define kGROUP_TYPE @"groupType"

@interface GroupObject : NSObject

@property (nonatomic,retain) NSString* groupId;
@property (nonatomic,retain) NSString* groupName;
@property (nonatomic,retain) NSString* userId;
@property (nonatomic,retain) NSString* groupType; //1:群，2：讨论组

//数据库增删改查
+(BOOL)saveNewGroup:(GroupObject*)aGroup;
+(BOOL)saveNewUser:(GroupObject*)aGroup;
+(BOOL)deleteUserById:(NSString*)userId;
+(BOOL)deleteGroupById:(NSString*)groupId;
+(BOOL)updateUser:(NSString*)newUser;
+(BOOL)updateGroup:(GroupObject*)newGroup;
+(BOOL)haveSaveGroupById:(NSString*)groupId;
+(BOOL)haveSaveUserById:(GroupObject*)aGroup;

+(NSMutableArray*)fetchAllGroupFromLocal;
//+(NSMutableArray*)fetchAllFriendsFromGroup;

//将对象转换为字典
//-(NSDictionary*)toDictionary;
+(UserObject*)userFromDictionary:(NSDictionary*)aDic;

@end
