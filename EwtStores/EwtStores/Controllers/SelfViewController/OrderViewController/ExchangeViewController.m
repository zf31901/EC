//
//  ExchangeViewController.m
//  Shop
//
//  Created by Jacob on 14-1-15.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "ExchangeViewController.h"
#import "QuartzCore/QuartzCore.h"
#import "ExchangeTypeViewController.h"
#import "ReturnOrderViewController.h"
#import "ProductObj.h"
#import "CartOfProductCell.h"

ExchangeViewController *exchangeVC;
extern SelfViewController *selfVC;

@interface ExchangeViewController ()<CartOfProductCellDelegate>
{
    UITableView     *tView;
    UILabel         *exchangeLb;     //退换货方式
    UITextView      *textV;
    UIView          *headerBg;
    UIView          *footerBg;
    NSString        *selectedProID;
    NSString        *selectedProName;
}
@end

@implementation ExchangeViewController

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
    
    [self setNavBarTitle:@"申请"];
    [self setRightBtnOffImg:nil andOnImg:nil andTitle:@"提交"];
    self.exchangeType = @"退货";
    [self buildBaseView];
    
    exchangeVC = self;
    
    [MobClick event:DDSQ];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [exchangeLb setText:self.exchangeType];
}

- (void)buildBaseView
{
    tView = [[UITableView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(0, Navbar_Height, Main_Size.width, Main_Size.height - StatusBar_Height - Navbar_Height)] style:UITableViewStyleGrouped];
    [tView setDataSource:self];
    [tView setDelegate:self];
    [tView setBackgroundView:nil];
    [tView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:tView];
    
//    headerBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Main_Size.width, 15)];
//    //[tView setTableHeaderView:headerBg];
//    UILabel *headlb = [GlobalMethod BuildLableWithFrame:CGRectMake(10, 0, 120, 15) withFont:[UIFont systemFontOfSize:14] withText:@"请选择申请反馈的商品"];
//    [headlb setTextColor:RGBS(51)];
//    [headerBg addSubview:headlb];
    
    footerBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Main_Size.width, 200)];
    //[tView setTableFooterView:footerBg];
    
    UILabel *lb = [GlobalMethod BuildLableWithFrame:CGRectMake(10, 10, 60, 15)
                                           withFont:[UIFont systemFontOfSize:14]
                                           withText:@"申请原因"];
    [lb setTextColor:RGBS(51)];
    [footerBg addSubview:lb];
    
    textV = [[UITextView alloc] initWithFrame:CGRectMake(10, lb.bottom+10, 300, 175)];
    textV.font = [UIFont fontWithName:@"Arial" size:14.0];//设置字体名字和字体大小
    textV.delegate = self;//设置它的委托方法
    textV.backgroundColor = [UIColor whiteColor];//设置它的背景颜色
    [textV.layer setCornerRadius:5];
    textV.scrollEnabled = YES;//是否可以拖动
    textV.autoresizingMask = UIViewAutoresizingFlexibleHeight;//自适应高度
    textV.text = @"请输入申请退换货的原因";//设置它显示的内容
    textV.textColor = [UIColor lightGrayColor]; //optional
    [footerBg addSubview:textV];
    
}

- (void)rightBtnAction:(UIButton *)btn{
    DLog(@"提交退换货信息");
    if (selectedProName == nil || selectedProID == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择需要反馈的商品" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alert show];
        return;
    }
    UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
    NSDictionary *parameters = @{};
    BLOCK_SELF(ExchangeViewController);
    HTTPRequest *hq = [HTTPRequest shareInstance];
    
    DLog(@"_exchangeType:%@",_exchangeType);
    if ([_exchangeType isEqualToString:@"退货"]) {
        /*parameters = @{@"userlogin": user.im, @"AR_OrderID": _order.orderId, @"AR_RefundAmount": [NSString stringWithFormat:@"%.2f",_order.totalPayAmount], @"AR_ApplyReason": textV.text};
        [self showHUDInView:block_self.view WithText:@"退款申请已提交" andDelay:2];
        [hq POSTURLString:ORDER_RETURN_REFUND parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *rqDic = (NSDictionary *)responseObject;
            if([rqDic[HTTP_STATE] boolValue]){
                [self goToOrderReturn];
            }else{
                NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
                [self showHUDInView:block_self.view WithText:[NSString stringWithFormat:@"%@:%@",rqDic[HTTP_ERRCODE],rqDic[HTTP_MSG]] andDelay:2];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@ , %@",operation,error);
            [self showHUDInView:block_self.view WithText:@"网络请求失败" andDelay:2];
        }];
        [self hideHUDInView:block_self.view];
        return;*/
        parameters = @{@"userlogin": user.im, @"clientkey":user.clientkey, @"R_OrderID": _order.orderId, @"R_RepType": @"2",@"R_ProblemDesc":textV.text,@"R_ProID":selectedProID,@"R_ProName":selectedProName};
    } else if ([_exchangeType isEqualToString:@"换货"]) {
        parameters = @{@"userlogin": user.im, @"clientkey":user.clientkey, @"R_OrderID": _order.orderId, @"R_RepType": @"3",@"R_ProblemDesc":textV.text,@"R_ProID":selectedProID,@"R_ProName":selectedProName};
    } else if ([_exchangeType isEqualToString:@"维修"]) {
        parameters = @{@"userlogin": user.im, @"clientkey":user.clientkey, @"R_OrderID": _order.orderId, @"R_RepType": @"1",@"R_ProblemDesc":textV.text,@"R_ProID":selectedProID,@"R_ProName":selectedProName};
    }
    [self showHUDInView:block_self.view WithText:@"正在提交申请"];
    [hq POSTURLString:ORDER_RETURN_REPAIR parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rqDic = (NSDictionary *)responseObject;
        [self hideHUDInView:block_self.view];
        if([rqDic[HTTP_STATE] boolValue]){
            [self  showHUDInView:block_self.view WithText:@"申请已提交" andDelay:1];
            [self goToOrderReturn];
        }else{
            NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
            if ([rqDic[HTTP_ERRCODE] intValue] == 10008) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"该订单已提交过反馈申请,请等待处理结果" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
                [alert show];
                
            }else{
                [self showHUDInView:block_self.view WithText:[NSString stringWithFormat:@"%@:%@",rqDic[HTTP_ERRCODE],rqDic[HTTP_MSG]] andDelay:LOADING_TIME];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@ , %@",operation,error);
        [self hideHUDInView:block_self.view];
        [self showHUDInView:block_self.view WithText:@"网络请求失败" andDelay:LOADING_TIME];
    }];
    
}

- (void)goToOrderReturn{
    //从堆栈中移除ViewController
    for (int i = 0; i < 2; i++) {
        [selfVC.navigationController popViewControllerAnimated:NO];
    }
    
    ReturnOrderViewController *orderVC = [ReturnOrderViewController shareInstance];
    [selfVC.navigationController pushViewController:orderVC animated:YES];
}

#pragma mark
#pragma mark UItableView methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }
    return _order.products.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        
        
        static NSString *identifier = @"exchange_cell";
        UITableViewCell *cell = cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        UILabel *lb = [GlobalMethod BuildLableWithFrame:CGRectMake(10, 14, 60, 15)
                                               withFont:[UIFont systemFontOfSize:16]
                                               withText:@"我要"];
        [lb setTextColor:RGBS(51)];
        [cell.contentView addSubview:lb];
        
        exchangeLb = [GlobalMethod BuildLableWithFrame:CGRectMake(140, 14, 140, 15)
                                              withFont:[UIFont systemFontOfSize:14]
                                              withText:self.exchangeType];
        [exchangeLb setTextColor:RGBS(180)];
        [exchangeLb setTextAlignment:NSTextAlignmentRight];
        [cell.contentView addSubview:exchangeLb];
        
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        return cell;
    }else{
        static NSString *indifiter = @"cart_product_cell";
        CartOfProductCell *cell = [tableView dequeueReusableCellWithIdentifier:indifiter];
        if(!cell){
            cell = [[CartOfProductCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indifiter];
        }
        
        //[cell set_delegate:self];
        ProductObj *obj = _order.products[indexPath.row];
        [cell reuserTableViewCell:obj AtIndex:indexPath.row];
        [cell.productImgView setImageURL:obj.imgUrl];
        cell.statusBt.userInteractionEnabled = NO;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        return cell;
       
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        ExchangeTypeViewController *exchangeTypeVC = [ExchangeTypeViewController shareInstance];
        [exchangeTypeVC setExchangeType:self.exchangeType];
        [self.navigationController pushViewController:exchangeTypeVC animated:YES];
    }else{
        CartOfProductCell *cell =(CartOfProductCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell.statusBt changeBackgroundImage];
        if (cell.statusBt.choiceStatus) {
            ProductObj  *obj = _order.products[indexPath.row];
            selectedProID =  obj.productId;
            selectedProName = obj.name;
            for (int i = 0; i < _order.products.count; i++) {
                if (i == indexPath.row) {
                    continue;
                }
                NSIndexPath *otherindexPath = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
                CartOfProductCell *otherCell =(CartOfProductCell *)[tableView cellForRowAtIndexPath:otherindexPath];
                if (otherCell.statusBt.choiceStatus == YES) {
                    [otherCell.statusBt changeBackgroundImage];
                }
            }
        }else{
            selectedProID = nil;
            selectedProName = nil;
        }
    }
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 44;
    }
    return 92;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        headerBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Main_Size.width, 20)];
        //[tView setTableHeaderView:headerBg];
        UILabel *headlb = [GlobalMethod BuildLableWithFrame:CGRectMake(5, -5, 150, 15) withFont:[UIFont systemFontOfSize:14] withText:@"请选择申请反馈的商品"];
        [headlb setTextColor:RGBS(51)];
        [headerBg addSubview:headlb];
        return headerBg;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 1) {
        [tView setTableFooterView:footerBg];
    }
    return nil;
}

#pragma mark UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"请输入申请退换货的原因"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"请输入申请退换货的原因";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
