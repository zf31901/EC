//
//  cMessageObject.m
//  微信
//
//  Created by Reese on 13-8-11.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "MessageObject.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
@implementation MessageObject
@synthesize messageContent,messageDate,messageFrom,messageTo,messageType,messageId;

+(MessageObject *)messageWithType:(int)aType{
    MessageObject *msg=[[MessageObject alloc]init];
    [msg setMessageType:[NSNumber numberWithInt:aType]];
    return  msg;
}
+(MessageObject*)messageFromDictionary:(NSDictionary*)aDic
{
    MessageObject *msg=[[MessageObject alloc]init];
    [msg setMessageFrom:[aDic objectForKey:kMESSAGE_FROM]];
    [msg setMessageTo:[aDic objectForKey:kMESSAGE_TO]];
    [msg setMessageContent:[aDic objectForKey:kMESSAGE_CONTENT]];
    [msg setMessageDate:[aDic objectForKey:kMESSAGE_DATE]];
    [msg setMessageDate:[aDic objectForKey:kMESSAGE_TYPE]];
    return  msg;
}


//将对象转换为字典
-(NSDictionary*)toDictionary
{
    NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:messageId,kMESSAGE_ID,messageFrom,kMESSAGE_FROM,messageTo,kMESSAGE_TO,messageContent,kMESSAGE_TYPE,messageDate,kMESSAGE_DATE,messageType,kMESSAGE_TYPE, nil];
    return dic;
    
}

//增删改查

+(BOOL)save:(MessageObject*)aMessage
{
    
    
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return NO;
    };
    
    NSString *createStr=@"CREATE  TABLE  IF NOT EXISTS 'cMessage' ('messageId' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL  UNIQUE , 'messageFrom' VARCHAR, 'messageTo' VARCHAR, 'messageContent' VARCHAR, 'messageDate' DATETIME,'messageType' INTEGER ,'currentUser' VARCHAR)";
    
    BOOL worked = [db executeUpdate:createStr];
    FMDBQuickCheck(worked);
    
    NSLog(@"创建数据库");
    [db beginTransaction];
    
    NSString *insertStr=@"INSERT INTO 'cMessage' ('messageFrom','messageTo','messageContent','messageDate','messageType','currentUser') VALUES (?,?,?,?,?,?)";
    worked = [db executeUpdate:insertStr,aMessage.messageFrom,aMessage.messageTo,aMessage.messageContent,aMessage.messageDate,aMessage.messageType,[[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_ID]];
    FMDBQuickCheck(worked);
    [db commit];
    
    
    [db close];
    //发送全局通知,会循环调用sendMessage
    //[[NSNotificationCenter defaultCenter]postNotificationName:kXMPPNewMsgNotifaction object:aMessage ];
   

    
    return worked;
}




//获取某联系人聊天记录
+(NSMutableArray*)fetchMessageListWithUser:(NSString *)userId byPage:(int)pageInde
{
    NSMutableArray *messageList=[[NSMutableArray alloc]init];
    
    FMDatabase *db=[FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"数据打开失败");
        return messageList;
    }
    
    NSString *queryString=@"select * from cMessage where (messageFrom=? or messageTo= ?) and (messageFrom=? or messageTo= ?) and currentUser=? order by messageDate";
    NSObject *obj = [[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_ID];
    
    FMResultSet *rs=[db executeQuery:queryString,userId,userId,obj,obj,obj];
    while ([rs next]) {
        MessageObject *message=[[MessageObject alloc]init];
        [message setMessageId:[rs objectForColumnName:kMESSAGE_ID]];
        [message setMessageContent:[rs stringForColumn:kMESSAGE_CONTENT]];
        [message setMessageDate:[rs dateForColumn:kMESSAGE_DATE]];
        [message setMessageFrom:[rs stringForColumn:kMESSAGE_FROM]];
        [message setMessageTo:[rs stringForColumn:kMESSAGE_TO]];
        [message setMessageType:[rs objectForColumnName:kMESSAGE_TYPE]];
        [ messageList addObject:message];
        
    }
    return  messageList;
    
}

//获取某群组聊天记录
+(NSMutableArray*)fetchMessageListWithGroup:(NSString *)groupId byPage:(int)pageInde
{
    NSMutableArray *messageList=[[NSMutableArray alloc]init];
    
    FMDatabase *db=[FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"数据打开失败");
        return messageList;
    }
    
    NSString *queryString=@"select * from cMessage where messageTo= ? and currentUser=? order by messageDate";
    
    FMResultSet *rs=[db executeQuery:queryString,groupId,[[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_ID]];
    while ([rs next]) {
        MessageObject *message=[[MessageObject alloc]init];
        [message setMessageId:[rs objectForColumnName:kMESSAGE_ID]];
        [message setMessageContent:[rs stringForColumn:kMESSAGE_CONTENT]];
        [message setMessageDate:[rs dateForColumn:kMESSAGE_DATE]];
        [message setMessageFrom:[rs stringForColumn:kMESSAGE_FROM]];
        [message setMessageTo:[rs stringForColumn:kMESSAGE_TO]];
        [message setMessageType:[rs objectForColumnName:kMESSAGE_TYPE]];
        [ messageList addObject:message];
        
    }
    return  messageList;
    
}

//获取最近联系人
+(NSMutableArray *)fetchRecentChatByPage:(int)pageIndex
{
    NSMutableArray *messageList=[[NSMutableArray alloc]init];
    
    FMDatabase *db=[FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"数据打开失败");
        return messageList;
    }
    
    NSString *queryString=@"select * from cMessage as m ,cUser as u where u.userId<>? and m.currentUser=? and ( u.userId=m.messageFrom or u.userId=m.messageTo ) and m.messageTo not in (select groupId from groups) group by u.userId  order by m.messageDate desc limit ?,10";
    //NSString *queryString=@"select * from cMessage as m ,cUser as u group by u.userId  order by m.messageDate desc limit ?,10";
    NSObject *obj = [[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_ID];
    FMResultSet *rs=[db executeQuery:queryString,obj,obj,[NSNumber numberWithInt:pageIndex-1]];
    //FMResultSet *rs=[db executeQuery:@"select * from cMessage"];
    while ([rs next]) {
        MessageObject *message=[[MessageObject alloc] init];
        [message setMessageId:[rs objectForColumnName:kMESSAGE_ID]];
        [message setMessageContent:[rs stringForColumn:kMESSAGE_CONTENT]];
        [message setMessageDate:[rs dateForColumn:kMESSAGE_DATE]];
        [message setMessageFrom:[rs stringForColumn:kMESSAGE_FROM]];
        [message setMessageTo:[rs stringForColumn:kMESSAGE_TO]];
        [message setMessageType:[rs objectForColumnName:kMESSAGE_TYPE]];
        
        UserObject *user=[[UserObject alloc] init];
        [user setUserId:[rs stringForColumn:kUSER_ID]];
        [user setUserNickname:[rs stringForColumn:kUSER_NICKNAME]];
        [user setUserHead:[rs stringForColumn:kUSER_USERHEAD]];
        [user setUserDescription:[rs stringForColumn:kUSER_DESCRIPTION]];
        [user setFriendFlag:[rs objectForColumnName:kUSER_FRIEND_FLAG]];
        
        MessageUserUnionObject *unionObject=[MessageUserUnionObject unionWithMessage:message andUser:user ];
        
        [ messageList addObject:unionObject];
        
    }
    if (rs == nil) {
       
        MessageObject *message=[[MessageObject alloc]init];
        [message setMessageId:[NSNumber numberWithInt:5]];
        [message setMessageContent:@"你是谁"];
        [message setMessageDate:[NSDate date]];
        [message setMessageFrom:@"张三"];
        [message setMessageTo:@"李四"];
        [message setMessageType:[NSNumber numberWithInt:2]];
        
        UserObject *user=[[UserObject alloc]init];
        [user setUserId:@"110101"];
        [user setUserNickname:@"爱心天地客服"];
        [user setUserHead:@"abc"];
        [user setUserDescription:@"非诚勿扰"];
        [user setFriendFlag:[NSNumber numberWithInt:2]];
        
        MessageUserUnionObject *unionObject=[MessageUserUnionObject unionWithMessage:message andUser:user ];
        
        [ messageList addObject:unionObject];
    }
    //[rs close];
    
    return  messageList;

}

//获取最近群消息
+(NSMutableArray *)fetchGroupChatByPage:(int)pageIndex
{
    NSMutableArray *messageList=[[NSMutableArray alloc]init];
    
    FMDatabase *db=[FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"数据打开失败");
        return messageList;
    }
    
    NSString *queryString=@"select * from cMessage as m ,groups as u where u.userId =? and ( u.groupId=m.messageFrom or u.groupId=m.messageTo ) group by u.groupId  order by m.messageDate desc limit ?,10";
    //NSString *queryString=@"select * from cMessage as m ,cUser as u group by u.userId  order by m.messageDate desc limit ?,10";
    NSObject *obj = [[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_ID];
    FMResultSet *rs=[db executeQuery:queryString,obj,[NSNumber numberWithInt:pageIndex-1]];
    //FMResultSet *rs=[db executeQuery:@"select * from cMessage"];
    while ([rs next]) {
        MessageObject *message=[[MessageObject alloc] init];
        [message setMessageId:[rs objectForColumnName:kMESSAGE_ID]];
        [message setMessageContent:[rs stringForColumn:kMESSAGE_CONTENT]];
        [message setMessageDate:[rs dateForColumn:kMESSAGE_DATE]];
        [message setMessageFrom:[rs stringForColumn:kMESSAGE_FROM]];
        [message setMessageTo:[rs stringForColumn:kMESSAGE_TO]];
        [message setMessageType:[rs objectForColumnName:kMESSAGE_TYPE]];
        
        GroupObject *group=[[GroupObject alloc] init];
        [group setGroupId:[rs stringForColumn:kGROUP_ID]];
        [group setGroupName:[rs stringForColumn:kGROUP_NAME]];
        /*[user setUserHead:[rs stringForColumn:kUSER_USERHEAD]];
        [user setUserDescription:[rs stringForColumn:kUSER_DESCRIPTION]];
        [user setFriendFlag:[rs objectForColumnName:kUSER_FRIEND_FLAG]];*/
        
        MessageUserUnionObject *unionObject=[MessageUserUnionObject unionWithMessage:message andUser:group ];
        
        [ messageList addObject:unionObject];
        
    }
    //[rs close];
    
    return  messageList;
    
}

@end
