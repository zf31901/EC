//
//  RegisterSetPasswordViewController.h
//  EwtStores
//
//  Created by Harry on 13-12-3.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "BaseViewController.h"

@interface RegisterSetPasswordViewController : BaseViewController<UITextFieldDelegate>

@property (nonatomic, assign) BOOL isComingFromRegister;

@property (nonatomic, copy) NSString *phoneNum;       //注册的手机号
@property (nonatomic, copy) NSString *verifycode;     //验证码

@end
