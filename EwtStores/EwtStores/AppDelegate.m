//
//  AppDelegate.m
//  EwtStores
//
//  Created by Harry on 13-11-30.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

/***************************
 * 该项目中的navBar全部自定义（UIView），但是使用了NavC的push和pop方法；
 * 兼容ios6_7界面位置，以ios6做基准位置
 * 以ios7界面风格做基准，xcode5.0.2（5A3005）
 ***************************/

#import "AppDelegate.h"

#import "HomeViewController.h"
#import "ProductViewController.h"
#import "CartViewController.h"
#import "SelfViewController.h"

#import "UserObj.h"

#import "UMSocial.h"
#import "MobClick.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>

#define WELCOME_IMG_COUNT 4

@implementation AppDelegate
#pragma mark -welcomeView
- (void)loadWelcomeView
{
    
    //tag bg harry 2014-02-21 开机引导更换
    /*
    if(Main_Size.height <= 480){
        self.comeBt = [GlobalMethod BuildButtonWithFrame:CGRectMake(50, Main_Size.height - 62.5, 220, 44)
                                               andOffImg:@"btn440_off"
                                                andOnImg:@"btn440_on"
                                               withTitle:@"猛戳进入"];
        

    }else{
        self.comeBt = [GlobalMethod BuildButtonWithFrame:CGRectMake(50, Main_Size.height - 95, 220, 44)
                                               andOffImg:@"btn440_off"
                                                andOnImg:@"btn440_on"
                                               withTitle:@"猛戳进入"];
        
    }
    [self.comeBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.comeBt addTarget:self action:@selector(removeWelcomeView) forControlEvents:UIControlEventTouchUpInside];
    
    //手机引导滑动界面
    self.welcomeView = [[UIScrollView alloc] initWithFrame:self.window.frame];
    [self.welcomeView setBackgroundColor:[UIColor clearColor]];
    [self.welcomeView setDelegate:self];
    [self.welcomeView setScrollEnabled:YES];
    [self.welcomeView setShowsHorizontalScrollIndicator:NO];
    [self.welcomeView setShowsVerticalScrollIndicator:NO];
    [self.welcomeView setPagingEnabled:YES];
    [self.welcomeView setContentSize:CGSizeMake(Main_Size.width * WELCOME_IMG_COUNT, Main_Size.height)];
    [self.window addSubview:self.welcomeView];
    [self.window bringSubviewToFront:self.welcomeView];
    
    for(int i=0; i<WELCOME_IMG_COUNT; i++)
    {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(Main_Size.width * i, 0, Main_Size.width, Main_Size.height)];
        
        if(Main_Size.height > 480){
            [imgView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"welcome_bg5%d",i+1]]];
        }else{
            [imgView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"welcome_bg4%d",i+1]]];
        }
        
        [self.welcomeView addSubview:imgView];
        
        UIImageView *phoneView = [[UIImageView alloc] initWithFrame:CGRectMake(164 * i, 0, 164, 291)];
        [phoneView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"img4&5_%d",i+1]]];
        [self.phoneScrolView addSubview:phoneView];
    }
    
    [self.window addSubview:self.phoneBgView];
    
    [self.window addSubview:self.comeBt];
    */
    
    
    UIImage *phone_bg;
    if(Main_Size.height <= 480){
        self.comeBt = [GlobalMethod BuildButtonWithFrame:CGRectMake(0, Main_Size.height - 62.5, 320, 62.5)
                                               andOffImg:@"btn4_off"
                                                andOnImg:@"btn4_on"
                                               withTitle:nil];
        
        phone_bg = [UIImage imageNamed:@"phone4_bg"];
    }else{
        self.comeBt = [GlobalMethod BuildButtonWithFrame:CGRectMake(0, Main_Size.height - 95, 320, 95)
                                               andOffImg:@"btn5_off"
                                                andOnImg:@"btn5_on"
                                               withTitle:nil];
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"phone5_bg@2x" ofType:@"png"];
        phone_bg = [UIImage imageWithContentsOfFile:filePath];
    }
    
    [self.comeBt addTarget:self action:@selector(removeWelcomeView) forControlEvents:UIControlEventTouchUpInside];
    
    //虚拟手机背景
    self.phoneBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, Main_Size.height - phone_bg.size.height, phone_bg.size.width, phone_bg.size.height)];
    [self.phoneBgView setImage:phone_bg];
    
    //手机引导滑动界面
    self.welcomeView = [[UIScrollView alloc] initWithFrame:self.window.frame];
    [self.welcomeView setBackgroundColor:[UIColor clearColor]];
    [self.welcomeView setDelegate:self];
    [self.welcomeView setScrollEnabled:YES];
    [self.welcomeView setShowsHorizontalScrollIndicator:NO];
    [self.welcomeView setShowsVerticalScrollIndicator:NO];
    [self.welcomeView setPagingEnabled:YES];
    [self.welcomeView setContentSize:CGSizeMake(Main_Size.width * WELCOME_IMG_COUNT, Main_Size.height)];
    [self.window addSubview:self.welcomeView];
    [self.window bringSubviewToFront:self.welcomeView];
    
    //虚拟手机引导滑动界面
    self.phoneScrolView = [[UIScrollView alloc] initWithFrame:CGRectMake(79, 60, 164, 291)];
    [self.phoneScrolView setBackgroundColor:RGBS(238)];
    [self.phoneScrolView setScrollEnabled:YES];
    [self.phoneScrolView setShowsHorizontalScrollIndicator:NO];
    [self.phoneScrolView setShowsVerticalScrollIndicator:NO];
    [self.phoneScrolView setPagingEnabled:YES];
    [self.phoneScrolView setContentSize:CGSizeMake(164 * WELCOME_IMG_COUNT, 291)];
    [self.phoneBgView addSubview:self.phoneScrolView];
    
    for(int i=0; i<WELCOME_IMG_COUNT; i++)
    {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(Main_Size.width * i, 0, Main_Size.width, Main_Size.height)];
        
        if(Main_Size.height > 480){
            
            NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"welcome5_%d_bg@2x",i+1] ofType:@"png"];
            
            [imgView setImage:[UIImage imageWithContentsOfFile:filePath]];
        }else{
            NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"welcome4_%d_bg@2x",i+1] ofType:@"png"];
            
            [imgView setImage:[UIImage imageWithContentsOfFile:filePath]];
        }
        
        [self.welcomeView addSubview:imgView];
        
        UIImageView *phoneView = [[UIImageView alloc] initWithFrame:CGRectMake(164 * i, 0, 164, 291)];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"img4&5_%d@2x",i+1] ofType:@"png"];
        [phoneView setImage:[UIImage imageWithContentsOfFile:filePath]];
        [self.phoneScrolView addSubview:phoneView];
    }
    
    [self.window addSubview:self.phoneBgView];

    [self.window addSubview:self.comeBt];
}

- (void)removeWelcomeView
{
    [self.tabBarC.view setAlpha:0.7];
    
    [self.welcomeView removeFromSuperview];
    [self.welcomeView setBackgroundColor:[UIColor clearColor]];
    
    [self.comeBt removeFromSuperview];
    [self.comeBt setBackgroundColor:[UIColor clearColor]];
    
    [self.phoneBgView removeFromSuperview];
    [self.phoneBgView setBackgroundColor:[UIColor clearColor]];
    
    [self.tabBarC.view setFrame:CGRectMake(0, 0, Main_Size.width, self.tabBarC.view.height)];
    [self.tabBarC.tabBar setFrame:CGRectMake(0, self.tabBarC.tabBar.top, Main_Size.width, self.tabBarC.tabBar.height)];
    
    [self.homeNC.view setFrame:CGRectMake(0, 0, Main_Size.width, self.window.height)];
    
    [UIView animateWithDuration:0.5 animations:^{

        [self.window setBackgroundColor:RGBS(238)];
        [self.tabBarC.view setAlpha:1];
    }];
    
    [GlobalMethod saveObject:@"1" withKey:ISFIRST_COMING];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView == self.welcomeView){
        
        if(scrollView.contentOffset.x <= 0){
            //控制第一张开机界面不能想右滑动
            [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
        }else if(scrollView.contentOffset.x >= (Main_Size.width * (WELCOME_IMG_COUNT - 1) + 80)){
            //最后一页向左滑动超过100dh时，引导界面消失
            [scrollView setScrollEnabled:NO];
            [self removeWelcomeView];
        }
        
        if(scrollView.contentOffset.x > (Main_Size.width * (WELCOME_IMG_COUNT - 1))){
            
            //首页渐变显示动画
            float plusAlpha = scrollView.contentOffset.x - (Main_Size.width * (WELCOME_IMG_COUNT - 1));
            
            if(plusAlpha*2/Main_Size.width < 1){
                [self.tabBarC.view setAlpha:plusAlpha*2/Main_Size.width];
            }
            
            if(8 > plusAlpha/30){
                [self.homeNC.view setFrame:CGRectMake(0, 8 - plusAlpha/30, Main_Size.width - 8 + plusAlpha/30, self.homeNC.view.height)];
                
                if([UIDevice currentDevice].systemVersion.floatValue >= 7.0){
                    [self.tabBarC.view setFrame:CGRectMake(0, 0, Main_Size.width - 8 + plusAlpha/30, self.homeNC.view.height)];
                }else{
                    [self.tabBarC.tabBar setFrame:CGRectMake(0, self.tabBarC.tabBar.top, Main_Size.width - 8 + plusAlpha/30, self.tabBarC.tabBar.height)];
                }
            }
        }else{
            
            //最后一页，虚拟手机里的开机图不移动
            [self.phoneScrolView setContentOffset:CGPointMake(scrollView.contentOffset.x * 164 / Main_Size.width, 0) animated:NO];
        }
    }
}


#pragma mark -ApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.canConnectSocket = YES;
    self.socketManager = [[SocketManager alloc] initWithDelegate:self];
    
    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, Main_Size.width, Main_Size.height)];
    
    self.tabBarC = [[UITabBarController alloc] init];
    [self.tabBarC setViewControllers:[self buildTabBar]];
    [self.tabBarC setDelegate:self];
    [self.tabBarC.tabBar setBackgroundImage:[UIImage imageNamed:@"Tabbar_Bg"]];
    [self.window setRootViewController:self.tabBarC];
    
    [self.window setBackgroundColor:RGBS(0)];
    [self.window makeKeyAndVisible];
    
//    if( ![[GlobalMethod getObjectForKey:ISFIRST_COMING] boolValue] ){
//        [self loadWelcomeView];
//    }
    
    NSString *urlStr = @"https://my.ewt.cc/Tool/Html%E5%B8%B8%E7%94%A8%E6%A8%A1%E6%9D%BF/301.html";
    
    [MobClick startWithAppkey:@"52e1cbd656240b5a2209d810" reportPolicy:SEND_ON_EXIT channelId:nil];
    [MobClick setLogEnabled:YES];
    [UMSocialData setAppKey:@"52e1cbd656240b5a2209d810"];
    [UMSocialConfig setWXAppId:@"wxf03b8f85ab54aae1" url:urlStr];
    
    //需要#import <TencentOpenAPI/QQApiInterface.h>  #import <TencentOpenAPI/TencentOAuth.h>
    //设置手机QQ的AppId，url传nil，将使用友盟的网址
    [UMSocialConfig setQQAppId:@"101022908" url:urlStr importClasses:@[[QQApiInterface class],[TencentOAuth class]]];
    
    return YES;
}

- (NSArray *)buildTabBar
{
    NSDictionary *textDic = [NSDictionary dictionaryWithObjectsAndKeys:NavBarColor,UITextAttributeTextColor,nil];
    
    HomeViewController *homeC = [[HomeViewController alloc] init];
    self.homeNC = [[UINavigationController alloc] initWithRootViewController:homeC];
    [self.homeNC setNavigationBarHidden:YES];
    [self.homeNC.tabBarItem setTitle:@"首页"];
    [self.homeNC.tabBarItem setTitleTextAttributes:textDic forState:UIControlStateSelected];
    [self.homeNC.tabBarItem setFinishedSelectedImage:[[UIImage imageNamed:@"Home_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] withFinishedUnselectedImage:[UIImage imageNamed:@"Home_off"]];
    
    ProductViewController *proC = [[ProductViewController alloc] init];
    UINavigationController *proNC = [[UINavigationController alloc] initWithRootViewController:proC];
    [proNC setNavigationBarHidden:YES];
    [proNC.tabBarItem setTitle:@"分类"];
    [proNC.tabBarItem setTitleTextAttributes:textDic forState:UIControlStateSelected];
    [proNC.tabBarItem setFinishedSelectedImage:[[UIImage imageNamed:@"Product_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] withFinishedUnselectedImage:[UIImage imageNamed:@"Product_off"]];
    
    CartViewController *cartC = [[CartViewController alloc] init];
    UINavigationController *cartNC = [[UINavigationController alloc] initWithRootViewController:cartC];
    [cartNC setNavigationBarHidden:YES];
    [cartNC.tabBarItem setTitle:@"购物车"];
    [cartNC.tabBarItem setTitleTextAttributes:textDic forState:UIControlStateSelected];
    [cartNC.tabBarItem setFinishedSelectedImage:[[UIImage imageNamed:@"Cart_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] withFinishedUnselectedImage:[UIImage imageNamed:@"Cart_off"]];
    
    SelfViewController *selfC = [[SelfViewController alloc] init];
    UINavigationController *selfNC = [[UINavigationController alloc] initWithRootViewController:selfC];
    [selfNC setNavigationBarHidden:YES];
    [selfNC.tabBarItem setTitle:@"我"];
    [selfNC.tabBarItem setTitleTextAttributes:textDic forState:UIControlStateSelected];
    [selfNC.tabBarItem setFinishedSelectedImage:[[UIImage imageNamed:@"Self_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]withFinishedUnselectedImage:[UIImage imageNamed:@"Self_off"]];
    
    return [NSArray arrayWithObjects:self.homeNC,proNC,cartNC,selfNC,nil];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //连接socket
    /*if ( self.socketManager ) {
        [self connectSocket];
    }*/
    
    [UMSocialSnsService  applicationDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    
}

#pragma mark
#pragma mark - AsyncSocketDelegate

-(BOOL)isConnected
{
    return (self.socketManager && [self.socketManager isConnected]);
}

-(void)connectSocket:(NSTimeInterval)timeout
{
    if (self.socketManager && self.canConnectSocket) {
        [self.socketManager connectSocket:timeout];
    }
}

-(void)connectSocket
{
    [self connectSocket:SOCKET_CONNECT_TIMEOUT];
}

-(void)sendData:(NSData *)data
{
    if (self.socketManager) {
        [self.socketManager sendData:data];
    } else {
        NSLog(@"socketManager is nil");
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return  [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil];
}

@end
