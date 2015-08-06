//
//  HarryButton.m
//  Shop
//
//  Created by Harry on 14-1-9.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "HarryButton.h"

@implementation HarryButton

- (instancetype)initWithFrame:(CGRect )frame andOffImg:(NSString *)offImg andOnImg:(NSString *)onImg withTitle:(NSString *)title
{
    self = [super init];
    
    if(self){
        self.statusImage1 = offImg;
        self.statusImage2 = onImg;

        [self setFrame:frame];
        [self setBackgroundImage:[UIImage imageNamed:self.statusImage1] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:self.statusImage2] forState:UIControlStateHighlighted];
        [self setTitle:title forState:UIControlStateNormal];
        [self setTitle:title forState:UIControlStateHighlighted];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    
    return self;
}

- (void)changeBackgroundImage
{
    self.choiceStatus = !self.choiceStatus;
    if(self.choiceStatus){
        [self setBackgroundImage:[UIImage imageNamed:self.statusImage2]forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:self.statusImage1] forState:UIControlStateHighlighted];
    }else{
        [self setBackgroundImage:[UIImage imageNamed:self.statusImage1] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:self.statusImage2] forState:UIControlStateHighlighted];
    }
    
}

@end

