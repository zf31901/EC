//
//  SocketManager.m
//  IOSAirPurifierProject
//
//  Created by chenheng on 13-10-13.
//  Copyright (c) 2013年 IOSAirPurifierProject. All rights reserved.
//

#import "SocketManager.h"

@implementation SocketManager

- (id)initWithDelegate:(id)delegate
{
    self.delegate = delegate;
    
	return self;
}

-(void)connectSocket {
    [self connectSocket:SOCKET_CONNECT_TIMEOUT];
}

-(void)connectSocket:(NSTimeInterval)timeout
{
    if (!self.asyncSocket) {
        self.asyncSocket = [[AsyncSocket alloc] initWithDelegate:self];
    }
    [self.asyncSocket disconnect];
    if (!self.isConnected && !self.isConnecting) {
        @try {
            NSError *err = nil;
            self.isConnecting = YES;
            if (![self.asyncSocket connectToHost:SOCKET_HOST onPort:SOCKET_PORT withTimeout:timeout error:&err])
            {
                NSLog(@"Error connecting: %@", err);
                self.isConnecting = NO;
            }
            
        }
        @catch (NSException *exception) {
            self.isConnecting = NO;
            NSLog(@"connect exception %@,%@", [exception name], [exception description]);
        }
    } else {
        NSLog(@"No Need Connect Socket!!!");
    }
}


-(void)sendData:(NSData *)data
{
    if (self.asyncSocket && self.isConnected) {
        /*ToolKit *tool = [[ToolKit alloc] init];
        int cmd = [tool byteArrayToInt:NSMakeRange(0, 4) withData:data];
        NSLog(@"cmd ========== %d",cmd);
        if (cmd == 0) {
           [self.asyncSocket writeData:data withTimeout:-1 tag:101];
        } else {
            [self.asyncSocket writeData:data withTimeout:-1 tag:0];
        }*/
        [self.asyncSocket writeData:data withTimeout:-1 tag:0];
    }
}

//param is AsyncSocketDelegate

-(void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    self.isConnected = NO;
    self.isConnecting = NO;
    if (self.socketDelegate && [self.socketDelegate respondsToSelector:@selector(onResult:value:)]) {
        [self.socketDelegate onResult:VALUE_MSG_CLOSE value:nil];
    }
    NSLog(@"AsyncSocket onSocketDidDisconnect!!!!");
}

-(void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    self.isConnected = YES;
    self.isConnecting = NO;
    if (self.connectionTimer) {
        [self.connectionTimer invalidate];
    }
    
    if (self.socketDelegate && [self.socketDelegate respondsToSelector:@selector(onResult:value:)]) {
        [self.socketDelegate onResult:VALUE_MSG_CONNECTED value:nil];
    }
    
    NSLog(@"asyncSocket is connected!");
    
    NSLog(@"Remote Address: %@:%hu", host, port);
    
    NSString *localHost = [sock localHost];
    UInt16 localPort = [sock localPort];
    
    NSLog(@"Local Address: %@:%hu", localHost, localPort);
    
}

-(void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    
    NSLog(@"socketDelegate：%@ ------ ：%d",self.socketDelegate,[self.socketDelegate respondsToSelector:@selector(onResult:value:)]);
    if (self.socketDelegate && [self.socketDelegate respondsToSelector:@selector(onResult:value:)]) {
        [self.socketDelegate onResult:VALUE_MSG_RECEIVER value:[NSDictionary dictionaryWithObjectsAndKeys:data,KEY_DATA, nil]];
    }
    [sock readDataWithTimeout:-1 tag:0];
    
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    
    NSLog(@"AsyncSocket willDisconnectWithError:%@--------%@",sock,err);
    self.isConnecting = NO;
    //连接失败
    self.connectionTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(reconnect:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.connectionTimer forMode:NSDefaultRunLoopMode];
    
    if (self.heartTimer && [self.heartTimer isValid]) {
        [self.heartTimer invalidate];
    }
    
}

-(void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
     //NSLog(@"didWriteDataWithTag!");
}

-(void)reconnect:(NSTimer *)timer
{
    [self connectSocket:SOCKET_CONNECT_TIMEOUT];
}

-(void)readData:(NSTimer *)timer
{
    AsyncSocket *sock = [timer valueForKey:@"userInfo"];
    [sock readDataWithTimeout:-1 tag:0];
}

-(void)startHeart
{
    
    self.heartTimer = [NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(executeHeart:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.heartTimer forMode:NSDefaultRunLoopMode];
}

-(void)stopHeart
{
    if (self.heartTimer && [self.heartTimer isValid]) {
        [self.heartTimer invalidate];
    }
}

-(void)executeHeart:(NSTimer *)timer
{
    NSLog(@"startHeart");
    //发送heart
    //NSString *heart = [CommandService test_buildHeartbeatData:MYAPPDELEGATE.appId];
    NSInteger headArray[] = {7, 0, 0, 20, 1927384650};
    int ll = 20;
    uint8_t len[ll];
    for (int i=0; i<ll; i++) {
        int l = i/4;
        len[i] = (Byte)(headArray[l]>>(8*(3-i%4))&0xff);
    }
    
    NSMutableData *heartData = [[NSMutableData alloc] initWithBytes:len length:20];
    [MYAPPDELEGATE sendData:heartData];
}

-(void)onResult:(NSInteger)type value:(NSDictionary *)value
{
    switch (type) {
        case VALUE_MSG_RECEIVER:
        {
            //NSLog(@"VALUE_MSG_RECEIVER = %@",[value objectForKey:KEY_DATA]);
            NSData *data = [value objectForKey:KEY_DATA];
            int cmd = [GlobalMethod byteArrayToInt:NSMakeRange(0, 4) withData:data];
            int length = [GlobalMethod byteArrayToInt:NSMakeRange(12, 4) withData:data];
            NSLog(@"class:%@--------cmd:%d,length:%d \n", NSStringFromClass([self class]), cmd,length);
            int result = [GlobalMethod byteArrayToInt:NSMakeRange(20, 4) withData:data];
            NSLog(@"sendMessage-result: %d \n", result);
            
        }
            break;
        case VALUE_MSG_CONNECTED:
        {
            NSLog(@"%@ is Connected!!!!!!,",NSStringFromClass([self class]));
        }
            break;
        case VALUE_MSG_ERROR:
        {
            NSLog(@"%@ Connected Error!!!!!!,",NSStringFromClass([self class]));
            
        }
            break;
        case VALUE_MSG_CLOSE:
        {
            NSLog(@"%@ Connected Close!!!!!!,",NSStringFromClass([self class]));
            
        }
            break;
        default:
            break;
    }
}

-(int)data2Int:(NSData *)data  start:(int)startIndex{
    int temp;
    Byte *b=(Byte *)[data bytes];
    temp = (b[startIndex] & 0xff)| (b[startIndex+1] & 0xff) << 8 | (b[startIndex+2] & 0xff) << 16 | (b[startIndex+3] & 0xff) << 24;
    return temp;
}

@end
