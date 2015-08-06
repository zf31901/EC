//
//  ActivityObj.h
//  Shop
//
//  Created by Harry on 13-12-30.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "BaseModel.h"

@interface ActivityObj : BaseModel

@property (nonatomic, strong) NSURL         *activityImgUrl;    //活动海报
@property (nonatomic, strong) NSString      *activityId;        //活动Id
@property (nonatomic, strong) NSString      *activityName;      //活动名称
@property (nonatomic, strong) NSURL         *activityLinkUrl;   //活动链接

@end
