//
//  GroupObject.m
//  IM
//
//  Created by Jacob on 13-11-18.
//  Copyright (c) 2013年 entcom. All rights reserved.
//

#import "GroupObject.h"
#import "FMDatabase.h"
#import "FMResultSet.h"

@implementation GroupObject


+(BOOL)saveNewGroup:(GroupObject*)aGroup
{
    
    
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return NO;
    };
    
    [GroupObject checkTableCreatedInDb:db];
    
    NSLog(@"保存群资料");
    
    NSString *insertStr=@"INSERT INTO 'groups' ('groupId','groupName','groupType','userId') VALUES (?,?,?,?)";
    BOOL worked = [db executeUpdate:insertStr,aGroup.groupId,aGroup.groupName,aGroup.groupType,aGroup.userId];
    FMDBQuickCheck(worked);
    [db close];
    
    
    return worked;
}
+(BOOL)saveNewUser:(GroupObject*)aGroup
{
    
    
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return NO;
    };
    
    [GroupObject checkTableCreatedInDb:db];
    
    NSString *insertStr=@"INSERT INTO 'groupUser' ('groupId','userId') VALUES (?,?)";
    BOOL worked = [db executeUpdate:insertStr,aGroup.groupId,aGroup.userId];
    
    [db close];
    
    
    return worked;
}


+(BOOL)haveSaveGroupById:(NSString*)groupId
{
    
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return YES;
    };
    [GroupObject checkTableCreatedInDb:db];
    
    FMResultSet *rs=[db executeQuery:@"select count(*) from groups where groupId=?",groupId];
    while ([rs next]) {
        int count= [rs intForColumnIndex:0];
        
        if (count!=0){
            [rs close];
            return YES;
        }else
        {
            [rs close];
            return NO;
        }
        
    };
    [rs close];
    return YES;
    
}
+(BOOL)haveSaveUserById:(GroupObject*)aGroup
{
    
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return YES;
    };
    [GroupObject checkTableCreatedInDb:db];
    
    FMResultSet *rs=[db executeQuery:@"select count(*) from groupUser where userId=? and groupId=?",aGroup.userId,aGroup.groupId];
    while ([rs next]) {
        int count= [rs intForColumnIndex:0];
        
        if (count!=0){
            [rs close];
            return YES;
        }else
        {
            [rs close];
            return NO;
        }
        
    };
    [rs close];
    return YES;
    
}
+(BOOL)deleteUserById:(NSNumber*)userId
{
    return NO;
    
}
+(BOOL)deleteGroupById:(NSString*)groupId
{
    return NO;
    
}

+(BOOL)updateUser:(NSString*)newUser{

    return NO;
}

+(BOOL)updateGroup:(GroupObject*)newGroup
{
    
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return NO;
    };
    [GroupObject checkTableCreatedInDb:db];
    BOOL worked=[db executeUpdate:@"update groups set groupName=?,groupType=?,userId=?  where groupId=?",newGroup.groupName,newGroup.groupType,newGroup.userId,newGroup.groupId];
    
    return worked;
    
}

+(NSMutableArray*)fetchAllGroupFromLocal
{
    NSMutableArray *resultArr=[[NSMutableArray alloc]init];
    
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return resultArr;
    };
    [GroupObject checkTableCreatedInDb:db];
    
    FMResultSet *rs=[db executeQuery:@"select groupId,groupName from groups where userId=? and groupType=1",[[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_ID]];
    while ([rs next]) {
        GroupObject *group=[[GroupObject alloc]init];
        group.groupId=[rs stringForColumn:kGROUP_ID];
        group.groupName=[rs stringForColumn:kGROUP_NAME];
        [resultArr addObject:group];
    }
    [rs close];
    return resultArr;
    
}

+(GroupObject*)userFromDictionary:(NSDictionary*)aDic
{
    GroupObject *group=[[GroupObject alloc]init];
    [group setGroupId:[aDic objectForKey:kGROUP_ID]];
    [group setGroupName:[aDic objectForKey:kGROUP_NAME]];
    [group setUserId:[aDic objectForKey:kGROUP_USERID]];
    [group setGroupType:[aDic objectForKey:kGROUP_TYPE]];
    return group;
}
/*
-(NSDictionary*)toDictionary
{
    NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:userId,kUSER_ID,userNickname,kUSER_NICKNAME,onLine,kUSER_ONLINE, userDescription,kUSER_DESCRIPTION,userHead,kUSER_USERHEAD,mark,kUSER_MARK, friendFlag,kUSER_FRIEND_FLAG, nil];
    return dic;
}
*/

+(BOOL)checkTableCreatedInDb:(FMDatabase *)db
{
    NSString *createStr=@"CREATE  TABLE  IF NOT EXISTS 'groups' ('groupId' VARCHAR , 'groupName' VARCHAR, 'groupType' VARCHAR, 'userId' VARCHAR)";
    BOOL worked = [db executeUpdate:createStr];
    FMDBQuickCheck(worked);
    
    NSString *createStr2=@"CREATE  TABLE  IF NOT EXISTS 'groupUser' ('groupId' VARCHAR , 'userId' VARCHAR)";
    BOOL worked2 = [db executeUpdate:createStr2];
    FMDBQuickCheck(worked2);
    
    return worked&&worked2;
    
}


@end
