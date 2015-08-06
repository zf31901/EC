//
//  LoginAuthCodeViewController.h
//  EwtStores
//
//  Created by Harry on 13-12-3.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "BaseViewController.h"

@protocol ShareDataDelegate <NSObject>
- (void)shareValue:(NSUInteger)value;
@end

@interface RegisterAuthCodeViewController : BaseViewController<UITextFieldDelegate>

@property (nonatomic, assign) BOOL isComingFromRegister;
@property (nonatomic, assign) BOOL isComingFromQuickRegister;


@property (nonatomic, copy) NSString *phoneNum;//注册的手机号
@property (nonatomic, copy) NSString *sessionkey;
@property (nonatomic, copy) NSString *im;

@property (nonatomic, assign) NSInteger secondNum;

@property(nonatomic,assign) id<ShareDataDelegate> _delegate;

@end
