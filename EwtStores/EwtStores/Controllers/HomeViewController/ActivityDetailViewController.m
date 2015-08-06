//
//  ActivityDetailViewController.m
//  Shop
//
//  Created by Harry on 14-1-16.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "ActivityDetailViewController.h"
#import "LoginInViewController.h"
#import "ProductDetailViewController.h"

#import "UMSocialSnsService.h"
#import "UMSocialSnsPlatformManager.h"

@interface ActivityDetailViewController () <UIWebViewDelegate>
{
    UIWebView *webView;
}

@end

@implementation ActivityDetailViewController

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
    
    [self hiddenRightBtn];
    
    webView = [[UIWebView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(0, Navbar_Height, Main_Size.width, Main_Size.height - StatusBar_Height - Navbar_Height)]];
    [webView setDelegate:self];
    [webView setScalesPageToFit:YES];
    [self.view addSubview:webView];
    [webView loadRequest:[NSURLRequest requestWithURL:self.activtyDetailUrl]];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self setNavBarTitle:self.actTitle];
    
//    [webView loadRequest:[NSURLRequest requestWithURL:self.activtyDetailUrl]];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    //[self showHUDInView:self.view WithText:NETWORKLOADING];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self hideHUDInView:self.view];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self hideHUDInView:self.view];
    [self showHUDInView:self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
}

- (BOOL)webView:(UIWebView *)webView
        shouldStartLoadWithRequest:(NSURLRequest *)request
        navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlString = [[request URL] absoluteString];
    NSRange rangeSearch = [urlString rangeOfString:@"objc_"];   //搜索
    if (rangeSearch.location != NSNotFound) {           //搜索不到是 NSNotFound
        urlString = [urlString substringFromIndex:rangeSearch.location];
    }
    NSArray *urlComps = [urlString componentsSeparatedByString:@":"];
    
    BLOCK_SELF(ActivityDetailViewController);
    HTTPRequest *hq = [HTTPRequest shareInstance];
    UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
    
    //分享下载界面：领取优惠券点击时间
    if([urlComps count] && [[urlComps objectAtIndex:0] isEqualToString:@"objc_receive"])
    {
        //NSString *funcStr = [urlComps objectAtIndex:1];
        [self checkLogin];
        //[[[UIAlertView alloc] initWithTitle:@"这里是标题" message:@"测试立即领取" delegate:self cancelButtonTitle:@"Cancel按钮" otherButtonTitles:@"OK", nil] show];
        /*NSDictionary *parameters = @{@"cmd": @"share",@"action": @"check",@"userlogin": user.im};
        [hq GETURLString:ACTIVITY_SUBJECT parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObj) {
            NSDictionary *rqDic = (NSDictionary *)responseObj;
            if([rqDic[HTTP_STATE] boolValue]){
                NSDictionary *dic = (NSDictionary *)[rqDic[HTTP_DATA] objectFromJSONString];
                if([dic[@"result"] intValue] == 0){
                    [self showHUDInView:block_self.view WithText:@"请先分享给小伙伴" andDelay:2];
                } else{ //已分享
                   
                }
            }else{
                NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
                [self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:2];
                //[self showHUDInView:block_self.view WithText:[NSString stringWithFormat:@"%@:%@",rqDic[HTTP_ERRCODE],rqDic[HTTP_MSG]] andDelay:2];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@ , %@",operation,error);
            [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:2];
        }];*/
        NSDictionary *params = @{@"cmd": @"coupon",@"action": @"add",@"userlogin": user.im};
        [hq GETURLString:ACTIVITY_SUBJECT userCache:NO parameters:params success:^(AFHTTPRequestOperation *operation, id responseObj) {
            NSDictionary *rqDic2 = (NSDictionary *)responseObj;
            if([rqDic2[HTTP_STATE] boolValue]){
                NSDictionary *dic2 = (NSDictionary *)[rqDic2[HTTP_DATA] objectFromJSONString];
                if([dic2[@"result"] intValue] == 0){
                    [self showHUDInView:block_self.view WithText:@"请先分享给小伙伴" andDelay:LOADING_TIME];
                } else if([dic2[@"result"] intValue] == 1){
                    [self showHUDInView:block_self.view WithText:@"领券成功" andDelay:LOADING_TIME];
                } else if([dic2[@"result"] intValue] == 2){
                    [self showHUDInView:block_self.view WithText:@"您已经领过券了" andDelay:LOADING_TIME];
                } else if([dic2[@"result"] intValue] == 3){
                    [self showHUDInView:block_self.view WithText:@"领券失败，活动未开始" andDelay:LOADING_TIME];
                }else if([dic2[@"result"] intValue] == 4){
                    [self showHUDInView:block_self.view WithText:@"领券失败，活动已结束" andDelay:LOADING_TIME];
                }else if([dic2[@"result"] intValue] == -1){
                    [self showHUDInView:block_self.view WithText:@"领券失败，程序错误" andDelay:LOADING_TIME];
                }
            }else{
                NSLog(@"errorMsg: %@",rqDic2[HTTP_MSG]);
                [self showHUDInView:block_self.view WithText:rqDic2[HTTP_MSG] andDelay:LOADING_TIME];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@ , %@",operation,error);
            [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
        }];
        
        return NO;
        
    } else if([urlComps count] && [[urlComps objectAtIndex:0] isEqualToString:@"objc_share"]){
        return NO;
        //分享下载界面：分享点击时间
        //NSString *funcStr = [urlComps objectAtIndex:1];
        [self checkLogin];
        //NSString *headStr = @"网通百货APP马上抢优惠券";
        NSString *textStr = @"【网通百货】马年送好礼，只需要3步免费领取优惠券，每笔订单购物满50元即可使用，全场还包邮哦。马上去参加：https://my.ewt.cc/Tool/Html%E5%B8%B8%E7%94%A8%E6%A8%A1%E6%9D%BF/301.html";
        //NSString *shareStr = [headStr stringByAppendingFormat:@"\n%@",textStr];
        [UMSocialSnsService presentSnsIconSheetView:self
                                             appKey:@"52e1cbd656240b5a2209d810"
                                          shareText:textStr
                                         shareImage:[UIImage imageNamed:@"share"]
                                    shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQQ,UMShareToQzone,UMShareToSina,UMShareToTencent,nil]
                                           delegate:self];
        
        
        return NO;
    }else{
        //点击网页上的某个商品
        // 从http://bh.ewt.cc/showitem/19675.htm 截取 showitem/19675.htm
        NSArray *arr = [urlString componentsSeparatedByString:@"http://bh.ewt.cc/"];
        
        if (arr.count > 1) {
            NSString *productIdInfo = arr[1];
            
            // 从 showitem/19675.htm 截取 showitem/19675
            NSArray *productIdArr = [productIdInfo componentsSeparatedByString:@"."];
            if (productIdArr.count > 1) {
                NSString *p = productIdArr[productIdArr.count - 2];
                
                // 从 showitem/19675 截取 19675
                NSArray *pA = [p componentsSeparatedByString:@"/"];
                if (pA.count > 1) {
                    NSString *productID = pA[1];
                    ProductDetailViewController *proDVC = [ProductDetailViewController shareInstance];
                    proDVC.productId = productID;
                    [self.navigationController pushViewController:proDVC animated:YES];
                    
                    return NO;
                }
            }
        }
    }
    
    return YES;
}

- (void)checkLogin
{
    UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
    if(user.isLogin == NO){
        LoginInViewController *loginViewC = [[LoginInViewController alloc] init];
        [loginViewC setIsComingFromActivity:YES];
        UINavigationController *loginNavC = [[UINavigationController alloc] initWithRootViewController:loginViewC];
        [loginNavC setNavigationBarHidden:YES];
        [self presentViewController:loginNavC animated:YES completion:Nil];
        return ;
    }
}

//分享成功之后
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    BLOCK_SELF(ActivityDetailViewController);
    HTTPRequest *hq = [HTTPRequest shareInstance];
    UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
    if (response.responseCode == 200) {
        NSDictionary *parameters = @{@"cmd": @"share",@"action": @"add",@"userlogin": user.im};
        [hq GETURLString:ACTIVITY_SUBJECT parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObj) {
            NSDictionary *rqDic = (NSDictionary *)responseObj;
            if([rqDic[HTTP_STATE] boolValue]){
                NSDictionary *dic = (NSDictionary *)[rqDic[HTTP_DATA] objectFromJSONString];
                if([dic[@"result"] intValue] == 0){
                    [self showHUDInView:block_self.view WithText:@"分享失败" andDelay:LOADING_TIME];
                } else{
                    [self showHUDInView:block_self.view WithText:@"分享成功" andDelay:LOADING_TIME];
                }
            }else{
                NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
                [self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
                //[self showHUDInView:block_self.view WithText:[NSString stringWithFormat:@"%@:%@",rqDic[HTTP_ERRCODE],rqDic[HTTP_MSG]] andDelay:2];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@ , %@",operation,error);
            [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
        }];
    } else if (response.responseCode == 505) {
        [self showHUDInView:block_self.view WithText:@"用户被封禁" andDelay:LOADING_TIME];
    } else if (response.responseCode == 510) {
        [self showHUDInView:block_self.view WithText:@"分享失败" andDelay:LOADING_TIME];
    } else if (response.responseCode == 5007) {
        [self showHUDInView:block_self.view WithText:@"发送内容为空" andDelay:LOADING_TIME];
    } else if (response.responseCode == 5016) {
        [self showHUDInView:block_self.view WithText:@"分享内容重复" andDelay:LOADING_TIME];
    } else if (response.responseCode == 5020) {
        [self showHUDInView:block_self.view WithText:@"授权之后没有得到用户uid" andDelay:LOADING_TIME];
    } else if (response.responseCode == 5027) {
        [self showHUDInView:block_self.view WithText:@"token过期" andDelay:LOADING_TIME];
    } else if (response.responseCode == 5050) {
        [self showHUDInView:block_self.view WithText:@"网络错误" andDelay:LOADING_TIME];
    } else if (response.responseCode == 5051) {
        [self showHUDInView:block_self.view WithText:@"获取账户失败" andDelay:LOADING_TIME];
    } else if (response.responseCode == 5052) {
        [self showHUDInView:block_self.view WithText:@"分享已取消" andDelay:LOADING_TIME];
    } else if (response.responseCode == 100031) {
        [self showHUDInView:block_self.view WithText:@"QQ空间应用没有在QQ互联平台上申请上传图片到相册的权限" andDelay:LOADING_TIME];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
