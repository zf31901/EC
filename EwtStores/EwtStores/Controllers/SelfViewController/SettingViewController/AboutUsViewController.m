
//
//  AboutUsViewController.m
//  Shop
//
//  Created by Harry on 13-12-20.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "AboutUsViewController.h"
#import "HTTPRequest.h"

@interface AboutUsViewController ()
{
    UIWebView   *aboutUsView;
}

@end

@implementation AboutUsViewController

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
    [self setNavBarTitle:@"关于我们"];
    HTTPRequest *hq = [HTTPRequest shareInstance];
    [hq GETURLString:WEBVIEW_HTML parameters:@{@"id":@"071609"} success:^(AFHTTPRequestOperation *operation, id responseObj) {
        NSDictionary *rqDic = (NSDictionary *)responseObj;
        if ([rqDic[HTTP_STATE] boolValue]) {
            NSDictionary * dataArr = (NSDictionary *)[rqDic[HTTP_DATA] objectFromJSONString];
            NSString *webUrl = dataArr[@"AContentUrl"];
            
            aboutUsView = [[UIWebView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(0, Navbar_Height, Main_Size.width, Main_Size.height - StatusBar_Height - Navbar_Height)]];
            [aboutUsView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:webUrl]]];
            [self.view addSubview:aboutUsView];
        
        }else{
            NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
            [self showHUDInView:self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@ , %@",operation,error);
        [self showHUDInView:self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
