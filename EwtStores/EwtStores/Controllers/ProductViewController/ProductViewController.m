//
//  ProductViewController.m
//  EwtStores
//
//  Created by Harry on 13-11-30.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "ProductViewController.h"
#import "ProductCategoryViewController.h"
#import "ProductSortViewController.h"

#import "HTTPRequest.h"
#import "JSONKit.h"
#import "EGOImageView.h"

#import "ProductCategory.h"
#import "UIImageView+WebCache.h"
#import "ProductTableViewCell.h"

@interface ProductViewController ()

@end

@implementation ProductViewController

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
    
    [self buildProductListView];
    
    [self showHUDInView:self.view WithText:NETWORKLOADING];
    [self loadDataSource];
    [self buildSearchBarView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MobClick event:YJLM];
    
//    //如果没有分类数据，先判断是否有缓存数据，如果也没有，那么每次进入该界面请求服务器
//    if(productNameArr.count == 0){
//        [self loadDataSource];
//    }
    
    [searchDC setActive:NO];
    
    NSArray *VCArr = MYAPPDELEGATE.tabBarC.viewControllers;
    if(VCArr.count >= 3){
        UINavigationController *cartVC = VCArr[2];
        NSString *cart_product_num = [GlobalMethod getObjectForKey:CART_PRODUCT_COUNT];
        if([cart_product_num integerValue] == 0){
            cartVC.tabBarItem.badgeValue = nil;
        }else{
            cartVC.tabBarItem.badgeValue = cart_product_num;
        }
    }
    if (MYAPPDELEGATE.isPush) {
        MYAPPDELEGATE.isPush = NO;
        [MYAPPDELEGATE.tabBarC setSelectedIndex:0];
    }
}

- (void)loadDataSource
{
    searchArr       = [NSMutableArray arrayWithCapacity:20];
    productNameArr  = [NSMutableArray arrayWithCapacity:11];
    
    BLOCK_SELF(ProductViewController);
    HTTPRequest *hq = [HTTPRequest shareInstance];
    NSDictionary *dic = [NSDictionary dictionaryWithObject:@"00" forKey:@"catecode"];
    [hq GETURLString:FIRST_PRODUCT_CATEGORY parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObj) {
        NSDictionary *rqDic = (NSDictionary *)responseObj;
        if([rqDic[HTTP_STATE] boolValue]){
            
            NSArray *dataArr = (NSArray *)[rqDic[HTTP_DATA] objectFromJSONString];
            for(int i=0; i<dataArr.count; i++){
                NSDictionary *dic = dataArr[i];
                
                ProductCategory *cate = [ProductCategory shareInstance];
                [cate setCId:dic[@"CId"]];
                [cate setCPId:dic[@"CPId"]];
                [cate setCategoryImgUrl:[NSURL URLWithString:dic[@"CImage"]]];
                [cate setCategoryName:dic[@"CName"]];
                
                [productNameArr addObject:cate];
                [self hideHUDInView:block_self.view];
            }
        }else{
            NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
            [self hideHUDInView:block_self.view];
            [self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
        }
        
        [self refreshTableView];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@ , %@",operation,error);
        [self refreshTableView];
        [self hideHUDInView:block_self.view];
        [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
    }];
}

//网络连接成功，则保持最近数据，失败则读取上次保存数据
- (void)refreshTableView
{
    if(productNameArr.count == 0){
        productNameArr = [GlobalMethod getObjectForKey:FIRSTSORTPRODUCTARR];
    }else{
        if( ![productNameArr isEqualToArray:[GlobalMethod getObjectForKey:FIRSTSORTPRODUCTARR]] ){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                [GlobalMethod saveObject:productNameArr withKey:FIRSTSORTPRODUCTARR];
            });
        }
    }
    
    [proTableView reloadData];
}

#pragma mark ViewBuild
- (void)buildSearchBarView
{
    UIView *searchBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Main_Size.width, [GlobalMethod AdapterIOS6_7ByIOS6Float:Navbar_Height])];
    [searchBg setBackgroundColor:NavBarColor];
    [self.view addSubview:searchBg];
    
    UISearchBar *searchbar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, [GlobalMethod AdapterIOS6_7ByIOS6Float:0], Main_Size.width,Navbar_Height)];
    [searchbar setDelegate:self];
    [searchbar setPlaceholder:@"请输入关键字"];
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
    
    searchDC = [[UISearchDisplayController alloc] initWithSearchBar:searchbar contentsController:self];
    [searchDC setDelegate:self];
    [searchDC setSearchResultsDataSource:self];
    [searchDC setSearchResultsDelegate:self];
}

- (void)buildProductListView
{
    proTableView = [[UITableView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(0, Navbar_Height, Main_Size.width, Main_Size.height - StatusBar_Height - Navbar_Height - Tabbar_Height)] style:UITableViewStylePlain];
    [proTableView setBackgroundView:nil];
    [proTableView setBackgroundColor:[UIColor clearColor]];
    [proTableView setDelegate:self];
    [proTableView setDataSource:self];
    [self.view addSubview:proTableView];
}

#pragma mark -Delegate
#pragma mark UITableView Methods  搜索结果里的TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == proTableView){
        return productNameArr.count;
    }
    
    return searchArr.count + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == proTableView){
        static NSString *proCell = @"productVC_pro_cell";
        ProductTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:proCell];
        
        if(cell == nil){
            cell = [[ProductTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:proCell];
            
            //            EGOImageView *imgView = [[EGOImageView alloc] initWithFrame:CGRectMake(20, 17, 30, 30)];
            //            [imgView setPlaceholderImage:[UIImage imageNamed:@"default_img_60"]];
            //            [imgView setTag:10001];
            //            [cell.contentView addSubview:imgView];
        }
        
        
        ProductCategory *cate = productNameArr[indexPath.row];
        //        EGOImageView *imgView1 = (EGOImageView *)[cell.contentView viewWithTag:10001];
        [cell.imgView setImageWithURL:cate.categoryImgUrl placeholderImage:[UIImage imageNamed:@"default_img_60"]];
        //[imgView1 setImageURL:cate.categoryImgUrl];
        //        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell.textLabel setText:[NSString stringWithFormat:@"           %@",cate.categoryName]];
        //        [cell.textLabel setFont:[UIFont systemFontOfSize:16]];
        
        return cell;
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"search_cell"];
    
    if(indexPath.row == 0){  //历史纪录
        [cell.textLabel setText:@"搜索历史"];
        [cell.textLabel setTextColor:RGBS(102)];
    }else if(indexPath.row == (searchArr.count + 1)){      //清空历史
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
        [cell.textLabel setText:[NSString stringWithFormat:@"\t%@",searchArr[indexPath.row - 1]]];
        [cell.textLabel setTextColor:RGBS(51)];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64.0f;
}

- (void)clearHistroyArr
{
    [GlobalMethod saveObject:nil withKey:HISTORYARR];
    [searchArr removeAllObjects];
    
    [searchDC.searchResultsTableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == proTableView){
        ProductCategoryViewController *proCateVC = [ProductCategoryViewController shareInstance];
        [proCateVC setHidesBottomBarWhenPushed:YES];
        ProductCategory *cate = productNameArr[indexPath.row];
        [proCateVC setCpId:cate.cId];
        [proCateVC setCategoryName:cate.categoryName];
        [self.navigationController pushViewController:proCateVC animated:YES];
        
        return ;
    }
    
    if(indexPath.row == 0 || indexPath.row == (searchArr.count + 1)){
        return ;
    }
    
    //选择历史纪录，先将其删除，然后加入到数组的第一个元素
    NSString *searchKey = searchArr[indexPath.row - 1];
    NSMutableArray *arr = [NSMutableArray arrayWithArray:searchArr];
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
    searchDC.searchBar.tintColor = [UIColor whiteColor];
    
    //点击搜索，读取历史搜索纪录
    [searchArr removeAllObjects];
    if([GlobalMethod getObjectForKey:HISTORYARR] != nil){
        NSArray *arr = [GlobalMethod getObjectForKey:HISTORYARR];
        [searchArr setArray:arr];
    }
}

- (void) searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    [searchDC.searchResultsTableView reloadData];
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    [self setTabBarShowWithAnimation:NO];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self setTabBarHiddenWithAnimation:YES];
    if (searchArr.count > 0) {
        searchBar.text = searchArr[0];  //不保留最后一次搜索
    }
    
    [MobClick event:SS];
    [MobClick event:LSJL];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
