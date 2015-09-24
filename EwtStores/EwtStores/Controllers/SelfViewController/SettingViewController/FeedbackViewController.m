//
//  FeedbackViewController.m
//  Shop
//
//  Created by Harry on 14-1-7.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "FeedbackViewController.h"
#import "UserObj.h"
#import <QuartzCore/QuartzCore.h>

@interface FeedbackViewController () <UITextViewDelegate>
{
    UILabel     *placeholderLb;
    
    UITextView  *feedbackTV;
}

@end

@implementation FeedbackViewController

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
    
    [self setNavBarTitle:@"意见反馈"];

    //UIButton *rightBtn = [self getRightButton];
    //[rightBtn setImage:[UIImage imageNamed:@"send"] forState:UIControlStateNormal];
    [self hiddenRightBtn];
    
    feedbackTV = [[UITextView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(10, Navbar_Height + 10, 300, 200)]];
    [feedbackTV setDelegate:self];
    [feedbackTV setBackgroundColor:[UIColor whiteColor]];
    [feedbackTV.layer setCornerRadius:8];
    [feedbackTV.layer setBorderColor:RGBS(218).CGColor];
    [feedbackTV.layer setBorderWidth:1];
    [feedbackTV setReturnKeyType:UIReturnKeySend];
    [self.view addSubview:feedbackTV];
    
    placeholderLb = [GlobalMethod BuildLableWithFrame:CGRectMake(10, 10, 240, 16)
                                                      withFont:[UIFont systemFontOfSize:15]
                                                      withText:@"有什么意见，都可以随时通知我们~"];
    [placeholderLb setTextColor:RGBS(201)];
    [feedbackTV addSubview:placeholderLb];
    
    UIButton *nextBtn = [GlobalMethod BuildButtonWithFrame:CGRectMake(6, feedbackTV.bottom + 20, 303, 44)
                                                 andOffImg:@"regist_next_off"
                                                  andOnImg:@"regist_next_on"
                                                 withTitle:@"发送"];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(rightBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
    
    [MobClick event:YJFK];
}

#pragma mark ViewAction
- (void)rightBtnAction:(UIButton *)btn{
    DLog(@"发送意见");
    
    [feedbackTV resignFirstResponder];
    
    if(feedbackTV.text.length == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"意见不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return ;
    }
    
    [self showHUDInView:self.view WithText:NETWORKLOADING];
    UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
    NSDictionary *dic;
    if (user.isLogin) {
        dic = @{@"UserLogin":user.im,@"Title":@"爱心天地问题" , @"Content":feedbackTV.text};
    }else{
        dic = @{@"Title":@"爱心天地问题" , @"Content":feedbackTV.text};
    }

    HTTPRequest *hq = [HTTPRequest shareInstance_myapi];
    [hq POSTURLString:FEEDBACK parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *rqDic = (NSDictionary *)responseObject;
        if([rqDic[HTTP_STATE] boolValue]){
            
            NSDictionary *dataDic = (NSDictionary *)[rqDic[HTTP_DATA] objectFromJSONString];
            if([dataDic[@"result"] boolValue]){
                DLog(@"反馈成功");
                
                [self hideHUDInView:self.view];
                [self showHUDInView:self.view WithText:@"谢谢您的意见反馈" andDelay:LOADING_TIME];
                
                [self performSelector:@selector(back) withObject:self afterDelay:LOADING_TIME];
            }
        }else{
            NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
            [self hideHUDInView:self.view];
            [self showHUDInView:self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"%@",error);
        [self hideHUDInView:self.view];
        [self showHUDInView:self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
    }];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [placeholderLb setHidden:YES];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if ([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
        
        [self rightBtnAction:nil];
        
        return NO;
        
    }
    
    return YES;
    
}

@end
