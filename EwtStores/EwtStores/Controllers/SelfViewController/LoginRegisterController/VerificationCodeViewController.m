//
//  VerificationCodeViewController.m
//  Shop
//
//  Created by Harry on 14-1-3.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "VerificationCodeViewController.h"
#import "EGOImageView.h"

@interface VerificationCodeViewController ()

@end

@implementation VerificationCodeViewController

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
    
    [self buildBaseView];
}

- (void)buildBaseView
{
    EGOImageView *codeIView = [[EGOImageView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(110, Navbar_Height + 25, 100, 40)]];
    [codeIView setPlaceholderImage:[UIImage imageNamed:@"default_img_200x80"]];
    [codeIView setImageURL:nil];
    [self.view addSubview:codeIView];
    
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(6, codeIView.bottom + 25, 303, 48)];
    [bgView setUserInteractionEnabled:YES];
    [bgView setImage:[UIImage imageNamed:@"cell-bg-single"]];
    [self.view addSubview:bgView];
    
    UITextField *codeTF = [GlobalMethod BuildTextFieldWithFrame:CGRectMake(10, 10, 283, 28) andPlaceholder:@"请输入验证码"];
    [codeTF setDelegate:self];
    [bgView addSubview:codeTF];
    
    UIButton *nextBtn = [GlobalMethod BuildButtonWithFrame:CGRectMake(6, bgView.bottom + 25, 303, 44)
                                       andOffImg:@"config_off"
                                        andOnImg:@"config_on"
                                       withTitle:@"提交"];
    [nextBtn setTitleColor:RGBS(180) forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(config) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
    
    UILabel *lb = [GlobalMethod BuildLableWithFrame:CGRectMake(10, nextBtn.bottom + 20, 300, 14)
                                           withFont:[UIFont boldSystemFontOfSize:14]
                                           withText:@"温馨提示：为了您的账号安全，请您填写验证码"];
    [lb setTextColor:RGBS(51)];
    [self.view addSubview:lb];
}


- (void)config
{
    
}

#pragma mark UItextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
