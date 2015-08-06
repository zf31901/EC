//
//  ProductRushListCell.m
//  Shop
//
//  Created by Harry on 13-12-30.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "ProductRushListCell.h"

@implementation ProductRushListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.leftCell       = [[ProductRushCell alloc] initWithStyle:style reuseIdentifier:reuseIdentifier];
        [self.leftCell      setFrame:CGRectMake(0, 0, 160, 240)];
        [self.leftCell      set_delegate:self];
        [self.contentView   addSubview:self.leftCell];
        
        self.rightCell      = [[ProductRushCell alloc] initWithStyle:style reuseIdentifier:reuseIdentifier];
        [self.rightCell     setFrame:CGRectMake(160, 0, 160, 240)];
        [self.rightCell     set_delegate:self];
        [self.contentView   addSubview:self.rightCell];
        
        [self setExclusiveTouchView:self.contentView];
    }
    return self;
}

- (void)reuserTableViewLeftCell:(ProductObj *)leftObj
                        AtIndex:(NSInteger)index
                         AtType:(PRODUCT_TYPE)type
{
    [self.leftCell  removeFromSuperview];
    [self.rightCell removeFromSuperview];
    
    [self.leftCell reuserTableViewCell:leftObj AtIndex:index AtType:type];
    
    [self.contentView addSubview:self.leftCell];
}

- (void)reuserTableViewLeftCell:(ProductObj *)leftObj
                        AtIndex:(NSInteger)leftIndex
                   AndRightCell:(ProductObj *)rightObj
                        AtIndex:(NSInteger)rightIndex
                         AtType:(PRODUCT_TYPE)type
{
    [self.leftCell  removeFromSuperview];
    [self.rightCell removeFromSuperview];
    
    [self.leftCell  reuserTableViewCell:leftObj AtIndex:leftIndex AtType:type];
    [self.rightCell reuserTableViewCell:rightObj AtIndex:rightIndex AtType:type];
    
    [self.contentView addSubview:self.leftCell];
    [self.contentView addSubview:self.rightCell];
}

#pragma mark ProductCellDelegate
- (void)clickToProductDetail:(NSInteger)index
{
    if(self._delegate && [self._delegate respondsToSelector:@selector(clickToRushProductDetail:)])
        [self._delegate clickToRushProductDetail:index];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
