//
//  AlipayViewController.m
//  Shop
//
//  Created by ewt on 15/8/11.
//  Copyright (c) 2015年 Harry. All rights reserved.
//

#import "AlipayViewController.h"
#import <AlipaySDK/AlipaySDK.h>
#import "DataSigner.h"


@interface AlipayViewController ()

@end

@implementation AlipayViewController

- (id)init{
    self = [super init];
    if (self) {
        _alipayOrder = [[AlipayOrder alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setNavBarTitle:@"支付宝支付"];
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [_alipayOrder description];
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(_alipayOrder.privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:_alipayOrder.appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
            NSString *resultStatus = [resultDic objectForKey:@"resultStatus"];

            if([resultStatus isEqualToString:@"9000"]){
                UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
                NSDictionary *parameters = @{@"clientkey": user.clientkey, @"userlogin": user.im, @"orderserial": _alipayOrder.tradeNO};
                HTTPRequest *hq = [HTTPRequest shareInstance];
                
                [hq GETURLString:ORDER_CLIENTPAY parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObj) {
                    
                    NSDictionary *rqDic = (NSDictionary *)responseObj;
                    if([rqDic[HTTP_STATE] boolValue]){
                        NSDictionary *dic = (NSDictionary *)[rqDic[HTTP_DATA] objectFromJSONString];
                        if([dic[@"result"] intValue] == 0){
                            [self showHUDInView:self.view WithText:@"支付信息提交至后台失败" andDelay:LOADING_TIME];
                            
                        } else{
                            NSLog(@"支付信息成功提交至后台");
                        }
                    }else{
                        NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
                        [self showHUDInView:self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
                    }
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"%@ , %@",operation,error);
                    [self showHUDInView:self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
                }];
                [self showHUDInView:self.view WithText:@"支付成功" andDelay:LOADING_TIME];
                 [self performSelector:@selector(comeToCart) withObject:nil afterDelay:LOADING_TIME];
            }else{
                switch ([resultStatus intValue]) {
                    case 8000:
                        [self showHUDInView:self.view WithText:resultStatus andDelay:LOADING_TIME];
                        break;
                    case 4000:
                        [self showHUDInView:self.view WithText:resultStatus andDelay:LOADING_TIME];
                        break;
                    case 6001:
                        [self showHUDInView:self.view WithText:@"已取消支付" andDelay:LOADING_TIME];
                        break;
                    case 6002:
                        [self showHUDInView:self.view WithText:resultStatus andDelay:LOADING_TIME];
                        break;
                    default:
                        break;
                }
                [self performSelector:@selector(comeToCart) withObject:nil afterDelay:LOADING_TIME];
            }
        }];
        
    }

}

- (void)comeToCart
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    [MYAPPDELEGATE.tabBarC setSelectedIndex:3];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
