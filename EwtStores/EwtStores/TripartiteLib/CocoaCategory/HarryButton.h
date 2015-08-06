//
//  HarryButton.h
//  Shop
//
//  Created by Harry on 14-1-9.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HarryButton : UIButton

@property (nonatomic, strong) NSString  *statusImage1;
@property (nonatomic, strong) NSString  *statusImage2;
@property (nonatomic, assign) BOOL      choiceStatus;
@property (nonatomic, strong) id        model;

- (instancetype)initWithFrame:(CGRect )frame andOffImg:(NSString *)offImg andOnImg:(NSString *)onImg withTitle:(NSString *)title;

- (void)changeBackgroundImage;

@end