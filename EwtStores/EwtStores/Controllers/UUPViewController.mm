//
//  UUPViewController.mm
//  Shop
//
//  Created by Harry on 14-1-22.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "UUPViewController.h"
#import "CartViewController/CartViewController.h"
#import "UnpayViewController.h"

#import "UPPayPluginDelegate.h"
#import "UPPayPlugin.h"
#import "HTTPRequest.h"

#import "UMSocialSnsService.h"
#import "UMSocialSnsPlatformManager.h"

extern CartViewController *cartVC;

@interface UUPViewController ()  <UPPayPluginDelegate,UMSocialUIDelegate>

@end

@implementation UUPViewController

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
    
    [self setNavBarTitle:@"银联支付"];
    
    //银联支付
    //[UPPayPlugin startPay:self.TNString mode:UUPAY_CODE viewController:self delegate:self];
}

-(void)UPPayPluginResult:(NSString*)result
{
    if ([result isEqualToString:@"success"]) {
        UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
        NSDictionary *parameters = @{@"clientkey": user.clientkey, @"userlogin": user.im, @"orderserial": _orderSerial};
        BLOCK_SELF(UUPViewController);
        HTTPRequest *hq = [HTTPRequest shareInstance];
        
        [hq GETURLString:ORDER_CLIENTPAY parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObj) {
            NSDictionary *rqDic = (NSDictionary *)responseObj;
            if([rqDic[HTTP_STATE] boolValue]){
                 NSDictionary *dic = (NSDictionary *)[rqDic[HTTP_DATA] objectFromJSONString];
                if([dic[@"result"] intValue] == 0){
                    [self showHUDInView:block_self.view WithText:@"支付信息提交至后台失败" andDelay:LOADING_TIME];
                    
                } else{
                    NSLog(@"支付信息成功提交至后台");
                }
            }else{
                NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
                [self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
            }
            
            [self performSelector:@selector(comeToCart) withObject:nil afterDelay:LOADING_TIME];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@ , %@",operation,error);
            [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
            [self performSelector:@selector(comeToCart) withObject:nil afterDelay:LOADING_TIME];
        }];
    }else{
        
        if([result isEqualToString:@"cannel"]){
            [self showHUDInView:self.view WithDetailText:@"取消支付" andDelay:LOADING_TIME];
        }else if ([result isEqualToString:@"fail"]){
            [self showHUDInView:self.view WithDetailText:@"支付失败" andDelay:LOADING_TIME];
        }
        
        [self performSelector:@selector(comeToCart) withObject:nil afterDelay:LOADING_TIME];
    }
}

- (void)comeToCart
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    [MYAPPDELEGATE.tabBarC setSelectedIndex:2];
    
    UnpayViewController *unpayVC = [UnpayViewController shareInstance];
    [unpayVC setHidesBottomBarWhenPushed:YES];
    [cartVC.navigationController pushViewController:unpayVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
