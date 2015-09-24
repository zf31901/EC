//
//  ProductSortViewController.m
//  Shop
//
//  Created by Harry on 13-12-20.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "ProductSortViewController.h"
#import "CartViewController.h"
#import "ProductDetailViewController.h"
#import "ProductSortCell.h"
#import "ProductObj.h"
#import "RADataObject.h"
#import "RATreeView.h"
#import "ProductObj.h"
#import "BrandsObj.h"
#import "UIButton+Extensions.h"
#import "HarryButton.h"
#import "HTTPRequest.h"
#import "JSONKit.h"

static float segment_height = 46;
static float rightView_width = 220;

@interface ProductSortViewController () <RATreeViewDataSource,RATreeViewDelegate>
{
    UISearchBar         *searchbar;
    UIView              *segmentBgView;
    
    NSMutableArray      *sortProArr;            //商品列表数据
    
    RATreeView          *brandsTView;           //右滑出来的筛选品牌view
    RADataObject        *brandsObj;             //筛选品牌的商品的品牌对象
    NSMutableArray      *brandsDataArr;         //筛选品牌的商品的品牌数组
    //NSMutableArray      *priceDataArr;        //筛选价格的商品 （保留）
    NSMutableArray      *filtrateDataArr;       //筛选的商品 的数据
    BOOL                isShowBanderTView;      //是否显示 筛选 界面
    
    NSMutableArray      *segbtArr;
    NSMutableArray      *segImgArr;
    
    CGFloat             scrollHeight;
    
    NSInteger           cureentPage;            //第几页数据
    NSString            *brandsChoice;          //品牌筛选
    SORT_STATUS         sortStatus;             //排序方式
    BOOL                isSaleUp;               //判断按价格是否按升序排列
    BOOL                isPriceUp;
    BOOL                isCommonUp;
    
    NSMutableArray      *proByBrands;           //多个 品牌 对商品筛选
    
    BOOL                shouldRefreshBrandArr;  //是否要刷新品牌列表
}

@end

@implementation ProductSortViewController

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
    
    [self setRightBtnOffImg:@"" andOnImg:@"" andTitle:@"筛选"];
    
    UIView *barView = [self getBaseNavBar];  //得到NavBar
    searchbar = [[UISearchBar alloc] initWithFrame:CGRectMake(68, [GlobalMethod AdapterIOS6_7ByIOS6Float:0], 200, 44)];
    [searchbar setDelegate:self];
    [searchbar setPlaceholder:@"请输入关键字"];
    [searchbar setText:self.searchKey];
    [searchbar setBackgroundImage:[[UIImage alloc] init]];
    if([[UIDevice currentDevice] systemVersion].floatValue >= 7.0) //ios7新特性
    {
        [searchbar setBarTintColor:NavBarColor];
    }
    else
    {
        [searchbar setBackgroundImage:[UIImage imageNamed:@"Home_SearchBar_Bg"]];
    }
    
    [barView addSubview:searchbar];
    
    [self loadDataSource];
    [self buildSegmentView];
    [self resetMainTableView];
    //[self buildCartView];         //2013-12-25 tag by harry : 将购物车去掉
    [self buildProductByBrands];
    
    [MobClick event:SPLB];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.mainTableView.delegate = self;
    self.mainTableView.delegate = self;
}

- (void)loadDataSource
{
    isShowBanderTView = NO;
    shouldRefreshBrandArr = YES;
    isSaleUp = NO;
    isPriceUp = NO;
    isCommonUp = YES;
    segbtArr        = [NSMutableArray arrayWithCapacity:3];
    segImgArr       = [NSMutableArray arrayWithCapacity:3];
    sortProArr      = [NSMutableArray arrayWithCapacity:14];
    brandsDataArr   = [NSMutableArray arrayWithCapacity:14];
    filtrateDataArr = [NSMutableArray arrayWithCapacity:1];
    proByBrands     = [NSMutableArray arrayWithCapacity:10];
    cureentPage     = 1;
    
    [self showHUDInView:self.view WithText:NETWORKLOADING];
    [self getDataSourceByNetwork:REQUEST_REFRSH andSortStatus:SORT_SALE_DOWN];
}

- (void)getDataSourceByNetwork:(REQUEST_STATUS)status andSortStatus:(SORT_STATUS)sort
{
    //每次筛选，brand数据删除
    //[brandsDataArr removeAllObjects];
    
    if(status == REQUEST_REFRSH){   //刷新
        [sortProArr removeAllObjects];
        cureentPage = 1;
        self.hasMore = YES;
    }else{                          //追加
        if(self.hasMore){
            cureentPage ++;
        }else{
            [self showHUDInView:self.view WithText:@"全部加载完毕" andDelay:1];
            [self finishReloadingData];
            return ;
        }
    }
    
    BLOCK_SELF(ProductSortViewController);
    HTTPRequest *hq = [HTTPRequest shareInstance];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:8];
    [dic setObject:[NSString stringWithFormat:@"%d",cureentPage] forKey:@"page"];
    [dic setObject:@"8" forKey:@"pagesize"];
    [dic setObject:[NSString stringWithFormat:@"%d",sort] forKey:@"sort"];
    
    //按关键字搜索
    if(self.searchKey != nil){
        [dic setObject:self.searchKey forKey:@"q"];
    }
    
    //按品牌id搜索
    if(self.brandId != nil){
        [dic setObject:self.brandId forKey:@"brand"];
    }
    
    //按分类搜索
    if(self.cpId != nil){
        [dic setObject:self.cpId forKey:@"cate"];
    }
    //筛选不为空,对品牌进行 整合 搜索
    if(proByBrands.count != 0){
        NSMutableString *mString = [[NSMutableString alloc] init];
        for(int i=0; i<proByBrands.count; i++){
            if(i == proByBrands.count-1){
                [mString appendString:proByBrands[i]];
            }else{
                [mString appendFormat:@"%@:",proByBrands[i]];
            }
        }
        
        [dic setObject:mString forKey:@"brand"];
    }

    [hq GETURLString:SORT_PRODUCT_LIST userCache:NO parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObj) {
        NSDictionary *rqDic = (NSDictionary *)responseObj;
        if([rqDic[HTTP_STATE] boolValue]){
            NSDictionary *dataDic = (NSDictionary *)[rqDic[HTTP_DATA] objectFromJSONString];
            NSArray *productArr = dataDic[@"ProductData"];
            NSArray *brandsArr = dataDic[@"BrandData"];
            
            //数据解析有误处理 :显示没有商品图片，筛选不可点击
            if([productArr isKindOfClass:[NSNull class]] || [brandsArr isKindOfClass:[NSNull class]]){
                
                [self finishReloadingData];
                [self hideHUDInView:block_self.view];
                
                if([self.noResultView superview] == nil){
                    [self buildNoResult];
                }
                
                [block_self.view bringSubviewToFront:block_self.noResultView];
                
                [[self getRightButton] setEnabled:NO];
                
                [MobClick event:SSWJG];
                
                return ;
            }
            
            //最后一次请求数据少于 8 表示加载完全 （8个商品为一个page）
            if(([productArr isKindOfClass:[NSNull class]]) || productArr.count < 8){
                self.hasMore = NO;
            }
            
            for(int i=0; i<productArr.count; i++){
                NSDictionary *productDic = productArr[i];
                
                ProductObj *obj = [ProductObj shareInstance];
                [obj setProductId:      productDic[@"PId"]];
                [obj setListImgUrl:     [NSURL URLWithString:productDic[@"PImage"]]];
                [obj setName:           productDic[@"PName"]];
                [obj setOldPrice:       productDic[@"PMarketPrice"]];
                [obj setSalePrice:      productDic[@"PPrice"]];
                [obj setSaleMonthNum:   productDic[@"PSalesNum"]];
                [obj setTotalComment:   productDic[@"PCommentCount"]];
                
                [sortProArr addObject:obj];
            }
            
            // 只是第一次需要获取 品牌 列表
            if(shouldRefreshBrandArr){
                for(int i=0; i<brandsArr.count; i++){
                    NSDictionary *brandsDic = (NSDictionary *)brandsArr[i];
                    RADataObject *obj = [RADataObject dataObjectWithName:brandsDic[@"BName"] pId:brandsDic[@"BId"] isChoice:NO children:nil];
                    [brandsDataArr addObject:obj];
                }
                brandsObj = [RADataObject dataObjectWithName:@"品牌" children:brandsDataArr];
                [filtrateDataArr addObject:brandsObj];
                
                shouldRefreshBrandArr = NO;
            }
            
            //没有数据
            if(sortProArr.count == 0){
                if([self.noResultView superview] == nil ){
                    [self buildNoResult];
                }
                [block_self.noResultView setHidden:NO];
                [block_self.view bringSubviewToFront:block_self.noResultView];
                
                [[self getRightButton] setEnabled:NO];
            }else{
                [[self getRightButton] setEnabled:YES];
                //商品有数据，隐藏 “没有商品”图片
                [block_self.noResultView setHidden:YES];
            }

            [brandsTView reloadData];
            [self.mainTableView reloadData];
            [self finishReloadingData];
            
            [self hideHUDInView:block_self.view];

        }else{
            NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
            [self hideHUDInView:block_self.view];
            //[self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
            [self.mainTableView reloadData];
            [self finishReloadingData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@ , %@",operation,error);
        [self hideHUDInView:block_self.view];
        [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
        [self finishReloadingData];
    }];
}

- (void)buildSegmentView
{
    segmentBgView = [[UIView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(0, Navbar_Height, Main_Size.width, segment_height)]];
    [segmentBgView setBackgroundColor:RGBS(238)];
    [self.view addSubview:segmentBgView];
    
    NSArray *titleArr = [NSArray arrayWithObjects:@"默认    ",@"价格   ",@"好评度  ", nil];
    for(int i=0; i<3; i++){
        UIButton *btn = [GlobalMethod BuildButtonWithFrame:CGRectMake(8 + 100*i, 8, 101, 30)
                                                 andOffImg:[NSString stringWithFormat:@"segment_%d_off",i]
                                                  andOnImg:[NSString stringWithFormat:@"segment_%d_on",i]
                                                 withTitle:titleArr[i]];
        [btn setTag:i];
        [btn addTarget:self action:@selector(SortBySegment:) forControlEvents:UIControlEventTouchUpInside];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [btn setTitleColor:NavBarColor forState:UIControlStateNormal];
        
        UIImageView *activeView;
        
        if(i == 1){
            UIImage *upImg = [UIImage imageNamed:@"item-grid-filter-up-arrow"];
            activeView = [[UIImageView alloc] initWithFrame:CGRectMake(65, btn.center.y - upImg.size.height/2 - 8, upImg.size.width, upImg.size.height)];
            [activeView setImage:upImg];
            [btn addSubview:activeView];
        }else if(i == 0){
            [btn setBackgroundImage:[UIImage imageNamed:@"segment_0_on"] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            UIImage *downImg = [UIImage imageNamed:@"item-grid-filter-down-active-arrow"];
            activeView = [[UIImageView alloc] initWithFrame:CGRectMake(65, btn.center.y - downImg.size.height/2 - 8, downImg.size.width, downImg.size.height)];
            [activeView setImage:downImg];
            [btn addSubview:activeView];
        }else{
            UIImage *downImg = [UIImage imageNamed:@"item-grid-filter-down-arrow"];
            activeView = [[UIImageView alloc] initWithFrame:CGRectMake(75, btn.center.y - downImg.size.height/2 - 8, downImg.size.width, downImg.size.height)];
            [activeView setImage:downImg];
            [btn addSubview:activeView];
        }
        
        [segmentBgView addSubview:btn];
        
        [segImgArr addObject:activeView];
        [segbtArr addObject:btn];
    }
}

- (void)resetMainTableView
{
    [self.mainTableView setFrame:CGRectMake(0, segmentBgView.bottom, Main_Size.width, Main_Size.height - StatusBar_Height - Navbar_Height - segment_height)];
    [self.mainTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self finishReloadingData];
    
    //取消左右滑动进行筛选的手势 tag by harry 2014-02-13
    /*
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showBanderView)];
    [leftSwipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideBanderView)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.mainTableView addGestureRecognizer:leftSwipe];
    [self.mainTableView addGestureRecognizer:rightSwipe];
     */
    
    [self.view addSubview:self.mainTableView];
}

- (void)buildCartView
{
    UIButton *cartBt = [GlobalMethod BuildButtonWithFrame:CGRectMake(260, Main_Size.height - 60, 44, 44)
                                                andOffImg:@"item-grid-float-bg-grey"
                                                 andOnImg:@"item-grid-float-bg-grey"
                                                withTitle:nil];
    [cartBt setImage:[UIImage imageNamed:@"item-grid-float-shopping-cart-icon"] forState:UIControlStateNormal];
    [cartBt addTarget:self action:@selector(comeToCartView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cartBt];
}

- (void)buildProductByBrands  //筛选界面
{
    UIImageView *bgIView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, rightView_width, [GlobalMethod AdapterIOS6_7ByIOS6Float:Main_Size.height - StatusBar_Height])];
    [bgIView setImage:[UIImage imageNamed:@"sort-bg"]];
    
    brandsTView = [[RATreeView alloc] initWithFrame:CGRectMake(Main_Size.width, 0, rightView_width, [GlobalMethod AdapterIOS6_7ByIOS6Float:Main_Size.height - StatusBar_Height])];
    [brandsTView setDelegate:self];
    [brandsTView setDataSource:self];
    [brandsTView setSeparatorStyle:RATreeViewCellSeparatorStyleNone];
    [brandsTView setBackgroundView:bgIView];
    [brandsTView setBackgroundColor:[UIColor clearColor]];
    [brandsTView reloadData];
    [self.view addSubview:brandsTView];
    
    UILabel *headerView = [GlobalMethod BuildLableWithFrame:CGRectMake(0, 0, rightView_width, [GlobalMethod AdapterIOS6_7ByIOS6Float:Navbar_Height]) withFont:[UIFont systemFontOfSize:17] withText:@"筛选"];
    [headerView setTextAlignment:NSTextAlignmentCenter];
    [headerView setTextColor:RGBS(255)];
    [brandsTView setTreeHeaderView:headerView];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rightView_width, 60)];
    [footerView setBackgroundColor:[UIColor clearColor]];
    UIButton *clearBt = [GlobalMethod BuildButtonWithFrame:CGRectMake(20, 10, 80, 35)
                                                 andOffImg:@"clearBanner_off"
                                                  andOnImg:@"clearBanner_on"
                                                 withTitle:@"全部清除"];
    [clearBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [clearBt.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [clearBt addTarget:self action:@selector(clearBanner) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:clearBt];
    UIButton *sureBt = [GlobalMethod BuildButtonWithFrame:CGRectMake(120, 10, 80, 35)
                                                 andOffImg:@"suerBanner_off"
                                                  andOnImg:@"suerBanner_on"
                                                 withTitle:@"确定"];
    [sureBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sureBt.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [sureBt addTarget:self action:@selector(sureBanner) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:sureBt];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 1, rightView_width, 0.5)];
    [line setBackgroundColor:RGBS(245)];
    [footerView addSubview:line];
    [brandsTView setTreeFooterView:footerView];
}

#pragma mark ViewAction
- (void)rightBtnAction:(UIButton *)btn
{
    [MobClick event:SXLB];
    
    DLog(@"筛选 商品");
    
    [searchbar resignFirstResponder];
    
    float start_x = 0;
    
    if(isShowBanderTView){
        start_x = 0;
        [brandsTView collapseRowForItem:brandsObj];
    }else{
        start_x = -rightView_width;
        
        [brandsTView expandRowForItem:brandsObj];
        
        [MobClick event:SXLB];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.mainTableView setFrame:CGRectMake(start_x, self.mainTableView.top, self.mainTableView.width, self.mainTableView.height)];
        UIView *navBar = [self getBaseNavBar];
        [navBar setFrame:CGRectMake(start_x, navBar.top, navBar.width, navBar.height)];
        [segmentBgView setFrame:CGRectMake(start_x, segmentBgView.top, segmentBgView.width, segmentBgView.height)];
        [brandsTView setFrame:CGRectMake(self.mainTableView.right, brandsTView.top, brandsTView.width, brandsTView.height)];
    }];
    
    isShowBanderTView = !isShowBanderTView;
}

- (void)SortBySegment:(UIButton *)bt
{
    [searchbar resignFirstResponder];
    
    for(UIButton *btn in segbtArr){
        int index = [segbtArr indexOfObject:btn];
        [btn setTitleColor:NavBarColor forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"segment_%d_off",index]] forState:UIControlStateNormal];
        
        UIImageView *activeView = [segImgArr objectAtIndex:index];
        if(index == 1){
            [activeView setImage:[UIImage imageNamed:@"item-grid-filter-up-arrow"]];
            if (isPriceUp) {
                [activeView setImage:[UIImage imageNamed:@"item-grid-filter-up-arrow"]];
            }else{
                [activeView setImage:[UIImage imageNamed:@"item-grid-filter-down-arrow"]];
            }
        }else if(index == 0){
            [activeView setImage:[UIImage imageNamed:@"item-grid-filter-down-arrow"]];
            if (isSaleUp) {
                [activeView setImage:[UIImage imageNamed:@"item-grid-filter-up-arrow"]];
            }else{
                [activeView setImage:[UIImage imageNamed:@"item-grid-filter-down-arrow"]];
            }
        }else{
            if (isCommonUp) {
                [activeView setImage:[UIImage imageNamed:@"item-grid-filter-up-arrow"]];
            }else{
                [activeView setImage:[UIImage imageNamed:@"item-grid-filter-down-arrow"]];
            }
        }
    }
    
    [bt setBackgroundImage:[bt backgroundImageForState:UIControlStateHighlighted] forState:UIControlStateNormal];
    [bt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    NSInteger index = [segbtArr indexOfObject:bt];
    UIImageView *activeView = [segImgArr objectAtIndex:index];
    if(index == 1){
        if (isPriceUp) {
            [activeView setImage:[UIImage imageNamed:@"item-grid-filter-up-active-arrow"]];
        }else{
            [activeView setImage:[UIImage imageNamed:@"item-grid-filter-down-active-arrow"]];
        }
        isPriceUp = !isPriceUp;
        
    }else{
        if(index == 0){
            isSaleUp = !isSaleUp;
            if (isSaleUp) {
                [activeView setImage:[UIImage imageNamed:@"item-grid-filter-up-active-arrow"]];
            }else{
                [activeView setImage:[UIImage imageNamed:@"item-grid-filter-down-active-arrow"]];
            }
        }else{
            isCommonUp = !isCommonUp;
            if (isCommonUp) {
                [activeView setImage:[UIImage imageNamed:@"item-grid-filter-up-active-arrow"]];
            }else{
                [activeView setImage:[UIImage imageNamed:@"item-grid-filter-down-active-arrow"]];
            }
        }
    }
    
    [self showHUDInView:self.view WithText:NETWORKLOADING];
    
    switch (bt.tag)
    {
        case 0:
        {
            DLog(@"分类搜索按 销量 排序");
            if(isSaleUp){
                sortStatus = SORT_SALE_UP;
                [activeView setImage:[UIImage imageNamed:@"item-grid-filter-up-active-arrow"]];
            }else{
                sortStatus = SORT_SALE_DOWN;
                [activeView setImage:[UIImage imageNamed:@"item-grid-filter-down-active-arrow"]];
            }
            
            [self getDataSourceByNetwork:REQUEST_REFRSH andSortStatus:sortStatus];
        }
            break;
            
        case 1:
        {
            DLog(@"分类搜索按 价格 排序");
            if(isPriceUp){
                sortStatus = SORT_PRICE_UP;
                [activeView setImage:[UIImage imageNamed:@"item-grid-filter-up-active-arrow"]];
            }else{
                sortStatus = SORT_PRICE_DOWN;
                [activeView setImage:[UIImage imageNamed:@"item-grid-filter-down-active-arrow"]];
            }

            [self getDataSourceByNetwork:REQUEST_REFRSH andSortStatus:sortStatus];
        }
            break;
            
        case 2:
        {
            DLog(@"分类搜索按 好评度 排序");
            if(isCommonUp){
                sortStatus = SORT_COMMENT_UP;
                [activeView setImage:[UIImage imageNamed:@"item-grid-filter-up-active-arrow"]];
            }else{
                sortStatus = SORT_COMMENT_DOWN;
                [activeView setImage:[UIImage imageNamed:@"item-grid-filter-down-active-arrow"]];
            }

            [self getDataSourceByNetwork:REQUEST_REFRSH andSortStatus:sortStatus];
        }
            break;
            
        default:
            break;
    }
}

- (void)comeToCartView
{
    DLog(@"前往 购物车");
    
    CartViewController *cartVC = [CartViewController shareInstance];
    [cartVC setIsRootNavC:NO];
    [self.navigationController pushViewController:cartVC animated:YES];
}

- (void)showBanderView  //要显示banderview
{
    isShowBanderTView = NO;
    
    [self rightBtnAction:nil];
}

- (void)hideBanderView  //要隐藏banderview
{
    isShowBanderTView = YES;
    
    [self rightBtnAction:nil];
}

- (void)clearBanner
{
    if(brandsDataArr.count == 0 || [brandsDataArr isKindOfClass:[NSNull class]]){
        return ;
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    for (int i=0; i<brandsDataArr.count; i++) {
        dispatch_group_async(group, queue, ^{
            RADataObject *obj = brandsDataArr[i];
            [obj setIsChoice:NO];
        });
    }
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    [proByBrands removeAllObjects];
    
    [brandsTView reloadData];
    
    [brandsTView expandRowForItem:brandsObj];
}

- (void)sureBanner
{
    [self hideBanderView];
    [self showHUDInView:self.view WithText:NETWORKLOADING];
    [self getDataSourceByNetwork:REQUEST_REFRSH andSortStatus:sortStatus];
}

#pragma mark Delegate
#pragma mark UITableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return sortProArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(sortProArr.count == 0){
        return [[UITableViewCell alloc] init];
    }
    
    static NSString *cellString = @"product_sort_cell";
    ProductSortCell *cell = [tableView dequeueReusableCellWithIdentifier:cellString];
    if(cell == nil){
        cell = [[ProductSortCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellString];
    }
    [cell reuserTableViewCell:sortProArr[indexPath.row] AtIndex:indexPath.row];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [searchbar resignFirstResponder];
    
    if(isShowBanderTView){              //如果品牌列表显示，先隐藏它
        [self rightBtnAction:nil];
    }else
    {
        DLog(@"查看商品详情");
        ProductDetailViewController *proDVC = [ProductDetailViewController shareInstance];
        [proDVC setProductId:[(ProductObj *)sortProArr[indexPath.row] productId]];
        [self.navigationController pushViewController:proDVC animated:YES];
    }
}

#pragma mark TreeView Delegate methods
- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    return 44;
}

- (NSInteger)treeView:(RATreeView *)treeView indentationLevelForRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    return 3 * treeNodeInfo.treeDepthLevel;
}

- (void)treeView:(RATreeView *)treeView willDisplayCell:(UITableViewCell *)cell forItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{

}

- (void)treeView:(RATreeView *)treeView didSelectRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    RADataObject *selectObj = (RADataObject *)item;
    
    if(selectObj.children==nil || selectObj.children.count==0){
        
        //[self rightBtnAction:nil];
    }else{
        UITableViewCell *cell = [treeView cellForItem:item];
        
        UIImageView *statusView = (UIImageView *)[cell.contentView viewWithTag:10001];
        if( !treeNodeInfo.isExpanded ){
            [statusView setImage:[UIImage imageNamed:@"arrow-top"]];
        }else{
            [statusView setImage:[UIImage imageNamed:@"arrow-bottom"]];
        }
    }
}

- (BOOL)treeView:(RATreeView *)treeView canEditRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    return NO;
}

#pragma mark TreeView Data Source
- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    RADataObject *data = item;
    if(data.children.count > 0 || (data == brandsObj)){   //父类cell :品牌，价格等等
        static NSString *cellString = @"product_parent_cell";
        UITableViewCell *cell = [treeView dequeueReusableCellWithIdentifier:cellString];
        
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellString];
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 1, rightView_width, 0.5)];
            [line setBackgroundColor:RGBS(245)];
            [cell.contentView addSubview:line];
            
            [cell setBackgroundColor:[UIColor clearColor]];
            [cell.textLabel setFont:[UIFont systemFontOfSize:16]];
            [cell.textLabel setTextColor:RGBS(255)];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIImageView *statusView = [[UIImageView alloc] initWithFrame:CGRectMake(180, 14, 15, 15)];
            [statusView setImage:[UIImage imageNamed:@"arrow-bottom"]];
            [statusView setTag:10001];
            [cell.contentView addSubview:statusView];
        }
        
        cell.textLabel.text = data.name;
        
        UIImageView *statusView = (UIImageView *)[cell.contentView viewWithTag:10001];
        if(treeNodeInfo.isExpanded){
            [statusView setImage:[UIImage imageNamed:@"arrow-top"]];
        }else{
            [statusView setImage:[UIImage imageNamed:@"arrow-bottom"]];
        }

        return cell;
    }else{  //子类cell
        static NSString *cellString = @"product_cate_cell";
        UITableViewCell *cell = [treeView dequeueReusableCellWithIdentifier:cellString];
        
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellString];
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 1, rightView_width, 0.5)];
            [line setBackgroundColor:RGBS(245)];
            [cell.contentView addSubview:line];
            
            HarryButton *statusBt = [[HarryButton alloc] initWithFrame:CGRectMake(190, 14, 18, 18)
                                                andOffImg:@"banndUnChoice"
                                                 andOnImg:@"autoLoginOn"
                                                withTitle:nil];
            [statusBt setTag:10000];
            [statusBt setButtonEdgeInsets:UIEdgeInsetsMake(-5, -120, -5, -30)];
            [statusBt addTarget:self action:@selector(backgroundColorChange:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:statusBt];
            [cell setBackgroundColor:[UIColor clearColor]];
            [cell.textLabel setFont:[UIFont systemFontOfSize:16]];
            [cell.textLabel setTextColor:RGBS(255)];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        
        HarryButton *statusBt = (HarryButton *)[cell.contentView viewWithTag:10000];
        [statusBt setModel:data];
        [statusBt setChoiceStatus:!data.isChoice];
        [statusBt changeBackgroundImage];
        
        [cell.textLabel setFrame:CGRectMake(cell.textLabel.left, cell.textLabel.top, 20, cell.textLabel.height)];
        cell.textLabel.text = data.name;
        
        return cell;
    }
    
    return nil;
}

- (void)backgroundColorChange:(HarryButton *)button
{
    RADataObject *obj = (RADataObject *)button.model;
    [obj setIsChoice:!obj.isChoice];
    
    if(obj.isChoice){   //选中该品牌
        if(![proByBrands containsObject:obj.pId]){
            [proByBrands addObject:obj.pId];
        }
    }else{              //删除该品牌
        if([proByBrands containsObject:obj.pId]){
            [proByBrands removeObject:obj.pId];
        }
    }
    
    [button changeBackgroundImage];
}

- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item
{
    if (item == nil) {
        return [filtrateDataArr count];
    }
    
    RADataObject *data = item;
    return [data.children count];
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item
{
    RADataObject *data = item;
    if (item == nil) {
        return [filtrateDataArr objectAtIndex:index];
    }
    
    return [data.children objectAtIndex:index];
}

#pragma mark UISearchBarDeleggate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    searchBar.text = self.searchKey;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSMutableArray *searchArr = [NSMutableArray arrayWithCapacity:10];
    
    if([GlobalMethod getObjectForKey:HISTORYARR] != nil){
        NSArray *arr = [GlobalMethod getObjectForKey:HISTORYARR];
        [searchArr setArray:arr];
    }
    
    [searchBar resignFirstResponder];
    DLog(@"搜索 %@ 商品",searchBar.text);
    self.searchKey = searchBar.text;
    [self getDataSourceByNetwork:REQUEST_REFRSH andSortStatus:sortStatus];
    
    //搜索结束，保持最新的历史纪录 (保存10条)
    if(searchArr.count >= 10){
        [searchArr removeLastObject];
    }
    
    //如果包含该字段，先删除再添加到 首位置
    if([searchArr containsObject:searchBar.text]){
        [searchArr removeObject:searchBar.text];
    }
    [searchArr insertObject:searchBar.text atIndex:0];
    
    NSArray *arr = [NSArray arrayWithArray:searchArr];
    [GlobalMethod saveObject:arr withKey:HISTORYARR];
    
    [MobClick event:SS];
    [MobClick event:LSJL];
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if(range.location > 20){
        return NO;
    }
    
    return YES;
}

#pragma mark EgoTableView Method
- (void)refreshView
{
    [self getDataSourceByNetwork:REQUEST_REFRSH andSortStatus:sortStatus];
}

- (void)getNextPageView
{
    [self getDataSourceByNetwork:REQUEST_GETMORE andSortStatus:sortStatus];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView == self.mainTableView){
        if(isShowBanderTView){              //如果当前显示brandView，在刷新追加前先隐藏
            [self hideBanderView];
        }
        
        if(scrollView.contentOffset.y - scrollHeight > 200){
            [self HideHeadView];
        }else if(scrollHeight - scrollView.contentOffset.y > 0){
            [self ShowHeadView];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [searchbar resignFirstResponder];
    
    if(scrollView == self.mainTableView){
        scrollHeight = scrollView.contentOffset.y;
    }
}

- (void)HideHeadView
{
    [UIView animateWithDuration:0.3 animations:^{
        [segmentBgView setFrame:CGRectMake(0, [GlobalMethod AdapterIOS6_7ByIOS6Float:0 - StatusBar_Height - segment_height], Main_Size.width, segment_height)];
        [self setNavBarHiddenWithAnimation:NO];
        [self.mainTableView setFrame:CGRectMake(0, segmentBgView.bottom, Main_Size.width, [GlobalMethod AdapterIOS6_7ByIOS6Float:Main_Size.height - StatusBar_Height])];
    }];
}

- (void)ShowHeadView
{
    [UIView animateWithDuration:0.3 animations:^{
        [segmentBgView setFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(0, Navbar_Height, Main_Size.width, segment_height)]];
        [self setNavBarShowWithAnimation:NO];
    } completion:^(BOOL finished) {
        if(finished){
        [self.mainTableView setFrame:CGRectMake(0, segmentBgView.bottom, Main_Size.width, Main_Size.height - Navbar_Height - segment_height - StatusBar_Height)];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
