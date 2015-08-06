//
//  FindPWVerifyByPhoneViewController.h
//  EwtStores
//
//  Created by Harry on 13-12-3.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "BaseViewController.h"

@interface FindPWVerifyByPhoneViewController : BaseViewController<UITextFieldDelegate>

@property (nonatomic, copy) NSString *phoneNum;//注册的手机号
@property (nonatomic, copy) NSString *sessionkey;
@property (nonatomic, copy) NSString *im;

@end
