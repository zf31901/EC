//
//  RegisterViewController.h
//  EwtStores
//
//  Created by Harry on 13-12-2.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "BaseViewController.h"
#import "RegisterAuthCodeViewController.h"

@interface RegisterViewController : BaseViewController<UITextFieldDelegate,ShareDataDelegate>

@property (nonatomic, assign) BOOL isQuickRegist;

@end
