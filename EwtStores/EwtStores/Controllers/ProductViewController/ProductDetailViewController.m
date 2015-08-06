//
//  ProductDetailViewController.m
//  Shop
//
//  Created by Harry on 13-12-26.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "ProductDetailViewController.h"
#import "EvaluateViewController.h"

#import "CartViewController.h"
#import "PXAlertView.h"
#import "ProductWebViewController.h"
#import "LoginInViewController.h"
#import "ImageBrowser.h"
#import "UserObj.h"
#import "UIImageView+WebCache.h"

#import "JSONKit.h"
#import "HTTPRequest.h"
#import "EGOImageView.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"

extern CartViewController *cartVC;

@interface ProductDetailViewController ()
{
    NSMutableArray  *dataArr;
    UIButton        *sizeBtn;
    //UIButton        *colorBtn;
    CGFloat         height;
    
    BOOL            hasProduct; //判断改商品是否有库存
    UIButton        *addCartBt;
    UILabel         *noProductView;
    
    UIView          *networkNotReachableView;
    
    UITableView     *mainTableView;
    
    NSString        *productCode;
    //NSMutableArray  *colorArr;
    NSMutableArray  *sizeArr;
    NSMutableArray  *PIdArr;
    NSMutableArray  *PPriceArr;
    UILabel *proSalePriceLb;//商品价格lab
    
    NSInteger       totalNum;       //总共买了几件商品
    
    UILabel         *proColorSizeSelect;
    //NSString        *selectedColor;
    NSString        *selectedSize;
    NSString        *ppRice;
    
    EGOImageView    *cartIV;
    
    CartViewController *cartVC;
}
@end

@implementation ProductDetailViewController

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
    
    [self.view setBackgroundColor:RGBS(201)];
    
    [self setNavBarTitle:@"商品简介"];
    [self hiddenRightBtn];
     ppRice = @"";
    dataArr = [[NSMutableArray alloc] initWithObjects:@"",@"库存",@"颜色尺码",nil];
    totalNum = 1;
    hasProduct = YES;
    
    cartVC = [CartViewController shareInstance];
    
    [self showHUDInView:self.view WithText:NETWORKLOADING];
    [self loadDataSource];
    [self buildAddCartView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if([[GlobalMethod getObjectForKey:CART_PRODUCT_COUNT] isKindOfClass:[NSNull class]]){
        [_numLb setText:@"0"];
    }else{
        [_numLb setText:[GlobalMethod getObjectForKey:CART_PRODUCT_COUNT]];
    }
    
    [cartIV removeFromSuperview];
    [self buildCartNumView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
    
    if (user.im && MYAPPDELEGATE.isAddCarNC){
        [self addCartNum:addCartBt];
    }
}


#pragma mark
#pragma mark - viewBuild
- (void)loadBaseView
{
    mainTableView = [[UITableView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(0, Navbar_Height, Main_Size.width, Main_Size.height - StatusBar_Height - Navbar_Height- Tabbar_Height)] style:UITableViewStylePlain];
    [mainTableView setDataSource:self];
    [mainTableView setDelegate:self];
    [mainTableView setBackgroundView:nil];
    [mainTableView setBackgroundColor:RGBS(238)];
    [self.view addSubview:mainTableView];
    [mainTableView setTableHeaderView:self.mainSView];
    
    //footerView
    UIView *footerBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 310, 100)];
    [mainTableView setTableFooterView:footerBg];
    UIImageView *footerView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 10, 304, 89)];
    [footerView setImage:[UIImage imageNamed:@"form2"]];
    [footerView setUserInteractionEnabled:YES];
    [footerBg addSubview:footerView];
    
    UILabel *detailLb = [GlobalMethod BuildLableWithFrame:CGRectMake(10, 0, 80, 44.5) withFont:[UIFont systemFontOfSize:16] withText:nil];
    [detailLb setText:@"商品详情"];
    [footerView addSubview:detailLb];
    UIButton *detailBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    detailBtn.frame = CGRectMake(detailLb.right, 7, 200, 30);
    [detailBtn addTarget:self action:@selector(detailInAction:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:detailBtn];
    UIImageView  *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(185, 7.5, 15, 15)];
    [imageView setImage:[UIImage imageNamed:@"arrow"]];
    [detailBtn addSubview:imageView];
    
    UILabel *commentLb = [GlobalMethod BuildLableWithFrame:CGRectMake(10, detailLb.bottom, 80, 44.5) withFont:[UIFont systemFontOfSize:16] withText:nil];
    [commentLb setText:@"评论"];
    [footerView addSubview:commentLb];
    UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    commentBtn.frame = CGRectMake(detailLb.right, detailLb.bottom + 7, 200, 30);
    [commentBtn addTarget:self action:@selector(commentInAction:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:commentBtn];
    UIImageView  *imageView2=[[UIImageView alloc] initWithFrame:CGRectMake(185, 7.5, 15, 15)];
    [imageView2 setImage:[UIImage imageNamed:@"arrow"]];
    [commentBtn addSubview:imageView2];
    
    //右滑手势返回
    UISwipeGestureRecognizer *rightGes = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(returnBack:)];
    [rightGes setDirection:UISwipeGestureRecognizerDirectionRight];
    //[mainTableView addGestureRecognizer:rightGes];
}

- (void)buildMainScrollView
{
    self.mainSView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, [GlobalMethod AdapterIOS6_7ByIOS6Float:Navbar_Height], Main_Size.width, BannerView_Height)];
    [self.mainSView setDelegate:self];
    [self.mainSView setScrollEnabled:YES];
    [self.mainSView setShowsHorizontalScrollIndicator:NO];
    [self.mainSView setShowsVerticalScrollIndicator:NO];
    [self.mainSView setContentSize:CGSizeMake(Main_Size.width, BannerView_Height)];
    [mainTableView addSubview:self.mainSView];
}

- (void)buildBannerView
{
    self.bannerSView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, Main_Size.width, BannerView_Height)];
     [self.bannerSView setDelegate:self];
     [self.bannerSView setScrollEnabled:YES];
     [self.bannerSView setPagingEnabled:YES];
     [self.bannerSView setShowsHorizontalScrollIndicator:NO];
     [self.bannerSView setShowsVerticalScrollIndicator:NO];
     if(self.obj.detailImgUrl.count == 0){
        [self.bannerSView setContentSize:CGSizeMake(Main_Size.width, BannerView_Height)];
     }else{
         [self.bannerSView setContentSize:CGSizeMake(Main_Size.width * self.obj.detailImgUrl.count, BannerView_Height)];
     }
    
     [self.mainSView addSubview:self.bannerSView];
     
     for(int i=0; i<self.obj.detailImgUrl.count; i++)
     {
         EGOImageView *iView = [[EGOImageView alloc] initWithFrame:CGRectMake(Main_Size.width*i, 0, Main_Size.width, BannerView_Height)];
         [iView setContentMode:UIViewContentModeScaleAspectFit];
         [iView setPlaceholderImage:[UIImage imageNamed:@"default_img_640x290"]];
         [iView setImageURL:[NSURL URLWithString:self.obj.detailImgUrl[i]]];
         [iView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)]];
         [iView setUserInteractionEnabled:YES];
         [self.bannerSView addSubview:iView];
     }
    
     [mainTableView setTableHeaderView:self.mainSView];
}

- (void)returnBack:(UISwipeGestureRecognizer *)rightGus
{
    UIView *view = rightGus.view;
    CGPoint point = [rightGus locationInView:mainTableView];
    
    NSLog(@"%f  ",view.left);
    
    [self.navigationController.view setFrame:CGRectMake(point.x, 0, 320, 568)];
    
    //[self.navigationController popViewControllerAnimated:YES];
}

- (void)refreshNetwork
{
    [self loadDataSource];
}

- (void)tapImage:(UITapGestureRecognizer *)tap
{
    DLog(@"查看商品大图");
    [MobClick event:SPDT];
    //[ImageBrowser showImage:(UIImageView*)tap.view];
    
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:4];
    for (int i = 0; i<self.obj.detailImgUrl.count; i++) {
       
        MJPhoto *photo = [[MJPhoto alloc] init];
        [photo setUrl:[NSURL URLWithString:self.obj.detailImgUrl[i]]];
        photo.srcImageView = self.bannerSView.subviews[0]; // 来源于哪个UIImageView
        [photos addObject:photo];
    }
    
    // 显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = tap.view.tag; // 弹出相册时显示的第一张图片
    browser.photos = photos; // 设置所有的图片
    [browser show];
    [browser.view removeGestureRecognizer:[UISwipeGestureRecognizer new]];
}

- (NSArray *)getImageUrlArrBy:(NSString *)imageString
{
    if([imageString isKindOfClass:[NSNull class]] || [imageString isEqualToString:nil]){
        return @[@"12"];
    }
    
    return  [imageString componentsSeparatedByString:@"|"];
}

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
    BLOCK_SELF(ProductDetailViewController);
    HTTPRequest *hq = [HTTPRequest shareInstance];
    
    NSString *imgageType = nil;
    if([[GlobalMethod getObjectForKey:FLOWCHOICE] boolValue]){
        imgageType = @"2";
    }else{
        imgageType = @"1";
    }
    
    NSDictionary *dic = @{@"id":self.productId?self.productId:@"" , @"imagetype":imgageType};
    //商品简介数据
    [hq GETURLString:PRODUCT_INFO userCache:NO parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObj) {
        NSDictionary *rqDic = (NSDictionary *)responseObj;
        if([rqDic[HTTP_STATE] boolValue]){
            NSDictionary *productDic = (NSDictionary *)[rqDic[HTTP_DATA] objectFromJSONString];
            self.obj = [ProductObj shareInstance];
            productCode = productDic[@"PProductCode"];
            [self.obj setProductCode:productDic[@"PProductCode"]];
            [self.obj setName:productDic[@"PName"]];
            [self.obj setDetailImgUrl:[self getImageUrlArrBy:productDic[@"PImage"]]];
            [self.obj setSalePrice:productDic[@"PPrice"]];
            [self.obj setOldPrice:productDic[@"PMarketPrice"]];
            [self.obj setSaleMonthNum:productDic[@"PSalesNum"]];
            [self.obj setProductId:productDic[@"PId"]];
            [self.obj setLinkUrl:productDic[@"PDescriptionUrl"]];
            [self.obj setStarNum:productDic[@"PStar"]];
            [self.obj setGoodCommentNum:productDic[@"PGoodCommentCount"]];
            [self.obj setMidCommentNum:productDic[@"PMidCommentCount"]];
            [self.obj setLowCommentNum:productDic[@"PLowCommentCount"]];
            /*[self.obj setColor:productDic[@"PColorStandard"]];//颜色
            [self.obj setSize:productDic[@"PSizeStandard"]];//尺寸*/
            [self.obj setStockNum:[self getProductNumWithString:productDic[@"PStore"]]]; //库存个数
            
            UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
            
            //通过购买商品来请求后台查询是否有 库存
            //[self requestProductCount];
            
            if(!networkNotReachableView.hidden){
                [networkNotReachableView setHidden:YES];
            }
            
            if([self.obj.productId integerValue] <= 0){
                
                [self hideHUDInView:block_self.view];
                [self showHUDInView:block_self.view WithText:PRODUCTNOEXIST andDelay:LOADING_TIME];
                
                return ;
            }
            
            //商品存在时，行为纪录
            [MobClick event:PRODUCT_DETAIL_VIEW];
            
            [self loadBaseView];
            [self buildMainScrollView];
            [self buildBannerView];
            [self buildCartView];
            [self buildCartNumView];
            [self colorAndSize];
            
            
            NSDictionary *dic1 = @{@"userlogin":user.im?user.im:@"" , @"clientkey":user.clientkey?user.clientkey:@""};
            //购物车数量
            [hq GETURLString:CART_PRODUCT_NUM userCache:NO parameters:dic1 success:^(AFHTTPRequestOperation *operation, id responseObj) {
                NSDictionary *rqDic = (NSDictionary *)responseObj;
                if([rqDic[HTTP_STATE] boolValue]){
                    
                    NSDictionary *dataDic = (NSDictionary *)[rqDic[HTTP_DATA] objectFromJSONString];
                    if([dataDic[@"result"] boolValue]){
                        [GlobalMethod saveObject:dataDic[@"count"] withKey:CART_PRODUCT_COUNT];
                        
                        [_numLb setText:dataDic[@"count"]];
                    }
                    
                    [self hideHUDInView:block_self.view];
                    
                }else{
                    NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
                    [self hideHUDInView:block_self.view];
                    //[self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"%@ , %@",operation,error);
                [self hideHUDInView:block_self.view];
                //[self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
            }];
            
            [self hideHUDInView:block_self.view];
            
        }else{
            NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
            [self buildNetworkView];
            [self hideHUDInView:block_self.view];
            [self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@ , %@",operation,error);
        [self buildNetworkView];
        [self hideHUDInView:block_self.view];
        [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
    }];
}

- (void)requestProductCount{
    
    BLOCK_SELF(ProductDetailViewController);
    UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
    NSMutableDictionary *dic22 = [NSMutableDictionary dictionaryWithCapacity:10];
    int i = -1;
    for (i = 0; i < sizeArr.count; i++) {
        if ([selectedSize isEqualToString:sizeArr[i]]) {
            break;
        }
    }
    if (i == -1) {
        [dic22 setObject:self.obj.productId   forKey:@"productid"];
    }else{
        [dic22 setObject:PIdArr[i]   forKey:@"productid"];
    }
    //[dic setObject:[NSString stringWithFormat:@"%d",[_numLb.text intValue]+1] forKey:@"quantity"];
    [dic22 setObject:@"1" forKey:@"quantity"];
    [dic22 setObject:user.im          forKey:@"userlogin"];
    [dic22 setObject:user.clientkey   forKey:@"clientkey"];
    [dic22 setObject:selectedSize?selectedSize:@""     forKey:@""];
//    [dic22 setObject:selectedColor?selectedColor:@""    forKey:@""];
    
    HTTPRequest *hq = [HTTPRequest shareInstance];
    [hq POSTURLString:ADDPRODUCT_TO_CART parameters:dic22 success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rqDic = (NSDictionary *)responseObject;
        
        if([rqDic[HTTP_STATE] boolValue]){
            NSDictionary *dic = (NSDictionary *)[rqDic[HTTP_DATA] objectFromJSONString];
            
            if ([dic[@"result"] integerValue] == 2){
                DLog(@"库存 不足");
                [self hideHUDInView:block_self.view];
                
                //[[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"商品库存不足" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show];
                hasProduct = NO;
                
                [self buildAddCartView];
                
                return ;
            }
            
            hasProduct = YES;
            
            [self buildAddCartView];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self hideHUDInView:block_self.view];
        [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
    }];

}

- (void)buildCartView
{
    int btnY = 0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
    {
        btnY = Main_Size.height - 80;
    } else {
        btnY = Main_Size.height - 60;
    }
    UIButton *cartBt = [GlobalMethod BuildButtonWithFrame:CGRectMake(260, btnY, 44, 44)
                                                andOffImg:@"item-grid-float-bg-grey"
                                                 andOnImg:@"item-grid-float-bg-grey"
                                                withTitle:nil];
    [cartBt setImage:[UIImage imageNamed:@"item-grid-float-shopping-cart-icon"] forState:UIControlStateNormal];
    [cartBt addTarget:self action:@selector(comeToCartView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cartBt];
}

- (void)buildAddCartView
{
    int btnY = 0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
    {
        btnY = Main_Size.height - 60;
    } else {
        btnY = Main_Size.height - 40;
    }
    
    addCartBt = [GlobalMethod BuildButtonWithFrame:CGRectMake(85, btnY, 150, 30)
                                                andOffImg:@"addtocart"
                                                 andOnImg:@"addtocart2"
                                                withTitle:nil];
    [addCartBt setImage:[UIImage imageNamed:@"addtocart"] forState:UIControlStateNormal];
    [addCartBt setImage:[UIImage imageNamed:@"addtocart2"] forState:UIControlStateHighlighted];
    [addCartBt addTarget:self action:@selector(addCartNum:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addCartBt];
}

- (void)buildCartNumView
{
    int btnY = 0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
    {
        btnY = Main_Size.height - 80;
    } else {
        btnY = Main_Size.height - 60;
    }
    /*UIButton *cartBt = [GlobalMethod BuildButtonWithFrame:CGRectMake(280, btnY-10, 30, 30)
                                                andOffImg:nil
                                                 andOnImg:nil
                                                withTitle:nil];
    UIImage *image = [UIImage imageNamed:@"shoppingcart_num"];
    UIEdgeInsets insets = UIEdgeInsetsMake(10, 12, 10, 12);
    // 指定为拉伸模式，伸缩后重新赋值
    image = [image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    [cartBt setImage:image forState:UIControlStateNormal];
    [cartBt addTarget:self action:@selector(comeToCartView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cartBt];*/
    
    UIImage *image = [UIImage imageNamed:@"shoppingcart_num"];
    CGRect rect = CGRectMake(280, btnY-10, 20, 20);
    if ([[GlobalMethod getObjectForKey:CART_PRODUCT_COUNT] intValue] > 99) {
        UIEdgeInsets insets = UIEdgeInsetsMake(8, 8, 8, 8);
        // 指定为拉伸模式，伸缩后重新赋值
        image = [image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
        rect = CGRectMake(280, btnY-10, 30, 15);
    }
    
    cartIV = [[EGOImageView alloc] initWithFrame:rect];
    [cartIV setImage:image];
    [self.view addSubview:cartIV];
    [cartIV setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(comeToCartView)];
    [cartIV addGestureRecognizer:tap];
    
    _numLb = [GlobalMethod BuildLableWithFrame:cartIV.frame withFont:[UIFont systemFontOfSize:12] withText:nil];
    if([[GlobalMethod getObjectForKey:CART_PRODUCT_COUNT] isKindOfClass:[NSNull class]]){
        [_numLb setText:@"0"];
    }else{
        [_numLb setText:[GlobalMethod getObjectForKey:CART_PRODUCT_COUNT]];
    }
    
    [_numLb setTextAlignment:NSTextAlignmentCenter];
    [_numLb setTextColor:[UIColor whiteColor]];
    [self.view addSubview:_numLb];
}

- (void)comeToCartView
{
    DLog(@"前往 购物车");
    
    [cartVC setIsRootNavC:NO];
    [self.navigationController pushViewController:cartVC animated:YES];
}

- (void)comeToLogin
{
    MYAPPDELEGATE.isAddCarNC = YES;
    [self hideHUDInView:self.view];
    LoginInViewController *loginViewC = [[LoginInViewController alloc] init];
    loginViewC.isComingFromCarNC = YES;
    UINavigationController *loginNavC = [[UINavigationController alloc] initWithRootViewController:loginViewC];
    [loginNavC setNavigationBarHidden:YES];
    [self presentViewController:loginNavC animated:YES completion:Nil];
}

- (void)addCartNum:(UIButton*) btn
{
    [MobClick event:JRGWC];
    
    UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
    
    if (user.im == nil || [user.im isEqualToString:@""]) {
        
        [self showHUDInView:self.view WithText:@"请登录后即可加入购物车"];
        [self performSelector:@selector(comeToLogin) withObject:nil afterDelay:1];
        return ;
    }
    
    /*
     客户端判断库存
    //库存不足
    if(self.obj.stockNum.intValue <= 0){
        [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"商品库存不足" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show];
        return ;
    }
    
    //超过库存数
    if(totalNum > self.obj.stockNum.integerValue){
        [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"商品库存不足" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show];
        return ;
    }
     */
    MYAPPDELEGATE.isAddCarNC = NO;
    
    //超过购物车限制时
    if([[GlobalMethod getObjectForKey:CART_PRODUCT_COUNT] integerValue] > 999){
        [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"购物车商品超过上限" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show];
        return ;
    }
    
    
    BLOCK_SELF(ProductDetailViewController);
    HTTPRequest *hq = [HTTPRequest shareInstance];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:10];
    int i = -1;
    for (i = 0; i < sizeArr.count; i++) {
        if ([selectedSize isEqualToString:sizeArr[i]]) {
            break;
        }
    }
    if (i == sizeArr.count) {
        [dic setObject:self.obj.productId   forKey:@"productid"];
    }else{
        [dic setObject:PIdArr[i]   forKey:@"productid"];
    }
    //[dic setObject:[NSString stringWithFormat:@"%d",[_numLb.text intValue]+1] forKey:@"quantity"];
    [dic setObject:@"1" forKey:@"quantity"];
    [dic setObject:user.im          forKey:@"userlogin"];
    [dic setObject:user.clientkey   forKey:@"clientkey"];
    [dic setObject:selectedSize     forKey:@""];
//    [dic setObject:selectedColor    forKey:@""];
    
    [hq POSTURLString:ADDPRODUCT_TO_CART parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rqDic = (NSDictionary *)responseObject;
        
        if([rqDic[HTTP_STATE] boolValue]){
            NSDictionary *dic = (NSDictionary *)[rqDic[HTTP_DATA] objectFromJSONString];
            
            if([dic[@"result"] integerValue] == 1){
                DLog(@"成功添加商品");
                
                [GlobalMethod saveObject:[NSString stringWithFormat:@"%d",[_numLb.text intValue]+1] withKey:CART_PRODUCT_COUNT];
                
                [btn setImage:[UIImage imageNamed:@"addtocart2"] forState:UIControlStateNormal];
                if ([_numLb.text integerValue] == 0) {
                    [self buildCartNumView];
                } else {
                    [_numLb setText:[NSString stringWithFormat:@"%d",[_numLb.text intValue]+1]];
                }
                
                totalNum ++;
                [self showHUDInView:block_self.view WithText:@"加入购物车成功" andDelay:1];
            }else if ([dic[@"result"] integerValue] == 2){
                DLog(@"库存 不足");
                [self hideHUDInView:block_self.view];
                
                [addCartBt setEnabled:NO];
                
                if (noProductView == nil) {
                    noProductView = [[UILabel alloc] initWithFrame:CGRectMake(0, addCartBt.top - 10 - 50, Main_Size.width, 50)];
                    [noProductView setBackgroundColor:RGBA(0, 0, 0, 0.5)];
                    [noProductView setText:@"该商品库存不足或者其他原因"];
                    [noProductView setTextAlignment:NSTextAlignmentCenter];
                    [noProductView setTextColor:[UIColor whiteColor]];
                    [noProductView setFont:[UIFont systemFontOfSize:13]];
                    [self.view addSubview:noProductView];
                }
                
                //[[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"商品库存不足" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show];
                return ;
            }else{
                NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
                [self hideHUDInView:block_self.view];
                [self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self hideHUDInView:block_self.view];
        [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
    }];
}

- (void)colorAndSize {
    //颜色尺码
//    colorArr = [[NSMutableArray alloc] init];
    sizeArr = [[NSMutableArray alloc] init];
    PIdArr = [[NSMutableArray alloc] init];
    PPriceArr = [[NSMutableArray alloc] init];
//    selectedColor = @"";
    selectedSize = @"";
//     ppRice = @"";
    
    BLOCK_SELF(ProductDetailViewController);
    HTTPRequest *hq = [HTTPRequest shareInstance];
    NSDictionary *params = @{@"productcode":productCode};
    [hq GETURLString:PRODUCT_COLORSIZE parameters:params success:^(AFHTTPRequestOperation *operation, id responseObj) {
        NSDictionary *rqDic = (NSDictionary *)responseObj;
        if([rqDic[HTTP_STATE] boolValue]){
            NSArray *productArr = (NSArray *)[rqDic[HTTP_DATA] objectFromJSONString];
            for(int i=0; i<productArr.count; i++){
                NSDictionary *dic = (NSDictionary *)productArr[i];
                
//                NSString *colorStr = dic[@"PColorStandard"];//颜色
                NSString *sizeStr = dic[@"PSizeStandard"];//尺寸
                NSString *Pid = dic[@"PId"];
                NSString *PPrice = dic[@"PPrice"];
                
//                if (![colorStr isEqualToString:@""]) {
//                    [colorArr addObject:colorStr];
//                }
                if (![sizeStr isEqualToString:@""]) {
                    [sizeArr addObject:sizeStr];
                    [PIdArr addObject:Pid];
                    [PPriceArr addObject:PPrice];
                }
            }
            if(sizeArr.count > 0){
                selectedSize = sizeArr[0];
                [proColorSizeSelect setText:selectedSize];
                ppRice  = PPriceArr[0];
                [proSalePriceLb setText:[NSString stringWithFormat:@"￥%@", ppRice]];
            }
            
            if(!networkNotReachableView.hidden){
                [networkNotReachableView setHidden:YES];
            }
            
            [self hideHUDInView:block_self.view];
            
        }else{
            NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
            [self buildNetworkView];
            [self hideHUDInView:block_self.view];
            [self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@ , %@",operation,error);
        [self buildNetworkView];
        [self hideHUDInView:block_self.view];
        [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView == self.bannerSView)
    {
        [self.pageC setCurrentPage:(int)(scrollView.contentOffset.x/320)];
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView == self.bannerSView){
        return;
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(scrollView == self.bannerSView){
        return;
    }
    
}

#pragma mark UITableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellString = @"detailViewIdenfitier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellString];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellString];
        if(indexPath.row == 0){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellString];
            //商品名称
            UILabel *proNameLb = [GlobalMethod BuildLableWithFrame:CGRectMake(10, 10, 300, 40)
                                                          withFont:[UIFont boldSystemFontOfSize:15]
                                                          withText:nil];
            [proNameLb setNumberOfLines:2];
            [proNameLb setTextColor:RGBS(51)];
            [proNameLb setText:self.obj.name?self.obj.name:@""];
            [cell.contentView addSubview:proNameLb];
            //商品价格
            proSalePriceLb = [GlobalMethod BuildLableWithFrame:CGRectMake(10, proNameLb.height+10, 80, 30)
                                                               withFont:[UIFont boldSystemFontOfSize:20]
                                                               withText:nil];
            [proSalePriceLb setTextColor:RGB(197, 0, 0)];
            [proSalePriceLb setText:[NSString stringWithFormat:@"￥%@", self.obj.salePrice]];
            [cell.contentView addSubview:proSalePriceLb];
            //商品原价
            UILabel *proOldPriceLb = [GlobalMethod BuildLableWithFrame:CGRectMake(proSalePriceLb.right-5, proNameLb.height+20, 50, 15)
                                                              withFont:[UIFont systemFontOfSize:12]
                                                              withText:nil];
            [proOldPriceLb setTextColor:RGBS(153)];
            [proOldPriceLb setText:[NSString stringWithFormat:@"￥%.2f", [self.obj.oldPrice floatValue]]];
            [cell.contentView addSubview:proOldPriceLb];
            UILabel *oldLineLb = [GlobalMethod BuildLableWithFrame:CGRectMake(proOldPriceLb.left, proOldPriceLb.center.y, proOldPriceLb.width, 0.5)
                                                          withFont:nil
                                                          withText:nil];
            [oldLineLb setBackgroundColor:RGBS(153)];
            [cell.contentView addSubview:oldLineLb];
            //好评
            for (int i = 0; i < 5; i++) {
                UIImageView  *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(190+(20+5)*i,proSalePriceLb.frame.origin.y+10,20,20)];
                if (i == 4) {
                    imageView.image = [UIImage imageNamed:@"star3"];
                } else {
                    imageView.image = [UIImage imageNamed:@"star1"];
                }
                [cell.contentView addSubview:imageView];
            }
            
        }else if(indexPath.row == 1){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellString];
            
            UILabel *proStockNum = [GlobalMethod BuildLableWithFrame:CGRectMake(80, 0, 100, 35)
                                                            withFont:[UIFont systemFontOfSize:12]
                                                            withText:nil];
            //[proStockNum setTextColor:RGB(180, 180, 180)];
            [proStockNum setText:[NSString stringWithFormat:@"%.0f", [self.obj.stockNum floatValue]]];
            [cell.contentView addSubview:proStockNum];
            
        }else if(indexPath.row == 2){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellString];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            proColorSizeSelect = [GlobalMethod BuildLableWithFrame:CGRectMake(80, 0, 100, 35)
                                                              withFont:[UIFont systemFontOfSize:12]
                                                              withText:nil];
            [proColorSizeSelect setText:@"无尺码选择"];
            [cell.contentView addSubview:proColorSizeSelect];
        }else if(indexPath.row == 3){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellString];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            UILabel *proColorSelect = [GlobalMethod BuildLableWithFrame:CGRectMake(80, 0, 100, 35)
                                                               withFont:[UIFont systemFontOfSize:12]
                                                               withText:nil];
            [proColorSelect setText:@"请选择"];
            [cell.contentView addSubview:proColorSelect];
            
        }
    }
    
    [cell.textLabel setText:dataArr[indexPath.row]];
    [cell.textLabel setFont:[UIFont systemFontOfSize:14]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        return 85;
    } else {
        return 35;
    }
    
    return 48;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
        {
            
        }
            break;
            
        case 1:
        {
            
        }
            break;
            
        case 2:
        {
            DLog(@"选择颜色与尺码");
            UIScrollView *view = [[UIScrollView alloc] initWithFrame:CGRectMake(0,10,250,100)];
            view.directionalLockEnabled = YES;
            view.showsHorizontalScrollIndicator = NO;
            //view.showsVerticalScrollIndicator = NO;
            view.contentSize = CGSizeMake(250, 100);
//            UILabel *colorLb = [GlobalMethod BuildLableWithFrame:CGRectMake(-20, 0, 80, 30) withFont:[UIFont systemFontOfSize:13] withText:nil];
//            [colorLb setText:@"颜色："];
//            [view addSubview:colorLb];
//            for(int i = 0; i < colorArr.count; i++){
//                
//                UIButton *button=[UIButton buttonWithType:UIButtonTypeRoundedRect];
//                button.tag=i+1;
//                button.backgroundColor = [UIColor clearColor];
//                [button setBackgroundImage:[UIImage imageNamed:@"btn296_3"] forState:UIControlStateNormal];
//                [button setBackgroundImage:[UIImage imageNamed:@"item-info-buy-kinds-active-btn"] forState:UIControlStateSelected];
//                [button setTitle:colorArr[i] forState:UIControlStateNormal];
//                [button setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
//                button.titleLabel.font = [UIFont systemFontOfSize: 12.0];
//                if (i >= 2) {
//                    button.frame=CGRectMake(i*(70 + 5)+15, 0 + ((i+1)%3) * 35, 60, 30);
//                } else {
//                    button.frame=CGRectMake(i*(70 + 5)+15, 0, 60, 30);
//                }
//                
//                if ([button.titleLabel.text isEqualToString:selectedColor]) {
//                    [button setSelected:YES];
//                    colorBtn = button;
//                }
//                
//                [button addTarget:self action:@selector(colorInAction:) forControlEvents:UIControlEventTouchUpInside];
//                [view addSubview:button];
//                
//            }
//            UILabel *sizeLb = [GlobalMethod BuildLableWithFrame:CGRectMake(-20, 40, 80, 30) withFont:[UIFont systemFontOfSize:13] withText:nil];
//            [sizeLb setText:@"尺码："];
//            [view addSubview:sizeLb];
            if (sizeArr.count <= 2) {
                for(int i = 0; i < sizeArr.count; i++){
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    button.tag = i+1;
                    [button setBackgroundImage:[UIImage imageNamed:@"item-info-buy-kinds-active-btn2"] forState:UIControlStateSelected];
                    [button setTitle:sizeArr[i] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
                    button.titleLabel.font = [UIFont systemFontOfSize: 12];
                    button.titleLabel.numberOfLines = 0;
                    if (i == 0) {
                        height = [self heightForText:sizeArr[i] andCustomWith:80];
                        if (height < 40) {
                            height = 40;
                        }
                    }
                    button.frame=CGRectMake(i*(110 + 5)+15, 40, 100, height);
                    if ([button.titleLabel.text isEqualToString:selectedSize]) {
                        [button setSelected:YES];
                        sizeBtn = button;
                    }
                    
                    [button addTarget:self action:@selector(sizeInAction:) forControlEvents:UIControlEventTouchUpInside];
                    //		[rootView addSubview:button];
                    [view addSubview:button];
                }
            }else{
                
                for(int i = 0; i < sizeArr.count; i++){

                    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
                    button.tag=i+1;
                    //button.layer.masksToBounds = YES;
//                button.backgroundColor = [UIColor whiteColor];
//                [button setBackgroundImage:[UIImage imageNamed:@"btn296_3"] forState:UIControlStateNormal];
                    [button setBackgroundImage:[UIImage imageNamed:@"item-info-buy-kinds-active-btn2"] forState:UIControlStateSelected];
                    [button setTitle:sizeArr[i] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
                    button.titleLabel.font = [UIFont systemFontOfSize: 12];
                    button.titleLabel.numberOfLines = 0;
                    if (i == 0) {
                        height = [self heightForText:sizeArr[i] andCustomWith:80];
                        if (height < 40) {
                            height = 40;
                        }
                    }
                    if (i >= 2) {
                        button.frame=CGRectMake(i%2*(110 + 5)+15, (i/2) * (height+10), 100, height);
                    //button.frame=CGRectMake(i*(70 + 5)+15, 0 + ((i+1)%3) * 35, 60, 30);
                    } else {
                        button.frame=CGRectMake(i*(110 + 5)+15, 0, 100, height);
                    //button.frame=CGRectMake(i*(70 + 5)+15, 0, 60, 30);
                    }
                
                    if ([button.titleLabel.text isEqualToString:selectedSize]) {
                        [button setSelected:YES];
                        sizeBtn = button;
                    }
                
                    [button addTarget:self action:@selector(sizeInAction:) forControlEvents:UIControlEventTouchUpInside];
                //		[rootView addSubview:button];
                    [view addSubview:button];
                    if (i == sizeArr.count - 1 && button.frame.origin.y +button.frame.size.height > 100) {
                        view.contentSize = CGSizeMake(250,button.frame.origin.y +button.frame.size.height+10);
                    }
                }
            }
            if (sizeArr.count == 0) {
                [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"此商品没有颜色与尺码哦" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
            } else {
       PXAlertView *alert = [PXAlertView showAlertWithTitle:@"颜色与尺码"
                                        message:nil
                                    cancelTitle:@"确定"
                                     otherTitle:nil
                                    contentView:view
                                     completion:^(BOOL cancelled) {
//                                         if (![selectedColor isEqualToString:@""] && ![selectedSize isEqualToString:@""]) {
//                                             [proColorSizeSelect setText:[NSString stringWithFormat:@"%@,%@",selectedColor,selectedSize]];
//                                         } else if (![selectedColor isEqualToString:@""]) {
//                                             [proColorSizeSelect setText:selectedColor];
//                                         } else
                                             if (![selectedSize isEqualToString:@""]) {
                                             [proColorSizeSelect setText:selectedSize];
                                         }
                                         alert.bounds = CGRectMake(0, 0, alert.bounds.size.width, 300);
                                         
                                     }];
            }
            
            
        }
            break;
            
        case 3:
        {
            
        }
            break;
        
        default:
            break;
    }
}

-(CGFloat)heightForText:(NSString *)text andCustomWith:(CGFloat)textWidth{
    CGRect rect = [text boundingRectWithSize:CGSizeMake(textWidth, 4000) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:12] forKey:NSFontAttributeName] context:nil];
    return rect.size.height;
}

- (void)sizeInAction:(UIButton *)btn
{
    DLog(@"选中尺码：%@",btn.currentTitle);
    NSLog(@"button.tag:%d",sizeBtn.tag);
    ppRice  = PPriceArr[btn.tag -1];
    [proSalePriceLb setText:[NSString stringWithFormat:@"￥%@", ppRice]];
    selectedSize = btn.currentTitle;
    sizeBtn.selected = NO;
    btn.selected = YES;
    sizeBtn = btn;
}

//- (void)colorInAction:(UIButton *)btn
//{
//    DLog(@"选中颜色：%@",btn.currentTitle);
//    NSLog(@"button.tag:%d",colorBtn.tag);
//    selectedColor = btn.currentTitle;
//    colorBtn.selected = NO;
//    btn.selected = YES;
//    colorBtn = btn;
//}

- (void)detailInAction:(UIButton *)btn
{
    DLog(@"商品详情");
    [MobClick event:SPXQ];
    ProductWebViewController *ProductWebVC = [ProductWebViewController shareInstance];
    [ProductWebVC setProductDetailUrl:[NSURL URLWithString:self.obj.linkUrl]];
    [ProductWebVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:ProductWebVC animated:YES];
}

- (void)commentInAction:(UIButton *)btn
{
    DLog(@"评论");
    [MobClick event:SPPL];
    EvaluateViewController *evVC = [EvaluateViewController shareInstance];
    [evVC setProductObj:self.obj];
    [self.navigationController pushViewController:evVC animated:YES];
}

@end
