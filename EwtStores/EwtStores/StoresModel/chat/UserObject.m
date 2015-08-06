//
//  UserObject.m
//
//  Created by Reese on 13-8-11.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "UserObject.h"
#import "FMDatabase.h"
#import "FMResultSet.h"

@implementation UserObject
@synthesize userDescription,userHead,userId,userNickname,friendFlag,onLine,mark;


+(BOOL)saveNewUser:(UserObject*)aUser
{
   
    
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return NO;
    };
    
    [UserObject checkTableCreatedInDb:db];
    
    NSString *insertStr=@"INSERT INTO 'cUser' ('userId','userNickname','userDescription','userHead','friendFlag') VALUES (?,?,?,?,?)";
    BOOL worked = [db executeUpdate:insertStr,aUser.userId,aUser.userNickname,aUser.userDescription,aUser.userHead,aUser.friendFlag];
   // FMDBQuickCheck(worked);

    
    
    [db close];

    
    return worked;
}

+(BOOL)haveSaveUserById:(NSString*)userId
{
    
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return YES;
    };
    [UserObject checkTableCreatedInDb:db];
    
    FMResultSet *rs=[db executeQuery:@"select count(*) from cUser where userId=?",userId];
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
+(BOOL)updateUser:(UserObject*)newUser
{
    
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return NO;
    };
    [UserObject checkTableCreatedInDb:db];
    BOOL worked=[db executeUpdate:@"update cUser set friendFlag=1 where userId=?",newUser.userId];
    
    return worked;

}

+(NSMutableArray*)fetchAllFriendsFromLocal
{
    NSMutableArray *resultArr=[[NSMutableArray alloc]init];
    
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return resultArr;
    };
    [UserObject checkTableCreatedInDb:db];
    
    FMResultSet *rs=[db executeQuery:@"select * from cUser where friendFlag=?",[NSNumber numberWithInt:1]];
    while ([rs next]) {
        UserObject *user=[[UserObject alloc]init];
        user.userId=[rs stringForColumn:kUSER_ID];
        user.userNickname=[rs stringForColumn:kUSER_NICKNAME];
        user.userHead=[rs stringForColumn:kUSER_USERHEAD];
        user.userDescription=[rs stringForColumn:kUSER_DESCRIPTION];
        user.friendFlag=[NSNumber numberWithInt:1];
        [resultArr addObject:user];
    }
    [rs close];
    return resultArr;
    
}

+(NSMutableArray*)fetchAllGroupsFromLocal
{
    NSMutableArray *resultArr=[[NSMutableArray alloc]init];
    
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return resultArr;
    };
    [UserObject checkTableCreatedInDb:db];
    
    FMResultSet *rs=[db executeQuery:@"select * from cUser where friendFlag=?",[NSNumber numberWithInt:1]];
    while ([rs next]) {
        UserObject *user=[[UserObject alloc]init];
        user.userId=[rs stringForColumn:kUSER_ID];
        user.userNickname=[rs stringForColumn:kUSER_NICKNAME];
        user.userHead=[rs stringForColumn:kUSER_USERHEAD];
        user.userDescription=[rs stringForColumn:kUSER_DESCRIPTION];
        user.friendFlag=[NSNumber numberWithInt:1];
        [resultArr addObject:user];
    }
    [rs close];
    return resultArr;
    
}

+(NSString*)userNameById:(NSString*)userId
{
    NSString *userName=@"";
    
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return userName;
    };
    [UserObject checkTableCreatedInDb:db];
    
    FMResultSet *rs=[db executeQuery:@"select userNickname from cUser where userId=?",userId];
    while ([rs next]) {
        userName = [rs stringForColumn:kUSER_NICKNAME];
    }
    [rs close];
    return userName;
}

+(UserObject*)userFromDictionary:(NSDictionary*)aDic
{
    UserObject *user=[[UserObject alloc]init];
    [user setUserId:[[aDic objectForKey:kUSER_ID]stringValue]];
    [user setUserHead:[aDic objectForKey:kUSER_USERHEAD]];
    [user setUserDescription:[aDic objectForKey:kUSER_DESCRIPTION]];
    [user setUserNickname:[aDic objectForKey:kUSER_NICKNAME]];
    return user;
}

-(NSDictionary*)toDictionary
{
    NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:userId,kUSER_ID,userNickname,kUSER_NICKNAME,onLine,kUSER_ONLINE, userDescription,kUSER_DESCRIPTION,userHead,kUSER_USERHEAD,mark,kUSER_MARK, friendFlag,kUSER_FRIEND_FLAG, nil];
    return dic;
}


+(BOOL)checkTableCreatedInDb:(FMDatabase *)db
{
    NSString *createStr=@"CREATE  TABLE  IF NOT EXISTS 'cUser' ('userId' VARCHAR PRIMARY KEY  NOT NULL  UNIQUE , 'userNickname' VARCHAR, 'onLine' VARCHAR, 'userDescription' VARCHAR, 'userHead' VARCHAR, 'mark' INT,'friendFlag' INT)";
    
    BOOL worked = [db executeUpdate:createStr];
    FMDBQuickCheck(worked);
    return worked;

}

@end
