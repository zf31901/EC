//
//  WCMessageCell.m
//  微信
//
//  Created by Reese on 13-8-15.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "MessageCell.h"



#define CELL_HEIGHT self.contentView.frame.size.height
#define CELL_WIDTH self.contentView.frame.size.width


@implementation MessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Initialization code
        _userHead =[[UIImageView alloc]initWithFrame:CGRectZero];
        _bubbleBg =[[UIImageView alloc]initWithFrame:CGRectZero];
        _chatUser=[[UILabel alloc]initWithFrame:CGRectZero];
        _messageConent=[[UILabel alloc]initWithFrame:CGRectZero];
        _messageDate=[[UILabel alloc]initWithFrame:CGRectZero];
        _headMask =[[UIImageView alloc]initWithFrame:CGRectZero];
        _chatImage =[[UIImageView alloc]initWithFrame:CGRectZero];
        
        [_chatUser setBackgroundColor:[UIColor clearColor]];
        [_chatUser setFont:[UIFont systemFontOfSize:12]];
        
        [_messageDate setBackgroundColor:[UIColor grayColor]];
        [_messageDate setFont:[UIFont systemFontOfSize:10]];
        _messageDate.textAlignment = NSTextAlignmentCenter;
        _messageDate.shadowColor = [UIColor grayColor];
        _messageDate.shadowOffset = CGSizeMake(1.0,1.0);
        _messageDate.layer.cornerRadius = 10;
        
        [_messageConent setBackgroundColor:[UIColor clearColor]];
        [_messageConent setFont:[UIFont systemFontOfSize:15]];
        [_messageConent setNumberOfLines:20];
        [self.contentView addSubview:_messageDate];
        [self.contentView addSubview:_bubbleBg];
        [self.contentView addSubview:_userHead];
        [self.contentView addSubview:_headMask];
        [self.contentView addSubview:_chatUser];
        [self.contentView addSubview:_messageConent];
        [self.contentView addSubview:_chatImage];
        [_chatImage setBackgroundColor:[UIColor redColor]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [_headMask setImage:[[UIImage imageNamed:@"UserHeaderImageBox"]stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
        
        //[self setBackgroundColor:[UIColor clearColor]];
        
        //[self setFrame:CGRectMake(self.frame.origin.x+30, self.frame.origin.y+50, self.contentView.frame.size.width, self.contentView.frame.size.height)];
        
    }
    return self;
}


-(void)layoutSubviews
{
    
    [super layoutSubviews];
    
    
    
    NSString *orgin=_messageConent.text;
    CGSize textSize=[orgin sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake((320-HEAD_SIZE-3*INSETS-40), TEXT_MAX_HEIGHT) lineBreakMode:NSLineBreakByWordWrapping];

    
    switch (_msgStyle) {
        case kWCMessageCellStyleMe:
        {
            [_chatImage setHidden:YES];
            [_chatUser setHidden:YES];
            [_messageConent setHidden:NO];
            [_messageConent setFrame:CGRectMake(CELL_WIDTH-INSETS*2-HEAD_SIZE-textSize.width-15, (CELL_HEIGHT-textSize.height)/2+10, textSize.width, textSize.height)];
            [_userHead setFrame:CGRectMake(CELL_WIDTH-INSETS-HEAD_SIZE, INSETS+DATESPACE,HEAD_SIZE , HEAD_SIZE)];
            
             [_bubbleBg setImage:[[UIImage imageNamed:@"SenderTextNodeBkg"]stretchableImageWithLeftCapWidth:20 topCapHeight:30]];
            _bubbleBg.frame=CGRectMake(_messageConent.frame.origin.x-15, _messageConent.frame.origin.y-12, textSize.width+30, textSize.height+30);
        }
            break;
        case kWCMessageCellStyleOther:
        {
            [_chatImage setHidden:YES];
            //[_messageDate setHidden:YES];
            [_chatUser setHidden:NO];
            [_messageConent setHidden:NO];
            [_userHead setFrame:CGRectMake(INSETS, INSETS+DATESPACE,HEAD_SIZE , HEAD_SIZE)];
            if (_isGroupMsg) {
                [_chatUser setFrame:CGRectMake(2*INSETS+HEAD_SIZE, INSETS+DATESPACE, 200, 20)];
                [_messageConent setFrame:CGRectMake(2*INSETS+HEAD_SIZE+15, (CELL_HEIGHT-textSize.height)/2+20, textSize.width, textSize.height)];
            } else {
                [_messageConent setFrame:CGRectMake(2*INSETS+HEAD_SIZE+15, (CELL_HEIGHT-textSize.height)/2+8, textSize.width, textSize.height)];
            }
            
            [_messageDate setFrame:CGRectMake(100, 0, 120, 20)];
            
            [_bubbleBg setImage:[[UIImage imageNamed:@"ReceiverTextNodeBkg"]stretchableImageWithLeftCapWidth:20 topCapHeight:30]];
            _bubbleBg.frame=CGRectMake(_messageConent.frame.origin.x-15, _messageConent.frame.origin.y-12, textSize.width+30, textSize.height+30);
        }
            break;
        case kWCMessageCellStyleMeWithImage:
        {
            //[_messageConent setFrame:CGRectMake(CELL_WIDTH-INSETS*2-HEAD_SIZE-textSize.width-15, (CELL_HEIGHT-textSize.height)/2, textSize.width, textSize.height)];
            [_chatImage setHidden:NO];
            [_messageConent setHidden:YES];
            [_chatImage setFrame:CGRectMake(CELL_WIDTH-INSETS*2-HEAD_SIZE-115, (CELL_HEIGHT-100)/2, 100, 100)];
            [_userHead setFrame:CGRectMake(CELL_WIDTH-INSETS-HEAD_SIZE, INSETS,HEAD_SIZE , HEAD_SIZE)];
            
            [_bubbleBg setImage:[[UIImage imageNamed:@"SenderTextNodeBkg"]stretchableImageWithLeftCapWidth:20 topCapHeight:30]];
            _bubbleBg.frame=CGRectMake(_chatImage.frame.origin.x-15, _chatImage.frame.origin.y-12, 100+30, 100+30);
        }
            break;
        case kWCMessageCellStyleOtherWithImage:
        {
            [_chatImage setHidden:NO];
            [_messageConent setHidden:YES];
            [_chatImage setFrame:CGRectMake(2*INSETS+HEAD_SIZE+15, (CELL_HEIGHT-100)/2,100,100)];
             [_userHead setFrame:CGRectMake(INSETS, INSETS,HEAD_SIZE , HEAD_SIZE)];
            
            [_bubbleBg setImage:[[UIImage imageNamed:@"ReceiverTextNodeBkg"]stretchableImageWithLeftCapWidth:20 topCapHeight:30]];

            _bubbleBg.frame=CGRectMake(_chatImage.frame.origin.x-15, _chatImage.frame.origin.y-12, 100+30, 100+30);

        }
            break;
        default:
            break;
    }
    
    
    _headMask.frame=CGRectMake(_userHead.frame.origin.x-3, _userHead.frame.origin.y-1, HEAD_SIZE+6, HEAD_SIZE+6);
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setMessageObject:(MessageObject*)aMessage
{
    [_messageConent setText:aMessage.messageContent];
    NSString *userNickName = [UserObject userNameById:aMessage.messageFrom];
    if (userNickName.length==0) {
        [_chatUser setText:aMessage.messageFrom];
    } else {
        [_chatUser setText:[UserObject userNameById:aMessage.messageFrom]];
    }
    
    //判断是否为群组消息
    if (![GroupObject haveSaveGroupById:aMessage.messageTo]) {
        _isGroupMsg = NO;
    } else {
        _isGroupMsg = YES;
    }
    //消息时间 
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setAMSymbol:@"上午"];
    [formatter setPMSymbol:@"下午"];
    [formatter setDateFormat:@"YYYY-MM-dd a HH:mm"];
    
    [_messageDate setText:[formatter stringFromDate:aMessage.messageDate ]];
    
    NSDate *last = [NSDate dateWithTimeIntervalSinceNow:0];
    if ([aMessage.messageDate timeIntervalSinceDate:last] > 1200) {
        [_messageDate setHidden:NO];
    }else {
        [_messageDate setHidden:YES];
    }
}
-(void)setHeadImage:(UIImage*)headImage
{
    //[_userHead setImage:headImage];
    [_userHead setImage:[UIImage imageNamed:@"defaut_friend_online"]];
}
-(void)setChatImage:(UIImage *)chatImage
{
    [_chatImage setImage:chatImage];
}

@end
