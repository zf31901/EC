//
//  AppDelegate.h
//  EwtStores
//
//  Created by Harry on 13-11-30.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import <UIKit/UIKit.h>

//SocketDelegate
#define MYAPPDELEGATE ((AppDelegate *)[UIApplication sharedApplication].delegate)

@interface AppDelegate : UIResponder <UIApplicationDelegate,UITabBarControllerDelegate,UIScrollViewDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarC;
@property (strong, nonatomic) UINavigationController *homeNC;

@property (strong, nonatomic) UIScrollView *welcomeView;
@property (strong, nonatomic) UIScrollView *phoneScrolView;
@property (strong, nonatomic) UIButton *comeBt;
@property (strong, nonatomic) UIImageView *phoneBgView;
@property (nonatomic,assign)  BOOL      isPush;
@property (nonatomic,assign)  BOOL      isAddCarNC;

//socket
@property (strong ,nonatomic) SocketManager *socketManager;
@property (nonatomic, assign) BOOL canConnectSocket;

-(void)sendData:(NSData*)data;

-(void)connectSocket:(NSTimeInterval)timeout;

-(void)connectSocket;

-(BOOL)isConnected;

@end
