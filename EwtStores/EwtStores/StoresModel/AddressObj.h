//
//  AddressObj.h
//  Shop
//
//  Created by Harry on 14-1-3.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "BaseModel.h"

@interface AddressObj : BaseModel

@property (nonatomic, strong) NSString  *addressId;         //地址标识符
@property (nonatomic, strong) NSString  *addressName;       //收货人名字
@property (nonatomic, strong) NSString  *phoneNum;          //电话号码
@property (nonatomic, strong) NSString  *addressArea;       //地区
@property (nonatomic, strong) NSString  *addressDetail;     //详细地址
@property (nonatomic, strong) NSString  *email;             //邮件
@property (nonatomic, strong) NSString  *postalCode;        //邮政编码

@property (nonatomic, assign) BOOL      isChoiceAddress;

@end
