//
//  UIButton+Extensions.m
//  BigOrSmallButton
//
//  Created by 邓 立兵 on 13-8-2.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "UIButton+Extensions.h"
#import <objc/runtime.h>

@implementation UIButton (Extensions)

static const NSString *KEY_HIT_TEST_EDGE_INSETS = @"HitTestEdgeInsets";

@dynamic buttonEdgeInsets;

- (void)setButtonEdgeInsets:(UIEdgeInsets)buttonEdgeInsets
{
    NSValue *value = [NSValue value:&buttonEdgeInsets withObjCType:@encode(UIEdgeInsets)];
    objc_setAssociatedObject(self, &KEY_HIT_TEST_EDGE_INSETS, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIEdgeInsets)buttonEdgeInsets
{
    NSValue *value = objc_getAssociatedObject(self, &KEY_HIT_TEST_EDGE_INSETS);
    if(value)
    {
        UIEdgeInsets edgeInsets;
        [value getValue:&edgeInsets];
        return edgeInsets;
    }
    else
    {
        return UIEdgeInsetsZero;
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if(UIEdgeInsetsEqualToEdgeInsets(self.buttonEdgeInsets, UIEdgeInsetsZero) || !self.enabled || self.hidden)
    {
        return [super pointInside:point withEvent:event];
    }
    
    CGRect frame = self.bounds;
    CGRect hitFrame = UIEdgeInsetsInsetRect(frame, self.buttonEdgeInsets);
    return CGRectContainsPoint(hitFrame, point);
}

@end
