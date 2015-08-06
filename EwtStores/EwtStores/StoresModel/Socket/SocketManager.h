//
//  SocketManager.h
//  IOSAirPurifierProject
//
//  Created by chenheng on 13-10-13.
//  Copyright (c) 2013年 IOSAirPurifierProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"

#define SOCKET_CONNECT_TIMEOUT  10.0f
#define IS_CLOSE_HEART_LOG      YES
//Socket host、port
#define SOCKET_HOST @"183.62.221.219"  //外网
#define SOCKET_PORT 11717
//MessageType
#define VALUE_MSG_RECEIVER                  0x01
#define VALUE_MSG_CONNECTED                 0x02
#define VALUE_MSG_ERROR                     0x03
#define VALUE_MSG_CLOSE                     0x04
//ParamKey
#define KEY_DATA                            @"data"

@protocol SocketResultDelegate <NSObject>

//@required
@optional

- (void) onResult:(NSInteger)type value:(NSDictionary*)value;
@end

@interface SocketManager : NSObject<AsyncSocketDelegate>

@property (nonatomic, strong) NSString *appid;

@property (nonatomic, strong) id<AsyncSocketDelegate> delegate;
//服务器socket的回调
@property (nonatomic, strong) id<SocketResultDelegate> socketDelegate;

@property (nonatomic, strong) NSTimer *connectionTimer;

@property (nonatomic, strong) NSTimer *heartTimer;
//服务器socket
@property (nonatomic, strong) AsyncSocket *asyncSocket;

@property (assign , nonatomic) BOOL isConnected;

@property (assign , nonatomic) BOOL isConnecting;
//socket从服务器接收到的数据
@property (assign , nonatomic) NSMutableData *serverData;
@property (assign , nonatomic) int command;
@property (assign , nonatomic) int totalLen;

- (id)initWithDelegate:(id)delegate;

-(void)sendData:(NSData*)data;



//-(void)connectSocket:(NSInteger)socketType setTimeout:(NSTimeInterval)timeout;
//连接服务器socket
-(void)connectSocket:(NSTimeInterval)timeout;

-(void)connectSocket;


-(void)reconnect:(NSTimer *)timer;

-(void)startHeart;

-(void)stopHeart;
@end
