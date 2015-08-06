//
//  BaseViewController.m
//  EwtStores
//
//  Created by Harry on 13-11-30.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "BaseViewController.h"

#import "MBProgressHUD.h"

#import "AppDelegate.h"
#import "UIButton+Extensions.h"

@interface BaseViewController () <MBProgressHUDDelegate,UIGestureRecognizerDelegate>
{
    //自定义navBar
    UIView      *barView;
    UIButton    *leftBtn;
    UIButton    *rightBtn;
    UILabel     *titleLb;
    CGRect      leftBtnRect;
    CGRect      rightBtnRect;
    CGRect      titleRect;
}

@end

@implementation BaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        leftBtnRect     = CGRectMake(6, [GlobalMethod AdapterIOS6_7ByIOS6Float:12], 60, 24);
        rightBtnRect    = CGRectMake(Main_Size.width - 40 - 10, [GlobalMethod AdapterIOS6_7ByIOS6Float:10], 40, 24);
        titleRect       = CGRectMake(80, [GlobalMethod AdapterIOS6_7ByIOS6Float:12], 160, 24);
    }
    return self;
}

+ (instancetype)shareInstance
{
    return [[self alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:RGBS(238)];
    
    [self.navigationItem setHidesBackButton:YES];
    if([UIDevice currentDevice].systemVersion.floatValue >= 7.0){
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    
    [self buildBaseNavBar];
}

#pragma mark -自定义NavBar
- (void)buildBaseNavBar
{
    barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Main_Size.width, [GlobalMethod AdapterIOS6_7ByIOS6Float:Navbar_Height])];
    [barView setBackgroundColor:NavBarColor];
        
    UIImage *leftImg = [UIImage imageNamed:@"nav-back"];
    
    leftBtn = [GlobalMethod BuildButtonWithFrame:leftBtnRect
                                                 andOffImg:nil
                                                  andOnImg:nil
                                                 withTitle:@"    返回"];
    [leftBtn setBackgroundImage:leftImg forState:UIControlStateNormal];
    [leftBtn setBackgroundImage:leftImg forState:UIControlStateHighlighted];
    [leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(leftBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setButtonEdgeInsets:UIEdgeInsetsMake(-10, -5, -10, -5)];
    [barView addSubview:leftBtn];
    
    rightBtn = [GlobalMethod BuildButtonWithFrame:rightBtnRect
                                                  andOffImg:@""
                                                   andOnImg:@""
                                                  withTitle:@""];
    [rightBtn addTarget:self action:@selector(rightBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightBtn setButtonEdgeInsets:UIEdgeInsetsMake(-10, -5, -10, -5)];
    [barView addSubview:rightBtn];
    
    titleLb = [GlobalMethod BuildLableWithFrame:titleRect withFont:[UIFont boldSystemFontOfSize:20] withText:@"title"];
    [titleLb setTextColor:[UIColor whiteColor]];
    [titleLb setTextAlignment:NSTextAlignmentCenter];
    [barView addSubview:titleLb];
    
    [self.view addSubview:barView];
}

- (UIView *)getBaseNavBar
{
    return barView;
}

- (UIButton *)getRightButton
{
    return rightBtn;
}

- (void)setNavBarTitle:(NSString *)title
{
    [titleLb setText:title];
}

- (void)setLeftBtnOffImg:(NSString *)offImg andOnImg:(NSString *)onImg andTitle:(NSString *)btnTitle
{
    [leftBtn setImage:nil forState:UIControlStateNormal];
    [leftBtn setImage:nil forState:UIControlStateHighlighted];
    [leftBtn setBackgroundImage:[UIImage imageNamed:offImg] forState:UIControlStateNormal];
    [leftBtn setBackgroundImage:[UIImage imageNamed:onImg]  forState:UIControlStateHighlighted];
    [leftBtn setTitle:btnTitle forState:UIControlStateNormal];
    [leftBtn setTitle:btnTitle forState:UIControlStateHighlighted];
}

- (void)setRightBtnOffImg:(NSString *)offImg andOnImg:(NSString *)onImg andTitle:(NSString *)btnTitle
{
    [rightBtn setBackgroundImage:[UIImage imageNamed:offImg] forState:UIControlStateNormal];
    [rightBtn setBackgroundImage:[UIImage imageNamed:onImg]  forState:UIControlStateHighlighted];
    [rightBtn setTitle:btnTitle forState:UIControlStateNormal];
    [rightBtn setTitle:btnTitle forState:UIControlStateHighlighted];
}

- (void)showLeftBtn{
    [leftBtn setHidden:NO];
}

- (void)hiddenLeftBtn
{
    [leftBtn setHidden:YES];
}

- (void)hiddenRightBtn
{
    [rightBtn setHidden:YES];
}

- (void)showRightBtn{
    [rightBtn setHidden:NO];
}

#pragma mark -子类调用该方法实现按钮点击事件
- (void)leftBtnAction:(UIButton *)btn
{
    DLog(@"父类左边按钮点击");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightBtnAction:(UIButton *)btn
{
    DLog(@"父类右边按钮点击");
}

#pragma mark -显示隐藏navBar
- (void)setNavBarHiddenWithAnimation:(BOOL)isAnimation
{
    if(isAnimation)
    {
        [UIView animateWithDuration:0.3 animations:^
        {
            [barView setFrame:CGRectMake(0, 0 - Navbar_Height - StatusBar_Height, Main_Size.width, Navbar_Height)];
        }];
    }
    else
    {
        [barView setFrame:CGRectMake(0, 0 - Navbar_Height - StatusBar_Height, Main_Size.width, Navbar_Height)];
    }
}

- (void)setNavBarShowWithAnimation:(BOOL)isAnimation
{
    if(isAnimation)
    {
        [UIView animateWithDuration:0.3 animations:^
         {
             [barView setFrame:CGRectMake(0, 0, Main_Size.width, [GlobalMethod AdapterIOS6_7ByIOS6Float:Navbar_Height])];
         }];
    }
    else
    {
        [barView setFrame:CGRectMake(0, 0, Main_Size.width, [GlobalMethod AdapterIOS6_7ByIOS6Float:Navbar_Height])];
    }
}

#pragma mark -显示隐藏tabBar
- (void)setTabBarHiddenWithAnimation:(BOOL)isAnimation
{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    if(isAnimation)
    {
        [UIView animateWithDuration:0.3 animations:^
         {
             [app.tabBarC.tabBar setFrame:CGRectMake(0, Main_Size.height, Main_Size.width, Tabbar_Height)];
         }];
    }
    else
    {
        [app.tabBarC.tabBar setFrame:CGRectMake(0, Main_Size.height, Main_Size.width, Tabbar_Height)];
    }
}

- (void)setTabBarShowWithAnimation:(BOOL)isAnimation
{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    if(isAnimation)
    {
        [UIView animateWithDuration:0.3 animations:^
         {
             [app.tabBarC.tabBar setFrame:CGRectMake(0, Main_Size.height - Tabbar_Height, Main_Size.width, Tabbar_Height)];
         }];
    }
    else
    {
        [app.tabBarC.tabBar setFrame:CGRectMake(0, Main_Size.height - Tabbar_Height, Main_Size.width, Tabbar_Height)];
    }
}

#pragma mark -显示隐藏HUD
- (void)showHUDInView:(UIView *)view WithDetailText:(NSString *)text andDelay:(float)delay
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithFrame:CGRectMake(60, 200, 200, 180)];
    [hud setDelegate:self];
    [view addSubview:hud];
    [hud setDetailsLabelText:text];
    [hud removeFromSuperViewOnHide];
    [hud show:YES];
    [hud hide:YES afterDelay:delay];
    
    //tag by harry 2014-02-20: 加载数据过程可以返回
   // [self.view bringSubviewToFront:barView];
}

- (void)showHUDInView:(UIView *)view WithText:(NSString *)text andDelay:(float)delay withTag:(NSInteger)tag
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithFrame:CGRectMake(60, 200, 200, 180)];
    [hud setDelegate:self];
    [hud setTag:tag];
    [view addSubview:hud];
    [hud setLabelText:text];
    [hud removeFromSuperViewOnHide];
    [hud show:YES];
    [hud hide:YES afterDelay:delay];
    
    //tag by harry 2014-02-20: 加载数据过程可以返回
    //[self.view bringSubviewToFront:barView];
}

- (void)showHUDInView:(UIView *)view WithText:(NSString *)text andDelay:(float)delay
{
    [self showHUDInView:view WithText:text andDelay:delay withTag:0];
}

- (void)showHUDInView:(UIView *)view WithText:(NSString *)text withTag:(NSInteger)tag
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    [hud setTag:tag];
    [view addSubview:hud];
    [hud setLabelText:text];
    [hud removeFromSuperViewOnHide];
    [hud show:YES];
    
    //tag by harry 2014-02-20: 加载数据过程可以返回
    [self.view bringSubviewToFront:barView];
}

- (void)showHUDInView:(UIView *)view WithText:(NSString *)text
{
    [self showHUDInView:view WithText:text withTag:0];
}

- (void)hideHUDInView:(UIView *)view
{
    [MBProgressHUD hideHUDForView:view animated:YES];
}

#pragma mark MBHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    
}

- (void)buildNetworkView
{
    if(self.networkNotReachableView){            //无网络界面存在，并且隐藏时
        if(self.networkNotReachableView.hidden){
            self.networkNotReachableView.hidden = NO;
            return ;
        }
        
        return;
    }
    
    self.networkNotReachableView = [[UIView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(0, Navbar_Height, Main_Size.width, Main_Size.height - StatusBar_Height - Navbar_Height)]];
    [self.networkNotReachableView setBackgroundColor:RGBS(238)];
    [self.view addSubview:self.networkNotReachableView];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(115, 100, 90, 80)];
    [imgView setImage:[UIImage imageNamed:@"wifi"]];
    [self.networkNotReachableView addSubview:imgView];
    
    UILabel *lb = [GlobalMethod BuildLableWithFrame:CGRectMake(50, 210, 220, 19)
                                           withFont:[UIFont systemFontOfSize:12]
                                           withText:@"网速不给力啊，请检查下网络吧！"];
    [lb setTextColor:RGBS(102)];
    [lb setTextAlignment:NSTextAlignmentCenter];
    [self.networkNotReachableView addSubview:lb];
    
    UIButton *comeToHomeBt = [GlobalMethod BuildButtonWithFrame:CGRectMake(110, 255, 100, 30)
                                                      andOffImg:nil
                                                       andOnImg:nil
                                                      withTitle:@"刷新"];
    [comeToHomeBt addTarget:self action:@selector(refreshNetwork) forControlEvents:UIControlEventTouchUpInside];
    [comeToHomeBt setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [comeToHomeBt.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [comeToHomeBt setTitleColor:RGBS(51) forState:UIControlStateNormal];
    [comeToHomeBt.layer setCornerRadius:5];
    [comeToHomeBt.layer setBorderColor:RGBS(102).CGColor];
    [comeToHomeBt.layer setMasksToBounds:YES];
    [comeToHomeBt.layer setBorderWidth:0.5];
    [self.networkNotReachableView addSubview:comeToHomeBt];
}

- (void)refreshNetwork
{
    
}

-(void)buildNoResult
{
    self.noResultView = [[UIView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(0, Navbar_Height*2, Main_Size.width, Main_Size.height - StatusBar_Height - Navbar_Height*2 - Tabbar_Height)]];
    UIImageView *noView = [[UIImageView alloc] initWithFrame:CGRectMake(115, (Main_Size.height-80)/2 - 100, 90, 80)];
    [noView setImage:[UIImage imageNamed:@"no_result"]];
    [self.noResultView addSubview:noView];
    [self.view addSubview:self.noResultView];
    
    UILabel *lb = [GlobalMethod BuildLableWithFrame:CGRectMake(50, noView.bottom + 20, 220, 13)
                                           withFont:[UIFont systemFontOfSize:12]
                                           withText:@"抱歉，没有找到符合条件的商品！"];
    [lb setTextColor:RGBS(102)];
    [lb setTextAlignment:NSTextAlignmentCenter];
    [self.noResultView addSubview:lb];
}

- (void)setExclusiveTouch:(UIView *)view
{
    [view setMultipleTouchEnabled:NO]; //多点触控禁用
    [view setExclusiveTouch:YES];   //单一点击
    
    if(view.subviews.count >= 1){
        for(UIView *v in view.subviews){
            [self setExclusiveTouch:v];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
