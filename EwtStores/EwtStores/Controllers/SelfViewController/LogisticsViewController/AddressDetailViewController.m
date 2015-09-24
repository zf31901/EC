//
//  AddressDetailViewController.m
//  Shop
//
//  Created by Harry on 14-1-3.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "AddressDetailViewController.h"
#import "AddressObj.h"
#import "RegexKitLite.h"
#import <QuartzCore/QuartzCore.h>

#define PROVINCE_TITLE  @"province_title"       //省名
#define CITY_TITLE      @"city_title"           //市名
#define COUNTY_TITLE    @"county_title"         //县/地区名

@interface AddressDetailViewController () <UIPickerViewDataSource,UIPickerViewDelegate,UIAlertViewDelegate>
{
    UITableView     *tView;
    
    UITextField     *nameTF;
    UITextField     *phoneTF;
    UITextField     *emailTF;
    UITextField     *postailTF;
    UILabel         *areaLb;
    UITextField     *detailTF;
    
    NSMutableArray  *provinceTitleArr;
    UIView          *bgView;                    //地区界面
    UIPickerView    *areaPickView;
    UIToolbar       *finishBar;
    
    NSInteger       currentProvinceIndex;       //第一列选择的省份，方便显示 市名
    NSInteger       currentCityIndex;           //地二列选择的市名，方便显示 县/地区名
    NSString        *selectProvince;
    NSString        *selectCity;
    NSString        *selectCounty;
}

@end

@implementation AddressDetailViewController

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
    if(self.addressObj){
        [self setNavBarTitle:@"地址管理"];
        
        NSArray *arr = [self.addressObj.addressArea componentsSeparatedByString:@"-"];
        if(arr.count >= 3){
            selectProvince  = arr[0];
            selectCity      = arr[1];
            selectCounty    = arr[2];
        }
        
    }else{
        [self setNavBarTitle:@"添加地址"];
        selectProvince          = @"北京";
        selectCity              = @"北京市辖";
        selectCounty            = @"东城区";
    }
    [self hiddenRightBtn];
    
    provinceTitleArr        = [NSMutableArray arrayWithCapacity:35];
    currentCityIndex        = 0;
    currentProvinceIndex    = 0;
    
    [self buildBaseView];
    
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
}

-(void)viewTapped:(UITapGestureRecognizer*)tapGr
{
    [nameTF resignFirstResponder];
    [phoneTF resignFirstResponder];
    //[emailTF resignFirstResponder];
    //[postailTF resignFirstResponder];
    [detailTF resignFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
     [tView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)buildBaseView
{
    tView = [[UITableView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(0, Navbar_Height, Main_Size.width, Main_Size.height - StatusBar_Height - Navbar_Height)] style:UITableViewStyleGrouped];
    [tView setDataSource:self];
    [tView setDelegate:self];
    [tView setBackgroundView:nil];
    [tView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:tView];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Main_Size.width, 60)];
    [tView setTableFooterView:footerView];
    
    if(self.addressObj){
        UIButton *addAddressBt = [GlobalMethod BuildButtonWithFrame:CGRectMake(50, 5, 100, 40)
                                                          andOffImg:@"login_off"
                                                           andOnImg:@"login_on"
                                                          withTitle:@"保存地址"];
        [addAddressBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [addAddressBt.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [addAddressBt addTarget:self action:@selector(editAddress) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:addAddressBt];
        
        UIButton *deleteAddressBt = [GlobalMethod BuildButtonWithFrame:CGRectMake(170, 5, 100, 40)
                                                             andOffImg:@"login_off"
                                                              andOnImg:@"login_on"
                                                             withTitle:@"删除地址"];
        [deleteAddressBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [deleteAddressBt.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [deleteAddressBt addTarget:self action:@selector(deleteAddress) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:deleteAddressBt];
    }else{
        UIButton *addAddressBt = [GlobalMethod BuildButtonWithFrame:CGRectMake(110, 5, 100, 40)
                                                          andOffImg:@"login_off"
                                                           andOnImg:@"login_on"
                                                          withTitle:@"添加地址"];
        [addAddressBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [addAddressBt.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [addAddressBt addTarget:self action:@selector(addAddress) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:addAddressBt];
    }
    
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, Main_Size.height, Main_Size.width, 162+Navbar_Height)];
    [bgView setBackgroundColor:[UIColor whiteColor]];
    [bgView.layer setBorderWidth:0.5];
    [bgView.layer setBorderColor:NavBarColor.CGColor];
    [self.view addSubview:bgView];
    
    finishBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, Main_Size.width, Navbar_Height)];
    [finishBar setBarStyle:UIBarStyleDefault];
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *finishItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(finishChoiceArea)];
    [finishBar setItems:[NSArray arrayWithObjects:spaceItem,finishItem,nil]];
    [bgView addSubview:finishBar];
    
    areaPickView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, Navbar_Height, Main_Size.width, 162)];
    [areaPickView setDelegate:self];
    [areaPickView setDataSource:self];
    [areaPickView setShowsSelectionIndicator:YES];
    [areaPickView setBackgroundColor:[UIColor whiteColor]];
    [bgView addSubview:areaPickView];
    
    [self showHUDInView:self.view WithText:NETWORKLOADING];
    HTTPRequest *hq = [HTTPRequest shareInstance_myapi];
    BLOCK_SELF(AddressDetailViewController);
    NSDictionary *dic = @{@"pid":@"0001",@"child":@"1"};
    [hq GETURLString:SYSTEM_AREAS userCache:YES parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObj) {
        NSDictionary *rqDic = (NSDictionary *)responseObj;
        if([rqDic[HTTP_STATE] boolValue]){
            
            NSDictionary *countryDic = (NSDictionary *)[rqDic[HTTP_DATA] objectFromJSONString];
            
            NSArray *proArr = (NSArray *)countryDic[@"AChildData"];
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_group_t group = dispatch_group_create();
            for(int i=0; i<proArr.count; i++)
            {
                dispatch_group_async(group, queue, ^{
                    
                    NSDictionary *proDic = (NSDictionary *)proArr[i];
                    
                    NSArray *cityArr = (NSArray *)proDic[@"AChildData"];
                    NSMutableArray *cityTitleArr = [NSMutableArray arrayWithCapacity:10];
                    for(int i=0; i<cityArr.count; i++){
                        NSDictionary *cityDic = (NSDictionary *)cityArr[i];
                        
                        NSArray *countyArr = (NSArray *)cityDic[@"AChildData"];
                        NSMutableArray *countyTitleArr = [NSMutableArray arrayWithCapacity:10];
                        for(int i=0; i<countyArr.count; i++){
                            NSDictionary *countyDic = (NSDictionary *)countyArr[i];
                            [countyTitleArr addObject:countyDic[@"AName"]];
                        }
                        
                        NSDictionary *city_countyDic = @{CITY_TITLE:cityDic[@"AName"], COUNTY_TITLE:countyTitleArr};
                        
                        [cityTitleArr addObject:city_countyDic];
                    }
                    
                    NSDictionary *pro_cityDic = @{PROVINCE_TITLE:proDic[@"AName"],CITY_TITLE:cityTitleArr};
                    
                    /*
                     解构：provinceTitleArr{ "PROVINCE_TITLE":"省名",
                     "CITY_TITLE":{ CITY_TITLE:@"城市名", COUNTY_TITLE : @"县/区 名数组" }
                     }
                     */
                    [provinceTitleArr addObject:pro_cityDic];
                });
                
                dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
            }
            
            [self writeAddressArea];
            
            [areaPickView reloadAllComponents]; 
            [self hideHUDInView:block_self.view];
            
        }else{
            NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
            [self readAddressArea];
            [self hideHUDInView:block_self.view];
            [self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self readAddressArea];
        [self hideHUDInView:block_self.view];
        [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
    }];
}

- (void)writeAddressArea{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        if( ![provinceTitleArr isEqualToArray:[GlobalMethod getObjectForKey:ADDRESS_AREA_ARR]] ){
            [GlobalMethod saveObject:provinceTitleArr withKey:ADDRESS_AREA_ARR];
        }
        
    });
}

- (void)readAddressArea{
    if(provinceTitleArr.count == 0){
        
        provinceTitleArr = [GlobalMethod getObjectForKey:ADDRESS_AREA_ARR];
        
        [areaPickView reloadAllComponents];
    }
}

#pragma mark ViewAction
- (void)finishChoiceArea{
    [UIView animateWithDuration:0.3 animations:^{
        [bgView setFrame:CGRectMake(0, Main_Size.height, Main_Size.width, 162 + Navbar_Height)];
    }];
    
    [areaLb setText:[NSString stringWithFormat:@"%@-%@-%@",selectProvince,selectCity,selectCounty]];
}


- (void)addAddress{
    
    //信息不完全或者不合理
    if( ![self isUseAddressInfo] ){
        return ;
    }
    
    UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
    
    BLOCK_SELF(AddressDetailViewController);
    HTTPRequest *hq = [HTTPRequest shareInstance];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:10];
    [dic setObject:user.im          forKey:@"URA_UserLogin"];
    [dic setObject:nameTF.text      forKey:@"URA_RecName"];
    [dic setObject:detailTF.text    forKey:@"URA_Address"];
    //[dic setObject:postailTF.text   forKey:@"URA_Post"];
    [dic setObject:phoneTF.text     forKey:@"URA_Mobile"];
    //[dic setObject:emailTF.text     forKey:@"URA_Email"];
    [dic setObject:selectProvince   forKey:@"URA_Province"];
    [dic setObject:selectCity       forKey:@"URA_City"];
    [dic setObject:selectCounty     forKey:@"URA_Area"];
    
    if(self.shouldDefaultAddress){
        [dic setObject:@"true"  forKey:@"URA_IsDefault"];
    }
    
    [hq POSTURLString:ADD_ADDRESS parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rqDic = (NSDictionary *)responseObject;
        if([rqDic[HTTP_STATE] boolValue]){
            
            NSDictionary *dataDic = (NSDictionary *)[rqDic[HTTP_DATA] objectFromJSONString];
            if([dataDic[@"result"] boolValue]){
                DLog(@"添加地址成功");
                
                [self.navigationController popViewControllerAnimated:YES];
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
}

- (void)editAddress{
    //信息不完全或者不合理
    if( ![self isUseAddressInfo] ){
        return ;
    }
    
    UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
    
    BLOCK_SELF(AddressDetailViewController);
    HTTPRequest *hq = [HTTPRequest shareInstance];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:10];
    [dic setObject:user.im          forKey:@"URA_UserLogin"];
    [dic setObject:nameTF.text      forKey:@"URA_RecName"];
    [dic setObject:detailTF.text    forKey:@"URA_Address"];
//    [dic setObject:postailTF.text   forKey:@"URA_Post"];
    [dic setObject:phoneTF.text     forKey:@"URA_Mobile"];
//    [dic setObject:emailTF.text     forKey:@"URA_Email"];
    [dic setObject:self.addressObj.addressId forKey:@"URA_Id"];
    [dic setObject:selectProvince   forKey:@"URA_Province"];
    [dic setObject:selectCity       forKey:@"URA_City"];
    [dic setObject:selectCounty     forKey:@"URA_Area"];
    
    [hq POSTURLString:EDIT_ADDRESS parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rqDic = (NSDictionary *)responseObject;
        if([rqDic[HTTP_STATE] boolValue]){
            
            NSDictionary *dataDic = (NSDictionary *)[rqDic[HTTP_DATA] objectFromJSONString];
            if([dataDic[@"result"] boolValue]){
                DLog(@"修改地址");
                [self.navigationController popViewControllerAnimated:YES];
            }
        }else{
            NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
            [self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"%@",error);
        [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
    }];
}

- (void)deleteAddress{

    
    UIAlertView *deleteView = [[UIAlertView alloc] initWithTitle:@"确定要删除该地址吗?" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [deleteView show];
}


- (BOOL)isUseAddressInfo{
    
    if(nameTF.text.length == 0){
        [self showHUDInView:self.view WithText:@"请输入姓名" andDelay:LOADING_TIME];
        return NO;
    }else if (nameTF.text.length > 10){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"姓名不要超过10个字符" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
    if(phoneTF.text.length == 0){
        [self showHUDInView:self.view WithText:@"请输入手机号码" andDelay:LOADING_TIME];
        return NO;
    }else{
        NSString *regex = @"^((13[0-9])|(147)|(15[^4,\\D])|(17[6-8])|(18[0-9]))\\d{8}$";
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        BOOL isMatch = [pred evaluateWithObject:phoneTF.text];
        if( !isMatch ){
            [self showHUDInView:self.view WithText:@"请输入正确的手机号码" andDelay:LOADING_TIME];
            return NO;
        }
    }
    
    if(detailTF.text.length > 20){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"详细地址不要超过20个字符" delegate:nil cancelButtonTitle:@"知道了"otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
//    if(emailTF.text.length == 0){
//        [self showHUDInView:self.view WithText:@"请输入email" andDelay:LOADING_TIME];
//        return NO;
//    }else{
//        BOOL isMatch = [emailTF.text isMatchedByRegex:@"\\b([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})\\b"];
//        if( !isMatch ){
//            [self showHUDInView:self.view WithText:@"请输入正确的email" andDelay:LOADING_TIME];
//            return NO;
//        }
//    }
    
//    if (detailTF.text.length == 0) {
//        [self showHUDInView:self.view WithText:@"请输入详细地址" andDelay:LOADING_TIME];
//        return NO;
//    }
    
    return YES;
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == alertView.cancelButtonIndex){
        DLog(@"取消");
    }else{
        UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
        
        BLOCK_SELF(AddressDetailViewController);
        HTTPRequest *hq = [HTTPRequest shareInstance];
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:10];
        [dic setObject:self.addressObj.addressId forKey:@"ID"];
        [dic setObject:user.im forKey:@"userlogin"];
        
        [hq GETURLString:DELETE_ADDRESS parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObj) {
            NSDictionary *rqDic = (NSDictionary *)responseObj;
            if([rqDic[HTTP_STATE] boolValue]){
                
                NSDictionary *dataDic = (NSDictionary *)[rqDic[HTTP_DATA] objectFromJSONString];
                if([dataDic[@"result"] boolValue]){
                    DLog(@"删除地址成功");
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }else{
                NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
                [self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"%@",error);
            [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
        }];
    }
}

#pragma mark
#pragma mark UItableView methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"address_detail_cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        switch (indexPath.row) {
            case 0:
            {
                nameTF = [GlobalMethod BuildTextFieldWithFrame:CGRectMake(10, 10, 250, 24)
                                                andPlaceholder:@"收货人姓名（必填）"];
                [nameTF setLeftViewMode:UITextFieldViewModeAlways];
                UILabel *l = [GlobalMethod BuildLableWithFrame:CGRectMake(0, 9, 60, 24)
                                                      withFont:[UIFont systemFontOfSize:12]
                                                      withText:@"姓       名"];
                [nameTF setLeftView:l];
                
                [nameTF setText:self.addressObj.addressName];
                [nameTF setFont:[UIFont systemFontOfSize:12]];
                [nameTF setDelegate:self];
                [nameTF setKeyboardType:UIKeyboardTypeNamePhonePad];
                [nameTF setReturnKeyType:UIReturnKeyNext];
                [cell.contentView addSubview:nameTF];
            }
                break;
                
            case 1:
            {
                phoneTF = [GlobalMethod BuildTextFieldWithFrame:CGRectMake(10, 10, 250, 24)
                                                 andPlaceholder:@"手机号码（必填）"];
                [phoneTF setLeftViewMode:UITextFieldViewModeAlways];
                
                UILabel *l = [GlobalMethod BuildLableWithFrame:CGRectMake(0, 9, 60, 24)
                                                      withFont:[UIFont systemFontOfSize:12]
                                                      withText:@"手机号码"];
                [phoneTF setLeftView:l];
                [phoneTF setText:self.addressObj.phoneNum];
                [phoneTF setFont:[UIFont systemFontOfSize:12]];
                [phoneTF setDelegate:self];
                [phoneTF setKeyboardType:UIKeyboardTypeNumberPad];
                [phoneTF setReturnKeyType:UIReturnKeyNext];
                [cell.contentView addSubview:phoneTF];
            }
                break;
                
//            case 2:
//            {
//                emailTF = [GlobalMethod BuildTextFieldWithFrame:CGRectMake(10, 10, 250, 24)
//                                                 andPlaceholder:@"Email（必填）"];
//                [emailTF setLeftViewMode:UITextFieldViewModeAlways];
//                
//                UILabel *l = [GlobalMethod BuildLableWithFrame:CGRectMake(0, 9, 60, 24)
//                                                      withFont:[UIFont systemFontOfSize:12]
//                                                      withText:@" Email"];
//                [emailTF setLeftView:l];
//                [emailTF setText:self.addressObj.email];
//                [emailTF setFont:[UIFont systemFontOfSize:12]];
//                [emailTF setDelegate:self];
//                [emailTF setKeyboardType:UIKeyboardTypeEmailAddress];
//                [emailTF setReturnKeyType:UIReturnKeyNext];
//                [cell.contentView addSubview:emailTF];
//            }
//                break;
//                
//            case 3:
//            {
//                postailTF = [GlobalMethod BuildTextFieldWithFrame:CGRectMake(10, 10, 250, 24)
//                                                   andPlaceholder:@"邮政编码"];
//                [postailTF setLeftViewMode:UITextFieldViewModeAlways];
//                
//                UILabel *l = [GlobalMethod BuildLableWithFrame:CGRectMake(0, 9, 60, 24)
//                                                      withFont:[UIFont systemFontOfSize:12]
//                                                      withText:@"邮政编码"];
//                [postailTF setLeftView:l];
//                [postailTF setText:self.addressObj.postalCode];
//                [postailTF setFont:[UIFont systemFontOfSize:12]];
//                [postailTF setDelegate:self];
//                [postailTF setKeyboardType:UIKeyboardTypeNumberPad];
//                [postailTF setReturnKeyType:UIReturnKeyNext];
//                [cell.contentView addSubview:postailTF];
//            }
//                break;
                
            case 2:
            {
                UILabel *lb = [GlobalMethod BuildLableWithFrame:CGRectMake(10, 10, 80, 24)
                                                       withFont:[UIFont systemFontOfSize:12]
                                                       withText:@"所在地区"];
                
                [cell.contentView addSubview:lb];
                
                areaLb = [GlobalMethod BuildLableWithFrame:CGRectMake(70, 10, 220, 24)
                                                  withFont:[UIFont systemFontOfSize:12]
                                                  withText:self.addressObj.addressArea];
                [areaLb setTextAlignment:NSTextAlignmentRight];
                [cell.contentView addSubview:areaLb];
                
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }
                break;
                
            case 3:
            {
                detailTF = [GlobalMethod BuildTextFieldWithFrame:CGRectMake(10, 10, 250, 24)
                                                  andPlaceholder:@"详细地址（必填）"];
                [detailTF setLeftViewMode:UITextFieldViewModeAlways];
                
                UILabel *l = [GlobalMethod BuildLableWithFrame:CGRectMake(0, 9, 60, 24)
                                                      withFont:[UIFont systemFontOfSize:12]
                                                      withText:@"详细地址"];
                [detailTF setLeftView:l];
                [detailTF setText:self.addressObj.addressDetail];
                [detailTF setFont:[UIFont systemFontOfSize:12]];
                [detailTF setReturnKeyType:UIReturnKeyDone];
                [detailTF setKeyboardType:UIKeyboardTypeNamePhonePad];
                [detailTF setDelegate:self];
                [cell.contentView addSubview:detailTF];
            }
                break;
                
            default:
                break;
        }
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 2){
        [UIView animateWithDuration:0.3 animations:^{
            [nameTF resignFirstResponder];
            [phoneTF resignFirstResponder];
            //[emailTF resignFirstResponder];
            //[postailTF resignFirstResponder];
            [detailTF resignFirstResponder];
            [bgView setFrame:CGRectMake(0, Main_Size.height - 367 - 44, Main_Size.width, 162+Navbar_Height)];
        }];
    }
}


#pragma mark UItextField
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    if (textField == nameTF) {
        [phoneTF becomeFirstResponder];
    }
    
    if(textField == emailTF){
        [postailTF becomeFirstResponder];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    [UIView animateWithDuration:0.3 animations:^{
        [bgView setFrame:CGRectMake(0, Main_Size.height, Main_Size.width, 162+Navbar_Height)];
    }];
    
    if(textField == detailTF){
        [tView setContentOffset:CGPointMake(0, 130) animated:YES];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if(textField == detailTF){
        [tView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

#pragma mark 
#pragma mark UIPickerMethods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    switch (component) {
        case 0: //省名
        {
            return provinceTitleArr.count;
        }
            break;
            
        case 1:
        {
            if(provinceTitleArr.count > 0){
                NSDictionary *currentCityDic = (NSDictionary *)provinceTitleArr[currentProvinceIndex];
                NSArray *currentCityArr = (NSArray *)currentCityDic[CITY_TITLE];
                return currentCityArr.count;
            }
        }
            break;
            
        case 2:
        {
            if(provinceTitleArr.count > 0){
                NSDictionary *currentCityDic = (NSDictionary *)provinceTitleArr[currentProvinceIndex];
                NSArray *currentCityArr = (NSArray *)currentCityDic[CITY_TITLE];
                if(currentCityArr.count > 0){
                    NSDictionary *currentCountyDic = (NSDictionary *)currentCityArr[currentCityIndex];
                    NSArray *currentCountyArr = (NSArray *)currentCountyDic[COUNTY_TITLE];
                    return currentCountyArr.count;
                }
            }
        }
            break;
            
        default:
            break;
    }
    
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    switch (component) {
        case 0: //省名
        {
            return [provinceTitleArr[row] objectForKey:PROVINCE_TITLE];
        }
            break;
            
        case 1:
        {
            if(provinceTitleArr.count > 0){
                NSDictionary *currentCityDic = (NSDictionary *)provinceTitleArr[currentProvinceIndex];
                NSArray *currentCityArr = (NSArray *)currentCityDic[CITY_TITLE];
                return [currentCityArr[row] objectForKey:CITY_TITLE];
            }
        }
            break;
            
        case 2:
        {
            if(provinceTitleArr.count > 0){
                NSDictionary *currentCityDic = (NSDictionary *)provinceTitleArr[currentProvinceIndex];
                NSArray *currentCityArr = (NSArray *)currentCityDic[CITY_TITLE];
                if(currentCityArr.count > 0){
                    NSDictionary *currentCountyDic = (NSDictionary *)currentCityArr[currentCityIndex];
                    NSArray *currentCountyArr = (NSArray *)currentCountyDic[COUNTY_TITLE];
                    return currentCountyArr[row];
                }
            }
        }
            break;
            
        default:
            break;
    }
    
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    switch (component)  {
        case 0:
        {
            currentProvinceIndex = row;
            currentCityIndex = 0;
            [pickerView reloadComponent:1];
            [pickerView reloadComponent:2];
            [pickerView selectRow:0 inComponent:1 animated:YES];
            [pickerView selectRow:0 inComponent:2 animated:YES];
            
            if(provinceTitleArr.count > 0){
                NSDictionary *currentCityDic = (NSDictionary *)provinceTitleArr[currentProvinceIndex];
                NSArray *currentCityArr = (NSArray *)currentCityDic[CITY_TITLE];
                if(currentCityArr.count > 0){
                    NSDictionary *currentCountyDic = (NSDictionary *)currentCityArr[currentCityIndex];
                    NSArray *currentCountyArr = (NSArray *)currentCountyDic[COUNTY_TITLE];
                    
                    selectProvince  = [provinceTitleArr[row] objectForKey:PROVINCE_TITLE];
                    selectCity      = [currentCityArr[0] objectForKey:CITY_TITLE];
                    selectCounty    = currentCountyArr[0];
                }
            }
        }
            break;
            
        case 1:
        {
            currentCityIndex = row;
            [pickerView reloadComponent:2];
            [pickerView selectRow:0 inComponent:2 animated:YES];
            
            
            if(provinceTitleArr.count > 0){
                NSDictionary *currentCityDic = (NSDictionary *)provinceTitleArr[currentProvinceIndex];
                NSArray *currentCityArr = (NSArray *)currentCityDic[CITY_TITLE];
                if(currentCityArr.count > 0){
                    NSDictionary *currentCountyDic = (NSDictionary *)currentCityArr[currentCityIndex];
                    NSArray *currentCountyArr = (NSArray *)currentCountyDic[COUNTY_TITLE];
                    
                    selectCity      = [currentCityArr[row] objectForKey:CITY_TITLE];
                    selectCounty    = currentCountyArr[0];
                }
            }
        }
            break;
            
        case 2:
        {
            if(provinceTitleArr.count > 0){
                NSDictionary *currentCityDic = (NSDictionary *)provinceTitleArr[currentProvinceIndex];
                NSArray *currentCityArr = (NSArray *)currentCityDic[CITY_TITLE];
                if(currentCityArr.count > 0){
                    NSDictionary *currentCountyDic = (NSDictionary *)currentCityArr[currentCityIndex];
                    NSArray *currentCountyArr = (NSArray *)currentCountyDic[COUNTY_TITLE];
                    
                    selectCounty = currentCountyArr[row];
                }
            }
        }
            break;
            
        default:
            break;
    }
    
    DLog(@"选择了 %@省  %@市 %@县/区",selectProvince,selectCity,selectCounty);
    
    [areaLb setText:[NSString stringWithFormat:@"%@-%@-%@",selectProvince,selectCity,selectCounty]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
