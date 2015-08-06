//
//  AddressDetailViewController.h
//  Shop
//
//  Created by Harry on 14-1-3.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "BaseViewController.h"

@class AddressObj;

@interface AddressDetailViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property (nonatomic, strong) AddressObj  *addressObj;
@property (nonatomic, assign) BOOL         shouldDefaultAddress;  //当第一次新建时，设置该地址为默认地址

@end
