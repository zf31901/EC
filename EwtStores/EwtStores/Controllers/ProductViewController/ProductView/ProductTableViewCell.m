//
//  ProductTableViewCell.m
//  Shop
//
//  Created by ewt on 14-7-30.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "ProductTableViewCell.h"

@implementation ProductTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _imgView = [[EGOImageView alloc] initWithFrame:CGRectMake(20, 17, 30, 30)];
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [self.textLabel setFont:[UIFont systemFontOfSize:16]];
        [self.contentView addSubview:_imgView];

    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
