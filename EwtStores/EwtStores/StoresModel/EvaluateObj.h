//
//  EvaluateObj.h
//  Shop
//
//  Created by Harry on 13-12-27.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "BaseModel.h"

@interface EvaluateObj : BaseModel

@property (nonatomic, strong) NSString  *Person;            //评价人
@property (nonatomic, strong) NSString  *Area;              //评价地区
@property (nonatomic, strong) NSString  *niceEvaluate;      //好评
@property (nonatomic, strong) NSString  *badEvaluate;       //不足
@property (nonatomic, strong) NSString  *Time;              //评价时间
@property (nonatomic, strong) NSString  *PersonId;          //评价人Id
@property (nonatomic, strong) NSURL     *PersonImgUrl;      //评价人头像

@end
