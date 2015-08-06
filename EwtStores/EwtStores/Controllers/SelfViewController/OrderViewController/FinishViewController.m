//
//  FinishViewController.m
//  Shop
//
//  Created by Jacob on 14-1-6.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "FinishViewController.h"
#import "UserObj.h"
#import "LoginInViewController.h"
#import "OrderCell.h"
#import "ProductObj.h"
#import "OrderDetailViewController.h"
#import "OrderObj.h"

#import "HTTPRequest.h"
#import <QuartzCore/QuartzCore.h>

@interface FinishViewController ()
{
    UIView          *emptyView;
    
    UIView          *networkNotReachableView;
    
    CGFloat         tabBar_height;
    
    NSMutableArray  *cartProArr;
    NSInteger       removeProductAtIndex;
    
    NSInteger       cureentPage;            //第几页数据
}
@end

@implementation FinishViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.isRootNavC = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if(self.isRootNavC){
        [self hiddenLeftBtn];
        tabBar_height = Tabbar_Height;
    }else{
        tabBar_height = 0;
    }
    [self hiddenRightBtn];
    [self setNavBarTitle:@"已完成订单"];
    
    [self loadDataSource];
    
    /*switch ([HTTPRequest getNetworkStatus])
     {
     case NotReachable:
     {
     [self buildNetworkView];
     }
     break;
     
     default:
     {
     [self resetMainTableView];
     //[self buildCartEmptyView];
     }
     break;
     }*/
    [self resetMainTableView];
    
    [MobClick event:YWC];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //[self refreshNetwork];
}

- (void)loadDataSource
{
    cartProArr = [NSMutableArray arrayWithCapacity:2];
    [self showHUDInView:self.view WithText:NETWORKLOADING];
    [self getDataSourceByNetwork:REQUEST_REFRSH];
    
}

- (void)getDataSourceByNetwork:(REQUEST_STATUS)status
{
    if(status == REQUEST_REFRSH){   //刷新
        [cartProArr removeAllObjects];
        cureentPage = 1;
        self.hasMore = YES;
    }else{                          //追加
        if(self.hasMore){
            cureentPage ++;
        }else{
            [self showHUDInView:self.view WithText:@"全部加载完毕" andDelay:1];
            [self finishReloadingData];
            return ;
        }
    }
    
    BLOCK_SELF(FinishViewController);
    HTTPRequest *hq = [HTTPRequest shareInstance];
    UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:4];
    [dic setObject:[NSString stringWithFormat:@"%d",cureentPage] forKey:@"page"];
    [dic setObject:@"10" forKey:@"pagesize"];
    [dic setObject:user.im forKey:@"u"];
    [dic setObject:@"9" forKey:@"type"]; //待付款
    
    
    [hq GETURLString:ORDER_LIST userCache:NO parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObj) {
        NSDictionary *rqDic = (NSDictionary *)responseObj;
        if([rqDic[HTTP_STATE] boolValue]){
            NSArray *dataArr = (NSArray *)[rqDic[HTTP_DATA] objectFromJSONString];
            for(int i=0; i<dataArr.count; i++){
                NSDictionary *dic = (NSDictionary *)dataArr[i];
                
                OrderObj *obj = [OrderObj shareInstance];
                [obj setOrderId:dic[@"UO_OrderSerial"]];
                [obj setOrderTime:dic[@"UO_SuccessTime"]];
                [obj setDeliverType:[dic[@"UO_DeliveryType"] intValue]];
                [obj setStatus:[dic[@"UO_Status"] intValue]];
                [obj setRecName:dic[@"UO_RecName"]];
                [obj setRecAddress:dic[@"UO_RecAddress"]];
                [obj setRecMobile:dic[@"UO_RecMobile"]];
                [obj setPayType:[dic[@"UO_PayType"] intValue]];
                [obj setTotalPrice:[dic[@"UO_ProductAmount"] floatValue]];
                [obj setCouponAmount:[dic[@"UO_CouponAmount"] floatValue]];
                [obj setGiftsAmount:[dic[@"UO_GiftsAmount"] floatValue]];
                [obj setTotalPayAmount:[dic[@"UO_TotalPayAmount"] floatValue]];
                [obj setFare:[dic[@"UO_Fare"] floatValue]];
                [obj setInvoiceType:dic[@"UO_InvoiceType"]];
                [obj setInvoiceHead:dic[@"UO_InvoiceHead"]];
                [obj setInvoinceContent:dic[@"UO_InvoinceContent"]];
                [obj setRemark:dic[@"UO_Remark"]];
                //给订单添加商品
                //[obj setProducts:[self addProducts:dic[@"UO_OrderSerial"]]];
                NSArray *proArr = (NSArray *)[dic[@"UO_ProductJsonData"] objectFromJSONString];
                NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:1];
                for(int j=0; j<proArr.count; j++){
                    NSDictionary *proDic = (NSDictionary *)proArr[j];
                    ProductObj *proObj = [ProductObj shareInstance];
                    [proObj setName:proDic[@"Name"]];
                    [proObj setNumber:proDic[@"Quantity"]];
                    [proObj setSalePrice:proDic[@"Price"]];
                    [proObj setImgUrl:[NSURL URLWithString:proDic[@"Pic"]]];
                    [tempArr addObject:proObj];
                }
                [obj setProducts:tempArr];
                
                [cartProArr addObject:obj];
            }
            
            if(dataArr.count == 0 && cureentPage == 1){
                [self buildCartEmptyView];
            }else{
                [emptyView removeFromSuperview];
            }
            
            //数据解析有误处理
            if([dataArr isKindOfClass:[NSNull class]]){
                
                [self finishReloadingData];
                [self hideHUDInView:block_self.view];
                
                if([self.noResultView superview] == nil){
                    [self buildNoResult];
                }
                
                [block_self.view bringSubviewToFront:block_self.noResultView];
                
                return ;
            }
            
            //最后一次请求数据少于 10 表示加载完全 （10个订单为一个page）
            if(([dataArr isKindOfClass:[NSNull class]]) || dataArr.count < 10){
                self.hasMore = NO;
            }
            [self.mainTableView reloadData];
            [self finishReloadingData];
            [self hideHUDInView:block_self.view];
            
        }else{
            NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
            [self hideHUDInView:block_self.view];
            [self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
            [self finishReloadingData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@ , %@",operation,error);
        [self hideHUDInView:block_self.view];
        [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
        [self finishReloadingData];
    }];
    
}

//查询订单中所含商品
- (NSMutableArray *)addProducts:(NSString *)orderId
{
    BLOCK_SELF(FinishViewController);
    HTTPRequest *hq = [HTTPRequest shareInstance];
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:1];
    NSDictionary *parameters = @{@"orderserial": @"1312040000001178"};
    [hq GETURLString:ORDER_PRODUCT parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObj) {
        DLog(@"come in");
        NSDictionary *rqDic = (NSDictionary *)responseObj;
        if([rqDic[HTTP_STATE] boolValue]){
            NSArray *dataArr = (NSArray *)[rqDic[HTTP_DATA] objectFromJSONString];
            for(int j=0; j<dataArr.count; j++){
                NSDictionary *dic = (NSDictionary *)dataArr[j];
                
                ProductObj *proObj = [ProductObj shareInstance];
                [proObj setName:dic[@"Name"]];
                [proObj setNumber:dic[@"Quantity"]];
                [proObj setSalePrice:dic[@"Price"]];
                [proObj setImgUrl:[NSURL URLWithString:dic[@"Pic"]]];
                
                [tempArr addObject:proObj];
            }
            
            //数据解析有误处理
            if([dataArr isKindOfClass:[NSNull class]]){
                
                [self finishReloadingData];
                [self hideHUDInView:block_self.view];
                
                if([self.noResultView superview] == nil){
                    [self buildNoResult];
                }
                
                [block_self.view bringSubviewToFront:block_self.noResultView];
                
                [[self getRightButton] setEnabled:NO];
                
                return ;
            }
        }else{
            NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
            [self hideHUDInView:block_self.view];
            [self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
            [self finishReloadingData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@ , %@",operation,error);
        [self hideHUDInView:block_self.view];
        [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
        [self finishReloadingData];
    }];
    return tempArr;
}

- (void)buildNetworkView
{
    networkNotReachableView = [[UIView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(0, Navbar_Height, Main_Size.width, Main_Size.height - StatusBar_Height - Navbar_Height - Tabbar_Height)]];
    [networkNotReachableView setBackgroundColor:RGBS(238)];
    [self.view addSubview:networkNotReachableView];
    [self.view bringSubviewToFront:networkNotReachableView];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(115, 100, 90, 80)];
    [imgView setImage:[UIImage imageNamed:@"wifi"]];
    [networkNotReachableView addSubview:imgView];
    
    UILabel *lb = [GlobalMethod BuildLableWithFrame:CGRectMake(50, 210, 220, 19)
                                           withFont:[UIFont systemFontOfSize:12]
                                           withText:@"网速不给力啊，请检查下网络吧！"];
    [lb setTextColor:RGBS(102)];
    [lb setTextAlignment:NSTextAlignmentCenter];
    [networkNotReachableView addSubview:lb];
    
    UIButton *comeToHomeBt = [GlobalMethod BuildButtonWithFrame:CGRectMake(110, 255, 100, 30)
                                                      andOffImg:nil
                                                       andOnImg:nil
                                                      withTitle:@"刷新"];
    [comeToHomeBt addTarget:self action:@selector(refreshNetwork) forControlEvents:UIControlEventTouchUpInside];
    [comeToHomeBt setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [comeToHomeBt.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [comeToHomeBt setTitleColor:RGBS(51) forState:UIControlStateNormal];
    [comeToHomeBt.layer setCornerRadius:5];
    [comeToHomeBt.layer setBorderColor:RGBS(102).CGColor];
    [comeToHomeBt.layer setMasksToBounds:YES];
    [comeToHomeBt.layer setBorderWidth:0.5];
    [networkNotReachableView addSubview:comeToHomeBt];
}

- (void)buildCartEmptyView
{
    emptyView = [[UIView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(0, Navbar_Height, Main_Size.width, Main_Size.height - StatusBar_Height - Navbar_Height - Tabbar_Height)]];
    [emptyView setBackgroundColor:RGBS(238)];
    [self.view addSubview:emptyView];
    
    UIImageView *emptyImgView = [[UIImageView alloc] initWithFrame:CGRectMake(115, 100, 90, 90)];
    [emptyImgView setImage:[UIImage imageNamed:@"notepad"]];
    [emptyView addSubview:emptyImgView];
    
    UILabel *lb = [GlobalMethod BuildLableWithFrame:CGRectMake(50, 220, 220, 19)
                                           withFont:[UIFont systemFontOfSize:12]
                                           withText:@"没有已完成的订单！"];
    [lb setTextColor:RGBS(102)];
    [lb setTextAlignment:NSTextAlignmentCenter];
    [emptyView addSubview:lb];
    
    UIButton *comeToHomeBt = [GlobalMethod BuildButtonWithFrame:CGRectMake(110, 265, 100, 30)
                                                      andOffImg:nil
                                                       andOnImg:nil
                                                      withTitle:@"去首页逛逛"];
    [comeToHomeBt addTarget:self action:@selector(comeToHome) forControlEvents:UIControlEventTouchUpInside];
    [comeToHomeBt setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [comeToHomeBt.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [comeToHomeBt setTitleColor:RGBS(51) forState:UIControlStateNormal];
    [comeToHomeBt.layer setCornerRadius:5];
    [comeToHomeBt.layer setBorderColor:RGBS(102).CGColor];
    [comeToHomeBt.layer setMasksToBounds:YES];
    [comeToHomeBt.layer setBorderWidth:0.5];
    [emptyView addSubview:comeToHomeBt];
}

- (void)resetMainTableView
{
    
    [self.mainTableView setFrame:CGRectMake(10,StatusBar_Height + Navbar_Height, 300, Main_Size.height - StatusBar_Height - Navbar_Height - tabBar_height)];
    [self.mainTableView setShowsVerticalScrollIndicator:NO];
    
    [self.mainTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:self.mainTableView];
    //[self hiddenFooterView];
}

- (void)refreshNetwork
{
    if([HTTPRequest getNetworkStatus]){
        if([emptyView superview]){
            [self.view bringSubviewToFront:emptyView];
        }else{
            [self buildCartEmptyView];
        }
    }else{
        if([networkNotReachableView superview]){
            [self.view bringSubviewToFront:networkNotReachableView];
        }else{
            [self buildNetworkView];
        }
    }
}

#pragma mark Delegate
#pragma mark UITableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return cartProArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderObj *order = cartProArr[indexPath.row];
    OrderObj *obj = [[OrderObj alloc] initWithCoder:nil];
    [obj setProducts:order.products];
    [GlobalMethod saveObject:obj withKey:ORDEROBJECT];
    
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    NSString *indifiter = [NSString stringWithFormat:@"finish_order_cell%d",indexPath.row];
    OrderCell *cell = [tableView dequeueReusableCellWithIdentifier:indifiter];
    if(!cell){
        cell = [[OrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indifiter];
    }
    
    //[cell set_delegate:self];
    [cell reuserTableViewCell:cartProArr[indexPath.row] AtIndex:indexPath.row];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderObj *order = cartProArr[indexPath.row];
    return 200 + (order.products.count - 1)*75;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderDetailViewController *orderDetailVC = [OrderDetailViewController shareInstance];
    orderDetailVC.order = cartProArr[indexPath.row];
    [orderDetailVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:orderDetailVC animated:YES];
}

- (void)reloadData {
    [self refreshView];
    
}

#pragma mark EgoTableView Method
- (void)refreshView
{
    [self getDataSourceByNetwork:REQUEST_REFRSH];
}

- (void)getNextPageView
{
    [self getDataSourceByNetwork:REQUEST_GETMORE];
}

- (void)comeToHome
{
    [MYAPPDELEGATE.tabBarC setSelectedIndex:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
