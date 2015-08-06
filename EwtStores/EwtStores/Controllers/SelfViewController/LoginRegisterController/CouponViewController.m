//
//  CouponViewController.m
//  Shop
//
//  Created by Harry on 14-1-7.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "CouponViewController.h"
#import "SettleViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "CouponObj.h"

extern SettleViewController *settleVC;

@interface CouponViewController ()
{
    UIView          *emptyView;
    NSMutableArray      *couponListArr;
    UITextField *couponTF;
    UITableView *tView;
}

@end

@implementation CouponViewController

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
    
    [self setNavBarTitle:@"优惠券"];
    [self hiddenRightBtn];
    
    couponListArr = [NSMutableArray arrayWithCapacity:10];
    
   
    
    
    
    tView = [[UITableView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(0, Navbar_Height +33, Main_Size.width, Main_Size.height - StatusBar_Height - Navbar_Height)] style:UITableViewStylePlain];
    [tView setDelegate:self];
    [tView setDataSource:self];
    [tView setBackgroundView:nil];
    [tView setBackgroundColor:RGBS(238)];
    [tView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tView];
    
    UIView *titView = [[UIView alloc]initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(0, Navbar_Height+8, Main_Size.width, 46)]];
    titView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:titView];
    
    couponTF  = [GlobalMethod BuildTextFieldWithFrame:CGRectMake(8, 8, Main_Size.width - 126, 30) andPlaceholder:@"请输入优惠券序列号"];
    couponTF.borderStyle = UITextBorderStyleRoundedRect;
    couponTF.font = [UIFont systemFontOfSize:15];
    couponTF.backgroundColor = RGBS(238);
    [couponTF setClearButtonMode:UITextFieldViewModeAlways];//右侧删除按钮
    [titView addSubview:couponTF];
    
    UIButton    *couponBtn = [GlobalMethod BuildButtonWithFrame:CGRectMake(couponTF.width + 18, 8, 100, 30) andOffImg:@"regist_next_off" andOnImg:@"regist_next_on" withTitle:nil];
    if ([self.fromPage  isEqualToString:@"selfVC"])
    {
        [couponBtn setTitle:@"添加" forState:UIControlStateNormal];
    }else if ([self.fromPage isEqualToString:@"settleVC"])
    {
        [couponBtn setTitle:@"使用" forState:UIControlStateNormal];
    }
//    couponBtn.layer.borderColor = [UIColor grayColor].CGColor;
//    couponBtn.layer.borderWidth =1.0;
    [couponBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    couponBtn.layer.cornerRadius = 4;
    couponBtn.layer.masksToBounds = YES;
    couponBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [couponBtn  addTarget:self action:@selector(addCouponRequest) forControlEvents:UIControlEventTouchUpInside];
    [titView addSubview:couponBtn];
    
    [self requestCouponData];
}

-(void)requestCouponData
{
    [couponListArr removeAllObjects];
    UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
    [self showHUDInView:self.view WithText:NETWORKLOADING];
    HTTPRequest *hq = [HTTPRequest shareInstance];
    BLOCK_SELF(CouponViewController);
    NSDictionary *dic = @{@"userlogin" : user.im?user.im:@"" , @"clientkey":user.clientkey, @"type":@"2"};
    [hq GETURLString:COUPONS_LIST userCache:NO parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObj) {
        NSDictionary *rqDic = (NSDictionary *)responseObj;
        if([rqDic[HTTP_STATE] boolValue]){
            NSLog(@"couponVC---requestData---->>>\n%@",rqDic);
            NSArray *dataArr = (NSArray *)[rqDic[HTTP_DATA] objectFromJSONString];
           
            for(int i=0; i<dataArr.count; i++){
                
                NSDictionary *dic = (NSDictionary *)dataArr[i];
                CouponObj *obj = [CouponObj shareInstance];
                [obj setCouponId:dic[@"UC_Id"]];
                [obj setCouponAmount:dic[@"UC_Amount"]];
                [obj setLimmitAmount:dic[@"UC_CouponAmount"]];
                [obj setBeginTime:[GlobalMethod getJsonDateString:dic[@"UC_StartTime"]]];
                [obj setEndTime:[GlobalMethod getJsonDateString:dic[@"UC_EndTime"]]];
                [couponListArr addObject:obj];
            }
            
            [tView reloadData];
           [self hideHUDInView:block_self.view];
            if(dataArr.count == 0){
                [self buildCartEmptyView];
            }else{
                [emptyView removeFromSuperview];
            }
            
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
/**
 * 根据优惠券序列号添加优惠券
 * @param userlogin
 * @param clientkey
 * @param SerialNumber 优惠券序列号  @"4131GAQ0PTMU7TGIKRSC382D"(202)
 */
#pragma mark 添加优惠券
-(void)addCouponRequest
{
    if (![couponTF.text isEqualToString:@""])
    {
        UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
        [self showHUDInView:self.view WithText:NETWORKLOADING];
        HTTPRequest *hq = [HTTPRequest shareInstance];
        BLOCK_SELF(CouponViewController);
        
        NSDictionary *dic = @{@"userlogin" : user.im?user.im:@"" , @"clientkey":user.clientkey,@"SerialNumber":couponTF.text, @"type":@"2", @"apikey":ApiKey};
        [hq GETURLString:COUPONS_check userCache:NO parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObj) {
            [self hideHUDInView:self.view];
            NSLog(@"---operation-->>\n%@",operation);
            NSDictionary *rqDic = (NSDictionary *)responseObj;
            if([rqDic[HTTP_STATE] boolValue])
            {
                NSDictionary *dataDic = (NSDictionary *)[rqDic[HTTP_DATA] objectFromJSONString];
                NSLog(@"----datadic--->>\n%@",dataDic);
                
                if (![dataDic objectForKey:@"result"])
                {
                    CouponObj *obj = [CouponObj shareInstance];
                    [obj setCouponId:dataDic[@"UC_Id"]];
                    [obj setCouponAmount:dataDic[@"UC_Amount"]];
                    [obj setLimmitAmount:dataDic[@"UC_CouponAmount"]];
                    [obj setBeginTime:[GlobalMethod getJsonDateString:dataDic[@"UC_StartTime"]]];
                    [obj setEndTime:[GlobalMethod getJsonDateString:dataDic[@"UC_EndTime"]]];
                    [obj setSerialnumber:dataDic[@"UC_SerialNumber"]];
                    [obj setBalance:[dic[@"UC_Balance"] floatValue]];
                    [obj setAmount:[dic[@"UC_Amount"] floatValue]];
                    [obj setUC_CouponType:[dic[@"UC_CouponType"] intValue]];
                    [self requestCouponData];
                    [self hideHUDInView:block_self.view];
                    couponTF.text = @"";
                    if ([self.fromPage isEqualToString:@"settleVC"])
                    {
                        //从结算界面来的
                        if(self.orderPrice.length != 0)
                        {
                            NSDate *nowDate = [NSDate date];
                            NSTimeInterval interval = [nowDate timeIntervalSince1970];
                            
                            if (obj.endTime.floatValue < interval) {
                                [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"该优惠券已过期哦" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show];
                                return ;
                            }
                            
                            if(self.orderPrice.floatValue >= obj.limmitAmount.floatValue){
                                //订单金额大于限制金额
                                
                                settleVC.couponPrice = obj.couponAmount;
                                settleVC.couponID = obj.couponId;
                                [self.navigationController popViewControllerAnimated:YES];
                            }else{
                                [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"订单商品金额不足哦" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show];
                            }
                        }
                    }
                }else
                {
                    [self isAlertView:[[dataDic objectForKey:@"result"] intValue]];
                    NSLog(@"--result---%@",[dataDic objectForKey:@"result"]);
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
        
    }else
    {
        UIAlertView *couponAlert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入优惠券序列号" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [couponAlert show];
    }
    
    
}

-(void)isAlertView:(int)result
{
    NSString   *mesgStr = nil;
 
    switch (result)
    {
        case 1:
        {
            mesgStr = @"核对绑定成功";
            
        }
            break;
        case 2:
        {
            mesgStr = @"卡号和密码不存在";
        }
            break;
        case 3:
        {
            mesgStr = @"优惠券不存在";
        }
            break;
        case 4:
        {
            mesgStr = @"不在有效期";
        }
            break;
        case 5:
        {
            mesgStr = @"已锁定,不能使用";
        }
            break;
        case 6:
        {
            mesgStr = @"已被使用";
        }
            break;
        case 7:
        {
            mesgStr = @"优惠券已经绑定";
        }
            break;
            
        default:
            break;
    }
    UIAlertView *coupAlert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:mesgStr delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] ;
    [coupAlert  show];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MobClick event:YHJ];
}

- (void)buildCartEmptyView
{
    emptyView = [[UIView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(0, Navbar_Height + 38, Main_Size.width, Main_Size.height - StatusBar_Height - Navbar_Height - Tabbar_Height)]];
    [emptyView setBackgroundColor:RGBS(238)];
    [self.view addSubview:emptyView];
    
    UIImageView *emptyImgView = [[UIImageView alloc] initWithFrame:CGRectMake(115, 100, 90, 90)];
    [emptyImgView setImage:[UIImage imageNamed:@"no"]];
    [emptyView addSubview:emptyImgView];
    
    UILabel *lb = [GlobalMethod BuildLableWithFrame:CGRectMake(50, 220, 220, 19)
                                           withFont:[UIFont systemFontOfSize:12]
                                           withText:@"还没有优惠券哦"];
    [lb setTextColor:RGBS(102)];
    [lb setTextAlignment:NSTextAlignmentCenter];
    [emptyView addSubview:lb];
    
}

#pragma mark UItableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return couponListArr.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"我的优惠券 (%d)",couponListArr.count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    CouponObj *obj = couponListArr[indexPath.row];
    
    UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(8, 0, 304, 90)];
    [bg.layer setBorderWidth:0.5];
    [bg.layer setBorderColor:RGBS(206).CGColor];
    [bg.layer setShadowColor:RGBS(218).CGColor];
    [bg setBackgroundColor:[UIColor whiteColor]];
    [cell.contentView addSubview:bg];
    
    UIImageView *iView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 170, 90)];
    if([obj.couponAmount floatValue] < 50){
        [iView setImage:[UIImage imageNamed:@"coupon1"]];
    }else if ([obj.couponAmount floatValue] < 500){
        [iView setImage:[UIImage imageNamed:@"coupon2"]];
    }else{
        [iView setImage:[UIImage imageNamed:@"coupon3"]];
    }

    [bg addSubview:iView];
    
    UILabel *priceLb = [GlobalMethod BuildLableWithFrame:CGRectMake(10, 20, 150, 50)
                                                withFont:[UIFont boldSystemFontOfSize:40]
                                                withText:[NSString stringWithFormat:@"¥ %@",obj.couponAmount]];
    [priceLb setTextColor:[UIColor whiteColor]];
    [priceLb setTextAlignment:NSTextAlignmentCenter];
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"¥ %@",obj.couponAmount]];
    [attString addAttribute:NSFontAttributeName value:(id)[UIFont boldSystemFontOfSize:18] range:NSMakeRange(0,1)];
    [priceLb setAttributedText:attString];
    [iView addSubview:priceLb];
    
    UILabel *limmitLb = [GlobalMethod BuildLableWithFrame:CGRectMake(iView.right + 10, 10, 120, 15)
                                                 withFont:[UIFont systemFontOfSize:14]
                                                 withText:[NSString stringWithFormat:@"订单满%@可用",obj.limmitAmount]];
    [limmitLb setTextAlignment:NSTextAlignmentCenter];
    [limmitLb setTextColor:RGBS(101)];
    [cell.contentView addSubview:limmitLb];
    
    UILabel *timeLb = [GlobalMethod BuildLableWithFrame:CGRectMake(iView.right + 10, limmitLb.bottom + 2, 120, 60)
                                               withFont:[UIFont systemFontOfSize:14]
                                               withText:[NSString stringWithFormat:@"使用日期\n%@\n%@",
                                                         [GlobalMethod getTimeByTimeInterval:obj.beginTime],
                                                         [GlobalMethod getTimeByTimeInterval:obj.endTime]]];
    [timeLb setTextColor:RGBS(51)];
    [bg addSubview:timeLb];

    [cell.contentView setBackgroundColor:RGBS(238)];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //从结算界面来的
    if(self.orderPrice.length != 0){
        CouponObj *obj = couponListArr[indexPath.row];
        
        NSDate *nowDate = [NSDate date];
        NSTimeInterval interval = [nowDate timeIntervalSince1970];
        
        if (obj.endTime.floatValue < interval) {
            [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"该优惠券已过期哦" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show];
            return ;
        }
        
        if(self.orderPrice.floatValue >= obj.limmitAmount.floatValue){
            //订单金额大于限制金额
            
            settleVC.couponPrice = obj.couponAmount;
            settleVC.couponID = obj.couponId;
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"订单商品金额不足哦" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
