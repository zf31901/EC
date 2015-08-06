
//
//  Created by Reese on 13-8-11.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "SendMessageController.h"
#import "MessageCell.h"
#import "Photo.h"

@interface SendMessageController ()

@end

@implementation SendMessageController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    if (MYAPPDELEGATE.socketManager) {
        [MYAPPDELEGATE.socketManager setSocketDelegate:self];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    if (MYAPPDELEGATE.socketManager) {
        //NSLog(@"DIS=====CLASS = %@",NSStringFromClass([self class]));
        [MYAPPDELEGATE.socketManager setSocketDelegate:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNavBarTitle:_chatPerson.userNickname];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(newMsgCome:) name:kNewMsgNotifaction object:nil];
     [self refresh];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        _myHeadImage=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_Head]]]];
        _userHeadImage=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_chatPerson.userHead]]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [msgRecordTable reloadData];
        });
    });
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [msgRecordTable addGestureRecognizer:tap];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeKeyBoard:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [msgRecordTable setBackgroundView:nil];
    [msgRecordTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    
    
    
    _shareMoreView =[[ChatSelectionView alloc]init];
    [_shareMoreView setFrame:CGRectMake(0, 0, 320, 170)];
    [_shareMoreView setDelegate:self];
}

-(void)refresh
{
    [messageText setInputView:nil];
    [messageText resignFirstResponder];
    /*if (_chatGroup == nil) {
        msgRecords =[MessageObject fetchMessageListWithUser:_chatPerson.userId byPage:1];
    } else {
        msgRecords =[MessageObject fetchMessageListWithGroup:_chatGroup.groupId byPage:1];
    }*/
    msgRecords =[MessageObject fetchMessageListWithUser:_chatPerson.userId byPage:1];
    
    if (msgRecords.count!=0) {
        [msgRecordTable reloadData];
        
        [msgRecordTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:msgRecords.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark ---触摸关闭键盘----
-(void)handleTap:(UIGestureRecognizer *)gesture
{
    [self.view endEditing:YES];
    NSLog(@"handleTap-------");
}


#pragma mark ----键盘高度变化------
-(void)changeKeyBoard:(NSNotification *)aNotifacation
{
    //获取到键盘frame 变化之前的frame
    NSValue *keyboardBeginBounds=[[aNotifacation userInfo]objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect beginRect=[keyboardBeginBounds CGRectValue];
    
    //获取到键盘frame变化之后的frame
    NSValue *keyboardEndBounds=[[aNotifacation userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect endRect=[keyboardEndBounds CGRectValue];
    
    CGFloat deltaY=endRect.origin.y-beginRect.origin.y;
    //拿frame变化之后的origin.y-变化之前的origin.y，其差值(带正负号)就是我们self.view的y方向上的增量
    
    NSLog(@"deltaY:%f",deltaY);
    float animateNum = 0.5f;
    if (deltaY > 0) {
        animateNum = 0.3f;
    }
    [CATransaction begin];
    [UIView animateWithDuration:animateNum animations:^{
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+deltaY, self.view.frame.size.width, self.view.frame.size.height)];
        [msgRecordTable setContentInset:UIEdgeInsetsMake(msgRecordTable.contentInset.top-deltaY, 0, 0, 0)];
        
    } completion:^(BOOL finished) {
        
    }];
    /*[UIView animateWithDuration:0.4f animations:^{
        [msgRecordTable setContentInset:UIEdgeInsetsMake(msgRecordTable.contentInset.top-deltaY, 0, 0, 0)];
        
    } completion:^(BOOL finished) {
        
    }];*/
    [CATransaction commit];
    
}
- (IBAction)sendIt:(id)sender {
    NSLog(@"消息发送成功");
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss \n"];
    NSDate *last = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *msgDate = [formatter stringFromDate:last];
    
    NSString *message = messageText.text;
    
    _msgText = message;
    
    if (message.length > 0) {
        
               
        //生成消息对象
        /*XMPPMessage *mes=[XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithUser:[NSString stringWithFormat:@"%@",_chatPerson.userId] domain:@"hcios.com" resource:@"ios"]];
        [mes addChild:[DDXMLNode elementWithName:@"body" stringValue:message]];*/
        
        //向服务器发送数据
        NSInteger headArray[] = {17, 0, 0, 133+[message lengthOfBytesUsingEncoding:NSUTF8StringEncoding]+21, 1927384650}; 
        int ll = 20;
        uint8_t len[ll];
        for (int i=0; i<ll; i++) {
            int l = i/4;
            len[i] = (Byte)(headArray[l]>>(8*(3-i%4))&0xff);
        }
        //0的字节数组
        int zero = 0;
        uint8_t zero_len[4];
        for(int i = 0;i<4;i++)
        {
            zero_len[i] = (Byte)(zero>>8*(3-i)&0xff);
        }
        //1的字节数组
        int one = 1;
        uint8_t one_len[4];
        for(int i = 0;i<4;i++)
        {
            one_len[i] = (Byte)(one>>8*(3-i)&0xff);
        }
        //userid的字节数组
        int userid;
        /*if (_chatGroup == nil) {
            userid = [_chatPerson.userId intValue];
        } else {
            userid = [_chatGroup.groupId intValue];
        }*/
        userid = [_chatPerson.userId intValue];
        
        uint8_t userid_len[4];
        for(int i = 0;i<4;i++)
        {
            userid_len[i] = (Byte)(userid>>8*(3-i)&0xff);
        }
        //msg的字节数组
        int msgLen = [message lengthOfBytesUsingEncoding:NSUTF8StringEncoding]+21;//时间长度为21
        uint8_t msg_len[4];
        for(int i = 0;i<4;i++)
        {
            msg_len[i] = (Byte)(msgLen>>8*(3-i)&0xff);
        }

               
        NSMutableData *sendData = [[NSMutableData alloc] initWithBytes:len length:20];
        /*if (_chatGroup == nil) {
            [sendData appendBytes:zero_len length:4];
        } else {
            [sendData appendBytes:one_len length:4];
        }*/
        [sendData appendBytes:zero_len length:4];
        
        [sendData appendBytes:userid_len length:4];
        [sendData appendBytes:msg_len length:4];
        [sendData appendData:[[NSData alloc]initWithBytes:[@"" UTF8String] length:92]];
        [sendData appendBytes:zero_len length:4];
        [sendData appendBytes:zero_len length:4];
        [sendData appendBytes:zero_len length:1]; //m_bIsAutoReply
        [sendData appendData:[[NSData alloc]initWithBytes:[[NSString stringWithFormat:@"%@%@", message, msgDate] UTF8String] length:msgLen]];
        
        
        NSLog(@"message:%@",message);
        [MYAPPDELEGATE sendData:sendData];        
   
    }
     [messageText setText:nil];
    
    
}



-(void)sendImage:(UIImage *)aImage
{
    NSLog(@"准备发送图片");
    
    
    UIAlertView *av=[[UIAlertView alloc]initWithTitle:@"请稍后" message:@"文件正在传送中..." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [av show];
    //服务器中转方式
//    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:API_BASE_URL(@"servlet/XMPPFileTransServlet")];
//    [request setData:UIImageJPEGRepresentation(aImage, 0.1) withFileName:@"temp.jpg" andContentType:@"image/jpg" forKey:@"transFile"];
//    [request setCompletionBlock:^{
//        //
//        //生成消息对象
//        NSString *message=request.responseString;
//        SBJsonParser *paser=[[[SBJsonParser alloc]init]autorelease];
//        NSError *err;
//        NSDictionary *dic= [paser objectWithString:message error:&err];
//        message =[dic objectForKey:@"filePath"];
//        XMPPMessage *mes=[XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithUser:[NSString stringWithFormat:@"%@",_chatPerson.userId] domain:@"hcios.com" resource:@"ios"]];
//        [mes addChild:[DDXMLNode elementWithName:@"body" stringValue:[NSString stringWithFormat:@"[1]%@",message]]];
//        
//                //发送消息
//        [[WCXMPPManager sharedInstance] sendMessage:mes];
//        
//        
//    }];
//    [request setTimeOutSeconds:10000];
//    [request startAsynchronous];
    
    NSString *message = [Photo image2String:aImage];
    
    if (message.length > 0) {
        
        
        
        /*//生成消息对象
        XMPPMessage *mes=[XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithUser:[NSString stringWithFormat:@"%@",_chatPerson.userId] domain:@"hcios.com" resource:@"ios"]];
        [mes addChild:[DDXMLNode elementWithName:@"body" stringValue:[NSString stringWithFormat:@"[1]%@",message]]];
        
        //发送消息
        [[WCXMPPManager sharedInstance] sendMessage:mes];*/
        
        
        
    }
    
   // [[WCXMPPManager sharedInstance]sendFile:nil toJID:[XMPPJID jidWithUser:[NSString stringWithFormat:@"%@",_chatPerson.userId] domain:@"hcios.com" resource:@"ios"]];

}



- (IBAction)shareMore:(id)sender {
    
    [messageText setInputView:messageText.inputView?nil: _shareMoreView];
    
    [messageText reloadInputViews];
    [messageText becomeFirstResponder];
}



#pragma mark   ---------tableView协议----------------
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return msgRecords.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier=@"friendCell";
    MessageCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell=[[MessageCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    MessageObject *msg=[msgRecords objectAtIndex:indexPath.row];
    [cell setMessageObject:msg];
    enum kWCMessageCellStyle style=[msg.messageFrom isEqualToString:[[NSUserDefaults standardUserDefaults]stringForKey:kMY_USER_ID]]?kWCMessageCellStyleMe:kWCMessageCellStyleOther;
   
    switch (style) {
        case kWCMessageCellStyleMe:
            [cell setHeadImage:_myHeadImage];
            break;
        case kWCMessageCellStyleOther:
            [cell setHeadImage:_userHeadImage];
            break;
        case kWCMessageCellStyleMeWithImage:
        {
             [cell setHeadImage:_myHeadImage];
            
        }
            break;
        case kWCMessageCellStyleOtherWithImage:{
            [cell setHeadImage:_userHeadImage];
        }
            break;
        default:
            break;
    }
   
    if ([msg.messageType intValue]==kWCMessageTypeImage) {
        style=style==kWCMessageCellStyleMe?kWCMessageCellStyleMeWithImage:kWCMessageCellStyleOtherWithImage;
        
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//            UIImage *image=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:msg.messageContent]]];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [cell setChatImage:image];
//            });
//            
//      
//        });
        
        
        //UIImage *img=[Photo string2Image:msg.messageContent];
        [cell setChatImage:[Photo string2Image:msg.messageContent ]];
      //  [msg setMessageContent:@""];
    }
    
     [cell setMsgStyle:style];
    
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   if( [[msgRecords[indexPath.row] messageType]intValue]==kWCMessageTypeImage)
       return 55+100;
   else{
    
    NSString *orgin=[msgRecords[indexPath.row]messageContent];
    CGSize textSize=[orgin sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake((320-HEAD_SIZE-3*INSETS-40), TEXT_MAX_HEIGHT) lineBreakMode:NSLineBreakByWordWrapping];
       return 75+textSize.height;}
}

#pragma mark  接受新消息广播
-(void)newMsgCome:(NSNotification *)notifacation
{
    [self.tabBarController.tabBarItem setBadgeValue:@"1"];
    
    [MessageObject save:notifacation.object];
    
    [self refresh];
    
}


#pragma mark sharemore按钮组协议

-(void)pickPhoto
{
    
    UIImagePickerController *imgPicker=[[UIImagePickerController alloc]init];
    [imgPicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [imgPicker setDelegate:self];
    [imgPicker setAllowsEditing:YES];
    [self.navigationController presentViewController:imgPicker animated:YES completion:^{
    }];
    
}


#pragma mark ----------图片选择完成-------------
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage  * chosedImage=[info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        //
        
        [self sendImage:chosedImage];
        

    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

#pragma mark -
#pragma mark - SocketResultDelegate

-(void)onResult:(NSInteger)type value:(NSDictionary *)value
{
    switch (type) {
        case VALUE_MSG_RECEIVER:
        {
            //            NSLog(@"VALUE_MSG_RECEIVER = %@",[value objectForKey:KEY_DATA]);
            NSData *data = [value objectForKey:KEY_DATA];
            
            int cmd = [GlobalMethod byteArrayToInt:NSMakeRange(0, 4) withData:data];
            int length = [GlobalMethod byteArrayToInt:NSMakeRange(12, 4) withData:data];
            NSLog(@"class:%@--------cmd:%d,length:%d \n", NSStringFromClass([self class]), cmd,length);
            if (cmd == 17) {
                int result = [GlobalMethod byteArrayToInt:NSMakeRange(20, 4) withData:data];
                NSLog(@"sendMessage-result: %d \n", result);
                if (result == 0) {
                    //发送消息
                    //创建message对象
                    MessageObject *msg=[[MessageObject alloc]init];
                    [msg setMessageDate:[NSDate date]];
                    [msg setMessageFrom:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_ID]];
                    /*if (_chatGroup == nil) {
                        [msg setMessageTo:_chatPerson.userId];
                    } else {
                        [msg setMessageTo:_chatGroup.groupId];
                    }*/
                    [msg setMessageTo:_chatPerson.userId];
                    
                    /*//判断多媒体消息
                     
                     if ([[body substringToIndex:3]isEqualToString:@"[1]"]) {
                     
                     [msg setMessageType:[NSNumber numberWithInt:kWCMessageTypeImage]];
                     body=[body substringFromIndex:3];
                     } else {
                     [msg setMessageType:[NSNumber numberWithInt:kWCMessageTypePlain]];
                     }*/
                    [msg setMessageType:[NSNumber numberWithInt:kWCMessageTypePlain]];
                    NSLog(@"sendMessage");
                    
                    [msg setMessageContent:_msgText];
                    [MessageObject save:msg];
                    
                    //发送全局通知
                    [[NSNotificationCenter defaultCenter]postNotificationName:kNewMsgNotifaction object:msg ];
                }

            } else if (cmd == 18) { //收到服务器消息
                
                int senderId = [GlobalMethod byteArrayToInt:NSMakeRange(20, 4) withData:data];
                //int destType = [GlobalMethod byteArrayToInt:NSMakeRange(24, 4) withData:data];
                int groupId = [GlobalMethod byteArrayToInt:NSMakeRange(28, 4) withData:data];
                
                NSLog(@"sendMessage-senderId: %d, groupId:%d \n", senderId,groupId);
                //非当前用户发送的消息才解析
                if (senderId != [[[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_ID] intValue]) {
                    int receiverId = [GlobalMethod byteArrayToInt:NSMakeRange(32, 4) withData:data];
                    int textLen = [GlobalMethod byteArrayToInt:NSMakeRange(36, 4) withData:data];
//                    NSString *charFormat = [GlobalMethod byteArrayToString2:NSMakeRange(40,92) data:data];
//                    int sizeOfCharformat = [GlobalMethod byteArrayToInt:NSMakeRange(132, 4) withData:data];
//                    int picNum = [GlobalMethod byteArrayToInt:NSMakeRange(136, 4) withData:data];
                    int isAutoReply = [GlobalMethod byteArrayToInt:NSMakeRange(140, 1) withData:data];
                    NSString *str = [GlobalMethod byteArrayToString2:NSMakeRange(141,length-141) data:data];
                    NSString *context = [str substringWithRange:NSMakeRange(0, str.length-21)]; //去掉后面带的时间
                    
                    NSLog(@"isAutoReply:%d, length-141:%d, textlen:%d",isAutoReply,length-141,textLen);
                    NSLog(@"class:%@--------textLen:%d,context:%@ \n", NSStringFromClass([self class]), textLen,context);
                    
                    //发送消息
                    //创建message对象
                    MessageObject *msg=[[MessageObject alloc]init];
                    [msg setMessageDate:[NSDate date]];
                    [msg setMessageFrom:[NSString stringWithFormat:@"%d",senderId]];
                    if (groupId == 0) {
                        [msg setMessageTo:[NSString stringWithFormat:@"%d", receiverId ]];
                    } else {
                        [msg setMessageTo:[NSString stringWithFormat:@"%d", groupId ]];
                    }
                    
                    //[msg setMessageTo:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_ID]];
                    /*//判断多媒体消息
                     
                     if ([[body substringToIndex:3]isEqualToString:@"[1]"]) {
                     
                     [msg setMessageType:[NSNumber numberWithInt:kWCMessageTypeImage]];
                     body=[body substringFromIndex:3];
                     } else {
                     [msg setMessageType:[NSNumber numberWithInt:kWCMessageTypePlain]];
                     }*/
                    [msg setMessageType:[NSNumber numberWithInt:kWCMessageTypePlain]];
                    
                    [msg setMessageContent:context];
                    //[WCMessageObject save:msg];
                    
                    //发送全局通知
                    [[NSNotificationCenter defaultCenter]postNotificationName:kNewMsgNotifaction object:msg ];
                }
                
            }
            
        }
            break;
        case VALUE_MSG_CONNECTED:
        {
            NSLog(@"%@ is Connected!!!!!!,",NSStringFromClass([self class]));
        }
            break;
        case VALUE_MSG_ERROR:
        {
            NSLog(@"%@ Connected Error!!!!!!,",NSStringFromClass([self class]));
            
        }
            break;
        case VALUE_MSG_CLOSE:
        {
            NSLog(@"%@ Connected Close!!!!!!,",NSStringFromClass([self class]));
            
        }
            break;
        default:
            break;
    }
}



@end
