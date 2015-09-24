//
//  RegisterViewController.m
//  EwtStores
//
//  Created by Harry on 13-12-2.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "RegisterViewController.h"
#import "RegisterAuthCodeViewController.h"
#import <CoreText/CoreText.h>

#import "HTTPRequest.h"
#import "JSONKit.h"
#import "ActivityObj.h"

@interface RegisterViewController ()
{
    UIButton    *nextBtn;
    UITextField *phoneNumTF;
    BOOL        isAgreement;
    
    UIWebView  *ewtAgreementDetailView;
    
    NSUInteger  secondNum;
    RegisterAuthCodeViewController *registerACC;
    
}

@end

@implementation RegisterViewController

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
    
    [self hiddenRightBtn];
    
    [self loadBaseView];
    if(self.isQuickRegist){
        [self setNavBarTitle:@"快速注册"];
        [MobClick event:KSZC];
    }else{
        [self setNavBarTitle:@"注册"];
        [MobClick event:ZC];
    }
}

#pragma mark viewBuild
- (void)loadBaseView
{
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(6, Navbar_Height + 25, 303, 48)]];
    [bgView setUserInteractionEnabled:YES];
    [bgView setImage:[UIImage imageNamed:@"cell-bg-single"]];
    [self.view addSubview:bgView];
    
    phoneNumTF = [GlobalMethod BuildTextFieldWithFrame:CGRectMake(10, 10, 283, 28) andPlaceholder:@"请输入手机号码"];
    [phoneNumTF setDelegate:self];
    [phoneNumTF setKeyboardType:UIKeyboardTypeNumberPad];
    [bgView addSubview:phoneNumTF];
    
    nextBtn = [GlobalMethod BuildButtonWithFrame:CGRectMake(6, bgView.bottom + 25, 303, 44)
                                       andOffImg:@"regist_next_off"
                                        andOnImg:@"regist_next_on"
                                       withTitle:@"下一步"];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if (_isQuickRegist) {
        [nextBtn addTarget:self action:@selector(nextToQuickRegisterNews:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [nextBtn addTarget:self action:@selector(nextToRegisterNews:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.view addSubview:nextBtn];
    
    UIButton *agreementBtn = [GlobalMethod BuildButtonWithFrame:CGRectMake(16, nextBtn.bottom + 20, 118, 13)
                                                      andOffImg:nil
                                                       andOnImg:nil
                                                      withTitle:@"点击下一步表示同意"];
    [agreementBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [agreementBtn setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:agreementBtn];
    
    UILabel *ewtLb = [GlobalMethod BuildLableWithFrame:CGRectMake(agreementBtn.right, nextBtn.bottom + 19, 140, 13)
                                              withFont:[UIFont systemFontOfSize:12]
                                              withText:@"爱心天地用户服务协议"];
    [ewtLb setTextColor:RGB(0, 117, 169)];
    [ewtLb setUserInteractionEnabled:YES];
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:@"爱心天地用户服务协议"];
    [attString addAttribute:(NSString *)kCTUnderlineColorAttributeName
                      value:(id)[NSNumber numberWithInt:kCTUnderlineStyleSingle]
                      range:NSMakeRange(0, 8)];
    [ewtLb setAttributedText:attString];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ewtAgreemetnDetail)];
    [ewtLb addGestureRecognizer:tap];
    [self.view addSubview:ewtLb];
}

- (void)loadEwtAgreementDetailView
{
    HTTPRequest *hq = [HTTPRequest shareInstance];
    [hq GETURLString:WEBVIEW_HTML parameters:@{@"id":@"071608"} success:^(AFHTTPRequestOperation *operation, id responseObj) {
        NSDictionary *rqDic = (NSDictionary *)responseObj;
        if ([rqDic[HTTP_STATE] boolValue]) {
             NSDictionary * dataArr = (NSDictionary *)[rqDic[HTTP_DATA] objectFromJSONString];
            NSString *webUrl = dataArr[@"AContentUrl"];
            
            ewtAgreementDetailView = [[UIWebView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(0, Navbar_Height, Main_Size.width, Main_Size.height - StatusBar_Height - Navbar_Height)]];
            [ewtAgreementDetailView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:webUrl]]];
            [self.view addSubview:ewtAgreementDetailView];
            [self.view bringSubviewToFront:ewtAgreementDetailView];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenEwtAgreeDetailView)];
            [ewtAgreementDetailView setUserInteractionEnabled:YES];
            [ewtAgreementDetailView addGestureRecognizer:tap];
            
            isAgreement = YES;
            
        }else{
            NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
            [self showHUDInView:self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@ , %@",operation,error);
        [self showHUDInView:self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
    }];
    
}

- (void)removewEwtAgreementDetailView
{
    [ewtAgreementDetailView removeFromSuperview];
    ewtAgreementDetailView = nil;
}

#pragma mark viewAction
- (void)nextToRegisterNews:(UIButton *)button
{
    DLog(@"注册界面，输入手机下一步");
    
    [phoneNumTF resignFirstResponder];
    
    NSDictionary *parameters = @{@"phone": phoneNumTF.text};
    if (registerACC.phoneNum != nil && ![registerACC.phoneNum isEqualToString:phoneNumTF.text]) {
        registerACC = [RegisterAuthCodeViewController shareInstance];
        registerACC._delegate = self;
        secondNum = 0;
    }
    if (secondNum == 0) {
        registerACC.secondNum = 60;
        
        BLOCK_SELF(RegisterViewController);
        [self showHUDInView:self.view WithText:@"正在验证手机"];
        button.userInteractionEnabled = NO;
        HTTPRequest *hq = [HTTPRequest shareInstance_myapi];
        
        [hq GETURLString:REGISTER_SEND_PHONE userCache:NO parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObj) {
            NSDictionary *rqDic = (NSDictionary *)responseObj;
            [self hideHUDInView:self.view];
            button.userInteractionEnabled = YES;
            if([rqDic[HTTP_STATE] boolValue]){
                NSArray *dataArr = (NSArray *)[rqDic[HTTP_DATA] objectFromJSONString];
                NSDictionary *dic = (NSDictionary *)dataArr;
                DLog(@"sessionkey:%@",dic[@"sessionkey"]);
                registerACC.phoneNum = phoneNumTF.text;
                registerACC.sessionkey = dic[@"sessionkey"];
                [registerACC setIsComingFromRegister:YES];
                [self.navigationController pushViewController:registerACC animated:YES];
                
            }else{
                NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
                [self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@ , %@",operation,error);
            [self hideHUDInView:self.view];
            button.userInteractionEnabled = YES;
            [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
        }];
    } else {
        registerACC.secondNum = secondNum;
        registerACC.phoneNum = phoneNumTF.text;
        [registerACC setIsComingFromRegister:YES];
        [self.navigationController pushViewController:registerACC animated:YES];
    }
}

- (void)nextToQuickRegisterNews:(UIButton *)button{
    DLog(@"快速注册，输入手机下一步");
    [phoneNumTF resignFirstResponder];
    NSDictionary *parameters = @{@"phone": phoneNumTF.text};
    if (registerACC.phoneNum != nil && ![registerACC.phoneNum isEqualToString:phoneNumTF.text]) {
        registerACC = [RegisterAuthCodeViewController shareInstance];
        registerACC._delegate = self;
        secondNum = 0;
    }
    if (secondNum == 0) {
        registerACC.secondNum = 60;
        
        BLOCK_SELF(RegisterViewController);
        [self showHUDInView:self.view WithText:@"正在验证手机"];
        button.userInteractionEnabled = NO;
        HTTPRequest *hq = [HTTPRequest shareInstance_myapi];
        
        [hq GETURLString:QUICKREGISTER_SEND_PHONE userCache:NO parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObj) {
            NSDictionary *rqDic = (NSDictionary *)responseObj;
            [self hideHUDInView:self.view];
            button.userInteractionEnabled = YES;
            if([rqDic[HTTP_STATE] boolValue]){
                NSArray *dataArr = (NSArray *)[rqDic[HTTP_DATA] objectFromJSONString];
                NSDictionary *dic = (NSDictionary *)dataArr;
                DLog(@"sessionkey:%@",dic[@"sessionkey"]);
                registerACC.phoneNum = phoneNumTF.text;
                registerACC.sessionkey = dic[@"sessionkey"];
                [registerACC setIsComingFromQuickRegister:YES];
                [self.navigationController pushViewController:registerACC animated:YES];
            }else{
                NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
                [self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@ , %@",operation,error);
            [self hideHUDInView:self.view];
            button.userInteractionEnabled = YES;
            [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
        }];
    } else {
        registerACC.secondNum = secondNum;
        registerACC.phoneNum = phoneNumTF.text;
        [registerACC setIsComingFromQuickRegister:YES];
        [self.navigationController pushViewController:registerACC animated:YES];
    }

}

- (void)agreementAction:(UIButton *)agreementBtn
{
    isAgreement = !isAgreement;
    
    DLog(@"%@ ewt协议",isAgreement?@"同意":@"取消");
    
    if(isAgreement)
    {
        [nextBtn setEnabled:YES];
    }
    else
    {
        [nextBtn setEnabled:NO];
    }
}

- (void)ewtAgreemetnDetail
{
    DLog(@"查看ewt协议详情");
    
    [phoneNumTF resignFirstResponder];
    [self loadEwtAgreementDetailView];
}

- (void)hiddenEwtAgreeDetailView
{
    
    isAgreement = NO;
    [self removewEwtAgreementDetailView];
}

- (void)leftBtnAction:(UIButton *)btn
{
    if (isAgreement) {
        [self hiddenEwtAgreeDetailView];
    } else {
        [super leftBtnAction:btn];
    }
}

#pragma mark ShareDataDelegate
- (void)shareValue:(NSUInteger)value
{
    secondNum = value;
    DLog(@"value:%d--------secondNum:%d",value,secondNum);
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
