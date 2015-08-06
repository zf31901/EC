//
//  ProductSortCell.m
//  Shop
//
//  Created by Harry on 13-12-20.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "ProductSortCell.h"

#import "ProductObj.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"

@implementation ProductSortCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.proImageView = [[EGOImageView alloc] initWithFrame:CGRectMake(8, 10, 70, 70)];
        [self.proImageView setContentMode:UIViewContentModeScaleToFill];
        //[self.proImageView      setPlaceholderImage:[UIImage imageNamed:@"default_img_140"]];
        [self.proImageView.layer setBorderWidth:0.5];
        [self.proImageView.layer setBorderColor:RGBS(201).CGColor];
        [self.contentView addSubview:self.proImageView];
        
        self.proNameLb = [GlobalMethod BuildLableWithFrame:CGRectMake(self.proImageView.right + 10, 11, 220, 34)
                                                  withFont:[UIFont boldSystemFontOfSize:13]
                                                  withText:nil];
        [self.proNameLb setNumberOfLines:2];
        [self.proNameLb setTextColor:RGBS(51)];
        [self.contentView addSubview:self.proNameLb];
        
        self.proSalePriceLb = [GlobalMethod BuildLableWithFrame:CGRectMake(self.proImageView.right + 10, self.proNameLb.bottom + 2, 80, 16)
                                                       withFont:[UIFont boldSystemFontOfSize:15]
                                                       withText:nil];
        [self.proSalePriceLb setTextColor:RGB(255, 51, 0)];
        [self.contentView addSubview:self.proSalePriceLb];
        
        self.proOldPriceLb = [GlobalMethod BuildLableWithFrame:CGRectMake(self.proSalePriceLb.right + 10, self.proNameLb.bottom + 4, 80, 12)
                                                      withFont:[UIFont systemFontOfSize:11]
                                                      withText:nil];
        [self.proOldPriceLb setTextColor:RGBS(153)];
        [self.contentView addSubview:self.proOldPriceLb];
        self.oldLineLb = [GlobalMethod BuildLableWithFrame:CGRectMake(self.proOldPriceLb.left, self.proOldPriceLb.center.y, 80, 0.5)
                                                  withFont:nil
                                                  withText:nil];
        [self.oldLineLb setBackgroundColor:RGBS(153)];
        [self.contentView addSubview:self.oldLineLb];
        
        self.saleMonthNumLb = [GlobalMethod BuildLableWithFrame:CGRectMake(self.proImageView.right + 10, self.proSalePriceLb.bottom + 4, 100, 12)
                                                       withFont:[UIFont systemFontOfSize:11]
                                                       withText:nil];
        [self.saleMonthNumLb setTextColor:RGBS(153)];
        [self.contentView addSubview:self.saleMonthNumLb];
        
        self.starNumLb = [GlobalMethod BuildLableWithFrame:CGRectMake(self.saleMonthNumLb.right + 20, self.proSalePriceLb.bottom + 4, 80, 12)
                                                       withFont:[UIFont systemFontOfSize:11]
                                                       withText:nil];
        [self.starNumLb setTextColor:RGBS(153)];
        [self.contentView addSubview:self.starNumLb];
        self.saleMonthNumLb.hidden = YES;
        //self.starNumLb.hidden = YES;
        UILabel *line = [GlobalMethod BuildLableWithFrame:CGRectMake(0, self.proImageView.bottom + 9, Main_Size.width, 0.5) withFont:nil withText:nil];
        [line setBackgroundColor:RGBS(191)];
        [self.contentView addSubview:line];
    }
    return self;
}

- (void)reuserTableViewCell:(ProductObj *)obj AtIndex:(NSInteger)index
{
    //[self.proImageView      setImageURL:obj.listImgUrl];
    [self.proImageView setImageWithURL:obj.listImgUrl placeholderImage:[UIImage imageNamed:@"default_img_140"]];
    [self.proNameLb         setText:obj.name];
    
    NSString *saleString = [NSString stringWithFormat:@"¥ %0.2f",[obj.salePrice floatValue]];
    CGSize size = [saleString sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(320, 999) lineBreakMode:NSLineBreakByWordWrapping];
    [self.proSalePriceLb    setFrame:CGRectMake(self.proSalePriceLb.left, self.proSalePriceLb.top, size.width, 16)];
    [self.proSalePriceLb    setText:saleString];

    NSString *oldString = [NSString stringWithFormat:@"¥ %0.2f",[obj.oldPrice floatValue]];
    CGSize size2 = [oldString sizeWithFont:[UIFont systemFontOfSize:11] constrainedToSize:CGSizeMake(320, 999) lineBreakMode:NSLineBreakByWordWrapping];
    [self.proOldPriceLb     setFrame:CGRectMake(self.proSalePriceLb.right + 10, self.proOldPriceLb.top, size2.width, size2.height)];
    [self.proOldPriceLb     setText:oldString];
    [self.oldLineLb         setFrame:CGRectMake(self.proOldPriceLb.left, self.oldLineLb.top, size2.width, 0.5)];
    
    [self.saleMonthNumLb    setText:[NSString stringWithFormat:@"月销售：%@件",obj.saleMonthNum]];
    [self.starNumLb         setText:[NSString stringWithFormat:@"评价：%@条",obj.totalComment]];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
