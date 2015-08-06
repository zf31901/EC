//
//  FindPasswordViewController.m
//  EwtStores
//
//  Created by Harry on 13-12-2.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "FindPasswordViewController.h"
#import "FindPWVerifyByPhoneViewController.h"
#import "FindPWByWebViewViewController.h"
#import "RegisterAuthCodeViewController.h"

@interface FindPasswordViewController ()
{
    UITextField *phoneNumTF;
    
    NSUInteger  secondNum;
    RegisterAuthCodeViewController *registerACC;
}
@end

@implementation FindPasswordViewController

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
    RegisterAuthCodeViewController *registerAVC = [RegisterAuthCodeViewController shareInstance];
    registerACC = registerAVC;
    registerAVC._delegate = self;
    
    [self setNavBarTitle:@"找回密码"];
    [self hiddenRightBtn];
    
    [self loadBaseView];
    
    [MobClick event:ZHMM];
}

#pragma mark viewBuild
- (void)loadBaseView
{
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(6, Navbar_Height + 25, 303, 48)]];
    [bgView setUserInteractionEnabled:YES];
    [bgView setImage:[UIImage imageNamed:@"cell-bg-single"]];
    [self.view addSubview:bgView];
    
    phoneNumTF = [GlobalMethod BuildTextFieldWithFrame:CGRectMake(10, 10, 280, 28)
                                                     andPlaceholder:@"请输入会员号/手机号码"];
    [phoneNumTF setDelegate:self];
    [phoneNumTF setKeyboardType:UIKeyboardTypeNumberPad];
    [bgView addSubview:phoneNumTF];
    
    UIButton *nextBtn = [GlobalMethod BuildButtonWithFrame:CGRectMake(6, bgView.bottom + 20, 303, 44)
                                                 andOffImg:@"regist_next_off"
                                                  andOnImg:@"regist_next_off"
                                                 withTitle:@"下一步"];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(nextToFindPassword:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
}

#pragma viewAction
- (void)nextToFindPassword:(UIButton *)nextBtn
{
    DLog(@"寻找密码，输入手机号下一步");
    NSDictionary *parameters = @{@"u": phoneNumTF.text};

    if (secondNum == 0) {
        registerACC.secondNum = 60;
        
        BLOCK_SELF(FindPasswordViewController);
        HTTPRequest *hq = [HTTPRequest shareInstance_myapi];
        
        [hq GETURLString:FINDPWD_SEND parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *rqDic = (NSDictionary *)responseObject;
            if([rqDic[HTTP_STATE] boolValue]){
                NSArray *dataArr = (NSArray *)[rqDic[HTTP_DATA] objectFromJSONString];
                NSDictionary *dic = (NSDictionary *)dataArr;
                DLog(@"sessionkey:%@",dic[@"sessionkey"]);
                registerACC.phoneNum = dic[@"usermobile"];
                registerACC.sessionkey = dic[@"sessionkey"];
                registerACC.im = dic[@"userlogin"];
                [self.navigationController pushViewController:registerACC animated:YES];
            }else{
                NSLog(@"errorMsg: %@:%@",rqDic[HTTP_ERRCODE],rqDic[HTTP_MSG]);
                [self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
                if ([rqDic[HTTP_ERRCODE] intValue] == 10005) {
                    [self.navigationController pushViewController:[FindPWByWebViewViewController shareInstance] animated:YES];
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@ , %@",operation,error);
            [self showHUDInView:block_self.view WithText:@"网络请求失败" andDelay:LOADING_TIME];
        }];
    } else {
        registerACC.secondNum = secondNum;
        registerACC.phoneNum = phoneNumTF.text;
        [registerACC setIsComingFromRegister:YES];
        [self.navigationController pushViewController:registerACC animated:YES];
    }
}

#pragma mark UItextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark ShareDataDelegate
- (void)shareValue:(NSUInteger)value
{
    secondNum = value;
    DLog(@"value:%d--------secondNum:%d",value,secondNum);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
