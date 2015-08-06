//
//  WCMessageViewController.m
//  WeChat
//
//  Created by Reese on 13-8-10.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "MessageViewController.h"
#import "SendMessageController.h"
#import "RecentListCell.h"

@interface MessageViewController ()

@end

@implementation MessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //self.title = @"消息";
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNavBarTitle:@"消息"];
    
    [self refresh];
    //[_messageTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    //[self loadBaseView];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(newMsgCome:) name:kNewMsgNotifaction object:nil];
    
    /************************ 获取离线消息 ************************/
    //向服务器发送数据
    NSInteger headArray[] = {19, 0, 0, 20, 1927384650};
    int ll = 20;
    uint8_t len[ll];
    for (int i=0; i<ll; i++) {
        int l = i/4;
        len[i] = (Byte)(headArray[l]>>(8*(3-i%4))&0xff);
    }
    NSMutableData *sendData = [[NSMutableData alloc] initWithBytes:len length:20];
    [MYAPPDELEGATE sendData:sendData];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    if (MYAPPDELEGATE.socketManager) {
        [MYAPPDELEGATE.socketManager setSocketDelegate:self];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark viewBuild
- (void)loadBaseView
{
    UITableView *tView = [[UITableView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(0, Navbar_Height, Main_Size.width, Main_Size.height - StatusBar_Height - Navbar_Height)] style:UITableViewStyleGrouped];
    [tView setDataSource:self];
    [tView setDelegate:self];
    //[tView setBackgroundView:nil];
    [tView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:tView];
}

#pragma mark   ---------tableView协议----------------
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"numberOfRowsInSection-_msgArr.count:%lu",(unsigned long)_msgArr.count);
    return _msgArr.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier=@"messageCell";
    RecentListCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell=[[RecentListCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    MessageUserUnionObject *unionObject=[_msgArr objectAtIndex:indexPath.row];
    [cell setUnionObject:unionObject];
    NSLog(@"unionObject.user class is:%@", [NSString stringWithUTF8String:object_getClassName(unionObject.user)]);
    if ([unionObject.user isKindOfClass:[UserObject class]]) {
        UserObject *user = (UserObject *)unionObject.user;
        if ([_newMsgUserID isEqualToString:user.userId]) {
            [cell.bageNumber setText:[NSString stringWithFormat:@"%d",[cell.bageNumber.text intValue]+1]];
        }
        
    } else if ([unionObject.user isKindOfClass:[GroupObject class]]) {
        GroupObject *group = (GroupObject *)unionObject.user;
        if ([_newMsgUserID isEqualToString:group.groupId]) {
            [cell.bageNumber setText:[NSString stringWithFormat:@"%d",[cell.bageNumber.text intValue]+1]];
        }
    }
    NSLog(@"_newMsgUserID:%@",_newMsgUserID);
    if (_msgArr.count == indexPath.row+1) {
        
        _newMsgUserID = @"";
    }
    //[cell.bageNumber setText:[NSString stringWithFormat:@"%d",[cell.bageNumber.text intValue]+1]];
    NSLog(@"cell.bageNumber.text:%@",cell.bageNumber.text);
    if ([cell.bageNumber.text isEqualToString:@"0"] || cell.bageNumber.text.length == 0) {
        [cell.bageView setHidden:YES];
    } else {
        [cell.bageView setHidden:NO];
    }

    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}


#pragma mark  接受新消息广播
-(void)newMsgCome:(NSNotification *)notifacation
{
    NSLog(@"newMsgCome");
    [self.tabBarController.tabBarItem setBadgeValue:@"1"];
    MessageObject *message = notifacation.object;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (message.messageFrom != [defaults objectForKey:kMY_USER_ID]) {
        [MessageObject save:notifacation.object];
        
        if ([GroupObject haveSaveGroupById:message.messageTo]) { //群消息
            _newMsgUserID = message.messageTo;
        } else {
            _newMsgUserID = message.messageFrom;
        }
        
    } else {
        _newMsgUserID = @"";
    }
    
    
    
    [self refresh];
    
}
-(void)refresh
{
    _msgArr=[MessageObject fetchRecentChatByPage:1];
    NSArray *groupMsgArr=[MessageObject fetchGroupChatByPage:1];
    [_msgArr addObjectsFromArray:groupMsgArr];
    //[_messageTable reloadData];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SendMessageController *sendView=[[SendMessageController alloc]init];
    
    MessageUserUnionObject *unionObj=[_msgArr objectAtIndex:indexPath.row];
    /*if ([unionObj.user isKindOfClass:[UserObject class]]) {
        [sendView setChatPerson:unionObj.user];
    } else if ([unionObj.user isKindOfClass:[GroupObject class]]) {
        
        [sendView setChatGroup:unionObj.user];
    }*/
    [sendView setChatPerson:unionObj.user];
    
    [sendView setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:sendView animated:YES];
    
    RecentListCell *cell = (RecentListCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell.bageNumber setText:[NSString stringWithFormat:@"%d",0]];
    [cell.bageView setHidden:YES];
}

#pragma mark -
#pragma mark - SocketResultDelegate

-(void)onResult:(NSInteger)type value:(NSDictionary *)value
{
    switch (type) {
        case VALUE_MSG_RECEIVER:
        {
            //            NSLog(@"VALUE_MSG_RECEIVER = %@",[value objectForKey:KEY_DATA]);
            NSMutableData *data = [value objectForKey:KEY_DATA];
            int cmd = [GlobalMethod byteArrayToInt:NSMakeRange(0, 4) withData:data];
            int length = [GlobalMethod byteArrayToInt:NSMakeRange(12, 4) withData:data];
            NSLog(@"class:%@--------cmd:%d,length:%d \n", NSStringFromClass([self class]), cmd,length);
            
            if (cmd == 18) { //收到服务器消息
                /*//创建message对象
                WCMessageObject *msg=[[WCMessageObject alloc]init];
                [msg setMessageDate:[NSDate date]];
                [msg setMessageFrom:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_ID]];
                
                [msg setMessageTo:_chatPerson.userId];
                //判断多媒体消息
                 
                 if ([[body substringToIndex:3]isEqualToString:@"[1]"]) {
                 
                 [msg setMessageType:[NSNumber numberWithInt:kWCMessageTypeImage]];
                 body=[body substringFromIndex:3];
                 } else {
                 [msg setMessageType:[NSNumber numberWithInt:kWCMessageTypePlain]];
                 }
                 
                [msg setMessageType:[NSNumber numberWithInt:kWCMessageTypePlain]];
                NSLog(@"sendMessage");
                
                [msg setMessageContent:_msgText];
                [WCMessageObject save:msg];
                
                //发送全局通知
                [[NSNotificationCenter defaultCenter]postNotificationName:kXMPPNewMsgNotifaction object:msg ];*/
                
                int senderId = [GlobalMethod byteArrayToInt:NSMakeRange(20, 4) withData:data];
                //int destType = [GlobalMethod byteArrayToInt:NSMakeRange(24, 4) withData:data];
                int groupId = [GlobalMethod byteArrayToInt:NSMakeRange(28, 4) withData:data];
                
                NSLog(@"sendMessage-senderId: %d, groupId:%d \n", senderId,groupId);
                
                int receiverId = [GlobalMethod byteArrayToInt:NSMakeRange(32, 4) withData:data];
                int textLen = [GlobalMethod byteArrayToInt:NSMakeRange(36, 4) withData:data];
//                NSString *charFormat = [GlobalMethod byteArrayToString2:NSMakeRange(40,92) data:data];
//                int sizeOfCharformat = [GlobalMethod byteArrayToInt:NSMakeRange(132, 4) withData:data];
//                int picNum = [GlobalMethod byteArrayToInt:NSMakeRange(136, 4) withData:data];
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
                    //[msg setMessageType:[NSNumber numberWithInt:1]];//群消息

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
                NSLog(@"sendMessage");
                
                [msg setMessageContent:context];
                //[WCMessageObject save:msg];
                
                //发送全局通知
                [[NSNotificationCenter defaultCenter]postNotificationName:kNewMsgNotifaction object:msg ];
                
                
               
            } else if (cmd == 19) {
                NSLog(@"获取离线消息...");
                int result = [GlobalMethod byteArrayToInt:NSMakeRange(20, 4) withData:data];
                NSLog(@"sendMessage-result: %d \n", result);
                //NSLog(@"消息：%@",[GlobalMethod byteArrayToString:NSMakeRange(24,length-24) data:data]);
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
