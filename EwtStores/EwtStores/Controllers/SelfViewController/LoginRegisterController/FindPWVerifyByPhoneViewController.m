//
//  FindPWVerifyByPhoneViewController.m
//  EwtStores
//
//  Created by Harry on 13-12-3.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "FindPWVerifyByPhoneViewController.h"
#import "RegisterAuthCodeViewController.h"

@interface FindPWVerifyByPhoneViewController ()
{
    UITextField *authCodeTF;
}
@end

@implementation FindPWVerifyByPhoneViewController

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
    
    [self setNavBarTitle:@"手机验证"];
    [self hiddenRightBtn];
    
    [self loadBaseView];
}

#pragma mark viewBuild
- (void)loadBaseView
{
    UILabel *phoneLb = [GlobalMethod BuildLableWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(20, Navbar_Height + 20, 280, 30)] withFont:[UIFont systemFontOfSize:16] withText:[NSString stringWithFormat:@"您绑定的手机号码：%@*****%@",[_phoneNum substringToIndex:3],[_phoneNum substringFromIndex:8]]];
    [self.view addSubview:phoneLb];
    
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(6, phoneLb.bottom + 25, 303, 48)];
    [bgView setUserInteractionEnabled:YES];
    [bgView setImage:[UIImage imageNamed:@"cell-bg-single"]];
    [self.view addSubview:bgView];
    
    authCodeTF = [GlobalMethod BuildTextFieldWithFrame:CGRectMake(10, 10, 280, 28) andPlaceholder:@"请输入验证码"];
    [authCodeTF setDelegate:self];
    [authCodeTF setKeyboardType:UIKeyboardTypeNumberPad];
    [bgView addSubview:authCodeTF];
    
    UIButton *nextBtn = [GlobalMethod BuildButtonWithFrame:CGRectMake(6, bgView.bottom + 10, 303, 44)
                                                 andOffImg:@"regist_next_off"
                                                    andOnImg:@"regist_next_on"
                                                 withTitle:@"下一步"];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(nextToFindPW) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
}

#pragma mark viewAction
- (void)nextToFindPW
{
    
    RegisterAuthCodeViewController *registerACC = [RegisterAuthCodeViewController shareInstance];
    [registerACC setIsComingFromRegister:NO];
    [self.navigationController pushViewController:registerACC animated:YES];
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
