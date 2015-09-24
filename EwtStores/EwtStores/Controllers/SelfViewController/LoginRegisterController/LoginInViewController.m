//
//  LoginInViewController.m
//  EwtStores
//
//  Created by Harry on 13-12-2.
//  Copyright (c) 2013年 Harry. All rights reserved.
//



#pragma mark --LoginInView
#import "UserObj.h"
#import "RegisterViewController.h"
#import <CoreText/CoreText.h>
#import "FindPWByWebViewViewController.h"

#import "HTTPRequest.h"
#import "JSONKit.h"
#import "ActivityObj.h"

@protocol LoginInViewDelegate <NSObject>
@required
- (void)findPasswordClickedUserName:(NSString *)userName;
- (void)loginInClickedUserName:(NSString *)userName andPassword:(NSString *)password;
- (void)registNewUser;
- (void)quickRegisterNewUser;
@end

@interface LoginInView : UIView<UITextFieldDelegate>
{
    
    UIButton        *removeUserNameBt;
    UIButton        *removePwdBt;
}

@property (nonatomic, assign)id<LoginInViewDelegate> _delegate;
@property (nonatomic, assign)BOOL                    isAutoLogin;

@property (nonatomic, retain) UITextField     *userNameTF;
@property (nonatomic, retain) UITextField     *passwordTF;
@property (nonatomic, retain) UIButton        *quickRegister;
@property (nonatomic, retain) UIButton        *registBtn;

@end

@implementation LoginInView

- (id)initWithFrame:(CGRect)frame withUserObj:(UserObj *)user
{
    self = [super initWithFrame:frame];
    if(self != nil)
    {
        if (user == nil) {
            self.isAutoLogin = YES;
        } else {
            self.isAutoLogin = user.atLogin;
        }
        
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(8, 20, 303, 46)];
        [headView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"cell-bg-header"]]];
        [self addSubview:headView];
        
        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(8, 66, 303, 46)];
        [footView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"cell-bg-footer"]]];
        [self addSubview:footView];
        
        _userNameTF = [GlobalMethod BuildTextFieldWithFrame:CGRectMake(10, 14, 240, 18) andPlaceholder:@"请输入帐号"];
        [_userNameTF setText:user.userName];
        UIView *userLeft = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 25, 18)];
        UIImageView *userImgLeft = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [userImgLeft setImage:[UIImage imageNamed:@"log-in-user-name-icon"]];
        [userLeft addSubview:userImgLeft];
        [_userNameTF setLeftView:userLeft];
        [_userNameTF setLeftViewMode:UITextFieldViewModeAlways];
        //userNameTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_userNameTF setDelegate:self];
        [headView addSubview:_userNameTF];
        
        removeUserNameBt = [GlobalMethod BuildButtonWithFrame:CGRectMake(_userNameTF.right + 10, 14, 20, 20) andOffImg:@"remove_username" andOnImg:@"remove_username" withTitle:nil];
        [removeUserNameBt addTarget:self action:@selector(removeUserName) forControlEvents:UIControlEventTouchUpInside];
        [removeUserNameBt setHidden:YES];
        [headView addSubview:removeUserNameBt];
        
        _passwordTF = [GlobalMethod BuildTextFieldWithFrame:CGRectMake(10, 14, 240, 18) andPlaceholder:@"请输入密码"];
        [_passwordTF setText:user.password];
        UIView *passwordLeft = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 25, 18)];
        UIImageView *passwordImgLeft = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [passwordImgLeft setImage:[UIImage imageNamed:@"log-in-key-icon"]];
        [passwordLeft addSubview:passwordImgLeft]   ;
        [_passwordTF setLeftView:passwordLeft];
        [_passwordTF setLeftViewMode:UITextFieldViewModeAlways];
        //passwordTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_passwordTF setDelegate:self];
        [_passwordTF setSecureTextEntry:YES];
        [footView addSubview:_passwordTF];
        
        removePwdBt = [GlobalMethod BuildButtonWithFrame:CGRectMake(_passwordTF.right + 10, 14, 20, 20) andOffImg:@"remove_username" andOnImg:@"remove_username" withTitle:nil];
        [removePwdBt addTarget:self action:@selector(removePWD) forControlEvents:UIControlEventTouchUpInside];
        [removePwdBt setHidden:YES];
        [footView addSubview:removePwdBt];
        
        UIButton *atLoginBtn = [GlobalMethod BuildButtonWithFrame:CGRectMake(18, 140, 18, 18) andOffImg:nil andOnImg:nil withTitle:nil];
        [atLoginBtn addTarget:self action:@selector(autoLoginIn:) forControlEvents:UIControlEventTouchUpInside];
        if(self.isAutoLogin)
        {
            [atLoginBtn setBackgroundImage:[UIImage imageNamed:@"autoLoginOn"] forState:UIControlStateNormal];
        }
        else
        {
            [atLoginBtn setBackgroundImage:[UIImage imageNamed:@"autoLoginOff"] forState:UIControlStateNormal];
        }
        [self addSubview:atLoginBtn];
        
        UILabel *atLoginLb = [GlobalMethod BuildLableWithFrame:CGRectMake(50, 133, 80, 30)
                                                      withFont:[UIFont systemFontOfSize:14]
                                                      withText:@"自动登录"];
        [self addSubview:atLoginLb];
        
        UILabel *searchPWLb = [GlobalMethod BuildLableWithFrame:CGRectMake(245, 133, 80, 30)
                                                       withFont:[UIFont systemFontOfSize:14]
                                                       withText:@"找回密码"];
        [searchPWLb setUserInteractionEnabled:YES];
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:@"忘记密码"];
        [attString addAttribute:(NSString *)kCTUnderlineStyleAttributeName
                          value:(id)[NSNumber numberWithInt:kCTUnderlineStyleSingle]
                          range:NSMakeRange(0, 4)];
        [searchPWLb setAttributedText:attString];
        UITapGestureRecognizer *searchPWTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(forgetPassword:)];
        [searchPWLb addGestureRecognizer:searchPWTap];
        [self addSubview:searchPWLb];
        
        _registBtn = [GlobalMethod BuildButtonWithFrame:CGRectMake(8, atLoginBtn.bottom + 25, 148, 44)
                                                       andOffImg:@"regist_off"
                                                        andOnImg:@"regist_on"
                                                       withTitle:@"注册"];
        [_registBtn addTarget:self action:@selector(regist:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_registBtn];
        
       _quickRegister = [GlobalMethod BuildButtonWithFrame:CGRectMake(8, atLoginBtn.bottom + 25, 148, 44)
                                                       andOffImg:@"regist_off"
                                                        andOnImg:@"regist_on"
                                                       withTitle:@"快速注册"];
        [_quickRegister addTarget:self action:@selector(quickRegister:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_quickRegister];
        
        UIButton *loginBtn = [GlobalMethod BuildButtonWithFrame:CGRectMake(_registBtn.right + 8, _registBtn.top, 148, 44)
                                                      andOffImg:@"login_off"
                                                       andOnImg:@"login_on"
                                                      withTitle:@"登录"];
        [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [loginBtn addTarget:self action:@selector(loginIn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:loginBtn];
        
        }
    
    return self;
}

#pragma mark LoginViewAction
- (void)autoLoginIn:(UIButton *)atLoginBtn
{
    self.isAutoLogin = !self.isAutoLogin;
    
    UserObj *user= [GlobalMethod getObjectForKey:USEROBJECT];
    [user setAtLogin:self.isAutoLogin];
    [GlobalMethod saveObject:user withKey:USEROBJECT];
    
    if(self.isAutoLogin){
        [atLoginBtn setBackgroundImage:[UIImage imageNamed:@"autoLoginOn"] forState:UIControlStateNormal];
    }else{
        [atLoginBtn setBackgroundImage:[UIImage imageNamed:@"autoLoginOff"] forState:UIControlStateNormal];
    }
    
    DLog(@"%@自动登录",self.isAutoLogin?@"":@"取消");
}

- (void)forgetPassword:(UITapGestureRecognizer *)searchPWTap
{
    [_userNameTF resignFirstResponder];
    [_passwordTF resignFirstResponder];
    
    if(self._delegate && [self._delegate respondsToSelector:@selector(findPasswordClickedUserName:)])
    {
        [self._delegate findPasswordClickedUserName:_userNameTF.text];
    }
}

- (void)quickRegister:(UIButton *)quickRegister{
    [_userNameTF resignFirstResponder];
    [_passwordTF resignFirstResponder];
    
    if(self._delegate && [self._delegate respondsToSelector:@selector(quickRegisterNewUser)])
    {
        [self._delegate quickRegisterNewUser];
    }
}

- (void)loginIn:(UIButton *)loginBtn
{
    [_userNameTF resignFirstResponder];
    [_passwordTF resignFirstResponder];
    
    if(self._delegate && [self._delegate respondsToSelector:@selector(loginInClickedUserName:andPassword:)])
    {
        [self._delegate loginInClickedUserName:_userNameTF.text andPassword:_passwordTF.text];
    }
}

- (void)regist:(UIButton *)registBtn
{
    [_userNameTF resignFirstResponder];
    [_passwordTF resignFirstResponder];
    
    if(self._delegate && [self._delegate respondsToSelector:@selector(registNewUser)])
    {
        [self._delegate registNewUser];
    }
}

- (void)removeUserName
{
    [_userNameTF setText:@""];
    
    [removeUserNameBt setHidden:YES];
}

- (void)removePWD
{
    [_passwordTF setText:@""];
    
    [removePwdBt setHidden:YES];
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField == _userNameTF){
        [removeUserNameBt setHidden:NO];
    } else if (textField == _passwordTF) {
        [removePwdBt setHidden:NO];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [removeUserNameBt setHidden:YES];
    [removePwdBt setHidden:YES];
}

@end



#pragma mark --LoginInViewController
#import "LoginInViewController.h"
#import "AppDelegate.h"
#import "FindPasswordViewController.h"
#import "RegisterViewController.h"
#import "VerificationCodeViewController.h"

@interface LoginInViewController ()<LoginInViewDelegate>

@end

@implementation LoginInViewController

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
    
    [self setNavBarTitle:@"会员登录"];
    [self hiddenRightBtn];
    //[self setLeftBtnOffImg:@"nav-cannel" andOnImg:@"nav-cannel" andTitle:@"    取消"];
    [self setLeftBtnOffImg:nil andOnImg:nil andTitle:@"取消"];
    
    UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
    LoginInView *loginView = [[LoginInView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(0, Navbar_Height, Main_Size.width, Main_Size.height - Navbar_Height - StatusBar_Height)] withUserObj:user];
    if (!self.isComingFromCarNC) {
        loginView.quickRegister.hidden = YES;
    }else{
        loginView.registBtn.hidden = YES;
    }
    [loginView set_delegate:self];
    
    [self.view addSubview:loginView];
    
    [MobClick event:DL];
}

#pragma mark 点击NavBar左边按钮
- (void)leftBtnAction:(UIButton *)btn
{
    DLog(@"%@ 中点击NavBar左边按钮",NSStringFromClass([self class]));
    
    //取消登陆
    [self dismissViewControllerAnimated:YES completion:Nil];

    //[MYAPPDELEGATE.tabBarC setSelectedIndex:3];
}

#pragma mark LoginInViewDelegate
- (void)findPasswordClickedUserName:(NSString *)userName
{
    DLog(@"忘记%@的密码",userName);
    
    [self.navigationController pushViewController:[FindPasswordViewController shareInstance] animated:YES];
}

- (void)quickRegisterNewUser{
    DLog(@"快速注册");
    RegisterViewController *regist = [RegisterViewController shareInstance];
    regist.isQuickRegist = YES;
    [self.navigationController pushViewController:regist animated:YES];
}

- (void)loginInClickedUserName:(NSString *)userName andPassword:(NSString *)password
{
    DLog(@"登录");
    
    NSDictionary *parameters = @{@"u": userName, @"pwd": password};
    
    BLOCK_SELF(LoginInViewController);
    
    if ([[userName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        [self showHUDInView:block_self.view WithText:@"帐号不能为空" andDelay:LOADING_TIME];
        return;
    } else if([[password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        [self showHUDInView:block_self.view WithText:@"密码不能为空" andDelay:LOADING_TIME];
        return;
    }
    
    
//    CRSA *c = [CRSA shareInstance];
//    [c importRSAKeyWithType:KeyTypePublic];
//    
//    NSString *u = [[CRSA shareInstance] encryptByRsa:userName withKeyType:KeyTypePublic];
//    NSString *pwd = [[CRSA shareInstance] encryptByRsa:password withKeyType:KeyTypePublic];

    [self showHUDInView:block_self.view WithText:@"正在登录"];
    HTTPRequest *hq = [HTTPRequest shareInstance_myapi];
    [hq POSTURLString:LOGIN_USER withTimeout:40 parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rqDic = (NSDictionary *)responseObject;
        if([rqDic[HTTP_STATE] boolValue]){
            NSArray *dataArr_login = (NSArray *)[rqDic[HTTP_DATA] objectFromJSONString];
            NSDictionary *dic_login = (NSDictionary *)dataArr_login;
            
            NSDictionary *param = @{@"u": userName, @"clientkey": dic_login[@"clientkey"]};
            
            [hq GETURLString:USER_INFO parameters:param success:^(AFHTTPRequestOperation *operation, id responseObj) {
                NSDictionary *rqDic = (NSDictionary *)responseObj;
                if([rqDic[HTTP_STATE] boolValue]){
                    NSArray *dataArr = (NSArray *)[rqDic[HTTP_DATA] objectFromJSONString];
                    NSDictionary *dic = (NSDictionary *)dataArr;
                    UserObj *oldUser = [GlobalMethod getObjectForKey:USEROBJECT];
                    UserObj *user = [[UserObj alloc] init];
                    [user setUserName:dic[@"Mobile"]];
                    [user setPassword:password];
                    [user setIm:dic[@"UserLogin"]];
                    [user setPhone:dic[@"Mobile"]];
                    [user setClientkey:dic_login[@"clientkey"]];
                    [user setIsLogin:YES];
                    [user setNickName:dic[@"Nick"]];
                    [user setTrueName:dic[@"TrueName"]];
                    [user setSex:[dic[@"Sex"] boolValue]];
                    [user setHeadPic:dic[@"HeadPicture"]];
                    [user setEmail:dic[@"Email"]];
                    [user setEmailState:[dic[@"EmailState"] boolValue]];
                    [user setPhoneState:[dic[@"MobileState"] boolValue]];
                    [user setRegTime:dic[@"RegDateTime"]];
                    [user setAtLogin:oldUser.atLogin];
                    [GlobalMethod saveObject:user withKey:USEROBJECT];
                    
                    
                    NSDictionary *dic1 = @{@"userlogin":user.im?user.im:@"" , @"clientkey":user.clientkey?user.clientkey:@""};
                    //购物车数量
                    HTTPRequest *hq = [HTTPRequest shareInstance];
                    [hq GETURLString:CART_PRODUCT_NUM userCache:NO parameters:dic1 success:^(AFHTTPRequestOperation *operation, id responseObj) {
                        NSDictionary *rqDic = (NSDictionary *)responseObj;
                        if([rqDic[HTTP_STATE] boolValue]){
                            
                            NSDictionary *dataDic = (NSDictionary *)[rqDic[HTTP_DATA] objectFromJSONString];
                            if([dataDic[@"result"] boolValue]){
                                [GlobalMethod saveObject:dataDic[@"count"] withKey:CART_PRODUCT_COUNT];
                                
                                [self hideHUDInView:block_self.view];
                                //登录，回到 “我” 界面
                                [self dismissViewControllerAnimated:YES completion:Nil];
                                if (_isComingFromActivity) {
                                    [MYAPPDELEGATE.tabBarC setSelectedIndex:0];
                                }
                            }
                            
                            [self hideHUDInView:block_self.view];
                            
                        }else{
                            [self hideHUDInView:block_self.view];
                            [self dismissViewControllerAnimated:YES completion:Nil];
                            NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
                        }
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
 
                    }];

                    
                }else{
                    NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
                    [self hideHUDInView:block_self.view];
                    [self showHUDInView:block_self.view WithText:[NSString stringWithFormat:@"%@:%@",rqDic[HTTP_ERRCODE],rqDic[HTTP_MSG]] andDelay:LOADING_TIME];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"%@ , %@",operation,error);
                [self hideHUDInView:block_self.view];
                [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
            }];
            
        }else{
            NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
            
            [self hideHUDInView:block_self.view];
            
            if ([rqDic[HTTP_ERRCODE] intValue] == 100) {
                [self showHUDInView:block_self.view WithText:@"帐号不存在" andDelay:LOADING_TIME];
            } else if ([rqDic[HTTP_ERRCODE] intValue] == 101) {
                [self showHUDInView:block_self.view WithText:@"验证码错误" andDelay:LOADING_TIME];
            } else if ([rqDic[HTTP_ERRCODE] intValue] == 102) {
                [self showHUDInView:block_self.view WithText:@"密码和账号不匹配" andDelay:LOADING_TIME];
            } else if ([rqDic[HTTP_ERRCODE] intValue] == 103) {
                [self showHUDInView:block_self.view WithText:@"账号未激活" andDelay:LOADING_TIME];
            } else if ([rqDic[HTTP_ERRCODE] intValue] == 104) {
                [self showHUDInView:block_self.view WithText:@"邮箱未验证，无法通过邮箱登录" andDelay:LOADING_TIME];
            } else if ([rqDic[HTTP_ERRCODE] intValue] == 105) {
                [self showHUDInView:block_self.view WithText:@"手机未验证，无法通过手机登录" andDelay:LOADING_TIME];
            } else if ([rqDic[HTTP_ERRCODE] intValue] == 106) {
                [self showHUDInView:block_self.view WithText:@"账户被冻结" andDelay:LOADING_TIME];
            } else if ([rqDic[HTTP_ERRCODE] intValue] == 107) {
                [self showHUDInView:block_self.view WithText:@"验证码失效" andDelay:LOADING_TIME];
            } else if ([rqDic[HTTP_ERRCODE] intValue] == 108) {
                [self showHUDInView:block_self.view WithText:@"密码和账号不匹配" andDelay:LOADING_TIME];
            } else if ([rqDic[HTTP_ERRCODE] intValue] == 109) {
                [self showHUDInView:block_self.view WithText:@"密码和账号不匹配" andDelay:LOADING_TIME];
            } else if ([rqDic[HTTP_ERRCODE] intValue] == 200) {
                [self showHUDInView:block_self.view WithText:@"其他错误" andDelay:LOADING_TIME];
            } else {
                [self showHUDInView:block_self.view WithText:[NSString stringWithFormat:@"%@:%@",rqDic[HTTP_ERRCODE],rqDic[HTTP_MSG]] andDelay:LOADING_TIME];
            }
            
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@ , %@",operation,error);
        [self hideHUDInView:block_self.view];
        [self showHUDInView:block_self.view WithText:@"网络请求失败" andDelay:LOADING_TIME];
    }];
    

    [MYAPPDELEGATE.tabBarC setSelectedIndex:MYAPPDELEGATE.tabBarC.selectedIndex];
}

- (void)registNewUser
{
    DLog(@"注册新用户");
    
    [self.navigationController pushViewController:[RegisterViewController  shareInstance] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
