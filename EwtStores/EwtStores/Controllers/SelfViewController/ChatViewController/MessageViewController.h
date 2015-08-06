//
//  WCMessageViewController.h
//  WeChat
//
//  Created by Reese on 13-8-10.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageViewController : BaseRefreshTableViewController <UITableViewDataSource,UITableViewDelegate,SocketResultDelegate>
{
    NSMutableArray *_msgArr;
    IBOutlet UITableView *_messageTable;
    //UITableView *_messageTable;
    NSString *_newMsgUserID;
}


@end
