//
//  HelpCenterDetailViewController.m
//  Shop
//
//  Created by Harry on 14-1-16.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "HelpCenterDetailViewController.h"

@interface HelpCenterDetailViewController () <UIWebViewDelegate>
{
    UIWebView *webView;
}
@end

@implementation HelpCenterDetailViewController

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
    
    webView = [[UIWebView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(0, Navbar_Height, Main_Size.width, Main_Size.height - StatusBar_Height - Navbar_Height)]];
    [webView setDelegate:self];
    [webView setScalesPageToFit:YES];
    [self.view addSubview:webView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self setNavBarTitle:self.detailTitle];
    
    [webView loadRequest:[NSURLRequest requestWithURL:self.detailURL]];
    
    //[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://my.wt.com/Tool/Html%E5%B8%B8%E7%94%A8%E6%A8%A1%E6%9D%BF/291.html#none"]]];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self showHUDInView:self.view WithText:NETWORKLOADING];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
