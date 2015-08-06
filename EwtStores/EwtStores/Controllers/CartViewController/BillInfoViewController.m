//
//  BillInfoViewController.m
//  Shop
//
//  Created by Harry on 14-1-14.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "BillInfoViewController.h"
#import "SettleViewController.h"

extern SettleViewController *settleVC;

@interface BillInfoViewController () <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    NSArray             *sectionArr2;
    NSArray             *sectionArr3;
    NSMutableArray      *dataArr;
    NSArray             *headerTitle;
    
    UITableView         *tView;
    
    BOOL                isExistBill;      //  是否存在发票信息
    NSString            *billId;
    NSString            *companyName;
    
    UITextField         *tF;                //单位名称
}

@end

@implementation BillInfoViewController

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
    
    [self setNavBarTitle:@"发票信息"];
    [self setRightBtnOffImg:nil andOnImg:nil andTitle:@"完成"];
    
    dataArr = [NSMutableArray arrayWithCapacity:3];
    NSArray *dataArr1 = [NSArray arrayWithObjects:@"普通发票",nil];
    sectionArr2 = [NSArray arrayWithObjects:@"个人",@"单位",nil];
    sectionArr3 = [NSArray arrayWithObjects:@"明细",nil];
    [dataArr addObject:dataArr1];
    [dataArr addObject:sectionArr2];
    [dataArr addObject:sectionArr3];
    
    headerTitle = [NSArray arrayWithObjects:@"发票类型",@"发票抬头",@"发票内容",nil];
    
    tView = [[UITableView alloc] initWithFrame:CGRectMake(0, [GlobalMethod AdapterIOS6_7ByIOS6Float:Navbar_Height], Main_Size.width, Main_Size.height - StatusBar_Height - Navbar_Height) style:UITableViewStylePlain];
    [tView setDelegate:self];
    [tView setDataSource:self];
    [tView setBackgroundView:nil];
    [tView setBackgroundColor:RGBS(238)];
    [self.view addSubview:tView];
    
    UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:2];
    [dic setObject:user.clientkey   forKey:@"clientkey"];
    [dic setObject:user.im          forKey:@"userlogin"];
    
    BLOCK_SELF(BillInfoViewController);
    HTTPRequest *hq = [HTTPRequest shareInstance];
    
    [hq GETURLString:BILL_LIST_INFO userCache:NO parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObj) {
        NSDictionary *rqDic = (NSDictionary *)responseObj;
        if([rqDic[HTTP_STATE] boolValue]){
            
            NSArray *arr = (NSArray *)[rqDic[HTTP_DATA] objectFromJSONString];
            
            if(arr.count == 0){
                isExistBill = NO;
            }else{
                isExistBill = YES;
                
                for(int i=0; i<arr.count; i++){
                    if(i == arr.count - 1){
                        NSDictionary *billDic = arr[i];
                        billId = billDic[@"UII_ID"];
                        settleVC.billId = billId;
                        companyName = billDic[@"UII_CompanyInfo"];
                    }
                }
            }
            [tView reloadData];
            [self hideHUDInView:block_self.view];
        }else{
            NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
            [self hideHUDInView:block_self.view];
            [self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self hideHUDInView:block_self.view];
        [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
    }];
    
    [MobClick event:FPXX];
}


- (void)rightBtnAction:(UIButton *)btn{
    [tF resignFirstResponder];
    
    [settleVC setBillTitle:sectionArr2[self.billTitle]];
    [settleVC setBillContent:sectionArr3[self.content]];
    
    UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:8];
    [dic setObject:user.clientkey   forKey:@"clientkey"];
    [dic setObject:user.im          forKey:@"UII_UserLogin"];
    [dic setObject:@"1"             forKey:@"UII_InvoiceType"]; //普通发票
    [dic setObject:[NSString stringWithFormat:@"%d",self.billTitle + 1] forKey:@"UII_InvoiceHead"];
    if(self.billTitle == UNITS){
        //单位发票
        [dic setObject:tF.text?tF.text:@"" forKey:@"UII_CompanyInfo"];
    }
    [dic setObject:sectionArr3[self.content] forKey:@"UII_InvoinceContent"];
    [dic setObject:[NSNumber numberWithBool:YES] forKey:@"UII_IsDefault"];
    
    NSString *billapi;
    if(isExistBill){
        billapi = EDIT_BILL_INFO;
        [dic setObject:billId forKey:@"UII_ID"];
    }else{
        billapi = ADD_BILL_INFO;
    }
    
    BLOCK_SELF(BillInfoViewController);
    HTTPRequest *hq = [HTTPRequest shareInstance];
    [hq POSTURLString:billapi parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rqDic = (NSDictionary *)responseObject;
        if([rqDic[HTTP_STATE] boolValue]){
            
            NSDictionary *dataDic = (NSDictionary *)[rqDic[HTTP_DATA] objectFromJSONString];

            if([dataDic[@"result"] boolValue]){
                [self hideHUDInView:block_self.view];
                [self.navigationController popViewControllerAnimated:YES];
            }
            
            [self hideHUDInView:block_self.view];
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

#pragma mark UItableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return dataArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [(NSArray *)dataArr[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"cell"];
    
    [cell.textLabel setText:[dataArr[indexPath.section] objectAtIndex:indexPath.row]];
    [cell.textLabel setTextColor:RGBS(59)];
    [cell.textLabel setTextAlignment:NSTextAlignmentLeft];
    [cell.textLabel setFont:[UIFont systemFontOfSize:16]];
    
    //默认是选择普通发票
    if(indexPath.row == 0 && indexPath.section == 0){
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    
    if(indexPath.section == 1){
        if(indexPath.row == self.billTitle){
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }else{

        }
        
        if(indexPath.row == 1){
            tF = [GlobalMethod BuildTextFieldWithFrame:CGRectMake(70, 7, 200, 30) andPlaceholder:@"请输入单位名称"];
            UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 30)];
            [tF setLeftView:leftView];
            [tF setLeftViewMode:UITextFieldViewModeAlways];
            [tF setFont:[UIFont systemFontOfSize:14]];
            [tF.layer setMasksToBounds:YES];
            [tF.layer setCornerRadius:8];
            [tF.layer setBorderColor:RGBS(181).CGColor];
            [tF.layer setBorderWidth:1];
            [tF setBackgroundColor:RGBS(231)];
            [tF setDelegate:self];
            [tF setReturnKeyType:UIReturnKeyDone];
            [tF setText:companyName];
            [cell.contentView addSubview:tF];
        }
    }
    
    if(indexPath.section == 2){
        if(indexPath.row == self.content){
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];

    UILabel *lb = [GlobalMethod BuildLableWithFrame:CGRectMake(10, 7, 300, 17) withFont:[UIFont systemFontOfSize:13] withText:headerTitle[section]];
    [lb setTextColor:RGBS(59)];
    [bg addSubview:lb];
    
    return bg;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
    if(indexPath.section == 1){
        for(int i=0; i<2; i++){
            UITableViewCell *cell1 = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
            [cell1 setAccessoryType:UITableViewCellAccessoryNone];
        }
        
        switch (indexPath.row) {
            case 0:
                self.billTitle = PERSONAL;
                [tF resignFirstResponder];
                break;
                
            case 1:
                self.billTitle = UNITS;
                [tF becomeFirstResponder];
                break;
                
            default:
                break;
        }

        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    
    if(indexPath.section == 2){
        for(int i=0; i<4; i++){
            UITableViewCell *cell1 = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:2]];
            [cell1 setAccessoryType:UITableViewCellAccessoryNone];
        }
        
        switch (indexPath.row) {
            case 0:
                self.content = DETAIL;
                break;
                
            case 1:
                self.content = OFFICE;
                break;
                
            case 2:
                self.content = COMPUTER;
                break;
                
            case 3:
                self.content = CONSUMABLE;
                break;
                
            default:
                break;
        }
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.0001;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    [self tableView:tView didSelectRowAtIndexPath:indexPath];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
