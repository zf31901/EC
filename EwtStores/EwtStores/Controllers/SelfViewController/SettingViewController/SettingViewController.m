//
//  SettingViewController.m
//  EwtStores
//
//  Created by Harry on 13-12-4.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "SettingViewController.h"
#import "MBProgressHUD.h"

#import "AboutUsViewController.h"
#import "FeedbackViewController.h"
#import "HelpCenterViewController.h"

#import "HTTPRequest.h"

@interface SettingViewController ()
{
    NSMutableArray  *dataArr;
    UITableView     *tView;
    UIAlertView     *cacheAView;
    
    
    UISwitch        *sw;
}

@end

@implementation SettingViewController

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
    
    [self setNavBarTitle:@"设置"];
    [self hiddenRightBtn];
    
    dataArr = [[NSMutableArray alloc] initWithCapacity:3];
    NSArray *arr1 = [NSArray arrayWithObjects:@"清除缓存",@"省流量",nil];
    NSArray *arr2 = [NSArray arrayWithObjects:@"意见反馈",@"帮助中心",nil];
    NSArray *arr3 = [NSArray arrayWithObjects:@"检查更新",@"关于",@"去APPSTORE评分",nil];
    [dataArr addObject:arr1];
    [dataArr addObject:arr2];
    [dataArr addObject:arr3];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
    {
        sw = [[UISwitch alloc] initWithFrame:CGRectMake(250-45, 6, 60, 30)];
    } else {
        sw = [[UISwitch alloc] initWithFrame:CGRectMake(250, 6, 60, 30)];
    }
    
    if([[GlobalMethod getObjectForKey:FLOWCHOICE] boolValue]){
        [sw setOn:YES animated:NO];
    }else{
        [sw setOn:NO animated:NO];
    }
    
    
    [sw addTarget:self action:@selector(flowChoice) forControlEvents:UIControlEventValueChanged];
    
    [self loadBaseView];
}

#pragma mark viewBuild
- (void)loadBaseView
{
    tView = [[UITableView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(8.5, Navbar_Height, Main_Size.width-17, Main_Size.height - StatusBar_Height - Navbar_Height)] style:UITableViewStyleGrouped];
    [tView setDataSource:self];
    [tView setDelegate:self];
    [tView setBackgroundView:nil];
    [tView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:tView];
    
    cacheAView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%0.2fM",[HTTPRequest getFileCacheData]/1024.0/1024.0] message:@"成功清理" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
}

#pragma mark viewAction
- (void)quitAccount
{
    UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:nil
                                                     message:@"是否要退出?"
                                                    delegate:self
                                           cancelButtonTitle:@"取消"
                                           otherButtonTitles:@"退出",nil];
    [alertV show];
}

- (void)flowChoice
{
    if([[GlobalMethod getObjectForKey:FLOWCHOICE] boolValue]){
        [GlobalMethod saveObject:[NSNumber numberWithBool:NO] withKey:FLOWCHOICE];
        [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"关闭省流量模式" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show];
    }
    else{
        [GlobalMethod saveObject:[NSNumber numberWithBool:YES] withKey:FLOWCHOICE];
        [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"开启省流量模式" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show];
    }
}

#pragma mark UItableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return dataArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(NSArray *)dataArr[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    [cell.textLabel setText:[(NSArray *)dataArr[indexPath.section] objectAtIndex:indexPath.row]];
    [cell.textLabel setTextColor:RGBS(59)];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if(indexPath.section==0)
    {
        if(indexPath.row == 0){
            
            UILabel *numCacheLb = [GlobalMethod BuildLableWithFrame:CGRectMake(180, 15, 100, 15)
                                                           withFont:[UIFont systemFontOfSize:14]
                                                           withText:[NSString stringWithFormat:@"%0.3f M",[HTTPRequest getFileCacheData]/1024.0/1024.0]];
            [numCacheLb setTextAlignment:NSTextAlignmentRight];
            [numCacheLb setTextColor:RGBS(59)];
            
            //[cell.contentView addSubview:numCacheLb];
        }else if (indexPath.row == 1){  //省流量
            [cell.contentView addSubview:sw];
            
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section == 2)
    {
        return 64;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return 10;
    }
    
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if(section == 2)
    {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Main_Size.width, 64)];
        UIButton *exitBtn = [GlobalMethod BuildButtonWithFrame:CGRectMake(0, 10, Main_Size.width-17, 44)
                                                     andOffImg:@"regist_next_off"
                                                      andOnImg:@"regist_next_on"
                                                     withTitle:@"退出登录"];
        [exitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [exitBtn addTarget:self action:@selector(quitAccount) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:exitBtn];
        return bgView;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0 && indexPath.row==0){
        
        [MobClick event:QCHC];
        UIAlertView *aletV = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                        message:[NSString stringWithFormat:@"需要清除%0.2fM缓存？",[HTTPRequest getFileCacheData]/1024.0/1024.0]
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
        [aletV setTag:3];
        [aletV show];
        
        //tag by harry 二期需求更改 20140414
//        [self showHUDInView:self.view WithText:@"正在清理"];
//        [self performSelector:@selector(AfterDelayClearAllCacheData) withObject:nil afterDelay:1];

        return;
    }else if (indexPath.section == 1){
        if(indexPath.row == 0){
            [self.navigationController pushViewController:[FeedbackViewController shareInstance] animated:YES];        
        }else{
            [self.navigationController pushViewController:[HelpCenterViewController shareInstance] animated:YES];
        }
    }
    
    if(indexPath.section == 2){
        if(indexPath.row == 1){  //关于
            [self.navigationController pushViewController:[AboutUsViewController shareInstance] animated:YES];
        }else if (indexPath.row == 2){ //评分
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id825481902"]];
        }else{       //检查更新
            
            [self showHUDInView:self.view WithText:NETWORKLOADING];
            [[HTTPRequest shareInstance] GETURLString:CHECK_SYSTEMVERSON userCache:NO parameters:@{@"appid":@"1"} success:^(AFHTTPRequestOperation *operation, id responseObj) {
                NSDictionary *rqDic = (NSDictionary *)responseObj;
                if([rqDic[HTTP_STATE] boolValue]){
                    NSString *localityVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
                    NSArray *versionArr = [localityVersion componentsSeparatedByString:@"."];
                    localityVersion = [NSString stringWithFormat:@"%02d%02d%02d",[versionArr[0] integerValue],[versionArr[1] integerValue],[versionArr[2] integerValue]];
                    NSInteger version = [localityVersion integerValue];
                    NSDictionary *dataDic = (NSDictionary *)[rqDic[HTTP_DATA] objectFromJSONString];
                    if([dataDic[@"isUpgrade"] boolValue]){
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:dataDic[@"fileUrl"]]];
                    }else{
                        
                        if([dataDic[@"versionCode"] integerValue] > version){
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"有新版本，是否要立即更新?" delegate:self cancelButtonTitle:@"下次再说" otherButtonTitles:@"立即更新", nil];
                            [alert setTag:2];
                            [alert show];
                        }else{
                            UIAlertView *aView = [[UIAlertView alloc] initWithTitle:@"当前为最新版本"
                                                                            message:nil
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"知道了"
                                                                  otherButtonTitles:nil];
                            [aView show];
                        }
                    }
                    
                    [self hideHUDInView:self.view];
                    
                }else{
                    DLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
                    [self hideHUDInView:self.view];
                    [self showHUDInView:self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"%@ , %@",operation,error);
                [self hideHUDInView:self.view];
                [self showHUDInView:self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
            }];
        }
    }
}

#pragma mark - AlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 1){
        if(alertView.cancelButtonIndex != buttonIndex){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://4008825365"]];
        }
        
        return ;
    }
    
    if(alertView.tag == 2){
        if(alertView.cancelButtonIndex != buttonIndex){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/app/id825481902"]];
        }
        
        return ;
    }
    
    if (alertView.tag == 3) {
        if(alertView.cancelButtonIndex != buttonIndex){
            [self AfterDelayClearAllCacheData];
        }
        
        return ;
    }
    
    if(alertView.cancelButtonIndex != buttonIndex){
        [self showHUDInView:self.view WithText:@"正在退出..." andDelay:LOADING_TIME  withTag:1];
        
        BLOCK_SELF(SettingViewController);
        HTTPRequest *hq = [HTTPRequest shareInstance_myapi];
        UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
        
        //没有登陆情况
        if(user.im.length == 0){
            return ;
        }
        
        NSDictionary *parameters = @{@"u": user.im,@"clientkey":user.clientkey};
        [hq GETURLString:USER_LOGINOUT parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObj) {
            NSDictionary *rqDic = (NSDictionary *)responseObj;
            if([rqDic[HTTP_STATE] boolValue]){
                
                [GlobalMethod saveObject:@"" withKey:CART_PRODUCT_COUNT];
                
            }else{
                NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
                [self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
                //[self showHUDInView:block_self.view WithText:[NSString stringWithFormat:@"%@:%@",rqDic[HTTP_ERRCODE],rqDic[HTTP_MSG]] andDelay:2];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@ , %@",operation,error);
            [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
        }];
        
        UserObj *obj = [[UserObj alloc] init];
        obj.userName = user.im;
        obj.password = user.password;
        obj.atLogin = YES;
        [GlobalMethod saveObject:obj withKey:USEROBJECT];
    }
}

- (void)willPresentAlertView:(UIAlertView *)alertView
{
    if(alertView == cacheAView){
        alertView.frame = CGRectMake(100, alertView.top, 80, 400);
    }
}

#pragma mark MBHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    if(hud.tag == 1){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [tView reloadData];
    }
}

- (void)AfterDelayClearAllCacheData
{
    [self hideHUDInView:self.view];
    
    [cacheAView setTitle:[NSString stringWithFormat:@"%0.2fM",[HTTPRequest getFileCacheData]/1024.0/1024.0]];
    
    [cacheAView show];
    
    [self performSelector:@selector(hideCacheAView) withObject:nil afterDelay:1];

    [HTTPRequest clearAllFileCacheData];
}

- (void)hideCacheAView
{
    [cacheAView dismissWithClickedButtonIndex:0 animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
