//
//  RegisterSetPasswordViewController.m
//  EwtStores
//
//  Created by Harry on 13-12-3.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "RegisterSetPasswordViewController.h"
#import "LoginInViewController.h"
#import "UserObj.h"

@interface RegisterSetPasswordViewController ()
{
    UITextField *passwordTF;
    UITextField *passwordTF2;
}
@end

@implementation RegisterSetPasswordViewController

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
    
    [self setNavBarTitle:@"设置密码"];
    [self hiddenRightBtn];
    
    if(self.isComingFromRegister && 0)  //注册和找回密码都需要输入2次密码
    {
        [self loadSetPasswordView];
    }
    else
    {
        [self loadReSetPasswordView];
    }
    
    [MobClick event:SZMM];
}

#pragma mark viewBuild
- (void)loadSetPasswordView
{
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(6, Navbar_Height + 20, 303, 48)]];
    [bgView setUserInteractionEnabled:YES];
    [bgView setImage:[UIImage imageNamed:@"cell-bg-single"]];
    [self.view addSubview:bgView];
    
    passwordTF = [GlobalMethod BuildTextFieldWithFrame:CGRectMake(10, 10, 280, 28) andPlaceholder:@"由6-20个英文字母、数字或符号组成"];
    [passwordTF setFont:[UIFont systemFontOfSize:16]];
    [passwordTF setDelegate:self];
    passwordTF.secureTextEntry = YES;
    [bgView addSubview:passwordTF];
    
    UIButton *sureBtn = [GlobalMethod BuildButtonWithFrame:CGRectMake(6, bgView.bottom + 20, 303, 44)
                                                 andOffImg:@"regist_next_off"
                                                  andOnImg:@"regist_next_on"
                                                 withTitle:@"确定"];
    [sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(completeToRegister) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sureBtn];
}

- (void)loadReSetPasswordView
{
    /*UILabel *passwordLb = [GlobalMethod BuildLableWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(10, Navbar_Height + 20, 70, 30)] withFont:[UIFont systemFontOfSize:14] withText:@"新密码:"];
    [self.view addSubview:passwordLb];
    
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(passwordLb.right, passwordLb.top - 3, 220, 40)];
    [bgView setUserInteractionEnabled:YES];
    [bgView setImage:[UIImage imageNamed:@"cell-bg-single"]];
    [self.view addSubview:bgView];
    
    passwordTF = [GlobalMethod BuildTextFieldWithFrame:CGRectMake(10, 10, 180, 20)
                                                     andPlaceholder:@"由6-20个英文字母、数字或符号组成"];
    [passwordTF setFont:[UIFont systemFontOfSize:14]];
    
    [passwordTF setDelegate:self];
    passwordTF.secureTextEntry = YES;
    [bgView addSubview:passwordTF];
    
    UILabel *passwordLb2 = [GlobalMethod BuildLableWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(10, passwordLb.bottom + 20, 70, 30)] withFont:[UIFont systemFontOfSize:14] withText:@"确认密码:"];
    [self.view addSubview:passwordLb2];
    
    UIImageView *bgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(passwordLb2.right, passwordLb2.top - 3, 220, 40)];
    [bgView2 setUserInteractionEnabled:YES];
    [bgView2 setImage:[UIImage imageNamed:@"cell-bg-single"]];
    [self.view addSubview:bgView2];
    
    passwordTF2 = [GlobalMethod BuildTextFieldWithFrame:CGRectMake(10, 10, 180, 20)
                                                      andPlaceholder:@"请再次输入新密码"];
    [passwordTF2 setFont:[UIFont systemFontOfSize:14]];
    [passwordTF2 setDelegate:self];
    passwordTF2.secureTextEntry = YES;
    [bgView2 addSubview:passwordTF2];*/
    
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(8, Navbar_Height + 20, 304, 89)]];
    [bgView setUserInteractionEnabled:YES];
    [bgView setImage:[UIImage imageNamed:@"form2"]];
    [self.view addSubview:bgView];
    
    passwordTF = [GlobalMethod BuildTextFieldWithFrame:CGRectMake(10, 0, 280, 44.5)
                                        andPlaceholder:@"由6-20个英文字母、数字或符号组成"];
    [passwordTF setFont:[UIFont systemFontOfSize:14]];
    [passwordTF setTextAlignment:NSTextAlignmentLeft];
    [passwordTF setDelegate:self];
    passwordTF.secureTextEntry = YES;
    [bgView addSubview:passwordTF];
    
    passwordTF2 = [GlobalMethod BuildTextFieldWithFrame:CGRectMake(10, passwordTF.bottom, 280, 44.5)
                                         andPlaceholder:@"请再次输入新密码"];
    [passwordTF2 setFont:[UIFont systemFontOfSize:14]];
    [passwordTF2 setTextAlignment:NSTextAlignmentLeft];
    [passwordTF2 setDelegate:self];
    passwordTF2.secureTextEntry = YES;
    [bgView addSubview:passwordTF2];
    
    UIButton *sureBtn = [GlobalMethod BuildButtonWithFrame:CGRectMake(6, bgView.bottom + 20, 303, 44)
                                                 andOffImg:@"regist_next_off"
                                                  andOnImg:@"regist_next_on"
                                                 withTitle:@"确定"];
    [sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(completeToRegister) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sureBtn];
}

#pragma mark viewAction
- (void)completeToRegister
{
    BLOCK_SELF(RegisterSetPasswordViewController);
    HTTPRequest *hq = [HTTPRequest shareInstance_myapi];

    if ([[passwordTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        [self showHUDInView:block_self.view WithText:@"密码不能为空" andDelay:LOADING_TIME];
        [passwordTF becomeFirstResponder];
        return;
    } else if([[passwordTF2.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        [self showHUDInView:block_self.view WithText:@"确认密码不能为空" andDelay:LOADING_TIME];
        [passwordTF2 becomeFirstResponder];
        return;
    }
    if ([passwordTF.text isEqualToString:passwordTF2.text]) {
        if (_isComingFromRegister) {
            //NSDictionary *parameters = @{@"pwd": passwordTF.text, @"phone": _phoneNum, @"verifycode": _verifycode}; //verifycode为图片验证码，可不填
            NSDictionary *parameters = @{@"pwd": passwordTF.text, @"phone": _phoneNum};
            [hq POSTURLString:REGISTER_SEND_PWD parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *rqDic = (NSDictionary *)responseObject;
                if([rqDic[HTTP_STATE] boolValue]){
                    [self showHUDInView:block_self.view WithText:@"注册成功" andDelay:LOADING_TIME];
                    UserObj *user = [[UserObj alloc] init];
                    [user setUserName:_phoneNum];
                    [user setPassword:passwordTF.text];
                    [user setAtLogin:YES]; //自动登录
                    [GlobalMethod saveObject:user withKey:USEROBJECT];
                    //[self.navigationController popToRootViewControllerAnimated:YES];
                    LoginInViewController *loginVC = [LoginInViewController shareInstance];
                    [self.navigationController pushViewController:loginVC animated:YES];
                }else{
                    NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
                    [self showHUDInView:block_self.view WithText:[NSString stringWithFormat:@"%@:%@",rqDic[HTTP_ERRCODE],rqDic[HTTP_MSG]] andDelay:LOADING_TIME];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"%@ , %@",operation,error);
                [self showHUDInView:block_self.view WithText:@"网络请求失败" andDelay:LOADING_TIME];
            }];
        } else {
            NSDictionary *parameters = @{@"pwd": passwordTF.text, @"u": _phoneNum};
            [hq POSTURLString:FINDPWD_RESET parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *rqDic = (NSDictionary *)responseObject;
                if([rqDic[HTTP_STATE] boolValue]){
                    UserObj *user = [[UserObj alloc] init];
                    [user setUserName:_phoneNum];
                    [user setPassword:passwordTF.text];
                    [GlobalMethod saveObject:user withKey:USEROBJECT];
                    [self showHUDInView:block_self.view WithText:@"找回密码成功" andDelay:LOADING_TIME];
                    //[self.navigationController popToRootViewControllerAnimated:YES];
                    LoginInViewController *loginVC = [LoginInViewController shareInstance];
                    [self.navigationController pushViewController:loginVC animated:YES];
                }else{
                    NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
                    [self showHUDInView:block_self.view WithText:[NSString stringWithFormat:@"%@:%@",rqDic[HTTP_ERRCODE],rqDic[HTTP_MSG]] andDelay:LOADING_TIME];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"%@ , %@",operation,error);
                [self showHUDInView:block_self.view WithText:@"网络请求失败" andDelay:LOADING_TIME];
            }];
        }
        
    } else {
        [self showHUDInView:block_self.view WithText:@"两次输入的密码不一致" andDelay:LOADING_TIME];
        [passwordTF becomeFirstResponder];
    }
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
