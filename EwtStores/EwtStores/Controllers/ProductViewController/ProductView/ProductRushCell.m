//
//  ProductRushCell.m
//  Shop
//
//  Created by Harry on 13-12-30.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "ProductRushCell.h"

#import "EGOImageView.h"
#import "ProductObj.h"

@implementation ProductRushCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.proImageView = [[EGOImageView alloc] initWithFrame:CGRectMake(6, 13, 148, 149)];
        [self.proImageView setPlaceholderImage:[UIImage imageNamed:@"default_img_296"]];
        [self.proImageView.layer setBorderColor:RGBS(201).CGColor];
        [self.proImageView.layer setBorderWidth:0.5];
        [self.contentView addSubview:self.proImageView];
        
        self.proNameLb = [GlobalMethod BuildLableWithFrame:CGRectMake(8, self.proImageView.bottom + 7, 148, 30)
                                                  withFont:[UIFont systemFontOfSize:12]
                                                  withText:nil];
        [self.proNameLb setNumberOfLines:2];
        [self.proNameLb setTextColor:RGBS(51)];
        [self.contentView addSubview:self.proNameLb];
        
        self.proTypeLb = [GlobalMethod BuildLableWithFrame:CGRectMake(8, self.proNameLb.bottom + 7, 45, 11)
                                               withFont:[UIFont systemFontOfSize:10]
                                               withText:nil];
        [self.proTypeLb setTextColor:RGBS(102)];
        [self.contentView addSubview:self.proTypeLb];
        
        self.proSalePriceLb = [GlobalMethod BuildLableWithFrame:CGRectMake(42, self.proNameLb.bottom + 6, 60, 16)
                                                       withFont:[UIFont systemFontOfSize:13]
                                                       withText:nil];
        [self.proSalePriceLb setTextColor:RGB(250, 0, 0)];
        [self.contentView addSubview:self.proSalePriceLb];
        
        self.proOldPriceLb = [GlobalMethod BuildLableWithFrame:CGRectMake(8, self.proSalePriceLb.bottom + 6, 80, 11)
                                                      withFont:[UIFont systemFontOfSize:10]
                                                      withText:nil];
        [self.proOldPriceLb setTextColor:RGBS(180)];
        [self.contentView addSubview:self.proOldPriceLb];
        self.oldLineLb = [GlobalMethod BuildLableWithFrame:CGRectMake(self.proOldPriceLb.left, self.proOldPriceLb.center.y, 80, 0.5)
                                                           withFont:nil
                                                           withText:nil];
        [self.oldLineLb setBackgroundColor:RGBS(153)];
        [self.contentView addSubview:self.oldLineLb];
        
        self.startRushBt = [GlobalMethod BuildButtonWithFrame:CGRectMake(95, self.proSalePriceLb.top + 5, 57, 22)
                                                    andOffImg:nil
                                                     andOnImg:nil
                                                    withTitle:@"立即抢购"];
        [self.startRushBt setBackgroundColor:RGB(204, 0, 30)];
        [self.startRushBt addTarget:self action:@selector(clickToDetail:) forControlEvents:UIControlEventTouchUpInside];
        [self.startRushBt.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [self.startRushBt setTitleColor:RGBS(255) forState:UIControlStateNormal];
        [self.contentView addSubview:self.startRushBt];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickToDetail:)];
        [self addGestureRecognizer:tap];
        
        _timeLb = [GlobalMethod BuildLableWithFrame:CGRectMake(10, self.startRushBt.bottom + 13, 140, 13) withFont:[UIFont systemFontOfSize:12] withText:nil];
        [self.contentView addSubview:_timeLb];
    }
    return self;
}

- (void)reuserTableViewCell:(ProductObj *)obj AtIndex:(NSInteger)index AtType:(PRODUCT_TYPE)productType
{
    [self.proImageView      setImageURL:obj.imgUrl];
    [self.proNameLb         setText:obj.name];
    [self.proSalePriceLb    setText:obj.salePrice];
    [self                   setTag:index];
    
    if(productType == RUSH_PRODUCT){
        [self.startRushBt       setTag:index];
        [self.proTypeLb         setText:@"抢购价:"];
        NSString *oldPrice      = [NSString stringWithFormat:@"¥ %@",obj.oldPrice];
        CGSize size             = [oldPrice sizeWithFont:[UIFont systemFontOfSize:10]
                                       constrainedToSize:CGSizeMake(80, 11)
                                           lineBreakMode:NSLineBreakByWordWrapping];
        [self.proOldPriceLb     setText:oldPrice];
        [self.oldLineLb         setFrame:CGRectMake(self.proOldPriceLb.left, self.oldLineLb.top, size.width, 0.5)];
        
        
        NSArray *dateArr = [GlobalMethod getTimeDifferenceByBeginTimeInterval:obj.beginTime withEndTimeInterval:obj.endTime];
        rushHour    = [dateArr[0] integerValue];
        rushMinute  = [dateArr[1] integerValue];
        rushSecond  = [dateArr[2] integerValue];
        
        [_timeLb setText:[NSString stringWithFormat:@"剩余时间:%02ld:%02ld:%02ld",(long)rushHour,(long)rushMinute,(long)rushSecond]];
        
        [self performSelectorInBackground:@selector(TimeControll) withObject:nil];
    }else if(BANNER_PRODUCT){
        [self.startRushBt       setHidden:YES];
        [self.proTypeLb         setText:@"爱心天地价:"];
        NSString *oldPrice      = [NSString stringWithFormat:@"市场价:%@",obj.oldPrice];
        CGSize size             = [oldPrice sizeWithFont:[UIFont systemFontOfSize:10]
                                       constrainedToSize:CGSizeMake(80, 11)
                                           lineBreakMode:NSLineBreakByWordWrapping];
        [self.proOldPriceLb     setText:oldPrice];
        [self.oldLineLb         setFrame:CGRectMake(self.proOldPriceLb.left + 40, self.oldLineLb.top, size.width - 40, 0.5)];
    }
}

- (void)clickToDetail:(id)sender
{
    NSInteger tag = 0;
    if([sender isMemberOfClass:[UIButton class]]){
        tag = [(UIButton *)sender tag];
    }else
    {
        UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
        tag = [tap view].tag;
    }
    
    if(self._delegate && [self._delegate respondsToSelector:@selector(clickToProductDetail:)]){
        [self._delegate clickToProductDetail:tag];
    }
}

- (void)TimeControll{
    
    if( ![NSThread isMainThread] ){
        [timer invalidate];
        timer       = [NSTimer scheduledTimerWithTimeInterval:1
                                                       target:self
                                                     selector:@selector(rushProductTime)
                                                     userInfo:nil
                                                      repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] run];
    }
}

- (void)rushProductTime
{
    rushSecond --;
    if(rushSecond == -1){
        rushMinute --;
        rushSecond = 59;
        if(rushMinute == -1){
            rushHour --;
            rushMinute = 59;
        }
    }
    
    if(rushSecond <= 0 && rushMinute <= 0 && rushHour <= 0){
        [timer invalidate];
        [_timeLb setText:@"抢购结束"];
        [self.contentView setUserInteractionEnabled:NO];
    }else{
        [self.contentView setUserInteractionEnabled:YES];
        [_timeLb setText:[NSString stringWithFormat:@"剩余时间:%02ld:%02ld:%02ld",(long)rushHour,(long)rushMinute,(long)rushSecond]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
