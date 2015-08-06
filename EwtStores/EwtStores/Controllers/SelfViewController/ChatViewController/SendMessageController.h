//
//  WCSendMessageController.h
//  微信
//
//  Created by Reese on 13-8-11.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatSelectionView.h"

@interface SendMessageController : BaseViewController<UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,WCShareMoreDelegate,SocketResultDelegate>
{
    IBOutlet UITableView *msgRecordTable;
    NSMutableArray *msgRecords;
    IBOutlet UITextField *messageText;
    IBOutlet UIView *inputBar;
    UIImage *_myHeadImage,*_userHeadImage;
    ChatSelectionView *_shareMoreView;
}
- (IBAction)sendIt:(id)sender;
- (IBAction)shareMore:(id)sender;
@property (nonatomic,retain) UserObject *chatPerson;
//@property (nonatomic,retain) GroupObject *chatGroup;
@property (nonatomic,copy) NSString *msgText;
@end
