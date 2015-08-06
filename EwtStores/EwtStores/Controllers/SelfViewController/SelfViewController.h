//
//  SelfViewController.h
//  EwtStores
//
//  Created by Harry on 13-11-30.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "BaseRefreshTableViewController.h"
#import "SocketManager.h"


typedef enum
{
    ReadyPay = 0,
    Paying,
    FinishPay,
}Product_PayStatus;

@interface SelfViewController : BaseRefreshTableViewController<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>


@end
