//
//  EvaluateCell.h
//  Shop
//
//  Created by Harry on 13-12-27.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EGOImageView;
@class EvaluateObj;

@interface EvaluateCell : UITableViewCell

@property (nonatomic, strong) EGOImageView  *headImgView;
@property (nonatomic, strong) UILabel       *personNameLb;
@property (nonatomic, strong) UILabel       *areaLb;
@property (nonatomic, strong) UILabel       *timeLb;
@property (nonatomic, strong) UILabel       *niceEvaluateLb;
@property (nonatomic, strong) UILabel       *badEvaluateLb;

- (float )reuserTableViewCell:(EvaluateObj *)obj;

@end
