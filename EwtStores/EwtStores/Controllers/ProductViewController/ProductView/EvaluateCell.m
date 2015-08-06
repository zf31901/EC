//
//  EvaluateCell.m
//  Shop
//
//  Created by Harry on 13-12-27.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "EvaluateCell.h"
#import "EvaluateObj.h"
#import "EGOImageView.h"

@implementation EvaluateCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.headImgView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"default_img_60"]];
        [self.headImgView setFrame:CGRectMake(8, 8, 30, 30)];
        [self.contentView addSubview:self.headImgView];
        
        self.personNameLb = [GlobalMethod BuildLableWithFrame:CGRectMake(self.headImgView.right + 8, 8, 100, 13)
                                                     withFont:[UIFont boldSystemFontOfSize:12]
                                                     withText:nil];
        self.personNameLb.textColor = RGBS(51);
        self.personNameLb.numberOfLines = 1;
        [self.contentView addSubview:self.personNameLb];
        
        self.areaLb = [GlobalMethod BuildLableWithFrame:CGRectMake(self.personNameLb.right + 4, 8, 110, 11)
                                               withFont:[UIFont systemFontOfSize:10]
                                               withText:nil];
        self.areaLb.textColor = RGBS(102);
        self.areaLb.numberOfLines = 1;
        [self.contentView addSubview:self.areaLb];
        
        self.timeLb = [GlobalMethod BuildLableWithFrame:CGRectMake(200, 8, 112, 11)
                                               withFont:[UIFont systemFontOfSize:10]
                                               withText:nil];
        self.timeLb.textColor = RGBS(102);
        self.timeLb.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.timeLb];
        
        self.niceEvaluateLb = [GlobalMethod BuildLableWithFrame:CGRectMake(self.headImgView.right + 8, self.personNameLb.bottom + 8, 200, 13)
                                                       withFont:[UIFont systemFontOfSize:12]
                                                       withText:nil];
        self.niceEvaluateLb.textColor = RGBS(51);
        [self.contentView addSubview:self.niceEvaluateLb];
        
        self.badEvaluateLb = [GlobalMethod BuildLableWithFrame:CGRectMake(self.headImgView.right + 8, self.niceEvaluateLb.bottom + 8, 200, 13)
                                                       withFont:[UIFont systemFontOfSize:12]
                                                       withText:nil];
        self.badEvaluateLb.textColor = RGBS(51);
        [self.contentView addSubview:self.badEvaluateLb];
    }
    return self;
}

- (float )reuserTableViewCell:(EvaluateObj *)obj
{
    [self.headImgView setImageURL:obj.PersonImgUrl];
    
    CGSize nameSize = [obj.PersonId sizeWithFont:[UIFont boldSystemFontOfSize:12]
                               constrainedToSize:CGSizeMake(266, 999)
                                   lineBreakMode:NSLineBreakByWordWrapping];
    [self.personNameLb setFrame:CGRectMake(self.personNameLb.left, self.personNameLb.top, nameSize.width, nameSize.height)];
    [self.personNameLb setText:obj.PersonId];
    
    [self.areaLb setFrame:CGRectMake(self.personNameLb.right + 4, 8, 110, 11)];
    [self.areaLb setText:[NSString stringWithFormat:@"(%@)",obj.Area]];
    
    NSString *timeIntval  = [GlobalMethod getJsonDateString:obj.Time];
    NSString *time = [GlobalMethod getDateAndTimeArrByTimeInterval:timeIntval];
    [self.timeLb setText:time];
    
    NSString *niceS = [NSString stringWithFormat:@"优点：%@",obj.niceEvaluate];
    CGSize niceSize = [niceS sizeWithFont:[UIFont systemFontOfSize:12]
                        constrainedToSize:CGSizeMake(266, 999)
                            lineBreakMode:NSLineBreakByWordWrapping];
    [self.niceEvaluateLb setFrame:CGRectMake(self.niceEvaluateLb.left, self.personNameLb.bottom + 4, niceSize.width, niceSize.height)];
    [self.niceEvaluateLb setText:niceS];
    
    NSString *badS = [NSString stringWithFormat:@"不足：%@",obj.badEvaluate];
    CGSize badSize = [badS sizeWithFont:[UIFont systemFontOfSize:12]
                        constrainedToSize:CGSizeMake(266, 999)
                            lineBreakMode:NSLineBreakByWordWrapping];
    [self.badEvaluateLb setFrame:CGRectMake(self.badEvaluateLb.left, self.niceEvaluateLb.bottom + 4, badSize.width, badSize.height)];
    [self.badEvaluateLb setText:badS];
    
    return self.badEvaluateLb.bottom + 8;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
