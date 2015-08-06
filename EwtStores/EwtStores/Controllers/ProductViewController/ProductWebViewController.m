//
//  ProductWebViewController.m
//  Shop
//
//  Created by Jacob on 14-1-8.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "ProductWebViewController.h"

@interface ProductWebViewController ()

@end

@implementation ProductWebViewController

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
    
    [webView setDelegate:self];
    
    [self setNavBarTitle:@"商品详情"];
    
	webView = [[UIWebView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(0, Navbar_Height, Main_Size.width, Main_Size.height - StatusBar_Height - Navbar_Height)]];
    [webView setDelegate:self];
    [webView setScalesPageToFit:YES];
    NSURLRequest *request =[NSURLRequest requestWithURL:self.productDetailUrl];

    [self.view addSubview: webView];
    
    [webView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UIWebViewDelegate Methods
- (void) webViewDidStartLoad:(UIWebView *)webView
{
    [self showHUDInView:self.view WithText:NETWORKLOADING];
    
     NSLog(@"webViewDidStartLoad");
}
- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    [self hideHUDInView:self.view];
    NSLog(@"webViewDidFinishLoad");
}
- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self hideHUDInView:self.view];
    [self showHUDInView:self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
    NSLog(@"didFailLoadWithError:%@", error);
}

@end
