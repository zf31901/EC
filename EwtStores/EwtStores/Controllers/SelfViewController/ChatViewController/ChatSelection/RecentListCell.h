//
//  WCRecentListCell.h
//  微信
//
//  Created by Reese on 13-8-15.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageUserUnionObject.h"

@interface RecentListCell : UITableViewCell
{
    UIImageView *_userHead;
    
    UILabel *_userNickname;
    UILabel *_messageConent;
    UILabel *_timeLable;
    UIImageView *_cellBkg;
}

@property (nonatomic,retain) UILabel *bageNumber;
@property (nonatomic,retain) UIImageView *bageView;

-(void)setUnionObject:(MessageUserUnionObject*)aUnionObj;
-(void)setHeadImage:(NSString*)imageURL;
@end
