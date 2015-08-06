//
//  CartViewController.m
//  EwtStores
//
//  Created by Harry on 13-11-30.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "CartViewController.h"
#import "UserObj.h"
#import "LoginInViewController.h"
#import "CartOfProductCell.h"
#import "ProductObj.h"
#import "SettleViewController.h"
#import "AddressDetailViewController.h"

#import "HTTPRequest.h"
#import "JSONKit.h"
#import <QuartzCore/QuartzCore.h>

#import "HarryButton.h"
#import "UIButton+Extensions.h"

CartViewController *cartVC;

//删除单行／多行
typedef NS_ENUM(NSInteger, DELETE_PRODUCT_MODE){
    DELETE_PRODUCT_ALL = -1,
    DELETE_PRODUCT_LINE,
};

@interface CartViewController ()<CartOfProductCellDelegate>
{
    UIView          *emptyView;
    UIView          *submitView;    //结算界面
    UILabel         *totalPriceLb;  //购物车总价Lb
    CGFloat         totalPrice;     //购物车总价
    UIButton        *submitBt;      //结算按钮
    HarryButton     *statusBt;      //全选或者不全选
    
    CGFloat         tabBar_height;
    
    NSMutableArray  *cartProArr;                //购物车 中的 商品
    NSMutableArray  *submitProArr;              //要提交 的商品
    
    BOOL            isTotalChoice;              //是否全选
    BOOL            isShowRightView;            //是否显示右边的view
    BOOL            shouldDeleteView;           //是否 显示可以删除界面
    
    NSInteger       cartProductNum;             //选中 删除或者结算 购物车的商品总数
}

@end

@implementation CartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.isRootNavC = YES;
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
        [self showLeftBtn];
        tabBar_height = 0;
    }

    [self setRightBtnOffImg:nil andOnImg:nil andTitle:@"编辑"];
    [self setNavBarTitle:@"购物车"];
    
    cartProArr = [NSMutableArray arrayWithCapacity:13];
    submitProArr = [NSMutableArray arrayWithCapacity:13];
    totalPrice = 0;
    cartProductNum = 0;
    shouldDeleteView = YES;
    
    //[self loadDataSource];
    
    [self resetMainTableView];
    
    cartVC = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //只要进入该界面，取消编辑状态
    UIButton *rightBt = [self getRightButton];
    [rightBt setTitle:@"编辑" forState:UIControlStateNormal];
    [rightBt setTitle:@"编辑" forState:UIControlStateHighlighted];
    isShowRightView = NO;
    isTotalChoice = YES;
    [self.mainTableView reloadData];
    
    if([[GlobalMethod getObjectForKey:CART_PRODUCT_COUNT] integerValue] == 0){
        [self hiddenRightBtn];
    }else{
        [self showRightBtn];
    }
    
    [self loadDataSource];
    
    [MobClick event:GWC];
}

/**
 *  解析库存中商品的个数
 *
 *  @param string 库存字段
 *
 *  @return 库存中商品的个数
 */
- (NSString *)getProductNumWithString:(NSString *)string{
    
    //成功的string ： 1&有货&1.00
    
    if([string isKindOfClass:[NSNull class]] || string.length == 0){
        return nil;
    }
    
    NSArray *array = [string componentsSeparatedByString:@"&"];
    if(array.count == 3){
        return array[2];
    }
    
    return nil;
}


- (void)loadDataSource
{
    [cartProArr removeAllObjects];
    [submitProArr removeAllObjects];
    totalPrice = 0;
    cartProductNum = 0;
    
    UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
    
    [self showHUDInView:self.tabBarController.view WithText:NETWORKLOADING];
    HTTPRequest *hq = [HTTPRequest shareInstance];
    BLOCK_SELF(CartViewController);
    NSDictionary *dic = @{@"userlogin" : user.im?user.im:@""};
    [hq GETURLString:USER_SHOPCART_LIST userCache:NO parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObj) {
        NSDictionary *rqDic = (NSDictionary *)responseObj;
        if([rqDic[HTTP_STATE] boolValue]){
            
            NSArray *dataArr = (NSArray *)[rqDic[HTTP_DATA] objectFromJSONString];
    
            UIButton *rightBt = [self getRightButton];
            if ([rightBt.currentTitle isEqualToString:@"编辑"]) {
                isTotalChoice = YES;
                statusBt.choiceStatus = NO;
                [statusBt changeBackgroundImage];
            }else{
                isTotalChoice = NO;
                statusBt.choiceStatus = YES;
                [statusBt changeBackgroundImage];
            }
            
            int cart_product_num = 0;
            
            for(int i=0; i<dataArr.count; i++){
                NSDictionary *dic = dataArr[i];
                
                ProductObj *cartObj = [ProductObj shareInstance];
                [cartObj setName:dic[@"USCProductName"]];
                [cartObj setProductId:dic[@"USCProductID"]];
                [cartObj setProductCId:dic[@"USCID"]];
                [cartObj setProductBarCode:dic[@"USCProductBarCode"]];
                [cartObj setProductScrial:dic[@"USCProductSerial"]];
                [cartObj setListImgUrl:[NSURL URLWithString:dic[@"USCProductImage"]]];
                [cartObj setPriceUnKnow:[dic[@"USCPriceUnknow"] boolValue]];
                [cartObj setPrefer:dic[@"USCPrefer"]];
                [cartObj setIntegral:dic[@"USCIntegral"]];
                [cartObj setCoupon:dic[@"USCCoupon"]];
                [cartObj setSalePrice:dic[@"USCProductPrice"]];
                [cartObj setNumber:dic[@"USCQuantity"]];
                [cartObj setLinkUrl:dic[@"USCUrl"]];
                [cartObj setUserLogin:dic[@"USCUserlogin"]];
                [cartObj setWeight:dic[@"USCWeight"]];
                
                //只要刷新，默认全选
                [cartObj setChoiceToSettle:isTotalChoice];
                
                [cartObj setShowRightView:isShowRightView];
                [cartObj setStockNum:[self getProductNumWithString:dic[@"USCStore"]]]; //库存个数
                [cartObj setColor:dic[@"USCRemark"]];
                
                [cartProArr addObject:cartObj];
                totalPrice += [cartObj.number integerValue] * [cartObj.salePrice floatValue];
                cart_product_num += [cartObj.number intValue];
            }
            
            [GlobalMethod saveObject:[NSString stringWithFormat:@"%d",cart_product_num] withKey:CART_PRODUCT_COUNT];
            
            [self performSelectorOnMainThread:@selector(refreshBadge:) withObject:[NSString stringWithFormat:@"%d",cart_product_num] waitUntilDone:NO];
            
            
            [submitProArr removeAllObjects];
            [submitProArr setArray:cartProArr];
            
            for (int i=0; i<submitProArr.count; i++) {
                ProductObj *obj = submitProArr[i];
                cartProductNum += obj.number.integerValue;
            }
            
            [totalPriceLb setText:[NSString stringWithFormat:@"¥ %0.2f",totalPrice]];
            if ([rightBt.currentTitle isEqualToString:@"编辑"]) {
                //结算
                [submitBt setTitle:[NSString stringWithFormat:@"结算(%ld)",(long)cartProductNum] forState:UIControlStateNormal];
                [submitBt setTitle:[NSString stringWithFormat:@"结算(%ld)",(long)cartProductNum] forState:UIControlStateHighlighted];
            }else{
                //批量删除
                [submitBt setTitle:[NSString stringWithFormat:@"批量删除(%ld)",(long)cartProductNum] forState:UIControlStateNormal];
                [submitBt setTitle:[NSString stringWithFormat:@"批量删除(%ld)",(long)cartProductNum] forState:UIControlStateHighlighted];
            }
            
            [self.mainTableView reloadData];
            [self finishReloadingData];
            [self hideHUDInView:block_self.tabBarController.view];
            
            if(dataArr.count == 0){
                [self buildCartEmptyView];
                [self hiddenRightBtn];
            }else{
                [emptyView removeFromSuperview];
                [self showRightBtn];
            }
        }else{
            NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
            [self finishReloadingData];
            [self hideHUDInView:block_self.tabBarController.view];
            [self showHUDInView:block_self.tabBarController.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
            
            [self buildCartEmptyView];
            [self hiddenRightBtn];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self finishReloadingData];
        [self hideHUDInView:block_self.tabBarController.view];
        [self showHUDInView:block_self.tabBarController.view WithText:NETWORKERROR andDelay:LOADING_TIME];
        
        [self buildCartEmptyView];
        [self hiddenRightBtn];
    }];
}


- (void)buildCartEmptyView
{
    [self hiddenRightBtn];
    
    if([emptyView superview] != nil){
        [self.view bringSubviewToFront:emptyView];
        
        return ;
    }
    
    emptyView = [[UIView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(0, Navbar_Height, Main_Size.width, Main_Size.height - StatusBar_Height - Navbar_Height)]];
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
    UIImageView *headView = [[UIImageView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(3, Navbar_Height, 314, 15)]];
    [headView setImage:[UIImage imageNamed:@"shopping-cart-body-bg-01"]];
    [self.view addSubview:headView];
    
    [self.mainTableView setFrame:CGRectMake(10, headView.bottom, 300, Main_Size.height - StatusBar_Height - Navbar_Height - tabBar_height - 15)];
    [self.mainTableView setShowsVerticalScrollIndicator:NO];
    [self.mainTableView setBackgroundColor:[UIColor whiteColor]];
    
     
    [self hiddenFooterView];
    
    UIView *footBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    [footBgView setBackgroundColor:[UIColor clearColor]];
    [self.mainTableView setTableFooterView:footBgView];
    
    submitView = [[UIView alloc] initWithFrame:CGRectMake(0, self.mainTableView.bottom - 50, Main_Size.width, 50)];
    [submitView setBackgroundColor:RGBA(0, 0, 0, 0.5)];
    [self.view addSubview:submitView];
    
    statusBt = [[HarryButton alloc] initWithFrame:CGRectMake(18, 16, 18, 18)
                                                     andOffImg:@"banndUnChoice_white"
                                                      andOnImg:@"autoLoginOn"
                                                     withTitle:nil];
    statusBt.choiceStatus = NO; //默认未选中
    [statusBt setButtonEdgeInsets:UIEdgeInsetsMake(-20, -20, -20, -20)];
    [statusBt addTarget:self action:@selector(backgroundColorChange:) forControlEvents:UIControlEventTouchUpInside];
    [submitView addSubview:statusBt];
    
    UILabel *lb = [GlobalMethod BuildLableWithFrame:CGRectMake(statusBt.right + 8, statusBt.top + 2, 50, 14)
                                           withFont:[UIFont systemFontOfSize:13]
                                           withText:@"总金额:"];
    [lb setTextColor:[UIColor whiteColor]];
    [submitView addSubview:lb];
    totalPriceLb = [GlobalMethod BuildLableWithFrame:CGRectMake(lb.right, statusBt.top, 130, 17)
                                            withFont:[UIFont systemFontOfSize:16]
                                            withText:[NSString stringWithFormat:@"¥ %0.2f",totalPrice]];
    [totalPriceLb setTextColor:[UIColor redColor]];
    [submitView addSubview:totalPriceLb];
    
    submitBt = [GlobalMethod BuildButtonWithFrame:CGRectMake(Main_Size.width - 110, 10, 100, 30) andOffImg:@"settle_accounts_off" andOnImg:@"settle_accounts_on" withTitle:@"结算(0)"];
    [submitBt.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [submitBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitBt addTarget:self action:@selector(submitOrDeletePro) forControlEvents:UIControlEventTouchUpInside];
    [submitView addSubview:submitBt];
}

- (void)submitOrDeletePro{
    UIButton *rightBt = [self getRightButton];
    
    if ([rightBt.currentTitle isEqualToString:@"编辑"]) {
        [self settleCart]; //结算
    }else{
        //批量删除
        
        if (submitProArr.count == 0) {
            [self showHUDInView:self.view WithDetailText:@"尚未选中任何商品" andDelay:LOADING_TIME];
            return ;
        }
        
        [self removeProductWithRequest:DELETE_PRODUCT_ALL];
    }
}


- (void)backgroundColorChange:(HarryButton *)button{
    [button changeBackgroundImage];
    
    isTotalChoice = button.choiceStatus;
    totalPrice = 0;
    cartProductNum = 0;
    [submitProArr removeAllObjects];
    
    if (button.choiceStatus) {
        for (int i=0; i<cartProArr.count; i++) {
            ProductObj *obj = cartProArr[i];
            
            obj.choiceToSettle = YES;
            totalPrice += obj.salePrice.floatValue * obj.number.integerValue;
            
            [submitProArr addObject:obj];
        }
        
        for (int i=0; i<submitProArr.count; i++) {
            ProductObj *obj = submitProArr[i];
            cartProductNum += obj.number.integerValue;
        }
        
    }else{
        for (int i=0; i<cartProArr.count; i++) {
            ProductObj *obj = cartProArr[i];
            
            obj.choiceToSettle = NO;
        }
    }
    
    
    UIButton *rightBt = [self getRightButton];
    
    if ([rightBt.currentTitle isEqualToString:@"编辑"]) {
        //结算
        [submitBt setTitle:[NSString stringWithFormat:@"结算(%ld)",(long)cartProductNum] forState:UIControlStateNormal];
        [submitBt setTitle:[NSString stringWithFormat:@"结算(%ld)",(long)cartProductNum] forState:UIControlStateHighlighted];
    }else{
        //批量删除
        [submitBt setTitle:[NSString stringWithFormat:@"批量删除(%ld)",(long)cartProductNum] forState:UIControlStateNormal];
        [submitBt setTitle:[NSString stringWithFormat:@"批量删除(%ld)",(long)cartProductNum] forState:UIControlStateHighlighted];
    }
    
    [totalPriceLb setText:[NSString stringWithFormat:@"¥ %0.2f",totalPrice]];
    [self.mainTableView reloadData];
}

//结算
- (void)settleCart
{
    if([[GlobalMethod getObjectForKey:CART_PRODUCT_COUNT] integerValue] == 0){
        [self buildCartEmptyView];
        return;
    }
    
    if (submitProArr.count == 0) {
        [self showHUDInView:self.view WithDetailText:@"请选择要结算的商品" andDelay:LOADING_TIME];
        return;
    }
    
    DLog(@"结算");
    
    self.isSubmitSuccess = NO;
    
    SettleViewController *settleVC = [SettleViewController shareInstance];
    [settleVC setProductObjArr:submitProArr];
    [settleVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:settleVC animated:YES];
}

- (void)rightBtnAction:(UIButton *)btn{
    if ([btn.currentTitle isEqualToString:@"编辑"]) {
        [btn setTitle:@"完成" forState:UIControlStateNormal];
        [btn setTitle:@"完成" forState:UIControlStateHighlighted];

        
        isShowRightView = YES;
        shouldDeleteView = NO;
        
        //编辑状态： 全不选
        [submitProArr removeAllObjects];
        cartProductNum = 0;
        statusBt.choiceStatus = YES;
        [statusBt changeBackgroundImage];
        isTotalChoice = NO;
        
        for (int i=0; i<cartProArr.count; i++) {
            ProductObj *obj = cartProArr[i];
            
            obj.choiceToSettle = NO;
            obj.showRightView = YES;
        }
        [self.mainTableView reloadData];
        
        [totalPriceLb setText:@"¥ 0.00"];
        [submitBt setTitle:[NSString stringWithFormat:@"批量删除(%ld)",(long)cartProductNum] forState:UIControlStateNormal];
        [submitBt setTitle:[NSString stringWithFormat:@"批量删除(%ld)",(long)cartProductNum] forState:UIControlStateHighlighted];
        
    }else{
        [btn setTitle:@"编辑" forState:UIControlStateNormal];
        [btn setTitle:@"编辑" forState:UIControlStateHighlighted];

        
        isShowRightView = NO;
        shouldDeleteView = YES;
        
        for (int i=0; i<cartProArr.count; i++) {
            ProductObj *obj = cartProArr[i];
            
            obj.choiceToSettle = YES;
            obj.showRightView = NO;
        }
        
        //编辑状态： 全选
        [submitProArr setArray:cartProArr];
        for (int i=0; i<submitProArr.count; i++) {
            ProductObj *obj = submitProArr[i];
            cartProductNum += obj.number.integerValue;
        }
        statusBt.choiceStatus = YES;
        [statusBt changeBackgroundImage];
        isTotalChoice = YES;
        
        [self.mainTableView reloadData];
        
        [submitBt setTitle:[NSString stringWithFormat:@"结算(%ld)",(long)cartProductNum] forState:UIControlStateNormal];
        [submitBt setTitle:[NSString stringWithFormat:@"结算(%ld)",(long)cartProductNum] forState:UIControlStateHighlighted];
        
        //超过购物车限制时
        if([[GlobalMethod getObjectForKey:CART_PRODUCT_COUNT] integerValue] > 999){
            [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"购物车商品超过上限" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show];
            return ;
        }
        
        NSMutableString *idString = [NSMutableString new];
        NSMutableString *countString = [NSMutableString new];
        for (int i=0; i<submitProArr.count; i++) {
            
            ProductObj *obj = submitProArr[i];
            
            if (i == 0) {
                [idString appendFormat:@"%d",obj.productId.intValue];
                [countString appendFormat:@"%d",obj.number.intValue];
            }else{
                [idString appendFormat:@",%d",obj.productId.intValue];
                [countString appendFormat:@",%d",obj.number.intValue];
            }
        }
        
        if (submitProArr.count == 0) {
            return;
        }
        
        //点击完成，提交数据
        UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
        
        HTTPRequest *hq = [HTTPRequest shareInstance];
        BLOCK_SELF(CartViewController);
        NSDictionary *dic = @{@"userlogin" : user.im?user.im:@"" , @"count":countString, @"productid":idString};
        [hq POSTURLString:EDIT_PRODUCT_FROM_CART parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObj) {
            NSDictionary *rqDic = (NSDictionary *)responseObj;
            if([rqDic[HTTP_STATE] boolValue]){
                
                NSDictionary *dataDic = (NSDictionary *)[rqDic[HTTP_DATA] objectFromJSONString];
                
                if([dataDic[@"result"] boolValue]){
                    DLog(@"修改购物车商品数量成功");
                    
                    [self loadDataSource];
                }
                
                [self hideHUDInView:block_self.view];
                
            }else{
                NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
                [self hideHUDInView:block_self.view];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self hideHUDInView:block_self.view];
        }];
    }
}

#pragma mark Delegate
#pragma mark UITableView Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return cartProArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(cartProArr.count == 0){
        return [[UITableViewCell alloc] init];
    }
    
    static NSString *indifiter = @"cart_product_cell";
    CartOfProductCell *cell = [tableView dequeueReusableCellWithIdentifier:indifiter];
    if(!cell){
        cell = [[CartOfProductCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indifiter];
    }
    
    [cell set_delegate:self];
    [cell reuserTableViewCell:cartProArr[indexPath.row] AtIndex:indexPath.row];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 92;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    CartOfProductCell *cell = (CartOfProductCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell.rightView setHidden:YES];
}


- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    CartOfProductCell *cell = (CartOfProductCell *)[tableView cellForRowAtIndexPath:indexPath];
    [self performSelector:@selector(showCellRightView:) withObject:cell afterDelay:0.5];
}

- (void)showCellRightView:(CartOfProductCell *)cell{
    [cell.rightView setHidden:NO];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (shouldDeleteView) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self removeProductWithRequest:indexPath.row];
    }
}


#pragma mark ProductSpecialListCellDelegate
- (void)editProductAtIndex:(NSInteger)index AndCurrentNum:(NSInteger)num andIsChoicedTap:(BOOL)isChoiceTap{
    cartProductNum = 0;
    totalPrice = 0;

    [submitProArr removeAllObjects];
    for (int i=0; i<cartProArr.count; i++) {
        ProductObj *obj = cartProArr[i];
        if (obj.isChoiceToSettle) {
            totalPrice += obj.salePrice.floatValue * obj.number.integerValue;

            [submitProArr addObject:obj];
        }
    }
    
    for (int i=0; i<submitProArr.count; i++) {
        ProductObj *obj = submitProArr[i];
        cartProductNum += obj.number.integerValue;
    }
    
    [totalPriceLb setText:[NSString stringWithFormat:@"¥ %0.2f",totalPrice]];
    
    
    if (isChoiceTap) {
        
        UIButton *rightBt = [self getRightButton];
        
        if ([rightBt.currentTitle isEqualToString:@"编辑"]) {
            //结算
            [submitBt setTitle:[NSString stringWithFormat:@"结算(%ld)",(long)cartProductNum] forState:UIControlStateNormal];
            [submitBt setTitle:[NSString stringWithFormat:@"结算(%ld)",(long)cartProductNum] forState:UIControlStateHighlighted];
        }else{
            //批量删除
            [submitBt setTitle:[NSString stringWithFormat:@"批量删除(%ld)",(long)cartProductNum] forState:UIControlStateNormal];
            [submitBt setTitle:[NSString stringWithFormat:@"批量删除(%ld)",(long)cartProductNum] forState:UIControlStateHighlighted];
        }
        
        //全选
        if (submitProArr.count == cartProArr.count) {
            isTotalChoice = YES;
            [statusBt changeBackgroundImage];
        }else{
            isTotalChoice = NO;
            statusBt.choiceStatus = YES;
            [statusBt changeBackgroundImage];
        }
    }
}


#pragma mark EgoTableView Method
- (void)refreshView
{
    [self loadDataSource];
}

- (void)refreshBadge:(NSString *)badgeNum{
    if(self.isRootNavC){
        if(badgeNum.integerValue == 0){
            self.navigationController.tabBarItem.badgeValue = nil;
        }else{
            self.navigationController.tabBarItem.badgeValue = badgeNum;
        }
    }
}


#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == alertView.cancelButtonIndex){
        
    }else{
        [self removeProductWithRequest:DELETE_PRODUCT_ALL];
    }
}


//后台请求 删除商品
- (void)removeProductWithRequest:(NSInteger )index{
    
    NSMutableString *removeProductS = [NSMutableString new];
    
    if (index == DELETE_PRODUCT_ALL) {
        for (int i=0; i<submitProArr.count; i++) {
            ProductObj *obj = submitProArr[i];
            
            if (i == 0) {
                [removeProductS appendString:[NSString stringWithFormat:@"%d",obj.productCId.intValue]];
            }else{
                [removeProductS appendString:[NSString stringWithFormat:@",%d",obj.productCId.intValue]];
            }
        }
    }else{
        ProductObj *obj = (ProductObj *)cartProArr[index];
        [removeProductS appendString:[NSString stringWithFormat:@"%d",obj.productCId.intValue]];
    }
    
    BLOCK_SELF(CartViewController);
    HTTPRequest *hq = [HTTPRequest shareInstance];
    NSDictionary *dic = @{@"ID":removeProductS};
    [hq GETURLString:DELETE_PRODCT_FROM_CART parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rqDic = (NSDictionary *)responseObject;
        if([rqDic[HTTP_STATE] boolValue]){
            
            NSDictionary *dataDic = (NSDictionary *)[rqDic[HTTP_DATA] objectFromJSONString];
            if([dataDic[@"result"] boolValue]){
                
                NSMutableArray *indexPathArr = [NSMutableArray new];
                NSMutableIndexSet *indexSet = [NSMutableIndexSet new];
                
                if (index == DELETE_PRODUCT_ALL) {
                    
                    for (int i=0; i<submitProArr.count; i++) {
                        ProductObj *obj = submitProArr[i];
                        NSInteger index = [cartProArr indexOfObject:obj];
                        
                        DLog(@"删除 下表为 %ld 的商品",(long)index);
                        
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                        [indexSet addIndex:index];
                        
                        [indexPathArr addObject:indexPath];
                    }
                    
                    if (submitProArr.count == cartProArr.count) {
                        [statusBt changeBackgroundImage];
                    }
                    
                    [submitProArr removeAllObjects];
                    [cartProArr removeObjectsAtIndexes:indexSet];   //数据源删除
                    [self.mainTableView deleteRowsAtIndexPaths:indexPathArr withRowAnimation:UITableViewRowAnimationFade];  //UI界面更新
                }else{
                    
                    ProductObj *obj = cartProArr[index];
                    
                    if ([submitProArr containsObject:obj]) {
                        [submitProArr removeObject:obj];
                    }
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                    
                    [cartProArr removeObjectAtIndex:index];   //数据源删除
                    [self.mainTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];  //UI界面更新
                }

                
                [self.mainTableView reloadData];
                
                //删除成功后 总价为0 个数也为0
                totalPrice = 0;
                int cart_product_num = 0;           //购物车选中的所有商品总个数
                cartProductNum = 0;                 //购物车中选择的 列数
                [submitProArr removeAllObjects];    //删除之后， 要提交的商品重新获取
                for(int i=0; i<cartProArr.count; i++){
                    ProductObj *cartObj = cartProArr[i];
                    
                    if (cartObj.isChoiceToSettle) {
                        totalPrice += [cartObj.number integerValue] * [cartObj.salePrice floatValue];
                        
                        [submitProArr addObject:cartObj];
                    }
                    
                    cart_product_num += cartObj.number.integerValue;
                }
                
                for (int i=0; i<submitProArr.count; i++) {
                    ProductObj *obj = submitProArr[i];
                    cartProductNum += obj.number.integerValue;
                }
                
                [GlobalMethod saveObject:[NSString stringWithFormat:@"%d",cart_product_num] withKey:CART_PRODUCT_COUNT];
                
                [self performSelectorOnMainThread:@selector(refreshBadge:) withObject:[NSString stringWithFormat:@"%d",cart_product_num] waitUntilDone:NO];
                
                [totalPriceLb setText:[NSString stringWithFormat:@"¥ %0.2f",totalPrice]];
                UIButton *rightBt = [self getRightButton];
                
                if ([rightBt.currentTitle isEqualToString:@"编辑"]) {
                    //结算
                    [submitBt setTitle:[NSString stringWithFormat:@"结算(%ld)",(long)cartProductNum] forState:UIControlStateNormal];
                    [submitBt setTitle:[NSString stringWithFormat:@"结算(%ld)",(long)cartProductNum] forState:UIControlStateHighlighted];
                }else{
                    //批量删除
                    [submitBt setTitle:[NSString stringWithFormat:@"批量删除(%ld)",(long)cartProductNum] forState:UIControlStateNormal];
                    [submitBt setTitle:[NSString stringWithFormat:@"批量删除(%ld)",(long)cartProductNum] forState:UIControlStateHighlighted];
                }
                
                if (submitProArr.count == cartProArr.count) {
                    [statusBt changeBackgroundImage];
                }else{
                    statusBt.choiceStatus = YES;
                    [statusBt changeBackgroundImage];
                }
                
                if(cart_product_num == 0){
                    [self buildCartEmptyView];
                }else{
                    [emptyView removeFromSuperview];
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
}

- (void)comeToHome
{
    if( !self.isRootNavC ){
        MYAPPDELEGATE.isPush = YES;
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    
    [MYAPPDELEGATE.tabBarC setSelectedIndex:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
