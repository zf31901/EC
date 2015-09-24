//
//  LoginAuthCodeViewController.m
//  EwtStores
//
//  Created by Harry on 13-12-3.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "RegisterAuthCodeViewController.h"
#import "RegisterSetPasswordViewController.h"
#import "RegisterViewController.h"

#import "HTTPRequest.h"

@interface RegisterAuthCodeViewController ()
{
    UITextField *authCodeTF;
    UILabel     *l;
    
    
    NSTimer     *timer;
    
    UIButton    *reSendBtn;
}

@end

@implementation RegisterAuthCodeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        //secondNum = 60;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self setNavBarTitle:@"输入验证码"];
    [self hiddenRightBtn];
    
    [self loadBaseView];
    
    [MobClick event:YZM];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(ShouldReseedAuthCode) userInfo:nil repeats:YES];
    [timer fire];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [timer invalidate];
    timer = nil;
}

- (void)leftBtnAction:(UIButton *)btn
{
    if(self._delegate && [self._delegate respondsToSelector:@selector(shareValue:)]){
        DLog(@"父类左边按钮点击 come in");
        [self._delegate shareValue:_secondNum];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark viewBuild
- (void)loadBaseView
{
    NSString *str = @"";
    if (_isComingFromRegister == YES) {
        str = @"请输入短信中收到的验证码";
    }else if (_isComingFromQuickRegister == YES){
        str = [NSString stringWithFormat:@"您注册的手机号码：%@*****%@",[_phoneNum substringToIndex:3],[_phoneNum substringFromIndex:8]];
    } else {
        str = [NSString stringWithFormat:@"您绑定的手机号码：%@*****%@",[_phoneNum substringToIndex:3],[_phoneNum substringFromIndex:8]];
    }
    UILabel *authCodeLb = [GlobalMethod BuildLableWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(20, Navbar_Height + 25, 280, 20)]
                                          withFont:[UIFont systemFontOfSize:14]
                                          withText:str];
    [self.view addSubview:authCodeLb];
    
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(6, authCodeLb.bottom + 25, 193, 48)];
    [bgView setUserInteractionEnabled:YES];
    [bgView setImage:[UIImage imageNamed:@"cell-bg-single"]];
    [self.view addSubview:bgView];
    
    authCodeTF = [GlobalMethod BuildTextFieldWithFrame:CGRectMake(10, 10, 200, 28) andPlaceholder:@"请输入验证码"];
    [authCodeTF setDelegate:self];
    [authCodeTF setKeyboardType:UIKeyboardTypeNumberPad];
    [bgView addSubview:authCodeTF];
    
    reSendBtn = [GlobalMethod BuildButtonWithFrame:CGRectMake(bgView.right+10, bgView.top, 100, 46) andOffImg:@"gary_btn200_1" andOnImg:nil withTitle:[NSString stringWithFormat:@"重发(%lu)",(unsigned long)_secondNum]];
    [reSendBtn addTarget:self action:@selector(reSeedAuthCodeAction) forControlEvents:UIControlEventTouchUpInside];
    [reSendBtn setTitleColor:RGBS(101) forState:UIControlStateNormal];
    [reSendBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [reSendBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [reSendBtn setEnabled:NO];
    [self.view addSubview:reSendBtn];
    
    UIButton *nextBtn = [GlobalMethod BuildButtonWithFrame:CGRectMake(6, bgView.bottom + 20, 303, 44)
                                                 andOffImg:@"regist_next_off"
                                                  andOnImg:@"regist_next_on"
                                                 withTitle:@"下一步"];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(authCodeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
    
    /*reSeedAuthCodeBtn = [GlobalMethod BuildButtonWithFrame:CGRectMake(100, nextBtn.bottom + 20, 24, 13) andOffImg:nil andOnImg:nil withTitle:[NSString stringWithFormat:@"%lu",(unsigned long)_secondNum]];
    [reSeedAuthCodeBtn addTarget:self action:@selector(reSeedAuthCodeAction) forControlEvents:UIControlEventTouchUpInside];
    [reSeedAuthCodeBtn setTitleColor:RGB(197, 0, 0) forState:UIControlStateNormal];
    [reSeedAuthCodeBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [reSeedAuthCodeBtn setEnabled:NO];
    [self.view addSubview:reSeedAuthCodeBtn];
    
    l = [GlobalMethod BuildLableWithFrame:CGRectMake(reSeedAuthCodeBtn.right, reSeedAuthCodeBtn.top, 80, 13) withFont:[UIFont systemFontOfSize:12] withText:@"秒后重新发送"];
    [self.view addSubview:l];*/
}

#pragma mark viewAction
- (void)authCodeAction:(UIButton *)nextBtn
{
    DLog(@"注册验证码，下一步");
    if(authCodeTF.text == nil || [authCodeTF.text isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"验证码不能为空" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    BLOCK_SELF(RegisterAuthCodeViewController);
    HTTPRequest *hq = [HTTPRequest shareInstance_myapi];
    if (_isComingFromRegister == YES) {
        NSDictionary *parameters = @{@"phone": _phoneNum, @"verifycode": authCodeTF.text,  @"sessionkey": _sessionkey};
        [hq GETURLString:REGISTER_SEND_VERIFYCODE parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObj) {
            NSDictionary *rqDic = (NSDictionary *)responseObj;
            if([rqDic[HTTP_STATE] boolValue]){
                NSDictionary *dataDic = (NSDictionary *)[rqDic[HTTP_DATA] objectFromJSONString];
                if([dataDic[@"result"] boolValue]){
                     RegisterSetPasswordViewController *registerSPWC = [RegisterSetPasswordViewController shareInstance];
                     registerSPWC.isComingFromRegister = YES;
                     registerSPWC.phoneNum = _phoneNum;
                     registerSPWC.verifycode = authCodeTF.text;
                     [registerSPWC setIsComingFromRegister:self.isComingFromRegister];
                     [self.navigationController pushViewController:registerSPWC animated:YES];
                } else {
                    [self showHUDInView:block_self.view WithText:@"请求失败" andDelay:LOADING_TIME];
                }
                
                
            }else{
                NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
                if ([rqDic[HTTP_ERRCODE] intValue] == 10001) {
                    [self showHUDInView:block_self.view WithText:@"请输入验证码" andDelay:LOADING_TIME];
                } else {
                    [self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
                }
                //[self showHUDInView:block_self.view WithText:[NSString stringWithFormat:@"%@:%@",rqDic[HTTP_ERRCODE],rqDic[HTTP_MSG]] andDelay:2];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@ , %@",operation,error);
            [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
        }];
    }else if (_isComingFromQuickRegister){
        NSDictionary *parameters = @{@"phone": _phoneNum, @"verifycode": authCodeTF.text,  @"sessionkey": _sessionkey};
        [hq GETURLString:QUICKREGISTER_SEND_VERIFYCODE parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObj) {
            NSDictionary *rqDic = (NSDictionary *)responseObj;
            if([rqDic[HTTP_STATE] boolValue]){
                NSLog(@"%@",rqDic);
                NSDictionary *dataDic = (NSDictionary *)[rqDic[HTTP_DATA] objectFromJSONString];
                if ([dataDic[@"result"] boolValue]) {
                
                NSString *username = dataDic[@"userlogin"];
                NSString *clientkey = dataDic[@"clientkey"];
                NSDictionary *param = @{@"u":username, @"clientkey": clientkey};
                [hq GETURLString:USER_INFO parameters:param success:^(AFHTTPRequestOperation *operation, id responseObj) {
                    NSDictionary *rqDic = (NSDictionary *)responseObj;
                    if([rqDic[HTTP_STATE] boolValue]){
                        NSArray *dataArr = (NSArray *)[rqDic[HTTP_DATA] objectFromJSONString];
                        NSDictionary *dic = (NSDictionary *)dataArr;
                        
                        UserObj *user = [[UserObj alloc] init];
                        [user setUserName:dic[@"Mobile"]];
                        [user setPassword:@""];
                        [user setIm:dic[@"UserLogin"]];
                        [user setPhone:dic[@"Mobile"]];
                        [user setClientkey:clientkey];
                        [user setIsLogin:YES];
                        [user setNickName:dic[@"Nick"]];
                        [user setTrueName:dic[@"TrueName"]];
                        [user setSex:[dic[@"Sex"] boolValue]];
                        [user setHeadPic:dic[@"HeadPicture"]];
                        [user setEmail:dic[@"Email"]];
                        [user setEmailState:[dic[@"EmailState"] boolValue]];
                        [user setPhoneState:[dic[@"MobileState"] boolValue]];
                        [user setRegTime:dic[@"RegDateTime"]];
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
                                    
                                }
                                
                                [self hideHUDInView:block_self.view];
                                
                            }else{
                                NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
                            }
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            
                        }];
                        
                        
                    }else{
                        NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
                        [self hideHUDInView:block_self.view];
                        [self showHUDInView:block_self.view WithText:[NSString stringWithFormat:@"%@:%@",rqDic[HTTP_ERRCODE],rqDic[HTTP_MSG]] andDelay:LOADING_TIME];
                    }
                    [MYAPPDELEGATE.tabBarC setSelectedIndex:MYAPPDELEGATE.tabBarC.selectedIndex];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"%@ , %@",operation,error);
                    [self hideHUDInView:block_self.view];
                    [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
                }];
                }else{
                    [self showHUDInView:self.view WithText:@"请求失败" andDelay:LOADING_TIME];
                }
                
            }else{
                NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
                if ([rqDic[HTTP_ERRCODE] intValue] == 10001) {
                    [self showHUDInView:block_self.view WithText:@"请输入验证码" andDelay:LOADING_TIME];
                } else {
                    [self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@ , %@",operation,error);
            [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
        }];
    } else {
        NSDictionary *parameters = @{@"u": _phoneNum, @"verifycode": authCodeTF.text,  @"sessionkey": _sessionkey};
        [hq GETURLString:FINDPWD_CHECK parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObj) {
            NSDictionary *rqDic = (NSDictionary *)responseObj;
            if([rqDic[HTTP_STATE] boolValue]){
                NSDictionary *dataDic = (NSDictionary *)[rqDic[HTTP_DATA] objectFromJSONString];
                if([dataDic[@"result"] boolValue]){
                    RegisterSetPasswordViewController *registerSPWC = [RegisterSetPasswordViewController shareInstance];
                    registerSPWC.isComingFromRegister = NO;
                    registerSPWC.phoneNum = _phoneNum;
                    registerSPWC.verifycode = authCodeTF.text;
                    [registerSPWC setIsComingFromRegister:self.isComingFromRegister];
                    [self.navigationController pushViewController:registerSPWC animated:YES];
                } else {
                    [self showHUDInView:block_self.view WithText:@"请求失败" andDelay:LOADING_TIME];
                }
                
            }else{
                NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
                [self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@ , %@",operation,error);
            [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
        }];
    }
    
}

- (void)reSeedAuthCodeAction
{
    DLog(@"重新发送验证码");
    
    BLOCK_SELF(RegisterAuthCodeViewController);
    HTTPRequest *hq = [HTTPRequest shareInstance_myapi];
    if(_isComingFromRegister){
    NSDictionary *parameters = @{@"phone": _phoneNum};
    [hq GETURLString:REGISTER_SEND_PHONE userCache:NO parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rqDic = (NSDictionary *)responseObject;
        if([rqDic[HTTP_STATE] boolValue]){
            NSArray *dataArr = (NSArray *)[rqDic[HTTP_DATA] objectFromJSONString];
            NSDictionary *dic = (NSDictionary *)dataArr;
            DLog(@"sessionkey:%@",dic[@"sessionkey"]);

            _sessionkey = dic[@"sessionkey"];
        }else{
            NSLog(@"errorMsg: %@:%@",rqDic[HTTP_ERRCODE],rqDic[HTTP_MSG]);
            [self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@ , %@",operation,error);
        [self showHUDInView:block_self.view WithText:@"网络请求失败" andDelay:LOADING_TIME];
    }];
    }else if (_isComingFromQuickRegister){
    
    }else{
        NSDictionary *parameters = @{@"u": _phoneNum};
        [hq GETURLString:FINDPWD_SEND userCache:NO parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *rqDic = (NSDictionary *)responseObject;
            if([rqDic[HTTP_STATE] boolValue]){
                
            }else{
                NSLog(@"errorMsg: %@:%@",rqDic[HTTP_ERRCODE],rqDic[HTTP_MSG]);
                [self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@ , %@",operation,error);
            [self showHUDInView:block_self.view WithText:@"网络请求失败" andDelay:LOADING_TIME];
        }];
    }
    
    _secondNum = 60;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(ShouldReseedAuthCode) userInfo:nil repeats:YES];
    [timer fire];
}

- (void)ShouldReseedAuthCode
{
    _secondNum --;
    if(_secondNum < 0){
        _secondNum = 0;
    }
    DLog(@"还有 %d 秒就能重新获取验证码",_secondNum);
    
    [reSendBtn setEnabled:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [reSendBtn setTitle:[NSString stringWithFormat:@"重发(%ld)",(long)_secondNum] forState:UIControlStateNormal];
        [reSendBtn setTitle:[NSString stringWithFormat:@"重发(%ld)",(long)_secondNum] forState:UIControlStateHighlighted];
    });
    

    [reSendBtn setTitleColor:RGBS(101) forState:UIControlStateNormal];
    
    if(_secondNum == 0)
    {
        DLog(@"可以重新获取验证码");
        [timer invalidate];

        [reSendBtn setTitle:@"重发" forState:UIControlStateNormal];
        [reSendBtn setTitle:@"重发" forState:UIControlStateHighlighted];
        [reSendBtn setBackgroundImage:[UIImage imageNamed:@"gary_btn200_2"] forState:UIControlStateNormal];
        [reSendBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [reSendBtn setEnabled:YES];
    } else {
        /*[reSeedAuthCodeBtn setFrame:CGRectMake(100, l.top, 24, 13)];
        [l setHidden:NO];
        [reSeedAuthCodeBtn setEnabled:NO];*/
        [reSendBtn setEnabled:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
