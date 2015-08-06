//
//  PaymentViewController.m
//  Shop
//
//  Created by Harry on 14-1-4.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "PaymentViewController.h"
#import "SettleViewController.h"

extern SettleViewController *settleVC;

@interface PaymentViewController ()
{
    NSArray     *paymentArr;
    
    NSInteger   currentIndex;
}


@end

@implementation PaymentViewController

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
    
    [self setNavBarTitle:@"支付方式"];
    [self hiddenRightBtn];
    
    currentIndex = -1;
    paymentArr = [NSArray arrayWithObjects:@"货到付款",@"支付宝",nil];
    currentIndex = [paymentArr indexOfObject:self.purchaseType];

    UITableView *tView = [[UITableView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(0, Navbar_Height, Main_Size.width, Main_Size.height - StatusBar_Height - Navbar_Height)] style:UITableViewStyleGrouped];
    [tView setDataSource:self];
    [tView setDelegate:self];
    [tView setBackgroundView:nil];
    [tView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:tView];
    
    [MobClick event:ZFFS];
}

#pragma mark
#pragma mark UItableView methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return paymentArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"payment_cell";
    UITableViewCell *cell = cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    
    UILabel *lb = [GlobalMethod BuildLableWithFrame:CGRectMake(10, 14, 140, 15)
                                           withFont:[UIFont systemFontOfSize:14]
                                           withText:paymentArr[indexPath.row]];
    [cell.contentView addSubview:lb];
    
    if(indexPath.row == currentIndex){
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }else{
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    for(int i=0; i<paymentArr.count; i++){
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    currentIndex = indexPath.row;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    
    [self performSelector:@selector(comeBack) withObject:nil afterDelay:0.3];
}

- (void)comeBack{
    
    UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:8];
    [dic setObject:user.clientkey   forKey:@"clientkey"];
    [dic setObject:user.im          forKey:@"userlogin"];
  
    if([paymentArr[currentIndex] isEqualToString:@"银联手机支付"]){
        [dic setObject:@"11"   forKey:@"UDPayType"];  //支付方式
    }else{
        [dic setObject:@"1"   forKey:@"UDPayType"];  //支付方式
    }
    
    BLOCK_SELF(PaymentViewController);
    HTTPRequest *hq = [HTTPRequest shareInstance];
    [hq POSTURLString:EDIT_PAYMENT_INFO parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rqDic = (NSDictionary *)responseObject;
        if([rqDic[HTTP_STATE] boolValue]){
            
            NSDictionary *dataDic = (NSDictionary *)[rqDic[HTTP_DATA] objectFromJSONString];
            
            if([dataDic[@"result"] boolValue]){
//                [self hideHUDInView:block_self.view];
//                [self.navigationController popViewControllerAnimated:YES];
            }
            
            [self hideHUDInView:block_self.view];
            
            settleVC.purchaseType = paymentArr[currentIndex];
            [self.navigationController popViewControllerAnimated:YES];
            
        }else{
            NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
            [self hideHUDInView:block_self.view];
            [self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self hideHUDInView:block_self.view];
        [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
