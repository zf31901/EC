//
//  ProductSpecialCell.m
//  Shop
//
//  Created by Harry on 13-12-31.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "ProductSpecialCell.h"
#import "EGOImageView.h"
#import "ProductObj.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"

@implementation ProductSpecialCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.proImageView = [[EGOImageView alloc] initWithFrame:CGRectMake(6, 13, 148, 149)];
        //[self.proImageView setPlaceholderImage:[UIImage imageNamed:@"default_img_296"]];
        [self.proImageView.layer setBorderColor:RGBS(201).CGColor];
        [self.proImageView.layer setBorderWidth:0.5];
        [self.contentView addSubview:self.proImageView];
        
        self.proNameLb = [GlobalMethod BuildLableWithFrame:CGRectMake(8, self.proImageView.bottom + 7, 148, 30)
                                                  withFont:[UIFont systemFontOfSize:12]
                                                  withText:nil];
        [self.proNameLb setNumberOfLines:2];
        [self.proNameLb setTextColor:RGBS(51)];
        [self.contentView addSubview:self.proNameLb];
        
        self.proSalePriceLb = [GlobalMethod BuildLableWithFrame:CGRectMake(8, self.proNameLb.bottom + 2, 60, 16)
                                                       withFont:[UIFont systemFontOfSize:15]
                                                       withText:nil];
        [self.proSalePriceLb setTextColor:RGB(250, 0, 0)];
        [self.proSalePriceLb setNumberOfLines:1];
        [self.contentView addSubview:self.proSalePriceLb];
        
        self.proOldPriceLb = [GlobalMethod BuildLableWithFrame:CGRectMake(self.proSalePriceLb.right + 8, self.proNameLb.bottom + 6, 80, 11)
                                                      withFont:[UIFont systemFontOfSize:10]
                                                      withText:nil];
        [self.proOldPriceLb setNumberOfLines:1];
        [self.proOldPriceLb setTextColor:RGBS(180)];
        [self.contentView addSubview:self.proOldPriceLb];
        self.oldLineLb = [GlobalMethod BuildLableWithFrame:CGRectMake(self.proOldPriceLb.left, self.proOldPriceLb.center.y, 80, 0.5)
                                                  withFont:nil
                                                  withText:nil];
        [self.oldLineLb setBackgroundColor:RGBS(153)];
        [self.contentView addSubview:self.oldLineLb];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickToDetail:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)reuserTableViewCell:(ProductObj *)obj AtIndex:(NSInteger)index
{
    //[self.proImageView      setImageURL:obj.imgUrl];
    [self.proImageView setImageWithURL:obj.imgUrl placeholderImage:[UIImage imageNamed:@"default_img_296"]];
    [self.proNameLb         setText:obj.name];
    [self                   setTag:index];
    
    NSString *salePrice     = [NSString stringWithFormat:@"¥ %@",obj.salePrice];
    CGSize size             = [salePrice sizeWithFont:[UIFont systemFontOfSize:15]
                                    constrainedToSize:CGSizeMake(80, 16)
                                        lineBreakMode:NSLineBreakByWordWrapping];
    [self.proSalePriceLb    setFrame:CGRectMake(8, self.proSalePriceLb.top, size.width, size.height)];
    [self.proSalePriceLb    setText:salePrice];
    
    NSString *oldPrice      = [NSString stringWithFormat:@"¥ %@",obj.oldPrice];
    CGSize size2            = [oldPrice sizeWithFont:[UIFont systemFontOfSize:10]
                                   constrainedToSize:CGSizeMake(80, 11)
                                       lineBreakMode:NSLineBreakByWordWrapping];
    [self.proOldPriceLb     setFrame:CGRectMake(self.proSalePriceLb.right + 10, self.proOldPriceLb.top, size2.width, size2.height)];
    [self.proOldPriceLb     setText:oldPrice];
    [self.oldLineLb         setFrame:CGRectMake(self.proOldPriceLb.left, self.oldLineLb.top, size2.width, 0.5)];
}

- (void)clickToDetail:(id)sender
{
    NSInteger tag = 0;
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    tag = [tap view].tag;
    
    if(self._delegate && [self._delegate respondsToSelector:@selector(clickToProductDetail:)]){
        [self._delegate clickToProductDetail:tag];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
