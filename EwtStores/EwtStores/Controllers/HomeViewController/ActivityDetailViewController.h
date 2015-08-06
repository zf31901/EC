//
//  ActivityDetailViewController.h
//  Shop
//
//  Created by Harry on 14-1-16.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "BaseViewController.h"
#import "UMSocialControllerService.h"

@interface ActivityDetailViewController : BaseViewController <UMSocialUIDelegate>

@property (nonatomic, strong) NSString  *actTitle;
@property (nonatomic, strong) NSURL     *activtyDetailUrl;

@end
