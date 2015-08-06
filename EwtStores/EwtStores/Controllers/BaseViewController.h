//
//  BaseViewController.h
//  EwtStores
//
//  Created by Harry on 13-11-30.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

/************************************************************************************************************
 *  1.所有VC界面的基类，调用［shareInstance］快速生成VC对象；（ARC）
 *
 *  2.navBar自定义，子类可以调用［buildBaseNavBar］来覆盖基类实现自定义navBar，也可以调用getBaseNavBar获取navBar对象进行操作；
 *
 *  3.统一了leftBtn的风格也可以调用［setLeftBtnOffImg:andOnImg: andTitle:］实现独特风格；
 *
 *  4.灵活的控制NavBar、TabBar的显示或者隐藏，并支持选择动画效果；
 *
 *  5.HUD的显示或者隐藏随时可以控制,也可以实现hudWasHidden：方法来处理HUD消失后的时间
 ************************************************************************************************************/

#import <UIKit/UIKit.h>

typedef enum
{
    REQUEST_REFRSH = 0,
    REQUEST_GETMORE,
}REQUEST_STATUS;

@class MBProgressHUD;

@interface BaseViewController : UIViewController

@property (nonatomic, strong) UIView    *networkNotReachableView;   //无网络请求背景
@property (nonatomic, strong) UIView    *noResultView;              //无商品图

//快速生成viewC对象
+ (instancetype)shareInstance;

//建立父类的NavBar，子类重写可以替换
- (void)buildBaseNavBar;
- (UIView *)getBaseNavBar;
- (UIButton *)getRightButton;
- (void)setNavBarTitle:(NSString *)title;
- (void)setLeftBtnOffImg:(NSString *)offImg andOnImg:(NSString *)onImg andTitle:(NSString *)btnTitle;
- (void)setRightBtnOffImg:(NSString *)offImg andOnImg:(NSString *)onImg andTitle:(NSString *)btnTitle;
- (void)showLeftBtn;
- (void)hiddenLeftBtn;
- (void)hiddenRightBtn;
- (void)showRightBtn;

//显示或者隐藏navBar
- (void)setNavBarHiddenWithAnimation:(BOOL)isAnimation;
- (void)setNavBarShowWithAnimation:(BOOL)isAnimation;

//显示或者隐藏tabBar
- (void)setTabBarHiddenWithAnimation:(BOOL)isAnimation;
- (void)setTabBarShowWithAnimation:(BOOL)isAnimation;

//按钮点击事件
- (void)leftBtnAction:(UIButton *)btn;
- (void)rightBtnAction:(UIButton *)btn;

//HUD
- (void)showHUDInView:(UIView *)view WithDetailText:(NSString *)text andDelay:(float)delay;
- (void)showHUDInView:(UIView *)view WithText:(NSString *)text andDelay:(float)delay withTag:(NSInteger)tag; //延迟消失
- (void)showHUDInView:(UIView *)view WithText:(NSString *)text andDelay:(float)delay; //延迟消失
- (void)showHUDInView:(UIView *)view WithText:(NSString *)text withTag:(NSInteger)tag;//显示（一直不消失）
- (void)showHUDInView:(UIView *)view WithText:(NSString *)text;//显示（一直不消失）
- (void)hideHUDInView:(UIView *)view;//消失
- (void)hudWasHidden:(MBProgressHUD *)hud; //消失后进入该方法

//刷新网络
- (void)buildNetworkView;
- (void)refreshNetwork;

//无商品图
-(void)buildNoResult;


//多点点击禁用
- (void)setExclusiveTouch:(UIView *)view;

@end
