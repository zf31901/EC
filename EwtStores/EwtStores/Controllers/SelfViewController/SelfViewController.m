//
//  SelfViewController.m
//  EwtStores
//
//  Created by Harry on 13-11-30.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "SelfViewController.h"

#import "SettingViewController.h"
#import "LoginInViewController.h"
#import "AppDelegate.h"
#import "UserObj.h"
#import "MessageViewController.h"

#import "AddressManageViewController.h"
#import "PersonalInfoViewController.h"
#import "UnpayViewController.h"
#import "DeliverViewController.h"
#import "FinishViewController.h"
#import "ReturnOrderViewController.h"
#import "CouponViewController.h"
#import "RequestPostUploadHelper.h"
#import "EGOImageView.h"

SelfViewController *selfVC;

@interface SelfViewController ()
{
    NSMutableArray  *dataArr;
    
    EGOImageView     *headImageView;
    UILabel         *headNameLb;
    UILabel         *imLb;
}


@end

NSString *TMP_UPLOAD_IMG_PATH=@"";

@implementation SelfViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self setNavBarTitle:@"我的爱心天地"];
    [self hiddenLeftBtn];
    
    [self hiddenRightBtn];
    dataArr = [[NSMutableArray alloc] initWithObjects:@"",@"  订单反馈",@"  地址管理",@"  优惠券",@"  设置",nil];
    
    [self loadBaseView];
    
    selfVC = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self setTabBarShowWithAnimation:YES];
    
    UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
    if(user.isLogin){
        [headNameLb setText:user.userName];
        if (![user.headPic isEqualToString:@""]) {
            //url转NSData消耗很大，会出现卡顿
            /*UIImage *avatar =[[UIImage alloc]initWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:user.headPic]]];
            [headImageView setImage:[RequestPostUploadHelper circleImage:avatar withParam:0]];*/
            [headImageView setImageURL:[NSURL URLWithString:user.headPic]];
            [headImageView.layer setCornerRadius:25];
            [headImageView.layer setMasksToBounds:YES];
        } else {
            [headImageView setImage:[UIImage imageNamed:@"profile-no-avatar-icon"]];
        }
        
        [imLb setHidden:NO];
        [imLb setText:[NSString stringWithFormat:@"爱心号：%@",user.im]];
    }else{
        [headImageView setImage:[UIImage imageNamed:@"profile-no-avatar-icon"]];
        [headNameLb setText:@"点击此处登录"];
        [imLb setHidden:YES];
    }
    
    [MobClick event:GRZX];
    
    NSArray *VCArr = MYAPPDELEGATE.tabBarC.viewControllers;
    if(VCArr.count >= 3){
        UINavigationController *cartVC = VCArr[2];
        NSString *cart_product_num = [GlobalMethod getObjectForKey:CART_PRODUCT_COUNT];
        if([cart_product_num integerValue] == 0 || !user.isLogin){
            cartVC.tabBarItem.badgeValue = nil;
        }else{
            cartVC.tabBarItem.badgeValue = cart_product_num;
        }
    }
}

#pragma mark －点击NavBar左边按钮
- (void)leftBtnAction:(UIButton *)btn
{
    DLog(@"%@ 中点击NavBar左边按钮",NSStringFromClass([self class]));
    /****************** chat登录 ******************/
    NSInteger headArray[] = {0, 0, 0, 499, 1927384650};
    //int length = LENGTH(headArray);
    int ll = 20;
    uint8_t len[ll];
    for (int i=0; i<ll; i++) {
        int l = i/4;
        len[i] = (Byte)(headArray[l]>>(8*(3-i%4))&0xff);
    }
    
    int someInt = 0;
    NSString *aString = [NSString stringWithFormat:@"%d",someInt];
    NSData *someData = [aString dataUsingEncoding:NSUTF8StringEncoding];
    //Byte *someByte = (Byte *)[someData bytes];
    const void *someByte = [someData bytes];
    //Byte *someByte = (Byte *)(0XFF & someInt);
    
    Byte byte[] = {0,0,0,0};
    NSData *adata = [[NSData alloc] initWithBytes:byte length:4];
    
    int instanceNo = 1001;
    uint8_t instanceNo_len[4];
    for(int i = 0;i<4;i++)
    {
        instanceNo_len[i] = (Byte)(instanceNo>>8*(3-i)&0xff);
    }
    
    int instanceNo_Net = 10035;
    uint8_t instanceNo_Net_len[4];
    for(int i = 0;i<4;i++)
    {
        instanceNo_Net_len[i] = (Byte)(instanceNo_Net>>8*(3-i)&0xff);
    }
    
    int mode = 4;
    uint8_t mode_len[4];
    for(int i = 0;i<4;i++)
    {
        mode_len[i] = (Byte)(mode>>8*(3-i)&0xff);
    }
    
    NSMutableData *sendData = [[NSMutableData alloc] initWithBytes:len length:20];
    [sendData appendData:[[NSData alloc]initWithBytes:[@"110103" UTF8String] length:17]];
    [sendData appendData:[[NSData alloc]initWithBytes:[[[GlobalMethod md5:@"888888"] uppercaseString] UTF8String] length:33]];
    [sendData appendData:[[NSData alloc]initWithBytes:[@"192.168.9.162" UTF8String] length:16]]; //m_szPrivateIP
    [sendData appendBytes:someByte length:4]; //m_nPrivatePort
    [sendData appendData:adata];  //m_nStatus
    [sendData appendData:[[NSData alloc]initWithBytes:[@"255.255.255.0" UTF8String] length:17]];  //m_szHisID
    [sendData appendBytes:someByte length:4];  //m_nBusinessType
    [sendData appendBytes:instanceNo_Net_len length:4];  //m_nBusinessInstanceNo,内网网为1001
    //[sendData appendBytes:instanceNo_len length:4];  //m_nBusinessInstanceNo,外网为10038
    [sendData appendData:[[NSData alloc]initWithBytes:[@"255.255.255.0" UTF8String] length:16]];
    [sendData appendBytes:someByte length:4];
    [sendData appendData:[[NSData alloc]initWithBytes:[@"0.0.0.0" UTF8String] length:16]];
    [sendData appendData:[[NSData alloc]initWithBytes:[@"0.0.0.0" UTF8String] length:170]];
    [sendData appendData:[[NSData alloc]initWithBytes:[@"0.0.0.0" UTF8String] length:170]];
    [sendData appendBytes:mode_len length:4];
    
    [MYAPPDELEGATE sendData:sendData];
    //发送心跳包
    [MYAPPDELEGATE.socketManager startHeart];
    
    //保存客服
    UserObject *user = [[UserObject alloc] init];
    //user.userId =
    [user setFriendFlag:[NSNumber numberWithInt:1]];
    
    if (![UserObject haveSaveUserById:user.userId]) {
        [UserObject saveNewUser:user];
    }
    else [UserObject updateUser:user];
    
    MessageViewController *msgVC = [MessageViewController shareInstance];
    //MessageViewController *msgVC = [[MessageViewController alloc] init];
    [msgVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:msgVC animated:YES];
}

#pragma mark viewBuild
- (void)loadBaseView
{
    UIImageView *headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, Main_Size.width, 200)];
    [headView setUserInteractionEnabled:YES];
    [headView setImage:[UIImage imageNamed:@"profile-bg@2x.jpg"]];
    
    headImageView = [[EGOImageView alloc] initWithFrame:CGRectMake(135, 35, 50, 50)];
    [headImageView.layer setCornerRadius:25]; //设置图片成圆形
    [headImageView.layer setMasksToBounds:YES];
    [headImageView setPlaceholderImage:[UIImage imageNamed:@"profile-no-avatar-icon"]];
    [headView addSubview:headImageView];
    [headImageView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(LoginOrChangeHeadView)];
    [headImageView addGestureRecognizer:tap];
    
    headNameLb = [GlobalMethod BuildLableWithFrame:CGRectMake(50, 90, 220, 20)
                                          withFont:[UIFont systemFontOfSize:18]
                                          withText:@"点击此处登录"];
    [headNameLb setTextAlignment:NSTextAlignmentCenter];
    [headNameLb setTextColor:[UIColor whiteColor]];
    [headView addSubview:headNameLb];
    [headNameLb setUserInteractionEnabled:YES];
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(LoginOrChangeHeadView)];
    [headNameLb addGestureRecognizer:tap];
    
    imLb = [GlobalMethod BuildLableWithFrame:CGRectMake(50, headNameLb.bottom, 220, 20)
                                    withFont:[UIFont systemFontOfSize:16]
                                    withText:@"爱心号："];
    [imLb setTextAlignment:NSTextAlignmentCenter];
    [imLb setTextColor:[UIColor whiteColor]];
    [imLb setHidden:YES];
    [headView addSubview:imLb];
    
    [self.mainTableView setFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(0, Navbar_Height, Main_Size.width, Main_Size.height - StatusBar_Height - Navbar_Height - Tabbar_Height)]];
    [self.mainTableView setTableHeaderView:headView];
    [self.mainTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self hiddenFooterView];
}

#pragma mark viewAction
- (void)ProductPayStatus:(id)sender
{
    NSInteger tag = 0;
    
    if([sender isKindOfClass:[UIButton class]]){
        tag = ((UIButton *)sender).tag;
    }else{
        UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
        UILabel *lb = (UILabel *)[tap view];
        tag = lb.tag;
    }
    
    UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
    if(user.isLogin == NO){
        LoginInViewController *loginViewC = [[LoginInViewController alloc] init];
        UINavigationController *loginNavC = [[UINavigationController alloc] initWithRootViewController:loginViewC];
        [loginNavC setNavigationBarHidden:YES];
        [self presentViewController:loginNavC animated:YES completion:Nil];
        return ;
    }
    
    switch (tag) {
        case ReadyPay:
        {
            DLog(@"查看待付款");
            UnpayViewController *unpayVC = [UnpayViewController shareInstance];
            [unpayVC setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:unpayVC animated:YES];
        }
            break;
            
        case Paying:
        {
            DLog(@"配送中");
            DeliverViewController *deliverVC = [DeliverViewController shareInstance];
            [deliverVC setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:deliverVC animated:YES];
        }
            break;
            
        case FinishPay:
        {
            DLog(@"已完成");
            FinishViewController *finishVC = [FinishViewController shareInstance];
            [finishVC setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:finishVC animated:YES];
        }
            break;
            
        default:
            break;
    }
}

- (void)LoginOrChangeHeadView
{
    UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
    if(user.isLogin){
        DLog(@"登录状态，换头像");
        
        //一期不去个人中心，直接改头像
        [self ChangeHeadView];
        return ;
        
        PersonalInfoViewController *info = [PersonalInfoViewController shareInstance];
        [info setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:info animated:YES];
    }else{
        DLog(@"开始登录");
        
        LoginInViewController *loginViewC = [[LoginInViewController alloc] init];
        UINavigationController *loginNavC = [[UINavigationController alloc] initWithRootViewController:loginViewC];
        [loginNavC setNavigationBarHidden:YES];
        [self presentViewController:loginNavC animated:YES completion:Nil];
    }
}

#pragma mark UITableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellString = @"selfViewIdenfitier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellString];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellString];
        
        UIImage *cellBg = [UIImage imageNamed:@"cell-bg-single"];
        cellBg = [cellBg resizableImageWithCapInsets:UIEdgeInsetsMake(24, 151.5, 24, 151.5)];
        UIImageView *cellBgView = [[UIImageView alloc] initWithImage:cellBg];
        if(indexPath.row == 0){
            [cellBgView setFrame:CGRectMake(8.5, 12, 303, 60)];
            
            UIButton *readyPayBt = [GlobalMethod BuildButtonWithFrame:CGRectMake(60, 20, 20, 20)
                                                            andOffImg:@"profile-refresh-payment-icon"
                                                             andOnImg:@"profile-refresh-payment-icon"
                                                            withTitle:nil];
            [readyPayBt addTarget:self action:@selector(ProductPayStatus:) forControlEvents:UIControlEventTouchUpInside];
            [readyPayBt setTag:ReadyPay];
            [cell.contentView addSubview:readyPayBt];
            UILabel *readyPayLb = [GlobalMethod BuildLableWithFrame:CGRectMake(40, 40, 60, 22)
                                                           withFont:[UIFont systemFontOfSize:14]
                                                           withText:@"待处理"];
            [readyPayLb setTextAlignment:NSTextAlignmentCenter];
            [readyPayLb setUserInteractionEnabled:YES];
            [readyPayLb setTag:ReadyPay];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ProductPayStatus:)];
            [readyPayLb addGestureRecognizer:tap];
            [cell.contentView addSubview:readyPayLb];
            
            UIButton *PayingBt = [GlobalMethod BuildButtonWithFrame:CGRectMake(150, 20, 20, 20)
                                                          andOffImg:@"profile-refresh-receipt-icon"
                                                           andOnImg:@"profile-refresh-receipt-icon"
                                                          withTitle:nil];
            [PayingBt addTarget:self action:@selector(ProductPayStatus:) forControlEvents:UIControlEventTouchUpInside];
            [PayingBt setTag:Paying];
            [cell.contentView addSubview:PayingBt];
            UILabel *payingLb = [GlobalMethod BuildLableWithFrame:CGRectMake(130, 40, 60, 22)
                                                         withFont:[UIFont systemFontOfSize:14]
                                                         withText:@"配送中"];
            [payingLb setTextAlignment:NSTextAlignmentCenter];
            [payingLb setUserInteractionEnabled:YES];
            [payingLb setTag:Paying];
            tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ProductPayStatus:)];
            [payingLb addGestureRecognizer:tap];
            [cell.contentView addSubview:payingLb];
            
            UIButton *PayedBt = [GlobalMethod BuildButtonWithFrame:CGRectMake(240, 20, 20, 20)
                                                         andOffImg:@"profile-refresh-history-icon"
                                                          andOnImg:@"profile-refresh-history-icon"
                                                         withTitle:nil];
            [PayedBt addTarget:self action:@selector(ProductPayStatus:) forControlEvents:UIControlEventTouchUpInside];
            [PayedBt setTag:FinishPay];
            [cell.contentView addSubview:PayedBt];
            UILabel *payedLb = [GlobalMethod BuildLableWithFrame:CGRectMake(220, 40, 60, 22)
                                                        withFont:[UIFont systemFontOfSize:14]
                                                        withText:@"已完成"];
            [payedLb setTextAlignment:NSTextAlignmentCenter];
            [payedLb setUserInteractionEnabled:YES];
            [payedLb setTag:FinishPay];
            tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ProductPayStatus:)];
            [payedLb addGestureRecognizer:tap];
            [cell.contentView addSubview:payedLb];
            
        }else{
            [cellBgView setFrame:CGRectMake(8.5, 4, 303, 48)];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
        UIView *bg = [[UIView alloc] initWithFrame:cell.frame];
        [bg setBackgroundColor:RGBS(238)];
        [bg addSubview:cellBgView];
        [cell setBackgroundView:bg];
    }
    
    if (indexPath.row != 0) {
        [cell.textLabel setText:dataArr[indexPath.row]];
        [cell.textLabel setFont:[UIFont systemFontOfSize:16]];
    }
    

    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        return 78;
    }
    
    return 56;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
        {
            
        }
            break;
            
        case 1:
        {
            DLog(@"退款/退货");
            
            UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
            if(user.isLogin == NO){
                LoginInViewController *loginViewC = [[LoginInViewController alloc] init];
                UINavigationController *loginNavC = [[UINavigationController alloc] initWithRootViewController:loginViewC];
                [loginNavC setNavigationBarHidden:YES];
                [self presentViewController:loginNavC animated:YES completion:Nil];
                return ;
            }
            
            ReturnOrderViewController *returnVC = [ReturnOrderViewController shareInstance];
            [returnVC setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:returnVC animated:YES];
        }
            break;
            
        case 2:
        {
            DLog(@"收货地址管理");
            
            UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
            
            if(user.im == nil || [user.im isEqualToString:@""]|| !user.isLogin){
                LoginInViewController *loginViewC = [[LoginInViewController alloc] init];
                UINavigationController *loginNavC = [[UINavigationController alloc] initWithRootViewController:loginViewC];
                [loginNavC setNavigationBarHidden:YES];
                [self presentViewController:loginNavC animated:YES completion:Nil];
                return ;
            }
            
            AddressManageViewController *addressVC = [AddressManageViewController shareInstance];
            [addressVC setShouldChoiceAddress:NO];
            [addressVC setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:addressVC animated:YES];
        }
            break;
            
        case 3:
        {
            DLog(@"进入购物券界面");
            
            UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
            
            if(user.im == nil || [user.im isEqualToString:@""] || !user.isLogin){
                LoginInViewController *loginViewC = [[LoginInViewController alloc] init];
                UINavigationController *loginNavC = [[UINavigationController alloc] initWithRootViewController:loginViewC];
                [loginNavC setNavigationBarHidden:YES];
                [self presentViewController:loginNavC animated:YES completion:Nil];
                return ;
            }
            
            CouponViewController *coupVC = [CouponViewController shareInstance];
            coupVC.fromPage = @"selfVC";
            [coupVC setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:coupVC animated:YES];
        }
            break;
            
        case 4:
        {
            DLog(@"进入设置界面");
            
            SettingViewController *settingVC = [SettingViewController shareInstance];
            [settingVC setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:settingVC animated:YES];
        }
            break;
            
        default:
            break;
    }
}

- (void)comeToLogin
{
    [self hideHUDInView:self.view];
    LoginInViewController *loginViewC = [[LoginInViewController alloc] init];
    UINavigationController *loginNavC = [[UINavigationController alloc] initWithRootViewController:loginViewC];
    [loginNavC setNavigationBarHidden:YES];
    [self presentViewController:loginNavC animated:YES completion:Nil];
}

- (void)ChangeHeadView{
    
    [MobClick event:GRXS];
    
    UIActionSheet *aSheet = [[UIActionSheet alloc] initWithTitle:@"更换头像?"
                                                        delegate:self
                                               cancelButtonTitle:@"取消"
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"拍照",@"相机选取", nil];
    [aSheet showInView:self.tabBarController.view];
}

#pragma mark UIAcionSheet Methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == actionSheet.cancelButtonIndex){
        
    }else if (buttonIndex == 0){
        
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){ //相机能用
            UIImagePickerController *imagePC = [[UIImagePickerController alloc] init];
            [imagePC setSourceType:UIImagePickerControllerSourceTypeCamera];
            [imagePC setDelegate:self];
            [imagePC setAllowsEditing:YES];
            [self presentViewController:imagePC animated:YES completion:Nil];
        } else {
            [self showHUDInView:self.view WithText:@"此设备不支持拍照" andDelay:LOADING_TIME];
        }
    }else{
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){//相册可用
            UIImagePickerController *imagePC = [[UIImagePickerController alloc] init];
            [imagePC setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            [imagePC setDelegate:self];
            [imagePC setAllowsEditing:YES];
            [self presentViewController:imagePC animated:YES completion:Nil];
        }
    }
}

#pragma mark UIImagePickerVC Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *editImg = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera){
        /*// 判断，图片是否允许修改
        if ([picker allowsEditing]){
            //获取用户编辑之后的图像
            img = [info objectForKey:UIImagePickerControllerEditedImage];
        } else {
            // 照片的元数据参数
            img = [info objectForKey:UIImagePickerControllerOriginalImage];
            
        }*/
        // 保存图片到相册中
        SEL selectorToCall = @selector(imageWasSavedSuccessfully:didFinishSavingWithError:contextInfo:);
        UIImageWriteToSavedPhotosAlbum(editImg, self,selectorToCall, NULL);
        /*// 保存图片至本地，方法见下文
        [self saveImage:img withName:@"avatar.jpg"];
        NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"avatar.jpg"];
        editImg = [[UIImage alloc] initWithContentsOfFile:fullPath];*/

    }
    
    DLog(@"%@",[info objectForKey:UIImagePickerControllerReferenceURL]);
    
    //editImg为JPG格式，使用UIImagePNGRepresentation转NSData后发送request会报400错误
    /*UIImagePNGRepresentation(UIImage* image) 要比UIImageJPEGRepresentation(UIImage* image, 1.0) 返回的图片数据量大很多
     *如果对图片的清晰度要求不高,还可以通过设置 UIImageJPEGRepresentation函数的第二个参数,大幅度降低图片数据量.譬如,刚才拍摄的图片, 通过调用UIImageJPEGRepresentation(UIImage* image, 1.0)读取数据时,返回的数据大小为140KB,但更改压缩系数后,通过调用UIImageJPEGRepresentation(UIImage* image, 0.5)读取数据时,返回的数据大小只有11KB多,大大压缩了图片的数据量 ,而且从视角角度看,图片的质量并没有明显的降低
     
     */
    //NSData *imageData = UIImagePNGRepresentation(editImg);
    /*NSData *imageData;
    if (UIImagePNGRepresentation(editImg) == nil){
        imageData = UIImageJPEGRepresentation(editImg, 0.5);
    } else {
        imageData = UIImagePNGRepresentation(editImg);
    }*/
    NSData *imageData = UIImageJPEGRepresentation(editImg, 0.5);

    if (imageData.length > 100000) {
        imageData = UIImageJPEGRepresentation(editImg, 0.1);
    }
    
    BLOCK_SELF(SelfViewController);
    HTTPRequest *hq = [HTTPRequest shareInstance_myapi];
    UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
    NSDictionary *parameters = @{@"clientkey": user.clientkey, @"UserLogin": user.im};
    //先将pickerView隐藏，否则会请求失败
    [self dismissViewControllerAnimated:YES completion:Nil];
    [self showHUDInView:block_self.view WithText:@"头像上传中"];

    [hq POSTURLString:USER_UPDATEFILE parameters:parameters imageData:imageData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self hideHUDInView:block_self.view];
        NSDictionary *rqDic = (NSDictionary *)responseObject;
        if([rqDic[HTTP_STATE] boolValue]){
            NSDictionary *dic = (NSDictionary *)[rqDic[HTTP_DATA] objectFromJSONString];
            DLog(@"fileurl=%@",dic[@"fileurl"]);
            [user setHeadPic:dic[@"fileurl"]];
            [GlobalMethod saveObject:user withKey:USEROBJECT];
            [headImageView setImage:[RequestPostUploadHelper circleImage:editImg withParam:0]];
        }else{
            NSLog(@"errorMsg: %@:%@",rqDic[HTTP_ERRCODE],rqDic[HTTP_MSG]);
            [self showHUDInView:block_self.view WithText:@"上传失败" andDelay:LOADING_TIME];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",[error description]);
        [self hideHUDInView:block_self.view];
        [self showHUDInView:block_self.view WithText:@"上传失败" andDelay:LOADING_TIME];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:Nil];
}

#pragma mark - 保存图片至沙盒
- (void) saveImage:(UIImage *)currentImage withName:(NSString *)imageName
{
    
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.5);
    // 获取沙盒目录
    
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    // 将图片写入文件
    
    [imageData writeToFile:fullPath atomically:NO];
}

// 保存图片后到相册后，调用的相关方法，查看是否保存成功
- (void) imageWasSavedSuccessfully:(UIImage *)paramImage didFinishSavingWithError:(NSError *)paramError contextInfo:(void *)paramContextInfo{
    if (paramError == nil){
        NSLog(@"Image was saved successfully.");
    } else {
        NSLog(@"An error happened while saving the image.");
        NSLog(@"Error = %@", paramError);
    }
}

#pragma mark EgoTableView Method
- (void)refreshView
{
    [self finishReloadingData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
