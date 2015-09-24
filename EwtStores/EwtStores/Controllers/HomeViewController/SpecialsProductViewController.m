//
//  SpecialsProductViewController.m
//  Shop
//
//  Created by Harry on 13-12-31.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "SpecialsProductViewController.h"
#import "ProductSpecialListCell.h"
#import "ProductDetailViewController.h"

#import "HTTPRequest.h"
#import "JSONKit.h"
#import "ProductObj.h"

//headerView隐藏
//static const float headView_height = 50.0f;
static const float headView_height = 0.0f;

@interface SpecialsProductViewController ()<ProductSpecialListCellDelegate>
{
    UIView          *headView;
    
    NSMutableArray  *specialsProArr;
    
    CGFloat         scrollHeight;
    
    NSInteger       currentPage;
    
    NSString        *product_api;       //热卖还是特价商品 api
    NSString        *title;
}

@end

@implementation SpecialsProductViewController

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
    
    switch (self.product_attribute) {
        case PRODUCT_SPECIAL:
        {
            product_api = HOME_SPECIAL_REQUEST;
            title = @"特价商品";
        }
            break;
            
        case PRODUCT_HOT:
        {
            product_api = HOME_HOT_REQUEST;
            title = @"热卖商品";
        }
            break;
            
        case PRODUCT_NEW:
        {
            product_api = HOME_NEW_REQUEST;
            title = @"新品上架";
        }
            break;
            
        case PRODUCT_CRAZY:
        {
            product_api = HOME_CRAZY_REQUEST;
            title = @"疯狂抢购";
        }
            break;
            
        default:
            break;
    }
    
    [self setNavBarTitle:title];
    [self hiddenRightBtn];
    
    [self loadDataSource];
    
    [self buildHeadView];
    [self resetMainTableView];
}

- (void)loadDataSource
{
    specialsProArr = [NSMutableArray arrayWithCapacity:10];
    currentPage = 1;
    
    [self getDataSourceByNetwork:REQUEST_REFRSH];
}

- (void)getDataSourceByNetwork:(REQUEST_STATUS)status
{
    if(status == REQUEST_REFRSH){
        [specialsProArr removeAllObjects];
        currentPage = 1;
        self.hasMore = YES;
    }else{
        if(self.hasMore){
            currentPage ++;
        }else{
            [self showHUDInView:self.view WithText:@"全部加载完毕" andDelay:1];
            [self finishReloadingData];
            return ;
        }
    }
    
    BLOCK_SELF(SpecialsProductViewController);
    HTTPRequest *hq = [HTTPRequest shareInstance];
    NSMutableDictionary *sDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [NSString stringWithFormat:@"%ld",(long)currentPage],@"page",
                                 @"8",@"pagesize",nil];
    [hq GETURLString:product_api userCache:NO parameters:sDic success:^(AFHTTPRequestOperation *operation, id responseObj) {
        NSDictionary *rqDic = (NSDictionary *)responseObj;
        if([rqDic[HTTP_STATE] boolValue]){
            
            NSArray *dataArr = (NSArray *)[rqDic[HTTP_DATA] objectFromJSONString];
            
            for(int i=0; i<dataArr.count; i++){
                NSDictionary *dic = (NSDictionary *)dataArr[i];
                
                ProductObj *obj = [ProductObj shareInstance];
                [obj setProductId:dic[@"ProductId"]];
                [obj setEndTime:[GlobalMethod getJsonDateString:dic[@"EndTime"]]];
                [obj setImgUrl:[NSURL URLWithString:dic[@"Image"]]];
                [obj setName:dic[@"Name"]];
                [obj setOldPrice:dic[@"MarketPrice"]];
                [obj setSalePrice:dic[@"Price"]];
                
                [specialsProArr addObject:obj];
            }
            
            [self.mainTableView reloadData];
            [self finishReloadingData];
            
        }else{
            NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
            [self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
            [self finishReloadingData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@ , %@",operation,error);
        [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
        [self finishReloadingData];
    }];
}

- (void)buildHeadView
{
    headView = [[UIView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(0, Navbar_Height, Main_Size.width, headView_height)]];
    [headView setBackgroundColor:RGBS(238)];
    
    //headerView隐藏
    //[self.view addSubview:headView];
    
    UIImageView *alarmView = [[UIImageView alloc] initWithFrame:CGRectMake(115, 15, 24, 24)];
    [alarmView setImage:[UIImage imageNamed:@"tags"]];
    [headView addSubview:alarmView];
    
    UILabel *lb = [GlobalMethod BuildLableWithFrame:CGRectMake(alarmView.right + 8, 18, 120, 16)
                                           withFont:[UIFont boldSystemFontOfSize:15]
                                           withText:title];
    [lb setTextColor:RGBS(51)];
    [headView addSubview:lb];
}

- (void)resetMainTableView
{
    [self.mainTableView setFrame:CGRectMake(0, headView.bottom, Main_Size.width, Main_Size.height - Navbar_Height - headView_height - StatusBar_Height)];
    [self.mainTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self finishReloadingData];
}


#pragma mark Action
#pragma mark ViewAction
- (void)leftBtnAction:(UIButton *)btn{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark Delegate
#pragma mark UITableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(specialsProArr.count%2 == 0){
        return specialsProArr.count/2;
    }else{
        return specialsProArr.count/2 + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(specialsProArr.count == 0){
        return [[UITableViewCell alloc] init];
    }
    
    static NSString *indifiter = @"rush_product_cell";
    ProductSpecialListCell *cell = [tableView dequeueReusableCellWithIdentifier:indifiter];
    if(!cell){
        cell = [[ProductSpecialListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indifiter];
        [cell set_delegate:self];
    }
    
    if(specialsProArr.count%2 == 0){
        [cell reuserTableViewLeftCell:specialsProArr[indexPath.row*2]
                              AtIndex:indexPath.row*2
                         AndRightCell:specialsProArr[indexPath.row*2 + 1]
                              AtIndex:indexPath.row*2 + 1];
    }else{
        if(indexPath.row < specialsProArr.count/2){
            [cell reuserTableViewLeftCell:specialsProArr[indexPath.row*2]
                                  AtIndex:indexPath.row*2
                             AndRightCell:specialsProArr[indexPath.row*2 + 1]
                                  AtIndex:indexPath.row*2 + 1];
        }else
        {
            [cell reuserTableViewLeftCell:specialsProArr[indexPath.row*2] AtIndex:indexPath.row*2];
        }
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 220;
}


#pragma mark ProductSpecialListCellDelegate
- (void)clickToRushProductDetail:(NSInteger)index
{
    DLog(@"查看下标为 %d 商品详情",index);
    
    ProductDetailViewController *proDVC = [ProductDetailViewController shareInstance];
    [proDVC setProductId:[(ProductObj *)specialsProArr[index] productId]];
    [self.navigationController pushViewController:proDVC animated:YES];
}

#pragma mark EgoTableView Method
- (void)refreshView
{
    [self getDataSourceByNetwork:REQUEST_REFRSH];
}

- (void)getNextPageView
{
    [self getDataSourceByNetwork:REQUEST_GETMORE];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView.contentOffset.y - scrollHeight > 200){
        [self HideHeadView];
    }else if(scrollHeight - scrollView.contentOffset.y > 0){
        [self ShowHeadView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    scrollHeight = scrollView.contentOffset.y;
}

- (void)HideHeadView
{
    [UIView animateWithDuration:0.5 animations:^{
        [headView setFrame:CGRectMake(0, [GlobalMethod AdapterIOS6_7ByIOS6Float:0 - StatusBar_Height - headView_height], Main_Size.width, headView_height)];
        [self setNavBarHiddenWithAnimation:NO];
        [self.mainTableView setFrame:CGRectMake(0, headView.bottom, Main_Size.width, [GlobalMethod AdapterIOS6_7ByIOS6Float:Main_Size.height - StatusBar_Height])];
    }];
}

- (void)ShowHeadView
{
    [UIView animateWithDuration:0.5 animations:^{
        [headView setFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(0, Navbar_Height, Main_Size.width, headView_height)]];
        [self setNavBarShowWithAnimation:NO];
    }completion:^(BOOL finished) {
        if(finished){
            [self.mainTableView setFrame:CGRectMake(0, headView.bottom, Main_Size.width, Main_Size.height - Navbar_Height - headView_height - StatusBar_Height)];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
