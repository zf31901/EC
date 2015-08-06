//
//  FindPWByWebViewViewController.m
//  Shop
//
//  Created by Harry on 14-1-7.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "FindPWByWebViewViewController.h"

#import <CoreText/CoreText.h>

@interface FindPWByWebViewViewController ()

@end

@implementation FindPWByWebViewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self setNavBarTitle:@"找回密码"];
    [self hiddenRightBtn];
    
    UIImageView *noresult = [[UIImageView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(115, Navbar_Height + 100, 90, 80)]];
    [noresult setImage:[UIImage imageNamed:@"no"]];
    [self.view addSubview:noresult];
    
    /*NSString *s = @"您的账号还未绑定手机号码，不支持找回密码，请登录电脑网通http://www.ewt.cc/，使用其他验证方式找回";
    UILabel *lb = [GlobalMethod BuildLableWithFrame:CGRectMake(20, noresult.bottom + 30, 280, 70)
                                           withFont:[UIFont systemFontOfSize:14]
                                           withText:nil];
    [lb setUserInteractionEnabled:YES];
    [lb setTextColor:RGBS(51)];
    [lb setTextAlignment:NSTextAlignmentCenter];
    [lb setNumberOfLines:0];
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:s];
    [attString addAttribute:NSForegroundColorAttributeName
                      value:RGB(0, 117, 169)
                      range:NSMakeRange(28, 18)];
    [lb setAttributedText:attString];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(FindPasswordWithWeb)];
    [lb addGestureRecognizer:tap];
    [self.view addSubview:lb];*/
    UILabel *lb = [GlobalMethod BuildLableWithFrame:CGRectMake(20, noresult.bottom + 15, 280, 30)
                                           withFont:[UIFont systemFontOfSize:12]
                                           withText:@"您的账号还未绑定手机号码，不支持找回密码"];
    [lb setTextColor:RGBS(102)];
    [lb setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:lb];
    
    UIButton *comeToHomeBt = [GlobalMethod BuildButtonWithFrame:CGRectMake(110, lb.bottom + 10, 100, 30)
                                                      andOffImg:nil
                                                       andOnImg:nil
                                                      withTitle:@"去官网找回"];
    [comeToHomeBt addTarget:self action:@selector(FindPasswordWithWeb) forControlEvents:UIControlEventTouchUpInside];
    [comeToHomeBt setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [comeToHomeBt.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [comeToHomeBt setTitleColor:RGBS(51) forState:UIControlStateNormal];
    [comeToHomeBt.layer setCornerRadius:5];
    [comeToHomeBt.layer setBorderColor:RGBS(102).CGColor];
    [comeToHomeBt.layer setMasksToBounds:YES];
    [comeToHomeBt.layer setBorderWidth:0.5];
    [self.view addSubview:comeToHomeBt];
}

- (void)FindPasswordWithWeb{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.ewt.cc/"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
