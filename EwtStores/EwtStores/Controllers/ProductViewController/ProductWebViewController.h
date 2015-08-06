//
//  ProductWebViewController.h
//  Shop
//
//  Created by Jacob on 14-1-8.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductWebViewController : BaseViewController<UIWebViewDelegate> 
{
    UIWebView *webView;
}

@property (nonatomic, strong) NSURL *productDetailUrl;

@end
