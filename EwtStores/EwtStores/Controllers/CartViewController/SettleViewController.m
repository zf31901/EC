//
//  SettleViewController.m
//  Shop
//
//  Created by Harry on 14-1-3.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "SettleViewController.h"
#import "CartViewController.h"
#import "AddressManageViewController.h"
#import "PaymentViewController.h"
#import "DelivementViewController.h"
#import "BillInfoViewController.h"
#import "CouponViewController.h"
#import "AddressDetailViewController.h"
#import "UnpayViewController.h"
#import "SelfViewController.h"
#import "AddressObj.h"
#import "ProductObj.h"

#import <QuartzCore/QuartzCore.h>

#import "UUPViewController.h"
#import "AlipayViewController.h"

SettleViewController *settleVC;

extern SelfViewController *selfVC;
extern CartViewController *cartVC;

@interface SettleViewController ()
{
    UITableView *tView;
    AddressObj  *selectAddress;
    
    UILabel     *paymentLb;     //支付方式
    UILabel     *devideLb;      //运输方式
    UILabel     *billTitleLb;   //发票抬头
    UILabel     *billContentLb; //发票内容
    
    UIView      *headerBg;
    UILabel     *userNameLb;
    UILabel     *phoneLb;
    UILabel     *areaLb;
    UILabel     *detailLb;
    
    UITextField *remarkTF;
    
    float       totalPrice;
    UILabel     *totalPriceLb;
    UILabel     *priceLb3;      //优惠券lb
    UILabel     *couponeLb;     //优惠券cell上的lb
    UILabel     *priceLb2;    //运输费lb
    
    BOOL        hasDefaultAddress;      //是否有默认地址
}

@end

@implementation SettleViewController

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
    
    [self setNavBarTitle:@"结算"];
    [self hiddenRightBtn];
    
    self.purchaseType = @"货到付款";    //默认为 货到付款
    self.billTitle = @"个人";
    self.billContent = @"明细";
    self.billId = @"";
    self.shouldNotif = @"1";
    self.UOFreight = 0.00;
    
    [self buildBaseView];
    
    //设置默认的支付方式： 货到付款
    [self setDefaultPayment];
    
    settleVC = self;
    
    couponeLb = [GlobalMethod BuildLableWithFrame:CGRectMake(180, 14, 100, 15)
                                         withFont:[UIFont systemFontOfSize:14]
                                         withText:nil];
    [couponeLb setTextAlignment:NSTextAlignmentRight];
    [couponeLb setTextColor:[UIColor redColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    hasDefaultAddress = NO;
    
    [self loadDataSource];
    
    [MobClick event:SPJS];
    
    if(self.couponPrice.floatValue != 0){
        [couponeLb setText:[NSString stringWithFormat:@"¥ %0.2f 元",self.couponPrice.floatValue]];
    }
    [priceLb3 setText:[NSString stringWithFormat:@"- ¥ %0.2f 元",self.couponPrice.floatValue]];
    [totalPriceLb setText:[NSString stringWithFormat:@"%0.2f 元",totalPrice - self.couponPrice.floatValue + self.UOFreight]];
}

- (void)leftBtnAction:(UIButton *)btn{
    cartVC.isSubmitSuccess = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadDataSource
{
    UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
    
    selectAddress = nil;
    
    [self showHUDInView:self.view WithText:NETWORKLOADING];
    HTTPRequest *hq = [HTTPRequest shareInstance];
    BLOCK_SELF(SettleViewController);
    NSMutableString *submitString = [NSMutableString new];
    for (int i=0; i<self.productObjArr.count; i++) {
        ProductObj *obj = self.productObjArr[i];
        if (i == 0) {
            [submitString appendFormat:@"%d",obj.productId.intValue];
        }else{
            [submitString appendFormat:@",%d",obj.productId.intValue];
        }
    }
    NSDictionary *dic = @{@"userlogin" : user.im?user.im:@"",@"productid":submitString};
    [hq GETURLString:ADDRESS_LIST userCache:NO parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObj) {
        NSDictionary *rqDic = (NSDictionary *)responseObj;
        if([rqDic[HTTP_STATE] boolValue]){
            
            NSArray *dataArr = (NSArray *)[rqDic[HTTP_DATA] objectFromJSONString];
            
            if(dataArr.count > 0){
                
                [tView setTableHeaderView:headerBg];
                
                for (int i=0; i<dataArr.count; i++) {
                    NSDictionary *dic = (NSDictionary *)dataArr[i];
                    
                    if([dic[@"URA_IsDefault"] boolValue]){
                        selectAddress = [AddressObj shareInstance];
                        [selectAddress setAddressId:dic[@"URA_Id"]];
                        [selectAddress setAddressName:dic[@"URA_RecName"]];
                        [selectAddress setAddressArea:[NSString stringWithFormat:@"%@ %@ %@",dic[@"URA_Province"],dic[@"URA_City"],dic[@"URA_Area"]]];
                        [selectAddress setAddressDetail:dic[@"URA_Address"]];
                        [selectAddress setEmail:dic[@"URA_Email"]];
                        [selectAddress setPostalCode:dic[@"URA_Post"]];
                        [selectAddress setPhoneNum:dic[@"URA_Mobile"]];
                        [selectAddress setIsChoiceAddress:[dic[@"URA_IsDefault"] boolValue]];
                        [self setUOFreight:[dic[@"URA_Freight"] floatValue]];
                        
                        [userNameLb setText:[NSString stringWithFormat:@"收件人  %@",selectAddress.addressName]];
                        [phoneLb setText:selectAddress.phoneNum];
                        [areaLb setText:selectAddress.addressArea];
                        [detailLb setText:selectAddress.addressDetail];
                        
                        [priceLb2 setText:[NSString stringWithFormat:@"+ ¥ %0.2f元",self.UOFreight]];
                        [totalPriceLb setText:[NSString stringWithFormat:@"%0.2f 元",totalPrice - self.couponPrice.floatValue + self.UOFreight]];
                        hasDefaultAddress = YES;
                    }
                }
                
                [tView reloadData];
                
                if (hasDefaultAddress == NO) {
                    [tView setTableHeaderView:nil];
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                        message:@"您还没有选择默认收货地址，是否立即选择？"
                                                                       delegate:self
                                                              cancelButtonTitle:nil
                                                              otherButtonTitles:@"前去选择", nil];
                    alertView.tag = 0xffff;
                    [alertView show];
                }

            }else{
                DLog(@"无地址");
                
                [tView setTableHeaderView:nil];
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                    message:@"您还没有收货地址，是否立即新建？"
                                                                   delegate:self
                                                          cancelButtonTitle:@"取消"
                                                          otherButtonTitles:@"新建地址", nil];
                alertView.tag = 1003;
                [alertView show];
            }

            [self hideHUDInView:block_self.view];
            
        }else{
            NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
            [self hideHUDInView:block_self.view];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                message:@"您还没有收货地址，是否立即新建？"
                                                               delegate:self
                                                      cancelButtonTitle:@"取消"
                                                      otherButtonTitles:@"新建地址", nil];
            alertView.tag = 1003;
            [alertView show];

            //[self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self hideHUDInView:block_self.view];
        [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
    }];
}

- (void)buildBaseView
{
    tView = [[UITableView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(0, Navbar_Height, Main_Size.width, Main_Size.height - StatusBar_Height - Navbar_Height)] style:UITableViewStyleGrouped];
    [tView setDataSource:self];
    [tView setDelegate:self];
    [tView setBackgroundView:nil];
    [tView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:tView];
    
    //headerView
    
    headerBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Main_Size.width, 140)];
    [tView setTableHeaderView:headerBg];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToAddressManage)];
    [headerBg addGestureRecognizer:tap];
    
    UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(8.5, 15, 303, 113)];
    [headerView setImage:[UIImage imageNamed:@"shopping-checkout-cont-bg"]];
    [headerBg addSubview:headerView];
    userNameLb = [GlobalMethod BuildLableWithFrame:CGRectMake(10, 16, 150, 30)
                                                   withFont:[UIFont systemFontOfSize:14]
                                          withText:[NSString stringWithFormat:@"收件人  %@",selectAddress.addressName?selectAddress.addressName:@"无"]];
    [headerView addSubview:userNameLb];
    
    UIImageView *phoneImgView = [[UIImageView alloc] initWithFrame:CGRectMake(userNameLb.right + 10, 25, 12, 13)];
    [phoneImgView setImage:[UIImage imageNamed:@"shopping-checkout-phone-icon"]];
    [headerView addSubview:phoneImgView];
    phoneLb = [GlobalMethod BuildLableWithFrame:CGRectMake(phoneImgView.right + 10, 16, 100, 30)
                                                 withFont:[UIFont systemFontOfSize:12]
                                                 withText:selectAddress.phoneNum];
    [headerView addSubview:phoneLb];
    
    areaLb = [GlobalMethod BuildLableWithFrame:CGRectMake(10, userNameLb.bottom + 12, 200, 20)
                                               withFont:[UIFont systemFontOfSize:12]
                                               withText:selectAddress.addressArea];
    [headerView addSubview:areaLb];
    
    detailLb = [GlobalMethod BuildLableWithFrame:CGRectMake(10, areaLb.bottom + 4, 200, 20)
                                                withFont:[UIFont systemFontOfSize:12]
                                                withText:selectAddress.addressDetail];
    [headerView addSubview:detailLb];
    
    
    //footerView
    UIView *footerBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Main_Size.width, 350)];
    
    UIImageView *tfBg = [[UIImageView alloc] initWithFrame:CGRectMake(6, 0, 304, 44)];
    [tfBg setImage:[UIImage imageNamed:@"input_bg"]];
    [tfBg setUserInteractionEnabled:YES];
    [footerBg addSubview:tfBg];
    
    remarkTF = [GlobalMethod BuildTextFieldWithFrame:CGRectMake(4, 2, 296, 40)
                                                   andPlaceholder:@"给订单备注，不要超过50字数哦！"];
    [remarkTF setReturnKeyType:UIReturnKeyDone];
    [remarkTF setDelegate:self];
    [remarkTF setFont:[UIFont systemFontOfSize:12]];
    [remarkTF setTextColor:RGBS(180)];
    [remarkTF setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 40)];
    [remarkTF setLeftView:leftView];
    [remarkTF setLeftViewMode:UITextFieldViewModeAlways];
    [tfBg addSubview:remarkTF];
    
    UIImage *f1 = [UIImage imageNamed:@"shopping-checkout-body-bg"];
    f1 = [f1 resizableImageWithCapInsets:UIEdgeInsetsMake(37.5, 157, 37.5, 157)];
    UIImageView *footerView1 = [[UIImageView alloc] initWithFrame:CGRectMake(3, remarkTF.bottom + 10, 314, 180)];
    [footerView1 setImage:f1];
    [footerBg addSubview:footerView1];
    
    UILabel *l1 = [GlobalMethod BuildLableWithFrame:CGRectMake(10, 10, 100, 13)
                                           withFont:[UIFont boldSystemFontOfSize:12]
                                           withText:@"订单明细"];
    [footerView1 addSubview:l1];
    
    float height = 20;
    totalPrice = 0;
    
    for(int i=0; i<self.productObjArr.count; i++){
        ProductObj *obj = (ProductObj *)self.productObjArr[i];
        
        UILabel *nameLb = [GlobalMethod BuildLableWithFrame:CGRectMake(10, height + 6, 160, 13)
                                                   withFont:[UIFont systemFontOfSize:12]
                                                   withText:[NSString stringWithFormat:@"%@  X%@",obj.name,obj.number]];
        [nameLb setLineBreakMode:NSLineBreakByTruncatingMiddle];
        [nameLb setNumberOfLines:1];
        [footerView1 addSubview:nameLb];
        
        UILabel *priceLb = [GlobalMethod BuildLableWithFrame:CGRectMake(nameLb.right + 10, nameLb.top, 120, 13)
                                                    withFont:[UIFont systemFontOfSize:12]
                                                    withText:[NSString stringWithFormat:@"¥%0.2f元",[obj.salePrice floatValue] * [obj.number floatValue]]];
        [priceLb setTextAlignment:NSTextAlignmentRight];
        [priceLb setTextColor:[UIColor redColor]];
        [footerView1 addSubview:priceLb];
        
        height = nameLb.bottom;
        totalPrice += [obj.salePrice floatValue] * [obj.number floatValue];
    }
    
    
    //priceLb.bottom
    UILabel *transLb = [GlobalMethod BuildLableWithFrame:CGRectMake(10, height + 5, 100, 13)
                                                withFont:[UIFont systemFontOfSize:12]
                                                withText:@"运输费"];
    [footerView1 addSubview:transLb];
    
    priceLb2 = [GlobalMethod BuildLableWithFrame:CGRectMake(transLb.right + 10, transLb.top, 180, 13)
                                                 withFont:[UIFont systemFontOfSize:12]
                                                 withText:[NSString stringWithFormat:@"+ ¥ %0.2f元",self.UOFreight]];
    [priceLb2 setTextAlignment:NSTextAlignmentRight];
    [priceLb2 setTextColor:[UIColor redColor]];
    [footerView1 addSubview:priceLb2];
    
    UILabel *IntegrationLb = [GlobalMethod BuildLableWithFrame:CGRectMake(10, transLb.bottom + 5, 100, 13)
                                                      withFont:[UIFont systemFontOfSize:12]
                                                      withText:@"优惠券"];
    [footerView1 addSubview:IntegrationLb];
    
    priceLb3 = [GlobalMethod BuildLableWithFrame:CGRectMake(IntegrationLb.right + 10, IntegrationLb.top, 180, 13) withFont:[UIFont systemFontOfSize:12] withText:@"- ¥ 0.0元"];
    [priceLb3 setTextColor:[UIColor redColor]];
    [priceLb3 setTextAlignment:NSTextAlignmentRight];
    [footerView1 addSubview:priceLb3];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(8, IntegrationLb.bottom + 5, 298, 2)];
    [line setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"shopping-cart-body-dotted-line"]]];
    [footerView1 addSubview:line];
    
    [footerView1 setFrame:CGRectMake(3, remarkTF.bottom + 10, 314, line.bottom)];
    
    UIImage *f2 = [UIImage imageNamed:@"shopping-checkout-body-bg-sm"];
    f2 = [f2 resizableImageWithCapInsets:UIEdgeInsetsMake(17.5, 157, 17.5, 157)];
    UIImageView *footerView2 = [[UIImageView alloc] initWithFrame:CGRectMake(3, footerView1.bottom, 314, 100)];
    [footerView2 setUserInteractionEnabled:YES];
    [footerView2 setImage:f2];
    [footerBg addSubview:footerView2];
    
    UILabel *ll = [GlobalMethod BuildLableWithFrame:CGRectMake(10, 15, 50, 13)
                                           withFont:[UIFont systemFontOfSize:12]
                                           withText:@"总额"];
    [footerView2 addSubview:ll];
    
    totalPriceLb = [GlobalMethod BuildLableWithFrame:CGRectMake(ll.right + 10, 13, 100, 15)
                                                     withFont:[UIFont systemFontOfSize:14]
                                                     withText:[NSString stringWithFormat:@"%0.2f 元",totalPrice]];
    [totalPriceLb setTextColor:[UIColor redColor]];
    [footerView2 addSubview:totalPriceLb];

    UIButton *subBt = [GlobalMethod BuildButtonWithFrame:CGRectMake(12, totalPriceLb.top + 28, 290, 44)
                                               andOffImg:@"regist_next_off"
                                                andOnImg:@"regist_next_on"
                                               withTitle:@"提交订单"];
    [subBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [subBt.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [subBt addTarget:self action:@selector(submitOrder) forControlEvents:UIControlEventTouchUpInside];
    [footerView2 addSubview:subBt];
    
    [footerBg setFrame:CGRectMake(0, 0, Main_Size.width, footerView1.height + footerView2.height + 100)];
    [tView setTableFooterView:footerBg];
}

#pragma mark
#pragma mark UItableView methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 3;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"settle_cell";
    UITableViewCell *cell = cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];

    if(indexPath.section == 1){
        UILabel *lb = [GlobalMethod BuildLableWithFrame:CGRectMake(10, 14, 60, 15)
                                               withFont:[UIFont systemFontOfSize:14]
                                               withText:@"优惠券"];
        [lb setTextColor:RGBS(51)];
        [cell.contentView addSubview:lb];
        
        [cell.contentView addSubview:couponeLb];
        
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }
    
    switch (indexPath.row) {
        case 0:
        {
            UILabel *lb = [GlobalMethod BuildLableWithFrame:CGRectMake(10, 14, 60, 15)
                                                   withFont:[UIFont systemFontOfSize:14]
                                                   withText:@"支付方式"];
            [lb setTextColor:RGBS(51)];
            [cell.contentView addSubview:lb];
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(lb.right + 8, 14, 24, 15)];
            [imgView setImage:[UIImage imageNamed:@"icon-necessary"]];
            [cell.contentView addSubview:imgView];
            
            paymentLb = [GlobalMethod BuildLableWithFrame:CGRectMake(120, 14, 140, 15)
                                                 withFont:[UIFont systemFontOfSize:14]
                                                 withText:self.purchaseType];
            [paymentLb setTextColor:RGBS(180)];
            [cell.contentView addSubview:paymentLb];
        }
            break;
            
        case 1:
        {
            UILabel *lb = [GlobalMethod BuildLableWithFrame:CGRectMake(10, 14, 60, 15)
                                                   withFont:[UIFont systemFontOfSize:14]
                                                   withText:@"配送方式"];
            [lb setTextColor:RGBS(51)];
            [cell.contentView addSubview:lb];
            
            devideLb = [GlobalMethod BuildLableWithFrame:CGRectMake(120, 14, 150, 15)
                                                 withFont:[UIFont systemFontOfSize:14]
                                                 withText:@"快递"];
            [devideLb setTextColor:RGBS(180)];
            [cell.contentView addSubview:devideLb];
            
            UILabel *devideTimeLb = [GlobalMethod BuildLableWithFrame:CGRectMake(120, 38, 150, 15)
                                                withFont:[UIFont systemFontOfSize:14]
                                                withText:@"配送时间：1-2个工作日"];
            [devideTimeLb setTextColor:RGBS(180)];
            //[cell.contentView addSubview:devideTimeLb];
        }
            break;
            
        case 2:
        {
            UILabel *lb = [GlobalMethod BuildLableWithFrame:CGRectMake(10, 14, 60, 15)
                                                   withFont:[UIFont systemFontOfSize:14]
                                                   withText:@"发票信息"];
            [lb setTextColor:RGBS(51)];
            [cell.contentView addSubview:lb];
            
            UILabel *billTypeLb = [GlobalMethod BuildLableWithFrame:CGRectMake(120, 10, 150, 15)
                                                withFont:[UIFont systemFontOfSize:14]
                                                withText:@"发票类型：普通"];
            [billTypeLb setTextColor:RGBS(180)];
            [cell.contentView addSubview:billTypeLb];
            
            billTitleLb = [GlobalMethod BuildLableWithFrame:CGRectMake(120, 34, 150, 15)
                                                withFont:[UIFont systemFontOfSize:14]
                                                withText:[NSString stringWithFormat:@"发票抬头：%@",self.billTitle]];
            [billTitleLb setTextColor:RGBS(180)];
            [cell.contentView addSubview:billTitleLb];
            
            billContentLb = [GlobalMethod BuildLableWithFrame:CGRectMake(120, 59, 150, 15)
                                                withFont:[UIFont systemFontOfSize:14]
                                                withText:[NSString stringWithFormat:@"发票内容：%@",self.billContent]];
            [billContentLb setTextColor:RGBS(180)];
            [cell.contentView addSubview:billContentLb];
        }
            break;

        default:
            break;
    }
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == 1){
        CouponViewController *couponVC = [CouponViewController shareInstance];
        couponVC.orderPrice = [NSString stringWithFormat:@"%f",totalPrice];
        couponVC.fromPage = @"settleVC";
        [self.navigationController pushViewController:couponVC animated:YES];
        
        return ;
    }
    
    switch (indexPath.row) {
        case 0:
        {
            PaymentViewController *paymentVC = [PaymentViewController shareInstance];
            [paymentVC setPurchaseType:self.purchaseType];
            [self.navigationController pushViewController:paymentVC animated:YES];
        }
            break;
            
        case 1:
        {
            DelivementViewController *delivetVC = [DelivementViewController shareInstance];
            [delivetVC setDevideType:self.devideType];
            [delivetVC setFreight:self.UOFreight];
            [self.navigationController pushViewController:delivetVC animated:YES];
        }
            
            break;
            
        case 2:
        {
            NSArray *dataArr2 = [NSArray arrayWithObjects:@"个人",@"单位",nil];
            NSArray *dataArr3 = [NSArray arrayWithObjects:@"明细",@"办公用品",@"电脑配件",@"耗材",nil];
            BillInfoViewController *billInfoVC = [BillInfoViewController shareInstance];
            [billInfoVC setBillTitle:[dataArr2 indexOfObject:self.billTitle]];
            [billInfoVC setContent:[dataArr3 indexOfObject:self.billContent]];
            [self.navigationController pushViewController:billInfoVC animated:YES];
        }
            
            break;
            
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 1){
        return 63;
    }else if (indexPath.row == 2){
        return 85;
    }
    return 44;
}


#pragma mark UItextFiledDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [tView setCenter:CGPointMake(160, 100)];
    [self.view bringSubviewToFront:[self getBaseNavBar]];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [tView  setCenter:CGPointMake(160, [GlobalMethod AdapterIOS6_7ByIOS6Float:Main_Size.height/2 + 12])];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if(string.length == 0){      //点击了删除键
        return YES;
    }

    if(textField.text.length >= 50){
        return NO;
    }
    
    return YES;
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(alertView.tag == 10004){
        
        if (alertView.cancelButtonIndex == buttonIndex) {
            [self.navigationController popToRootViewControllerAnimated:NO];
            [MYAPPDELEGATE.tabBarC setSelectedIndex:0];
            return ;
        }
        
        UnpayViewController *unpayVC = [UnpayViewController shareInstance];
        [self.navigationController pushViewController:unpayVC animated:YES];
        
        return ;
    }
    
    if(buttonIndex == alertView.cancelButtonIndex){
        if (alertView.tag == 1003){
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
    }else{
        
        if (alertView.tag == 0xffff) {
            AddressManageViewController *addDView =  [AddressManageViewController shareInstance];
            addDView.shouldChoiceAddress = YES;
            [self.navigationController pushViewController:addDView animated:YES];
        }else{
            AddressDetailViewController *addDView =  [AddressDetailViewController shareInstance];
            [addDView setShouldDefaultAddress:YES];
            [self.navigationController pushViewController:addDView animated:YES];
        }
    }
}


- (void)setDefaultPayment{
    UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:8];
    [dic setObject:user.clientkey   forKey:@"clientkey"];
    [dic setObject:user.im          forKey:@"userlogin"];

    [dic setObject:@"1"   forKey:@"UDPayType"];  //货到付款

    HTTPRequest *hq = [HTTPRequest shareInstance];
    [hq POSTURLString:EDIT_PAYMENT_INFO parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

    }];
}


- (void)submitOrder{
    
    if(remarkTF.text.length >= 50){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"订单备注请不要超过50字符" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [MobClick event:MSZF];
    
    UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
    
    BLOCK_SELF(SettleViewController);
    HTTPRequest *hq = [HTTPRequest shareInstance];
    
    
    //货到付款
    if([self.purchaseType isEqualToString:@"货到付款"]){
        NSDictionary *parameter = @{@"userlogin" : user.im?user.im:@"",@"clientkey":user.clientkey};
        [self showHUDInView:self.view WithText:NETWORKLOADING];
        [hq POSTURLString:ISSUPPORT_HDFK parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *rqDic = (NSDictionary *)responseObject;
            if([rqDic[HTTP_STATE] boolValue]){
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:10];
                [dic setObject:user.clientkey               forKey:@"clientkey"];
                [dic setObject:user.im                      forKey:@"UserLogin"];
                [dic setObject:selectAddress.addressId?selectAddress.addressId : @""      forKey:@"RecAddressID"];
                [dic setObject:[NSNumber numberWithInt:1]   forKey:@"DeliveryType"];
                [dic setObject:self.shouldNotif             forKey:@"RecGiveNotice"];
                [dic setObject:self.billId                  forKey:@"Invoiceid"];
                [dic setObject:remarkTF.text                forKey:@"Remark"];
                [dic setObject:self.couponID?self.couponID : @""             forKey:@"Coupons"];
                
                NSMutableString *submitString = [NSMutableString new];
                for (int i=0; i<self.productObjArr.count; i++) {
                    ProductObj *obj = self.productObjArr[i];
                    if (i == 0) {
                        [submitString appendFormat:@"%d",obj.productId.intValue];
                    }else{
                        [submitString appendFormat:@",%d",obj.productId.intValue];
                    }
                }
                
                [dic setObject:submitString forKey:@"productid"];
                
                [hq POSTURLString:SUBMIT_ORDER  withTimeout:40 parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSDictionary *rqDic = (NSDictionary *)responseObject;
                    if([rqDic[HTTP_STATE] boolValue]){
                        
                        NSDictionary *dataDic = (NSDictionary *)[rqDic[HTTP_DATA] objectFromJSONString];
                        if([dataDic[@"result"] boolValue]){
                            
                            //提交成功，购物车商品数变化
                            int totalNum = [[GlobalMethod getObjectForKey:CART_PRODUCT_COUNT] intValue];
                            
                            for(int i=0; i<self.productObjArr.count; i++){
                                ProductObj *obj = (ProductObj *)self.productObjArr[i];
                                totalNum = totalNum - obj.number.intValue;
                            }
                            
                            [GlobalMethod saveObject:[NSString stringWithFormat:@"%d",totalNum] withKey:CART_PRODUCT_COUNT];
                            UIAlertView *unpayAView = [[UIAlertView alloc] initWithTitle:@"提交订单成功"
                                                                                 message:nil
                                                                                delegate:self
                                                                       cancelButtonTitle:@"再逛逛"
                                                                       otherButtonTitles:@"查看订单", nil];
                            [unpayAView setTag:10004];
                            [unpayAView show];
                            
                            
                        }
                    }else{
                        NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
                        
                        [self hideHUDInView:block_self.view];
                        [self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    DLog(@"%@",error);
                    
                    [self hideHUDInView:block_self.view];
                    [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
                }];
                
                cartVC.isSubmitSuccess = YES;
            }else{
                [self hideHUDInView:block_self.view];
                [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"你选择的地区无法货到付款，请重新选择" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil] show];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",[error description]);
            [self hideHUDInView:block_self.view];
            [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
        }];
        return;
    }
  
    
    
    
    //支付宝支付
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:10];
    [dic setObject:user.clientkey               forKey:@"clientkey"];
    [dic setObject:user.im                      forKey:@"UserLogin"];
    [dic setObject:selectAddress.addressId?selectAddress.addressId : @""      forKey:@"RecAddressID"];
    [dic setObject:[NSNumber numberWithInt:1]   forKey:@"DeliveryType"];
    [dic setObject:self.shouldNotif             forKey:@"RecGiveNotice"];
    [dic setObject:self.billId                  forKey:@"Invoiceid"];
    [dic setObject:remarkTF.text                forKey:@"Remark"];
    [dic setObject:self.couponID?self.couponID : @""             forKey:@"Coupons"];

    NSMutableString *submitString = [NSMutableString new];
    for (int i=0; i<self.productObjArr.count; i++) {
        ProductObj *obj = self.productObjArr[i];
        if (i == 0) {
            [submitString appendFormat:@"%d",obj.productId.intValue];
        }else{
            [submitString appendFormat:@",%d",obj.productId.intValue];
        }
    }
    
    [dic setObject:submitString forKey:@"productid"];
    NSLog(@"%@",dic);
    [self showHUDInView:self.view WithText:NETWORKLOADING];
    [hq POSTURLString:SUBMIT_ORDER  withTimeout:40 parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rqDic = (NSDictionary *)responseObject;
        if([rqDic[HTTP_STATE] boolValue]){
            
            NSDictionary *dataDic = (NSDictionary *)[rqDic[HTTP_DATA] objectFromJSONString];
            if([dataDic[@"result"] boolValue]){
                
                DLog(@"订单号: %@ \n银联流水号:%@",dataDic[@"orderserial"],dataDic[@"payserial"]);
                
                //提交成功，购物车商品数变化
                int totalNum = [[GlobalMethod getObjectForKey:CART_PRODUCT_COUNT] intValue];
                
                for(int i=0; i<self.productObjArr.count; i++){
                    ProductObj *obj = (ProductObj *)self.productObjArr[i];
                    totalNum = totalNum - obj.number.intValue;
                }
                
                [GlobalMethod saveObject:[NSString stringWithFormat:@"%d",totalNum] withKey:CART_PRODUCT_COUNT];
                
                if([self.purchaseType isEqualToString:@"货到付款"]){
                    
                    UIAlertView *unpayAView = [[UIAlertView alloc] initWithTitle:@"提交订单成功"
                                                                         message:nil
                                                                        delegate:self
                                                               cancelButtonTitle:@"再逛逛"
                                                               otherButtonTitles:@"查看订单", nil];
                    [unpayAView setTag:10004];
                    [unpayAView show];
                    
                }else{
                    //跳至银联支付
//                    UUPViewController *uupVC = [UUPViewController shareInstance];
//                    [uupVC setTNString:dataDic[@"payserial"]];
//                    [uupVC setOrderSerial:dataDic[@"orderserial"]];
//                    [self.navigationController pushViewController:uupVC animated:NO];
                    if ([dataDic[@"totalamount"] floatValue] > 0) {
                        //支付宝
                        AlipayViewController *alipayVC = [[AlipayViewController alloc] init];
                        alipayVC.alipayOrder.tradeNO = dataDic[@"orderserial"];
                        alipayVC.alipayOrder.productName = dataDic[@"productname"];
                        alipayVC.alipayOrder.productDescription = @"爱心天地商品"; //商品描述
                        alipayVC.alipayOrder.amount = dataDic[@"totalamount"]; //商品价格
                        [self.navigationController pushViewController:alipayVC animated:YES];
                        [self hideHUDInView:block_self.view];
                    }else{
                        UIAlertView *unpayAView = [[UIAlertView alloc] initWithTitle:@"提交订单成功"
                                                                             message:nil
                                                                            delegate:self
                                                                   cancelButtonTitle:@"再逛逛"
                                                                   otherButtonTitles:nil, nil];
                        unpayAView.tag = 10004;
                        [unpayAView show];
                    }
                }
            }
        }else{
            NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
            
            [self hideHUDInView:block_self.view];
            [self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"%@",error);
        
        [self hideHUDInView:block_self.view];
        [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
    }];
    
    cartVC.isSubmitSuccess = YES;
}

- (void)tapToAddressManage{
    AddressManageViewController *addressVC = [AddressManageViewController shareInstance];
    [addressVC setShouldChoiceAddress:YES];
    [self.navigationController pushViewController:addressVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
