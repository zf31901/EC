//
//  AddressManageViewController.m
//  Shop
//
//  Created by Harry on 13-12-26.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

@class AddressObj;

@protocol AddressCellDelegate <NSObject>

- (void)editAddressAtIndex:(NSInteger)index;

@end

@interface AddressCell : UITableViewCell

@property (nonatomic, strong) UIView        *bgView;
@property (nonatomic, strong) UILabel       *nameLb;
@property (nonatomic, strong) UILabel       *areaLb;
@property (nonatomic, strong) UILabel       *detailAddressLb;
@property (nonatomic, strong) UILabel       *phomeLb;
@property (nonatomic, strong) UIView        *editView;
@property (nonatomic, strong) UIImageView   *choiceImg;
@property (nonatomic, strong) UIView        *editingView;
@property (nonatomic, strong) UIView        *nomalView;

@property (nonatomic, assign) id<AddressCellDelegate> _delegate;

- (void)reuserTableViewCell:(AddressObj *)obj AtIndex:(NSInteger)index ShouldChoice:(BOOL)choice;

@end

#import "AddressObj.h"
#import <QuartzCore/QuartzCore.h>

@implementation AddressCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.bgView = [[UIView alloc] initWithFrame:CGRectMake(-1, 10, 322, 100)];
        [self.bgView setUserInteractionEnabled:YES];
        [self.bgView setBackgroundColor:[UIColor whiteColor]];
        [self.bgView.layer setBorderColor:RGBS(201).CGColor];
        [self.bgView.layer setBorderWidth:1];
        [self.contentView addSubview:self.bgView];
        
        self.nameLb = [GlobalMethod BuildLableWithFrame:CGRectMake(20, 10, 100, 13)
                                               withFont:[UIFont systemFontOfSize:12]
                                               withText:nil];
        [self.nameLb setTextColor:RGBS(51)];
        [self.bgView addSubview:self.nameLb];
        
        self.areaLb = [GlobalMethod BuildLableWithFrame:CGRectMake(20, self.nameLb.bottom + 10, 170, 13)
                                               withFont:[UIFont systemFontOfSize:12]
                                               withText:nil];
        [self.areaLb setTextColor:RGBS(51)];
        [self.bgView addSubview:self.areaLb];
        
        self.detailAddressLb = [GlobalMethod BuildLableWithFrame:CGRectMake(20, self.areaLb.bottom + 6, 170, 13)
                                               withFont:[UIFont systemFontOfSize:12]
                                               withText:nil];
        [self.detailAddressLb setTextColor:RGBS(51)];
        [self.detailAddressLb setNumberOfLines:1];
        [self.bgView addSubview:self.detailAddressLb];
        
        self.phomeLb = [GlobalMethod BuildLableWithFrame:CGRectMake(20, self.detailAddressLb.bottom + 10, 170, 13)
                                                withFont:[UIFont systemFontOfSize:12]
                                                withText:nil];
        [self.phomeLb setTextColor:RGBS(51)];
        [self.bgView addSubview:self.phomeLb];
        
        self.editView = [[UIView alloc] initWithFrame:CGRectMake(270, 0, 50, 100)];
        [self.bgView addSubview:self.editView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editAddress:)];
        [self.editView addGestureRecognizer:tap];
        
        //选中状态
        self.editingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 100)];
        [self.editingView setBackgroundColor:RGBS(245)];
        UIImageView *i1 = [[UIImageView alloc] initWithFrame:CGRectMake(13, 38, 23, 23)];
        [i1 setImage:[UIImage imageNamed:@"note1"]];
        [self.editingView addSubview:i1];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.5, 100)];
        [line setBackgroundColor:RGB(197, 0, 1)];
        [self.editingView addSubview:line];
        [self.editView addSubview:self.editingView];
        
        self.nomalView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 100)];
        [self.nomalView setBackgroundColor:[UIColor whiteColor]];
        UIImageView *i2 = [[UIImageView alloc] initWithFrame:CGRectMake(13, 38, 23, 23)];
        [i2 setImage:[UIImage imageNamed:@"note2"]];
        [self.nomalView addSubview:i2];
        [self.editView addSubview:self.nomalView];
        
        self.choiceImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [self.choiceImg setImage:[UIImage imageNamed:@"current-icon"]];
        [self.bgView addSubview:self.choiceImg];
    }
    return self;
}

- (void)reuserTableViewCell:(AddressObj *)obj AtIndex:(NSInteger)index ShouldChoice:(BOOL)choice
{
    [self.nameLb            setText:obj.addressName];
    [self.areaLb            setText:obj.addressArea];
    [self.detailAddressLb   setText:obj.addressDetail];
    [self.phomeLb           setText:obj.phoneNum];
    [self.editView          setTag:index];
    
    if(obj.isChoiceAddress){
        [self.bgView.layer setBorderColor:RGB(197, 0, 1).CGColor];
        [self.editView bringSubviewToFront:self.editingView];
        [self.choiceImg setAlpha:1];
    }else{
        [self.bgView.layer setBorderColor:RGBS(201).CGColor];
        [self.editView bringSubviewToFront:self.nomalView];
        [self.choiceImg setAlpha:0];
    }
}

- (void)editAddress:(UITapGestureRecognizer *)tap
{
    if(self._delegate && [self._delegate respondsToSelector:@selector(editAddressAtIndex:)]){
        [self._delegate editAddressAtIndex:[tap view].tag];
    }
}

@end



#import "AddressManageViewController.h"
#import "AddressDetailViewController.h"
#import "AddressObj.h"
#import "HTTPRequest.h"
#import "JSONKit.h"

@interface AddressManageViewController ()<AddressCellDelegate>
{
    NSMutableArray          *addressArr;
}

@end

@implementation AddressManageViewController

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
    
    [self setNavBarTitle:@"收货地址管理"];
    UIButton *rightBtn = [self getRightButton];
    [rightBtn setImage:[UIImage imageNamed:@"address-empty-body-add-icon"] forState:UIControlStateNormal];

    [self resetMainTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadDataSource];
    
    [MobClick event:DZGL];
}

- (void)loadDataSource
{
    addressArr = [NSMutableArray arrayWithCapacity:10];
    
    UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
    
    [self showHUDInView:self.view WithText:NETWORKLOADING];
    HTTPRequest *hq = [HTTPRequest shareInstance];
    BLOCK_SELF(AddressManageViewController);
    NSDictionary *dic = @{@"userlogin" : user.im?user.im:@""};
    [hq GETURLString:ADDRESS_LIST userCache:NO parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObj) {
        NSDictionary *rqDic = (NSDictionary *)responseObj;
        if([rqDic[HTTP_STATE] boolValue]){
            
            NSArray *dataArr = (NSArray *)[rqDic[HTTP_DATA] objectFromJSONString];
            
            for(int i=0; i<dataArr.count; i++){
                NSDictionary *dic = (NSDictionary *)dataArr[i];
                AddressObj *obj = [AddressObj shareInstance];
                [obj setAddressId:dic[@"URA_Id"]];
                [obj setAddressName:dic[@"URA_RecName"]];
                [obj setAddressArea:[NSString stringWithFormat:@"%@-%@-%@",dic[@"URA_Province"],dic[@"URA_City"],dic[@"URA_Area"]]];
                [obj setAddressDetail:dic[@"URA_Address"]];
                [obj setEmail:dic[@"URA_Email"]];
                [obj setPostalCode:dic[@"URA_Post"]];
                [obj setPhoneNum:dic[@"URA_Mobile"]];
                [obj setIsChoiceAddress:[dic[@"URA_IsDefault"] boolValue]];

                [addressArr addObject:obj];
            }

            [self.mainTableView reloadData];
            [self finishReloadingData];
            [self hideHUDInView:block_self.view];
            
        }else{
            NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
            [self finishReloadingData];
            [self hideHUDInView:block_self.view];
            [self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self finishReloadingData];
        [self hideHUDInView:block_self.view];
        [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
    }];
}

- (void)resetMainTableView
{
    [self.mainTableView setFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(0, Navbar_Height, Main_Size.width, Main_Size.height - StatusBar_Height - Navbar_Height)]];
    [self.mainTableView setShowsVerticalScrollIndicator:NO];
    [self.mainTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self hiddenFooterView];
}

#pragma mark ViewAction
- (void)rightBtnAction:(UIButton *)btn
{
    AddressDetailViewController *addDView = [AddressDetailViewController shareInstance];
    
    //第一次新增地址时，设置为默认地址
    if(addressArr.count == 0){
        [addDView setShouldDefaultAddress:YES];
    }
    
    [self.navigationController pushViewController:addDView animated:YES];
}

- (void)leftBtnAction:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Delegate
#pragma mark UITableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(addressArr.count == 0){
        return 1;
    }
    return addressArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(addressArr.count == 0){
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        [cell setBackgroundColor:RGBS(238)];
        UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(0, 10, 320, 44)];
        [bg setBackgroundColor:[UIColor whiteColor]];
        [cell addSubview:bg];
        
        UILabel *lb = [GlobalMethod BuildLableWithFrame:CGRectMake(20, 14, 100, 17)
                                               withFont:[UIFont systemFontOfSize:16]
                                               withText:@"马上创建"];
        [bg addSubview:lb];

        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }
    
    static NSString *indifiter = @"address_cell";
    AddressCell *cell = [tableView dequeueReusableCellWithIdentifier:indifiter];
    if(!cell){
        cell = [[AddressCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indifiter];
    }
    
    [cell set_delegate:self];
    [cell setBackgroundColor:RGBS(238)];
    [cell reuserTableViewCell:addressArr[indexPath.row] AtIndex:indexPath.row ShouldChoice:self.shouldChoiceAddress];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(addressArr.count == 0){
        return 60;
    }
    return 110;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //添加第一个地址
    if(addressArr.count == 0){
        AddressDetailViewController *addressDVC = [AddressDetailViewController shareInstance];
        [addressDVC setShouldDefaultAddress:YES];
        [self.navigationController pushViewController:addressDVC animated:YES];
    }else{
        
        //标志地址选中状态
        for(int i=0; i<addressArr.count; i++){
            AddressObj *obj = addressArr[i];
            [obj setIsChoiceAddress:NO];
        }

        __block AddressObj *obj = addressArr[indexPath.row];
        UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
        
        BLOCK_SELF(AddressManageViewController);
        HTTPRequest *hq = [HTTPRequest shareInstance];
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:10];
        [dic setObject:user.im              forKey:@"URA_UserLogin"];
        [dic setObject:obj.addressName      forKey:@"URA_RecName"];
        [dic setObject:obj.addressDetail    forKey:@"URA_Address"];
        [dic setObject:obj.postalCode       forKey:@"URA_Post"];
        [dic setObject:obj.phoneNum         forKey:@"URA_Mobile"];
        [dic setObject:obj.email            forKey:@"URA_Email"];
        [dic setObject:obj.addressId        forKey:@"URA_Id"];
        [dic setObject:@"true"              forKey:@"URA_IsDefault"];
        
        [hq POSTURLString:EDIT_ADDRESS parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *rqDic = (NSDictionary *)responseObject;
            if([rqDic[HTTP_STATE] boolValue]){
                
                NSDictionary *dataDic = (NSDictionary *)[rqDic[HTTP_DATA] objectFromJSONString];
                if([dataDic[@"result"] boolValue]){
                    
                    [obj setIsChoiceAddress:YES];
                    [self.mainTableView reloadData];
                }
            }else{
                NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
                [self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"%@",error);
            [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
        }];
        
        //用来判断是从购物车的结算界面近来还是 收货地址管理进来的，若是从购物车的结算界面进来，那么选择后会回到购物车的结算界面
        if(self.shouldChoiceAddress){
            [self performSelector:@selector(leftBtnAction:) withObject:nil afterDelay:0.5];
        }
    }
}


#pragma mark EgoTableView Method
- (void)refreshView
{
    [self loadDataSource];
}


- (void)editAddressAtIndex:(NSInteger)index{
    
    for(int i=0; i<addressArr.count; i++){
        AddressObj *obj = addressArr[i];
        [obj setIsChoiceAddress:NO];
    }
    AddressObj *obj = addressArr[index];
    [obj setIsChoiceAddress:YES];
    
    [self.mainTableView reloadData];
    [self performSelector:@selector(editAddressDelay:) withObject:[NSNumber numberWithInteger:index] afterDelay:0.5];
}

- (void)editAddressDelay:(NSNumber *)number
{
    AddressDetailViewController *addressDVC = [AddressDetailViewController shareInstance];
    [addressDVC setAddressObj:addressArr[number.integerValue]];
    [self.navigationController pushViewController:addressDVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
