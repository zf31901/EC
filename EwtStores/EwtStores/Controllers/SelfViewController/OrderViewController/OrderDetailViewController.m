//
//  OrderDetailViewController.m
//  Shop
//
//  Created by Jacob on 14-1-6.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "OrderDetailViewController.h"
#import "OrderDetailCell.h"
#import "ProductObj.h"
#import "OrderObj.h"
#import "ExchangeViewController.h"
#import "CartViewController.h"
#import "PXAlertView.h"
#import "UUPViewController.h"
#import "UnpayViewController.h"
#import "SelfViewController.h"

#import "HTTPRequest.h"
#import <QuartzCore/QuartzCore.h>
#import "AlipayViewController.h"

extern SelfViewController *selfVC;

@interface OrderDetailViewController ()
{
    UIView          *emptyView;
    UIView          *networkNotReachableView;
    CGFloat         tabBar_height;
    
    UIView          *footerBg;
    UIView          *orderView;
    UIView          *detailView;
    UIView          *moveView;
    UIButton        *imagebtn;
    UIButton        *subBt;
    
    NSDictionary    *payTypeDic;
    NSDictionary    *statusDic;
    NSDictionary    *deliveryDic;
}
@end

@implementation OrderDetailViewController

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
    
    tabBar_height = 0;
    [self hiddenRightBtn];
    [self setNavBarTitle:@"订单详情"];
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"type" ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    payTypeDic = [data objectForKey:@"payType"];
    statusDic = [data objectForKey:@"status"];
    deliveryDic = [data objectForKey:@"deliveryType"];
    
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //[self refreshNetwork];
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
    [emptyImgView setImage:[UIImage imageNamed:@"shopping-cart-empty-cart-icon"]];
    [emptyView addSubview:emptyImgView];
    
    UILabel *lb = [GlobalMethod BuildLableWithFrame:CGRectMake(50, 220, 220, 19)
                                           withFont:[UIFont systemFontOfSize:12]
                                           withText:@"空空如也，不如去逛逛吧！"];
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
    //[self.view addSubview:self.mainTableView];
    [self hiddenFooterView];
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

- (void)rightBtnAction:(UIButton *)btn{
    DLog(@"右侧按钮-取消订单");
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:@"取消订单"
                                  otherButtonTitles:nil,nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    [actionSheet showInView:self.view];
    
}

#pragma mark Delegate
#pragma mark UITableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderObj *obj = [[OrderObj alloc] initWithCoder:nil];
    [obj setProducts:_order.products];
    [GlobalMethod saveObject:obj withKey:ORDEROBJECT];

    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    static NSString *indifiter = @"order_product_cell";
    OrderDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:indifiter];
    if(!cell){
        cell = [[OrderDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indifiter];
    }
    
    //[cell set_delegate:self];
    [cell reuserTableViewCell:_order AtIndex:indexPath.row];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    //footerView
    footerBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Main_Size.width, 380)];
    [footerBg setBackgroundColor:[UIColor clearColor]];
    /*[footerBg setUserInteractionEnabled:YES];
    [moveView setClipsToBounds:YES];*/
    //[footerBg setAutoresizesSubviews:YES];
    //[footerBg setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [self.mainTableView setTableFooterView:footerBg];
    
    
    UILabel *msgLb = [GlobalMethod BuildLableWithFrame:CGRectMake(17, 0, 250, 30) withFont:[UIFont systemFontOfSize:13] withText:nil];
    [msgLb setTextColor:RGBS(180)];
    [msgLb setText:@"订单信息"];
    [footerBg addSubview:msgLb];
    
    UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, msgLb.bottom, 320, 4.5)];
    [headerView setImage:[UIImage imageNamed:@"dashed_border"]];
    [footerBg addSubview:headerView];
    
    orderView = [[UIView alloc] initWithFrame:CGRectMake(0, headerView.bottom, 320, 120)];
    [orderView setBackgroundColor:[UIColor whiteColor]];
    [footerBg addSubview:orderView];
    UILabel *receiverLb = [GlobalMethod BuildLableWithFrame:CGRectMake(msgLb.left, 5, 60, 30) withFont:[UIFont systemFontOfSize:14] withText:nil];
    [receiverLb setText:@"收货人"];
    [orderView addSubview:receiverLb];
    UILabel *receiver = [GlobalMethod BuildLableWithFrame:CGRectMake(receiverLb.right+10, 5, 300, 30) withFont:[UIFont systemFontOfSize:12] withText:nil];
    [receiver setText:_order.recName];
    [orderView addSubview:receiver];
    UIView *sepLine1 = [[UIView alloc] initWithFrame:CGRectMake(receiver.left, receiver.bottom + 5, 205, 0.5)];
    [sepLine1 setBackgroundColor:RGBS(202)];
    [orderView addSubview:sepLine1];
    
    UILabel *addressLb = [GlobalMethod BuildLableWithFrame:CGRectMake(msgLb.left, sepLine1.bottom + 5, 60, 30) withFont:[UIFont systemFontOfSize:14] withText:nil];
    [addressLb setText:@"地址"];
    [orderView addSubview:addressLb];
    UILabel *address = [GlobalMethod BuildLableWithFrame:CGRectMake(receiverLb.right+10, sepLine1.bottom + 5, 300, 30) withFont:[UIFont systemFontOfSize:12] withText:nil];
    [address setText:_order.recAddress];
    [orderView addSubview:address];
    UIView *sepLine2 = [[UIView alloc] initWithFrame:CGRectMake(receiver.left, address.bottom + 5, 205, 0.5)];
    [sepLine2 setBackgroundColor:RGBS(202)];
    [orderView addSubview:sepLine2];
    
    UILabel *detailLb = [GlobalMethod BuildLableWithFrame:CGRectMake(msgLb.left, sepLine2.bottom + 5, 60, 30) withFont:[UIFont systemFontOfSize:14] withText:nil];
    [detailLb setText:@"详细信息"];
    [orderView addSubview:detailLb];
    UIButton *detailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    detailBtn.frame = CGRectMake(receiverLb.right+10, sepLine2.bottom + 5, 300, 30);
    [detailBtn addTarget:self action:@selector(detailInAction:) forControlEvents:UIControlEventTouchUpInside];
    [orderView addSubview:detailBtn];
    imagebtn= [UIButton buttonWithType:UIButtonTypeCustom];
    imagebtn.frame = CGRectMake(190, 11, 14, 8);
    [imagebtn setBackgroundImage:[UIImage imageNamed:@"accsessory-arrow-down"] forState:UIControlStateNormal];
    [imagebtn addTarget:self action:@selector(detailInAction:) forControlEvents:UIControlEventTouchUpInside];
    [detailBtn addSubview:imagebtn];
    
    detailView = [[UIView alloc] initWithFrame:CGRectMake(0, orderView.bottom, 320, 200)];
    [detailView setBackgroundColor:[UIColor whiteColor]];
    [detailView setHidden:YES];
    [footerBg addSubview:detailView];
    UILabel *phoneLb = [GlobalMethod BuildLableWithFrame:CGRectMake(msgLb.left, 5, 100, 20) withFont:[UIFont systemFontOfSize:12] withText:@"手机号码"];
    [detailView addSubview:phoneLb];
    UILabel *phone = [GlobalMethod BuildLableWithFrame:CGRectMake(receiverLb.right+10, 5, 300, 20) withFont:[UIFont systemFontOfSize:13] withText:nil];
    [phone setText:_order.recMobile];
    [detailView addSubview:phone];                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
    
    UILabel *payTypeLb = [GlobalMethod BuildLableWithFrame:CGRectMake(msgLb.left, phone.bottom + 5, 100, 20) withFont:[UIFont systemFontOfSize:12] withText:@"支付方式"];
    [detailView addSubview:payTypeLb];
    UILabel *pay = [GlobalMethod BuildLableWithFrame:CGRectMake(receiverLb.right+10, phone.bottom + 5, 300, 20) withFont:[UIFont systemFontOfSize:13] withText:nil];
    [pay setText:[payTypeDic objectForKey:[NSString stringWithFormat:@"payType_%d",_order.payType]]];
    [detailView addSubview:pay];
    
    UILabel *deliveryLb = [GlobalMethod BuildLableWithFrame:CGRectMake(msgLb.left, pay.bottom + 5, 100, 20) withFont:[UIFont systemFontOfSize:12] withText:@"配送方式"];
    [detailView addSubview:deliveryLb];
    UILabel *delivery = [GlobalMethod BuildLableWithFrame:CGRectMake(receiverLb.right+10, pay.bottom + 5, 300, 20) withFont:[UIFont systemFontOfSize:13] withText:nil];
    [delivery setText:[deliveryDic objectForKey:[NSString stringWithFormat:@"deliveryType_%d",_order.deliverType]]];
    [detailView addSubview:delivery];
    UILabel *fare = [GlobalMethod BuildLableWithFrame:CGRectMake(receiverLb.right+10, delivery.bottom, 300, 20) withFont:[UIFont systemFontOfSize:13] withText:nil];
    [fare setText:[NSString stringWithFormat:@"运费：￥%.2f",_order.fare]];
    [detailView addSubview:fare];
    
    UILabel *invoiceLb = [GlobalMethod BuildLableWithFrame:CGRectMake(msgLb.left, fare.bottom + 5, 100, 20) withFont:[UIFont systemFontOfSize:12] withText:@"发票信息"];
    [detailView addSubview:invoiceLb];
    UILabel *invoiceType = [GlobalMethod BuildLableWithFrame:CGRectMake(receiverLb.right+10, fare.bottom + 5, 300, 20) withFont:[UIFont systemFontOfSize:13] withText:nil];
    [invoiceType setText:[NSString stringWithFormat:@"%@（类型）",_order.invoiceType]];
    [detailView addSubview:invoiceType];
    UILabel *invoiceHead = [GlobalMethod BuildLableWithFrame:CGRectMake(receiverLb.right+10, invoiceType.bottom, 300, 20) withFont:[UIFont systemFontOfSize:13] withText:nil];
    [invoiceHead setText:[NSString stringWithFormat:@"%@（抬头）",([_order.invoiceHead intValue]==1) ? @"个人" : @"单位"]];
    [detailView addSubview:invoiceHead];
    UILabel *invoinceContent = [GlobalMethod BuildLableWithFrame:CGRectMake(receiverLb.right+10, invoiceHead.bottom, 300, 20) withFont:[UIFont systemFontOfSize:13] withText:nil];
    [invoinceContent setText:[NSString stringWithFormat:@"%@（内容）",_order.invoinceContent]];
    [detailView addSubview:invoinceContent];
    
    UILabel *remarkLb = [GlobalMethod BuildLableWithFrame:CGRectMake(msgLb.left, invoinceContent.bottom + 5, 100, 20) withFont:[UIFont systemFontOfSize:12] withText:@"备注"];
    [detailView addSubview:remarkLb];
    UILabel *remark = [GlobalMethod BuildLableWithFrame:CGRectMake(receiverLb.right+10, invoinceContent.bottom + 5, 300, 20) withFont:[UIFont systemFontOfSize:13] withText:nil];
    if ([_order.remark isEqualToString:@"null"]) {
        [remark setText:@""];
    } else {
        [remark setText:_order.remark];
    }
    [detailView addSubview:remark];
    
    moveView = [[UIView alloc] initWithFrame:CGRectMake(0, orderView.bottom, 320, 150)];
    [moveView setBackgroundColor:[UIColor whiteColor]];
    /*[moveView setUserInteractionEnabled:YES];
    [moveView setClipsToBounds:YES];*/
    [footerBg addSubview:moveView];
    
    UIView *space = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
    [space setBackgroundColor:RGBS(238)];
    [moveView addSubview:space];
    
    UIView *payView = [[UIView alloc] initWithFrame:CGRectMake(0, space.bottom, 320, 40)];
    [payView setBackgroundColor:[UIColor whiteColor]];
    [moveView addSubview:payView];
    UILabel *payLb = [GlobalMethod BuildLableWithFrame:CGRectMake(msgLb.left, 5, 60, 30) withFont:[UIFont systemFontOfSize:14] withText:nil];
    [payLb setText:@"支付方式"];
    [payView addSubview:payLb];
    UILabel *payType = [GlobalMethod BuildLableWithFrame:CGRectMake(receiverLb.right+10, 5, 300, 30) withFont:[UIFont systemFontOfSize:12] withText:nil];
    if (_order.status == 20) {
        [payType setText:[payTypeDic objectForKey:@"payType_2"]];
    } else {
        [payType setText:[payTypeDic objectForKey:[NSString stringWithFormat:@"payType_%d",_order.payType]]];
    }
    [payView addSubview:payType];
    UIView *space2 = [[UIView alloc] initWithFrame:CGRectMake(0, payView.bottom, 320, 10)];
    [space2 setBackgroundColor:RGBS(238)];
    [moveView addSubview:space2];
    
    UIView *footerView1 = [[UIView alloc] initWithFrame:CGRectMake(0, space2.bottom, 320, 90)];
    [footerView1 setBackgroundColor:[UIColor whiteColor]];
    [moveView addSubview:footerView1];
    
    
    UILabel *nameLb = [GlobalMethod BuildLableWithFrame:CGRectMake(msgLb.left, 6, 150, 20)
                                               withFont:[UIFont systemFontOfSize:13]
                                               withText:[NSString stringWithFormat:@"商品总价：￥%.2f",_order.totalPrice]];
    [footerView1 addSubview:nameLb];
    
    UILabel *transLb = [GlobalMethod BuildLableWithFrame:CGRectMake(msgLb.left, nameLb.bottom + 5, 150, 20)
                                                withFont:[UIFont systemFontOfSize:12]
                                                withText:[NSString stringWithFormat:@"优惠券：￥%.2f",_order.couponAmount]];
    [footerView1 addSubview:transLb];
    
    UILabel *IntegrationLb = [GlobalMethod BuildLableWithFrame:CGRectMake(msgLb.left, transLb.bottom + 5, 150, 20)
                                                      withFont:[UIFont systemFontOfSize:12]
                                                      withText:[NSString stringWithFormat:@"礼品卡：￥%.2f",_order.giftsAmount]];
    [footerView1 addSubview:IntegrationLb];
    
    UILabel *priceLb = [GlobalMethod BuildLableWithFrame:CGRectMake(190, transLb.top, 50, 20) withFont:[UIFont systemFontOfSize:12] withText:@"合计：￥"];
    [footerView1 addSubview:priceLb];
    UILabel *price = [GlobalMethod BuildLableWithFrame:CGRectMake(240, transLb.top, 100, 20) withFont:[UIFont systemFontOfSize:14] withText:[NSString stringWithFormat:@"%.2f",_order.totalPayAmount]];
    [price setTextColor:[UIColor redColor]];
    [footerView1 addSubview:price];
    
    NSArray *statusArr = @[@"11",@"12",@"21",@"22",@"24",@"60",@"61"];
    /*if ([statusArr containsObject:[NSString stringWithFormat:@"%d", _order.status]]) {
        btnText = @"立即支付";
    }*/
    
    UIImage *img = [UIImage imageNamed:@"regist_next_on"];
    //img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(20, 27, 20, 27)];
    subBt = [GlobalMethod BuildButtonWithFrame:CGRectMake(2, moveView.bottom + 20, 296, 44) andOffImg:nil andOnImg:nil withTitle:@""];
    [subBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [subBt.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [subBt setBackgroundImage:img forState:UIControlStateNormal];
    [subBt setBackgroundImage:img forState:UIControlStateHighlighted];
    if (_order.status == 10) {
        [subBt setTitle:@"取消订单" forState:UIControlStateNormal];
        [subBt addTarget:self action:@selector(cancelOrder) forControlEvents:UIControlEventTouchUpInside];
        [footerBg addSubview:subBt];
    } else if (_order.status == 20) {
        [subBt setTitle:@"立即支付" forState:UIControlStateNormal];
        [subBt addTarget:self action:@selector(payOrder) forControlEvents:UIControlEventTouchUpInside];
        [footerBg addSubview:subBt];
        
        UIButton *rightBtn = [self getRightButton];
        [rightBtn setHidden:NO];
        [self setRightBtnOffImg:nil andOnImg:nil andTitle:@"更多"];
    } else if (_order.status == 80) {
        [subBt setTitle:@"重新购买" forState:UIControlStateNormal];
        [subBt addTarget:self action:@selector(buyAgain) forControlEvents:UIControlEventTouchUpInside];
        [footerBg addSubview:subBt];
    } else if ([statusArr containsObject:[NSString stringWithFormat:@"%d", _order.status]]) {
        DLog(@"配送中状态，无按钮");
    } else if (_order.status == 99) {
        [subBt setTitle:@"订单反馈" forState:UIControlStateNormal];
        [subBt addTarget:self action:@selector(returnOrder) forControlEvents:UIControlEventTouchUpInside];
        [footerBg addSubview:subBt];
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 314 + (_order.products.count - 1)*75;
}

- (void)detailInAction:(UIButton *)btn
{
    NSArray *statusArr = @[@"11",@"12",@"21",@"22",@"24",@"60",@"61"];
    
    [UIView animateWithDuration:0.3f animations:^{
        
        if (detailView.hidden) {
            [imagebtn setBackgroundImage:[UIImage imageNamed:@"accsessory-arrow-up"] forState:UIControlStateNormal];
            
            CGRect frame=footerBg.frame;
            frame.size.height+=200;
            [footerBg setFrame:frame];
            [self.mainTableView setTableFooterView:footerBg];
            if (![statusArr containsObject:[NSString stringWithFormat:@"%d", _order.status]] && _order.repType <= 0) {
                CGRect frame2=subBt.frame;
                frame2.origin.y+=200;
                [subBt setFrame:frame2];
                [footerBg addSubview:subBt];
            }
            
            
            [moveView setFrame:CGRectMake(0, detailView.bottom, 320, 0)];
            
            [detailView setHidden:NO];

            
        } else {
            [imagebtn setBackgroundImage:[UIImage imageNamed:@"accsessory-arrow-down"] forState:UIControlStateNormal];
            
            CGRect frame=footerBg.frame;
            frame.size.height-=200;
            [footerBg setFrame:frame];
            [self.mainTableView setTableFooterView:footerBg];
            
            [detailView setHidden:YES];
            [moveView setFrame:CGRectMake(0, orderView.bottom, 320, 0)];
            
            if (![statusArr containsObject:[NSString stringWithFormat:@"%d", _order.status]] && _order.repType  <= 0) {
                [subBt setFrame:CGRectMake(2, orderView.bottom + 170, 296, 44)];
            }
            
        }
        
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.3f animations:^{
            
        }];
    }];
}

- (void)cancelOrder
{
    DLog(@"取消订单");
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"确定要取消订单吗？"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定",nil];
    [alertView show];
}

- (void)payOrder
{
    DLog(@"立即支付");
    UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
    BLOCK_SELF(OrderDetailViewController);
    HTTPRequest *hq = [HTTPRequest shareInstance];
    NSDictionary *parameters = @{@"clientkey": user.clientkey, @"userlogin": user.im, @"orderserial": _order.orderId};
    [hq GETURLString:ORDER_REPAY parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObj) {
        NSDictionary *rqDic = (NSDictionary *)responseObj;
        if([rqDic[HTTP_STATE] boolValue]){
            NSDictionary *dic = (NSDictionary *)[rqDic[HTTP_DATA] objectFromJSONString];
            
            //跳至银联支付
//            UUPViewController *uupVC = [UUPViewController shareInstance];
//            [uupVC setTNString:dic[@"payserial"]];
//            [uupVC setOrderSerial:_order.orderId];
//            [self.navigationController pushViewController:uupVC animated:NO];
            
            //支付宝
            AlipayViewController *alipayVC = [[AlipayViewController alloc] init];
            alipayVC.alipayOrder.tradeNO = _order.orderId;
            alipayVC.alipayOrder.productName = _order.productNameList;
            alipayVC.alipayOrder.productDescription = @"爱心天地商品"; //商品描述
            alipayVC.alipayOrder.amount = [NSString stringWithFormat:@"%.2f",_order.totalPayAmount]; //商品价格
            [self.navigationController pushViewController:alipayVC animated:YES];
            
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

- (void)buyAgain
{
    DLog(@"重新购买");
    UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
    BLOCK_SELF(OrderDetailViewController);
    HTTPRequest *hq = [HTTPRequest shareInstance];
    NSDictionary *parameters = @{@"clientkey": user.clientkey, @"userlogin": user.im, @"orderserial": _order.orderId};
    
    [self showHUDInView:block_self.view WithText:@"重新下单中..."];
    
    [hq GETURLString:ORDER_TOSHOPCAR parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObj) {
        NSDictionary *rqDic = (NSDictionary *)responseObj;
        if([rqDic[HTTP_STATE] boolValue]){
            //NSDictionary *dic = (NSDictionary *)[rqDic[HTTP_DATA] objectFromJSONString];
            [self hideHUDInView:block_self.view];
            [self.navigationController popToRootViewControllerAnimated:NO];
            //跳转至购物车
            [MYAPPDELEGATE.tabBarC setSelectedIndex:2];
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
    
    //跳转至购物车
    /*CartViewController *cartVC = [CartViewController shareInstance];
    [self.navigationController pushViewController:cartVC animated:YES];
    [MYAPPDELEGATE.tabBarC setSelectedIndex:2];*/
    /*CartViewController *cartVC = [CartViewController shareInstance];
    [cartVC setIsRootNavC:NO];
    [self.navigationController pushViewController:cartVC animated:YES];*/
}

- (void)returnOrder
{
    DLog(@"退货/换货");
    ExchangeViewController *exchangeVC = [ExchangeViewController shareInstance];
    exchangeVC.order = _order;
    [self.navigationController pushViewController:exchangeVC animated:YES];
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == alertView.cancelButtonIndex){
        DLog(@"取消");
    }else{
        DLog(@"确定取消订单");
        
        [MobClick event:QXDD];
        UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
        NSDictionary *parameters = @{@"userlogin": user.im, @"orderserial": _order.orderId};
        BLOCK_SELF(OrderDetailViewController);
        HTTPRequest *hq = [HTTPRequest shareInstance];
        
        [hq GETURLString:ORDER_CANCEL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObj) {
            NSDictionary *rqDic = (NSDictionary *)responseObj;
            if([rqDic[HTTP_STATE] boolValue]){
                [self showHUDInView:block_self.view WithText:@"取消订单成功" andDelay:LOADING_TIME];
                //[self leftBtnAction:nil];
                //从堆栈中移除ViewController
//                for (int i = 0; i < 2; i++) {
//                    [selfVC.navigationController popViewControllerAnimated:NO];
//                }
                [self.navigationController popViewControllerAnimated:NO];
                
                UnpayViewController *unpayVC = [UnpayViewController shareInstance];
                [unpayVC setHidesBottomBarWhenPushed:YES];
                
                [selfVC.navigationController pushViewController:unpayVC animated:YES];
                
                
            }else{
                NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
                [self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
                [self.navigationController popViewControllerAnimated:YES];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@ , %@",operation,error);
            [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
        }];

    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self cancelOrder];
    }
    
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
