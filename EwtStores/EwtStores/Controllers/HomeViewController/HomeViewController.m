//
//  HoneViewController.m
//  EwtStores
//
//  Created by Harry on 13-11-30.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

//2013-12-16 Harry 没有将View 从Controller中分离出来，导致Controller中东西太多

#import "HomeViewController.h"
#import "RushProductViewController.h"
#import "PromotionActivityViewController.h"
#import "SpecialsProductViewController.h"
#import "ProductSortViewController.h"
#import "EGOImageView.h"
#import "BannerDetailViewController.h"
#import "ProductSortViewController.h"
#import "ActivityDetailViewController.h"
#import "UnpayViewController.h"
#import "SelfViewController.h"
#import "LoginInViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>
#import "HTTPRequest.h"
#import "JSONKit.h"
#import "EGOCache.h"
#import "UMSocialSnsService.h"
#import "UMSocialSnsPlatformManager.h"
#import "UserObj.h"
#import "ActivityObj.h"
#import "ProductObj.h"
#import "BrandsObj.h"

extern SelfViewController *selfVC;

@interface HomeViewController ()<EGOImageLoaderObserver>
{
    UIView          *rushPurchaseView;
    UIView          *specialProductView;
    UIView          *activityView;
    
    UILabel         *rushLb;
    UILabel         *hourLb;
    UILabel         *minuteLb;
    UILabel         *secondLb;
    NSInteger       rushHour;
    NSInteger       rushMinute;
    NSInteger       rushSecond;
    NSTimer         *timer;
    
    EGOImageView    *rushProImgView;
    UILabel         *rushProOldPriceLb;
    UILabel         *rushProSalePriceLb;
    
    EGOImageView    *specialProImgView;     //特价商品
    UILabel         *specialProNameLb;
    EGOImageView    *hotProImgView;         //热卖商品
    UILabel         *hotProNameLb;
    
    NSTimer         *scrolTimer;
    NSInteger       curentBannerIndex;
    
    NSMutableArray  *bannerArr;             //banner对象
    NSMutableArray  *brandsArr;             //品牌对象
    ProductObj      *rushProductObj;        //限时抢购商品
    ProductObj      *specialProductObj;     //特价商品
    ProductObj      *hotProductObj;         //热卖商品
}

@end

@implementation HomeViewController

#define BannerView_Height  150
    //71.6

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
    
    [self setNavBarHiddenWithAnimation:NO];

    [self loadDataSource];
    
    [self buildBaseView];
    
    [[NSNotificationCenter defaultCenter] addObserver:nil selector:@selector(netWorkChange:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MobClick event:HOME_VIEW];
    
    [self.searchDC setActive:NO];
    

    NSArray *VCArr = MYAPPDELEGATE.tabBarC.viewControllers;
    
    if(VCArr.count >= 3){
        UINavigationController *cartVC = VCArr[2];
        NSString *cart_product_num = [GlobalMethod getObjectForKey:CART_PRODUCT_COUNT];
        UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
        if([cart_product_num integerValue] == 0 || !user.isLogin){
            cartVC.tabBarItem.badgeValue = nil;
        }else{
            cartVC.tabBarItem.badgeValue = cart_product_num;
        }
    }
}

- (void)netWorkChange:(NSNotification *)notif
{
    
}

- (void)loadDataSource
{
    curentBannerIndex = 0;
//    scrolTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(bannerSViewChange) userInfo:nil repeats:YES];
    
    self.searchDataArr  = [NSMutableArray arrayWithCapacity:10];
    bannerArr           = [NSMutableArray arrayWithCapacity:10];
    brandsArr           = [NSMutableArray arrayWithCapacity:10];
    
    [self getFirstDataSource];      //只有开机请求的书数据来源
    [self getDataSourceByNetwork];  //可以手动刷新的数据来源
}


- (void)getFirstDataSource{
    BLOCK_SELF(HomeViewController);
    HTTPRequest *hq = [HTTPRequest shareInstance];
    
    //品牌专区
    [hq GETURLString:HOME_BRANDS_REQUEST  userCache:NO parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObj) {
        NSDictionary *rqDic = (NSDictionary *)responseObj;
        if([rqDic[HTTP_STATE] boolValue]){
            NSArray *dataArr = (NSArray *)[rqDic[HTTP_DATA] objectFromJSONString];
            for(int i=0; i<dataArr.count; i++){
                NSDictionary *dic = (NSDictionary *)dataArr[i];
                
                BrandsObj *obj = [BrandsObj shareInstance];
                [obj setBrandsId:dic[@"Code"]];
                [obj setName:dic[@"Name"]];
                [obj setImageUrl:[NSURL URLWithString:dic[@"Image"]]];
                [obj setBeginTime:[GlobalMethod getJsonDateString:dic[@"BeginTime"]]];
                [obj setEndTime:[GlobalMethod getJsonDateString:dic[@"EndTime"]]];
                [obj setLinkUrl:dic[@"LinkUrl"]];
                [brandsArr addObject:obj];
            }
            
            [self buildBrandView];
            
        }else{
            NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
            [self buildBrandView];
            [self showHUDInView:block_self.view WithText:NETWORKFAILED andDelay:LOADING_TIME];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@ , %@",operation,error);
        [self buildBrandView];
        [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
    }];

}

- (void)getDataSourceByNetwork{
    curentBannerIndex = 0;
    BLOCK_SELF(HomeViewController);
    HTTPRequest *hq = [HTTPRequest shareInstance];
    
    //banner
    [hq GETURLString:HOME_BANNER_REQUEST userCache:NO  parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObj) {
        NSDictionary *rqDic = (NSDictionary *)responseObj;
        if([rqDic[HTTP_STATE] boolValue]){
            NSArray *dataArr = (NSArray *)[rqDic[HTTP_DATA] objectFromJSONString];
            
            [bannerArr removeAllObjects];
            
            for(int i=0; i<dataArr.count; i++){
                NSDictionary *dic = (NSDictionary *)dataArr[i];
                
                ActivityObj *obj = [ActivityObj shareInstance];
                [obj setActivityId:dic[@"Id"]];
                [obj setActivityName:dic[@"Name"]];
                [obj setActivityImgUrl:[NSURL URLWithString:dic[@"Image"]]];
                [obj setActivityLinkUrl:[NSURL URLWithString:dic[@"LinkUrl"]]];
                [bannerArr addObject:obj];
            }
        }else{
            NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
            
            [self showHUDInView:block_self.view WithText:NETWORKFAILED andDelay:LOADING_TIME];
        }
        
         [self refreshBannerView];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@ , %@",operation,error);
        [self refreshBannerView];
    }];
    
    //限时抢购
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1",@"page",@"4",@"pagesize",nil];
    [hq GETURLString:XIANSHIQIANGGOU_REQUEST userCache:NO parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObj) {
        NSDictionary *rqDic = (NSDictionary *)responseObj;
        if([rqDic[HTTP_STATE] boolValue]){
            
            NSArray *dataArr = (NSArray *)[rqDic[HTTP_DATA] objectFromJSONString];
            
            if (dataArr.count > 0) {
                NSDictionary *dic = (NSDictionary *)dataArr[0];
                
                rushProductObj = [ProductObj shareInstance];
                [rushProductObj setProductId:dic[@"ProductId"]];
                [rushProductObj setBeginTime:[GlobalMethod getJsonDateString:dic[@"ServerTime"]]];
                [rushProductObj setEndTime:[GlobalMethod getJsonDateString:dic[@"EndTime"]]];
                [rushProductObj setImgUrl:[NSURL URLWithString:dic[@"Image"]]];
                [rushProductObj setOldPrice:dic[@"MarketPrice"]];
                [rushProductObj setSalePrice:dic[@"Price"]];
                
                [self refreshRushView];
            }else{
                [timer invalidate];
                DLog(@"抢购时间到");
                
                [rushLb setTextColor:[UIColor redColor]];
                [rushLb setText:@"抢购结束"];
                [rushPurchaseView setUserInteractionEnabled:NO];
            }

            
        }else{
            NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
            [self showHUDInView:block_self.view WithText:NETWORKFAILED andDelay:LOADING_TIME];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@ , %@",operation,error);
    }];
    
    //特价商品
    [hq GETURLString:HOME_SPECIAL_REQUEST  userCache:NO parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObj) {
        NSDictionary *rqDic = (NSDictionary *)responseObj;
        if([rqDic[HTTP_STATE] boolValue]){
            
            NSArray *dataArr = (NSArray *)[rqDic[HTTP_DATA] objectFromJSONString];
            
            for(int i=0; i<dataArr.count; i++){
                NSDictionary *dic = (NSDictionary *)dataArr[i];

                specialProductObj = [ProductObj shareInstance];
                [specialProductObj setProductId:dic[@"ProductId"]];
                [specialProductObj setEndTime:[GlobalMethod getJsonDateString:dic[@"EndTime"]]];
                [specialProductObj setImgUrl:[NSURL URLWithString:dic[@"Image"]]];
                [specialProductObj setOldPrice:dic[@"MarketPrice"]];
                [specialProductObj setSalePrice:dic[@"Price"]];
                [specialProductObj setName:dic[@"Name"]];
            }
            [self refreshSpecialView];
        }else{
            NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
            [self showHUDInView:block_self.view WithText:NETWORKFAILED andDelay:LOADING_TIME];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@ , %@",operation,error);
    }];
    
    //热卖商品
    [hq GETURLString:HOME_HOT_REQUEST  userCache:NO parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObj) {
        NSDictionary *rqDic = (NSDictionary *)responseObj;
        if([rqDic[HTTP_STATE] boolValue]){
            
            NSArray *dataArr = (NSArray *)[rqDic[HTTP_DATA] objectFromJSONString];
            
            for(int i=0; i<dataArr.count; i++){
                NSDictionary *dic = (NSDictionary *)dataArr[i];
                
                hotProductObj = [ProductObj shareInstance];
                [hotProductObj setProductId:dic[@"ProductId"]];
                [hotProductObj setEndTime:[GlobalMethod getJsonDateString:dic[@"EndTime"]]];
                [hotProductObj setImgUrl:[NSURL URLWithString:dic[@"Image"]]];
                [hotProductObj setOldPrice:dic[@"MarketPrice"]];
                [hotProductObj setSalePrice:dic[@"Price"]];
                [hotProductObj setName:dic[@"Name"]];
            }
            [self refreshHotView];
        }else{
            NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
            [self showHUDInView:block_self.view WithText:NETWORKFAILED andDelay:LOADING_TIME];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@ , %@",operation,error);
        [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
    }];
    
}

- (void)refreshBannerView
{
    for(UIView *view in self.bannerSView.subviews){
        [view removeFromSuperview];
    }
    
    [self.pageC removeFromSuperview];
    
    [self buildBannerView];
}

- (void)refreshRushView
{
    NSArray *dateArr = [GlobalMethod getTimeDifferenceByBeginTimeInterval:rushProductObj.beginTime withEndTimeInterval:rushProductObj.endTime];
    rushHour    = [dateArr[0] integerValue];
    rushMinute  = [dateArr[1] integerValue];
    rushSecond  = [dateArr[2] integerValue];
    
    [rushProImgView     setImageURL:rushProductObj.imgUrl];
    [rushProSalePriceLb setText:[NSString stringWithFormat:@"¥ %@",rushProductObj.salePrice]];
    [rushProOldPriceLb  setText:[NSString stringWithFormat:@"¥ %@",rushProductObj.oldPrice]];
    
    [self performSelectorInBackground:@selector(TimeControll) withObject:nil];
}


- (void)TimeControll{
    
    if( ![NSThread isMainThread] ){
        [timer invalidate];
        timer       = [NSTimer scheduledTimerWithTimeInterval:1
                                                       target:self
                                                     selector:@selector(rushProductTime)
                                                     userInfo:nil
                                                      repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] run];
    }
}

- (void)refreshSpecialView
{
    [specialProNameLb setText:specialProductObj.name];
    [specialProImgView setImageURL:specialProductObj.imgUrl];
}

- (void)refreshHotView
{
    [hotProNameLb setText:hotProductObj.name];
    [hotProImgView setImageURL:hotProductObj.imgUrl];
}

#pragma mark ViewBuild
- (void)buildBaseView
{
    [self buildSearchBarView];
    [self buildMainScrollView];
    [self buildHeaderView];
    [self buildBannerView];
    [self buildRushPurchaseView];
    [self buildSpecialProductView];
    [self buildActicityView];
    [self setExclusiveTouch:self.view]; //多点触控禁用
}

- (void)buildSearchBarView
{
    UIView *searchBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Main_Size.width, [GlobalMethod AdapterIOS6_7ByIOS6Float:Navbar_Height])];
    [searchBg setBackgroundColor:NavBarColor];
    [self.view addSubview:searchBg];
    
    UISearchBar *searchbar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, [GlobalMethod AdapterIOS6_7ByIOS6Float:0], Main_Size.width,Navbar_Height)];
    [searchbar setDelegate:self];
    [searchbar setPlaceholder:@"请输入关键字"];
    [searchbar setBarStyle:UIBarStyleDefault];
    [searchbar setBackgroundImage:[UIImage new]];
    if([[UIDevice currentDevice] systemVersion].floatValue >= 7.0) //ios7新特性
    {
        [searchbar setBarTintColor:NavBarColor];
    }
    else
    {
        [searchbar setBackgroundImage:[UIImage imageNamed:@"Home_SearchBar_Bg"]];
    }
    [searchBg addSubview:searchbar];
    
    self.searchDC = [[UISearchDisplayController alloc] initWithSearchBar:searchbar contentsController:self];
    [self.searchDC setDelegate:self];
    [self.searchDC setSearchResultsDataSource:self];
    [self.searchDC setSearchResultsDelegate:self];
}

- (void)buildMainScrollView
{
    self.mainSView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, [GlobalMethod AdapterIOS6_7ByIOS6Float:Navbar_Height], Main_Size.width, Main_Size.height - Navbar_Height - StatusBar_Height - Tabbar_Height)];
    [self.mainSView setDelegate:self];
    [self.mainSView setScrollEnabled:YES];
    [self.mainSView setShowsHorizontalScrollIndicator:NO];
    [self.mainSView setShowsVerticalScrollIndicator:NO];
    [self.mainSView setContentSize:CGSizeMake(Main_Size.width, 600)];
    [self.view addSubview:self.mainSView];
}

//建立headerView
- (void)buildHeaderView
{
    if(egoHeaderTable && [egoHeaderTable superview])
    {
        [egoHeaderTable removeFromSuperview];
    }
    
    egoHeaderTable = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0 - self.mainSView.frame.size.height, self.view.frame.size.width, self.mainSView.frame.size.height)];
    [egoHeaderTable setDelegate:self];
    [self.mainSView addSubview:egoHeaderTable];
    [egoHeaderTable refreshLastUpdatedDate];
}

#pragma mark 轮播广告
- (void)buildBannerView
{
    if([self.bannerSView superview] == nil){
        self.bannerSView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, Main_Size.width, BannerView_Height)];
        [self.bannerSView setDelegate:self];
        [self.bannerSView setScrollEnabled:YES];
        [self.bannerSView setPagingEnabled:YES];
        [self.bannerSView setShowsHorizontalScrollIndicator:NO];
        [self.bannerSView setShowsVerticalScrollIndicator:NO];
        [self.bannerSView setContentSize:CGSizeMake(Main_Size.width * (bannerArr.count+2), BannerView_Height)];
        [self.mainSView addSubview:self.bannerSView];
    }else{
        [self.bannerSView setContentSize:CGSizeMake(Main_Size.width * (2+bannerArr.count), BannerView_Height)];
    }
    
    if(bannerArr.count == 1){
        self.bannerSView.scrollEnabled = NO;
    }else{
        self.bannerSView.scrollEnabled = YES;
    }
    
    //banner个数为0，可能是网络请求失败，使用上次保存的数据显示
    if(bannerArr.count == 0){
        
        NSArray *arr = [GlobalMethod getObjectForKey:BANNERARR];
        if(arr.count == 0 || [arr isKindOfClass:[NSNull class]]){
            
        }else{
            bannerArr = [NSMutableArray arrayWithArray:arr];
        }
    }else{
        //得到新的品牌对象，先判断是否变化，若是变化，则进行保存
        if( ![bannerArr isEqualToArray:[GlobalMethod getObjectForKey:BANNERARR]] ){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                [GlobalMethod saveObject:bannerArr withKey:BANNERARR]; //将brands对象异步保存
            });
        }
    }
    
    for(int i=0; i<bannerArr.count; i++)
    {
        ActivityObj *obj = (ActivityObj *)bannerArr[i];
        
        EGOImageView *iView = [[EGOImageView alloc] initWithFrame:CGRectMake(Main_Size.width*(i+1), 0, Main_Size.width, BannerView_Height)];
        [iView setPlaceholderImage:[UIImage imageNamed:@"default_img_640x290"]];
        [iView setImageURL:obj.activityImgUrl];
        [iView setTag:i];
        [iView setUserInteractionEnabled:YES];
        [self.bannerSView addSubview:iView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(comeToBannerView:)];
        [iView addGestureRecognizer:tap];
        if (i == 0) {
            ActivityObj *obj = (ActivityObj *)[bannerArr lastObject];
            
            EGOImageView *iView = [[EGOImageView alloc] initWithFrame:CGRectMake(0, 0, Main_Size.width, BannerView_Height)];
            [iView setPlaceholderImage:[UIImage imageNamed:@"default_img_640x290"]];
            [iView setImageURL:obj.activityImgUrl];
            [iView setTag:bannerArr.count-1];
            [iView setUserInteractionEnabled:YES];
            [self.bannerSView addSubview:iView];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(comeToBannerView:)];
            [iView addGestureRecognizer:tap];
        }else if(i == bannerArr.count-1){
            ActivityObj *obj = (ActivityObj *)bannerArr[0];
            
            EGOImageView *iView = [[EGOImageView alloc] initWithFrame:CGRectMake(Main_Size.width*(bannerArr.count+1), 0, Main_Size.width, BannerView_Height)];
            [iView setPlaceholderImage:[UIImage imageNamed:@"default_img_640x290"]];
            [iView setImageURL:obj.activityImgUrl];
            [iView setTag:0];
            [iView setUserInteractionEnabled:YES];
            [self.bannerSView addSubview:iView];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(comeToBannerView:)];
            [iView addGestureRecognizer:tap];
        }
    }
    self.bannerSView.contentOffset = CGPointMake(320, 0);
    scrolTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(bannerSViewChange) userInfo:nil repeats:YES];
    if(self.pageC){
        [self.mainSView addSubview:self.pageC];
        return ;
    }
    self.pageC = [[UIPageControl alloc] initWithFrame:CGRectMake(0, BannerView_Height - 20, Main_Size.width, 20)];
    [self.pageC setUserInteractionEnabled:NO];
    [self.pageC setNumberOfPages:bannerArr.count];
    [self.pageC setCurrentPageIndicatorTintColor:NavBarColor];
    [self.pageC setCurrentPage:0];
    [self.mainSView addSubview:self.pageC];
}

- (void)buildRushPurchaseView
{
    rushPurchaseView = [[UIView alloc] initWithFrame:CGRectMake(8, self.bannerSView.bottom + 8, 151, 140)];
    [rushPurchaseView setBackgroundColor:[UIColor whiteColor]];
    [self.mainSView addSubview:rushPurchaseView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(comeToRushView)];
    [rushPurchaseView addGestureRecognizer:tap];
    
    UIImage *rushLogo = [UIImage imageNamed:@"Home_RushPurchase"];
    UIImageView *rushLogoView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, rushLogo.size.width, rushLogo.size.height)];
    [rushLogoView setImage:rushLogo];
    [rushPurchaseView addSubview:rushLogoView];
    
    rushLb = [GlobalMethod BuildLableWithFrame:CGRectMake(rushLogoView.right + 4, 15, 100, 16)
                                               withFont:[UIFont boldSystemFontOfSize:15]
                                               withText:@"抢购"];
    [rushLb setTextColor:RGBS(51)];
    [rushPurchaseView addSubview:rushLb];
    
    UILabel *timeLb = [GlobalMethod BuildLableWithFrame:CGRectMake(10, rushLogoView.bottom + 4, 140, 13)
                                               withFont:[UIFont systemFontOfSize:12]
                                               withText:@"还剩    时    分     秒"];
    [timeLb setTextColor:RGBS(102)];
    //[rushPurchaseView addSubview:timeLb];
    
    hourLb = [GlobalMethod BuildLableWithFrame:CGRectMake(10, rushLogoView.bottom + 4, 130, 13)
                                      withFont:[UIFont systemFontOfSize:12]
                                      withText:[NSString stringWithFormat:@"%ld:%ld:%ld",(long)rushHour,(long)rushMinute,(long)rushSecond]];
    [hourLb setTextColor:RGB(255, 52, 0)];
    [rushPurchaseView addSubview:hourLb];
    
    minuteLb = [GlobalMethod BuildLableWithFrame:CGRectMake(hourLb.right + 3, rushLogoView.bottom + 4, 25, 13)
                                      withFont:[UIFont systemFontOfSize:12]
                                      withText:[NSString stringWithFormat:@"%ld",(long)rushMinute]];
    [minuteLb setTextColor:RGB(255, 52, 0)];
    //[rushPurchaseView addSubview:minuteLb];
    
    secondLb = [GlobalMethod BuildLableWithFrame:CGRectMake(minuteLb.right + 2, rushLogoView.bottom + 4, 25, 13)
                                      withFont:[UIFont systemFontOfSize:12]
                                      withText:[NSString stringWithFormat:@"%ld",(long)rushSecond]];
    [secondLb setTextColor:RGB(255, 52, 0)];
    //[rushPurchaseView addSubview:secondLb];
    
    rushProSalePriceLb = [GlobalMethod BuildLableWithFrame:CGRectMake(0, 95, 80, 13)
                                                  withFont:[UIFont boldSystemFontOfSize:12]
                                                  withText:nil];
    [rushProSalePriceLb setTextAlignment:NSTextAlignmentCenter];
    [rushPurchaseView addSubview:rushProSalePriceLb];
    
    rushProOldPriceLb = [GlobalMethod BuildLableWithFrame:CGRectMake(0, 110, 80, 12)
                                                 withFont:[UIFont systemFontOfSize:11]
                                                 withText:nil];
    [rushProOldPriceLb setTextColor:RGBS(102)];
    [rushProOldPriceLb setTextAlignment:NSTextAlignmentCenter];
    [rushPurchaseView addSubview:rushProOldPriceLb];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, 5, 50, 1)];
    [line setBackgroundColor:RGBS(102)];
    [rushProOldPriceLb addSubview:line];
    
    rushProImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(70, 55, 75, 75)];
    [rushProImgView setPlaceholderImage:[UIImage imageNamed:@"default_img_150"]];
    [rushProImgView setImageURL:rushProductObj.imgUrl];
    [rushPurchaseView addSubview:rushProImgView];
}

- (void)buildSpecialProductView  //特价商品和热卖商品
{
    specialProductView = [[UIView alloc] initWithFrame:CGRectMake(rushPurchaseView.right + 2, rushPurchaseView.top, 152, 140)];
    [specialProductView setBackgroundColor:[UIColor whiteColor]];
    [self.mainSView addSubview:specialProductView];
    
    //特价商品
    UIView *sepicealBg = [[UIView alloc] initWithFrame:CGRectMake(1, 1, 150, 68)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(comeToSpecialProductListView)];
    [sepicealBg addGestureRecognizer:tap];
    [specialProductView addSubview:sepicealBg];
    UILabel *lb1 = [GlobalMethod BuildLableWithFrame:CGRectMake(8, 10, 70, 15)
                                            withFont:[UIFont boldSystemFontOfSize:14]
                                            withText:@"特价商品"];
    [sepicealBg addSubview:lb1];
    
    specialProNameLb = [GlobalMethod BuildLableWithFrame:CGRectMake(6, lb1.bottom + 2, 70, 30)
                                                withFont:[UIFont systemFontOfSize:11]
                                                withText:specialProductObj.name];
    [specialProNameLb setTextColor:RGBS(101)];
    [specialProNameLb setNumberOfLines:2];
    [sepicealBg addSubview:specialProNameLb];
    
    specialProImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(lb1.right + 5, 1, 68, 68)];
    [specialProImgView setUserInteractionEnabled:NO];
    [specialProImgView setPlaceholderImage:[UIImage imageNamed:@"default_img_150"]];
    [specialProImgView setImageURL:specialProductObj.imgUrl];
    [specialProductView addSubview:specialProImgView];
    
    UIView *line  = [[UIView alloc] initWithFrame:CGRectMake(0, 70, 152, 2)];
    [line setBackgroundColor:RGBS(238)];
    [specialProductView addSubview:line];
    
    //热卖商品
    hotProImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(1, 72, 68, 68)];
    [hotProImgView setUserInteractionEnabled:NO];
    [hotProImgView setPlaceholderImage:[UIImage imageNamed:@"default_img_150"]];
    [hotProImgView setImageURL:hotProductObj.imgUrl];

    [specialProductView addSubview:hotProImgView];
    
    UIView *hotBg = [[UIView alloc] initWithFrame:CGRectMake(1, 71, 150, 68)];
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(comeToHotProductListView)];
    [hotBg addGestureRecognizer:tap];
    [specialProductView addSubview:hotBg];
    UILabel *lb2 = [GlobalMethod BuildLableWithFrame:CGRectMake(74, 10, 70, 15)
                                            withFont:[UIFont boldSystemFontOfSize:14]
                                            withText:@"热卖商品"];
    [hotBg addSubview:lb2];
    
    hotProNameLb = [GlobalMethod BuildLableWithFrame:CGRectMake(70, lb1.bottom + 2, 70, 30)
                                                withFont:[UIFont systemFontOfSize:11]
                                                withText:hotProductObj.name];
    [hotProNameLb setTextColor:RGBS(101)];
    [hotProNameLb setNumberOfLines:2];
    [hotBg addSubview:hotProNameLb];
}

- (void)buildActicityView
{
    NSArray *imgArr = [NSArray arrayWithObjects:@"Home_Activity",@"Home_GroupPurchase",@"Home_Order",@"Home_Charge",nil];
    
    activityView = [[UIView alloc] initWithFrame:CGRectMake(8, rushPurchaseView.bottom + 8, 304, 138)];
    [self.mainSView addSubview:activityView];
    
    for (int i=0; i<2; i++)
    {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickToActivity:)];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(156*i, 0, 148, 65)];
        [imgView setImage:[UIImage imageNamed:imgArr[i]]];
        [imgView setUserInteractionEnabled:YES];
        [imgView setTag:Activity_Status + i];
        [imgView addGestureRecognizer:tap];
        [activityView addSubview:imgView];
    }
    
    for(int i=0; i<2; i++)
    {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickToActivity:)];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(156*i, 73, 148, 65)];
        [imgView setImage:[UIImage imageNamed:imgArr[i+2]]];
        [imgView setUserInteractionEnabled:YES];
        [imgView setTag:Order_Status + i];
        [imgView addGestureRecognizer:tap];
        [activityView addSubview:imgView];
    }
}

- (void)buildBrandView
{
    UIView *brandView = [[UIView alloc] initWithFrame:CGRectMake(0, activityView.bottom + 8, 320, 300)];
    [brandView setBackgroundColor:[UIColor whiteColor]];
    [self.mainSView addSubview:brandView];
    
    UILabel *lb = [GlobalMethod BuildLableWithFrame:CGRectMake(10, 15, 60, 16)
                                           withFont:[UIFont boldSystemFontOfSize:15]
                                           withText:@"品牌专区"];
    [brandView addSubview:lb];
    
    /*
    //如果品牌数不是3的倍数，则优化成3的倍数
    if(brandsArr.count % 3 == 1){
        [brandsArr removeLastObject];
    }else if (brandsArr.count % 3 == 2){
        [brandsArr removeLastObject];
        [brandsArr removeLastObject];
    }*/
    
//    //如果品牌数不是2的倍数，则优化成2的倍数
//    if(brandsArr.count % 2 == 1){
//        [brandsArr removeLastObject];
//    }
    
    //品牌专区最多显示8个
    if (brandsArr.count > 8) {
        int total = brandsArr.count;
        for (int i=8; i<total; i++) {
            [brandsArr removeLastObject];
        }
    }
    
    if(brandsArr.count == 0){   //品牌个数为0，可能是网络请求失败，使用上次保存的数据显示
        brandsArr = [GlobalMethod getObjectForKey:BRANDSARR];
    }else{
        //得到新的品牌对象，先判断是否变化，若是变化，则进行保存
        if( ![brandsArr isEqualToArray:[GlobalMethod getObjectForKey:BRANDSARR]] ){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                [GlobalMethod saveObject:brandsArr withKey:BRANDSARR]; //将brands对象保存
            });
        }
    }
    
    for(int i=0; i<brandsArr.count; i++){
        BrandsObj *obj = brandsArr[i];
        
        UIView *brandImgView = [[UIView alloc] initWithFrame:CGRectMake(8 + 152*(i%2), lb.bottom + 10 + 70*(i/2), 150, 69)];
        [brandView addSubview:brandImgView];
        
        UILabel *nameLb = [GlobalMethod BuildLableWithFrame:CGRectMake(8, 8, 120, 13)
                                                   withFont:[UIFont systemFontOfSize:12]
                                                   withText:obj.name];
        [brandImgView addSubview:nameLb];
        
        EGOImageView *imageView = [[EGOImageView alloc] initWithFrame:CGRectMake(40, nameLb.bottom + 10, 100, 32)];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        
        [imageView setPlaceholderImage:[UIImage imageNamed:@"default_img_88x30"]];
        [imageView setImageURL:obj.imageUrl];
        [brandImgView addSubview:imageView];
        
        [brandImgView setUserInteractionEnabled:YES];
        [brandImgView setTag:i];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(comeToBrandView:)];
        [brandImgView addGestureRecognizer:tap];
        
        //加下划线，最后一行不加
        if(i%2 == 0 && (i!=brandsArr.count-2)){
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, brandImgView.bottom, Main_Size.width, 1)];
            [line setBackgroundColor:RGBS(221)];
            [brandView addSubview:line];
        }
        
        if( i == brandsArr.count-1){
            UIView *vline = [[UIView alloc] initWithFrame:CGRectMake(Main_Size.width/2, lb.bottom + 10, 1, brandImgView.bottom- 45)];
            [vline setBackgroundColor:RGBS(221)];
            [brandView addSubview:vline];
        }
    }
    
    [brandView setFrame:CGRectMake(0, activityView.bottom + 8, 320, lb.bottom + 20 + 70 * (brandsArr.count/2))];
    [self.mainSView setContentSize:CGSizeMake(Main_Size.width, brandView.bottom + 20)];
    
    [self setExclusiveTouch:self.view];
}


#pragma mark -ViewAction
#pragma mark imgviewAction
- (void)comeToBannerView:(UITapGestureRecognizer *)tap
{
    [MobClick event:SYJDT];
    NSInteger tag = [tap view].tag;
    ActivityObj *currentObj = (ActivityObj *)bannerArr[tag];
    
    ActivityDetailViewController *actDetailVC = [ActivityDetailViewController shareInstance];
    [actDetailVC setActTitle:currentObj.activityName];
    [actDetailVC setActivtyDetailUrl:currentObj.activityLinkUrl];
    [actDetailVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:actDetailVC animated:YES];
}

- (void)clickToActivity:(UITapGestureRecognizer *)tap
{
    NSInteger tag = [tap view].tag;
    
    switch (tag) {
        case Activity_Status:
        {
            DLog(@"查看促销活动专场");
            [MobClick event:ACTIVITY_VIEW];
            PromotionActivityViewController *pActivityVC = [PromotionActivityViewController shareInstance];
            [pActivityVC setActivityArr:bannerArr];
            [pActivityVC setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:pActivityVC animated:YES];
        }
            break;
            
        case Charge_Status:
        {
            [MobClick event:NEW_VIEW];
            SpecialsProductViewController *specialVC = [SpecialsProductViewController shareInstance];
            [specialVC setProduct_attribute:PRODUCT_NEW];
            [specialVC setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:specialVC animated:YES];
        }
            break;
            
        case Order_Status:
        {
            UserObj *user = [GlobalMethod getObjectForKey:USEROBJECT];
            if(user.im){
                UnpayViewController *unpayVC = [UnpayViewController shareInstance];
                [unpayVC setHidesBottomBarWhenPushed:YES];
                [self.navigationController pushViewController:unpayVC animated:YES];
            }else{
                LoginInViewController *loginViewC = [[LoginInViewController alloc] init];
                UINavigationController *loginNavC = [[UINavigationController alloc] initWithRootViewController:loginViewC];
                [loginNavC setNavigationBarHidden:YES];
                [self presentViewController:loginNavC animated:YES completion:Nil];
            }
        }
            break;
            
        case GroupPurchase_Status:
        {
            [MobClick event:CRUZY_VIEW];
            SpecialsProductViewController *specialVC = [SpecialsProductViewController shareInstance];
            [specialVC setProduct_attribute:PRODUCT_CRAZY];
            [specialVC setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:specialVC animated:YES];
        }
            break;
            
        default:
            break;
    }
}

- (void)comeToRushView
{
    RushProductViewController *rushVC = [RushProductViewController shareInstance];
    [rushVC setHidesBottomBarWhenPushed:YES];
    [MobClick event:RUSH_VIEW];
    [self.navigationController pushViewController:rushVC animated:YES];
}

- (void)rushProductTime
{
    rushSecond --;
    if(rushSecond == -1){
        rushMinute --;
        rushSecond = 59;
        if(rushMinute == -1){
            rushHour --;
            rushMinute = 59;
        }
    }
    if(rushSecond <= 0 && rushMinute <= 0 && rushHour <= 0){
        [timer invalidate];
        DLog(@"抢购时间到");
        
        [rushLb setTextColor:[UIColor redColor]];
        [rushLb setText:@"抢购结束"];
        [rushPurchaseView setUserInteractionEnabled:NO];
        
        [hourLb setText:@""];
//        [secondLb setText:@"0"];
//        [minuteLb setText:@"0"];
    }else{
        [rushLb setTextColor:[UIColor blackColor]];
        [rushLb setText:@"抢购"];
        [rushPurchaseView setUserInteractionEnabled:YES];
        
        [hourLb setText:[NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)rushHour,(long)rushMinute,(long)rushSecond]];
        //[secondLb setText:[NSString stringWithFormat:@"%02ld",(long)rushSecond]];
        //[minuteLb setText:[NSString stringWithFormat:@"%02ld",(long)rushMinute]];
    }
}

- (void)comeToSpecialProductListView
{
    [MobClick event:SPECLIAL_VIEW];
    SpecialsProductViewController *specialVC = [SpecialsProductViewController shareInstance];
    [specialVC setProduct_attribute:PRODUCT_SPECIAL];
    [specialVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:specialVC animated:YES];
}

- (void)comeToHotProductListView
{
    [MobClick event:HOT_VIEW];
    SpecialsProductViewController *specialVC = [SpecialsProductViewController shareInstance];
    [specialVC setProduct_attribute:PRODUCT_HOT];
    [specialVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:specialVC animated:YES];
}

- (void)comeToBrandView:(UITapGestureRecognizer *)tap
{
    NSInteger index = [tap view].tag;
    
    BrandsObj *obj = brandsArr[index];
    
    [MobClick event:ACTIVITY_PRODUCT_LISR_VIEW];
    ProductSortViewController *sortVC = [ProductSortViewController shareInstance];
    [sortVC setBrandId:obj.brandsId];
    [sortVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:sortVC animated:YES];
}

- (void)bannerSViewChange
{
//    curentBannerIndex ++;
//    if(curentBannerIndex >= (bannerArr.count-1))
//    {
//        curentBannerIndex = 0;
//    }
//    [self.bannerSView setContentOffset:CGPointMake(curentBannerIndex*320, 0) animated:YES];
//    [self.pageC setCurrentPage:curentBannerIndex];
    NSInteger page = self.bannerSView.contentOffset.x /320;
    page++;
    [UIView animateWithDuration:1 animations:^{
        self.bannerSView.contentOffset = CGPointMake(page * 320, 0);
    } completion:^(BOOL finished) {
        [self scrollViewDidEndDecelerating:self.bannerSView];
    }];
    
}

#pragma mark -Delegate
#pragma mark UITableView Methods  搜索结果里的TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // 添加
    return self.searchDataArr.count + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    if(indexPath.row == 0){  //历史纪录
        [cell.textLabel setText:@"搜索历史"];
        [cell.textLabel setTextColor:RGBS(102)];
    }else if(indexPath.row == (self.searchDataArr.count + 1)){      //清空历史
        UIButton *clearBt = [GlobalMethod BuildButtonWithFrame:CGRectMake(110, 10, 100, 30)
                                                     andOffImg:nil
                                                      andOnImg:nil
                                                     withTitle:@"清空历史"];
        [clearBt addTarget:self action:@selector(clearHistroyArr) forControlEvents:UIControlEventTouchUpInside];
        [clearBt.layer setBorderColor:RGBS(201).CGColor];
        [clearBt.layer setBorderWidth:1];
        [clearBt.layer setCornerRadius:5];
        [cell.contentView addSubview:clearBt];
    }else{
        [cell.textLabel setText:[NSString stringWithFormat:@"\t%@",self.searchDataArr[indexPath.row - 1]]];
        [cell.textLabel setTextColor:RGBS(51)];
    }
    
    return cell;
}

- (void)clearHistroyArr
{
    [GlobalMethod saveObject:nil withKey:HISTORYARR];
    [self.searchDataArr removeAllObjects];
    
    [self.searchDC.searchResultsTableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0 || indexPath.row == (self.searchDataArr.count + 1)){
        return ;
    }
    
    //选择历史纪录，先将其删除，然后加入到数组的第一个元素
    NSString *searchKey = self.searchDataArr[indexPath.row - 1];
    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.searchDataArr];
    [arr removeObject:searchKey];
    [arr insertObject:searchKey atIndex:0];
    [GlobalMethod saveObject:arr withKey:HISTORYARR];
    
    ProductSortViewController *proSortVC = [ProductSortViewController shareInstance];
    [proSortVC setSearchKey:searchKey];
    [proSortVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:proSortVC animated:YES];
}

#pragma mark UISearchDisplay Methods
- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    self.searchDC.searchBar.tintColor = [UIColor whiteColor];
    
    //点击搜索，读取历史搜索纪录
    [self.searchDataArr removeAllObjects];
    if([GlobalMethod getObjectForKey:HISTORYARR] != nil){
        NSArray *arr = [GlobalMethod getObjectForKey:HISTORYARR];
        [self.searchDataArr setArray:arr];
    }
}

- (void) searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    [self.searchDC.searchResultsTableView reloadData];
}


- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    [self setTabBarShowWithAnimation:NO];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self setTabBarHiddenWithAnimation:YES];
    if (self.searchDataArr.count > 0) {
        //searchBar.text = self.searchDataArr[0];  //不显示最后一次得搜索
    }
    
    [MobClick event:SS];
    [MobClick event:LSJL];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //搜索结束，保持最新的历史纪录 (保存10条)
    if(self.searchDataArr.count >= 10){
        [self.searchDataArr removeLastObject];
    }
    
    //如果包含该字段，先删除再添加到 首位置
    if([self.searchDataArr containsObject:searchBar.text]){
        [self.searchDataArr removeObject:searchBar.text];
    }
    [self.searchDataArr insertObject:searchBar.text atIndex:0];
    
    NSArray *arr = [NSArray arrayWithArray:self.searchDataArr];
    [GlobalMethod saveObject:arr withKey:HISTORYARR];
    
    ProductSortViewController *proSortVC = [ProductSortViewController shareInstance];
    [proSortVC setSearchKey:searchBar.text];
    [proSortVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:proSortVC animated:YES];
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if(range.location > 20){
        return NO;
    }
    
    return YES;
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods 轮播广告滚动
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    if(scrollView == self.bannerSView)
    {
        NSInteger page = (int)(scrollView.contentOffset.x/320);
        if (page == 0) {
            page = bannerArr.count;
        }else if (page == bannerArr.count+1){
            page = 1;
        }
        [self.pageC setCurrentPage:page-1];
        self.bannerSView.contentOffset = CGPointMake(page * 320, 0);
        if (scrolTimer == nil) {
            scrolTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(bannerSViewChange) userInfo:nil repeats:YES];
        }

    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView == self.bannerSView){
//        if(scrollView.contentOffset.x/320.0 >= (bannerArr.count+1)){
//            [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
//            curentBannerIndex = 0;
//            [self.pageC setCurrentPage:curentBannerIndex];
//        }
//        
//        if(scrollView.contentOffset.x <= 0){
//            [scrollView setContentOffset:CGPointMake(320*(bannerArr.count ), 0) animated:NO];
//            curentBannerIndex = bannerArr.count - 1;
//            [self.pageC setCurrentPage:curentBannerIndex];
//        }
        if (scrolTimer != nil && scrolTimer.isValid) {
            [scrolTimer invalidate];
            scrolTimer = nil;
        }
        return;
    }
    
	if (egoHeaderTable){
        [egoHeaderTable egoRefreshScrollViewDidScroll:self.mainSView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
  
    if(scrollView == self.bannerSView){
        return;
    }
    
	if (egoHeaderTable){
        [egoHeaderTable egoRefreshScrollViewDidEndDragging:self.mainSView];
    }
}

#pragma mark -
#pragma mark EGORefreshTableDelegate Methods

- (void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos
{
	[self beginToReloadData:aRefreshPos];
}

- (BOOL)egoRefreshTableDataSourceIsLoading:(UIView*)view
{
	return _isLoading;   // should return if data source model is reloading
}


// if we don't realize this method, it won't display the refresh timestamp
- (NSDate*)egoRefreshTableDataSourceLastUpdated:(UIView*)view
{
	return [NSDate date]; // should return date data source was last changed
}

-(void)beginToReloadData:(EGORefreshPos)aRefreshPos   //刷新或追加开始
{
	_isLoading = YES;
    
    if (aRefreshPos == EGORefreshHeader)  // pull down to refresh data
    {
        [self performSelector:@selector(refreshView) withObject:nil afterDelay:0];
    }
}

- (void)refreshView
{
    self.searchDataArr  = [NSMutableArray arrayWithCapacity:10];
    bannerArr           = [NSMutableArray arrayWithCapacity:10];
    brandsArr           = [NSMutableArray arrayWithCapacity:10];
    [self getDataSourceByNetwork];
    [self finishReloadingData];
    [self getFirstDataSource];
    self.pageC.currentPage = 0;
    if(scrolTimer != nil && scrolTimer.isValid){
        [scrolTimer invalidate];
        scrolTimer = nil;
    }
    scrolTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(bannerSViewChange) userInfo:nil repeats:YES];
}

- (void)finishReloadingData       //刷新或追加结束
{
	_isLoading = NO;
    
	if (egoHeaderTable)
    {
        [egoHeaderTable egoRefreshScrollViewDataSourceDidFinishedLoading:self.mainSView];
    }
    
    //[self.mainTableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
