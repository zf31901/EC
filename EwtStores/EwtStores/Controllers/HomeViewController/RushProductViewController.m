//
//  RushProductViewController.m
//  Shop
//
//  Created by Harry on 13-12-30.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "RushProductViewController.h"
#import "ProductRushListCell.h"
#import "ProductObj.h"
#import "ProductDetailViewController.h"

#import "HTTPRequest.h"
#import "JSONKit.h"

//headerView隐藏
//static const float headView_height = 50.0f;
static const float headView_height = 0.0f;

@interface RushProductViewController () <ProductRushListCellDelegate>
{
    UIView          *headView;
    NSMutableArray  *rushProArr;
    
    CGFloat         scrollHeight;   //纪录scroll滑动的距离，向上超过了200px/s navBar隐藏
    
    NSInteger       currentPage;    //第几页数据
}

@end

@implementation RushProductViewController

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
    
    [self setNavBarTitle:@"限时抢购"];
    [self hiddenRightBtn];

    [self loadDataSource];
    
    [self buildHeadView];
    [self resetMainTableView];
}

- (void)loadDataSource
{
    rushProArr      = [NSMutableArray arrayWithCapacity:8];
    scrollHeight    = 0;
    currentPage     = 1;
    
    [self getDataSourceByNetwork:REQUEST_REFRSH];
}

- (void)getDataSourceByNetwork:(REQUEST_STATUS)status
{
    if(status == REQUEST_REFRSH){
        [rushProArr removeAllObjects];
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
    
    BLOCK_SELF(RushProductViewController);
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)currentPage],@"page",@"8",@"pagesize",nil];
    HTTPRequest *hq = [HTTPRequest shareInstance];
    [hq GETURLString:XIANSHIQIANGGOU_REQUEST userCache:NO parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObj) {
        NSDictionary *rqDic = (NSDictionary *)responseObj;
        if([rqDic[HTTP_STATE] boolValue]){
            
            NSArray *dataArr = (NSArray *)[rqDic[HTTP_DATA] objectFromJSONString];
            
            if(dataArr.count < 8){
                self.hasMore = NO;
            }
            
            for(int i=0; i<dataArr.count; i++){
                NSDictionary *dic = (NSDictionary *)dataArr[i];
                
                ProductObj *obj = [ProductObj shareInstance];
                [obj setName:dic[@"Name"]];
                [obj setProductId:dic[@"ProductId"]];
                [obj setImgUrl:[NSURL URLWithString:dic[@"Image"]]];
                [obj setOldPrice:dic[@"MarketPrice"]];
                [obj setSalePrice:dic[@"Price"]];
                [obj setBeginTime:[GlobalMethod getJsonDateString:dic[@"ServerTime"]]];
                [obj setEndTime:[GlobalMethod getJsonDateString:dic[@"EndTime"]]];
                
                [rushProArr addObject:obj];
            }
            
            if(rushProArr.count % 2 == 1){  //当收到的数据个数为奇数时，删去最后一个
                [rushProArr removeLastObject];
            }
            
            [self.mainTableView reloadData];
            [self finishReloadingData];
            
        }else{
            NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
            [self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@ , %@",operation,error);
        [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
    }];
}

- (void)buildHeadView
{
    headView = [[UIView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(0, Navbar_Height, Main_Size.width, headView_height)]];
    [headView setBackgroundColor:RGBS(238)];
    
    //headerView隐藏
    //[self.view addSubview:headView];
    
    UIImageView *alarmView = [[UIImageView alloc] initWithFrame:CGRectMake(110, 15, 24, 24)];
    [alarmView setImage:[UIImage imageNamed:@"alarm"]];
    [headView addSubview:alarmView];
    
    UILabel *lb = [GlobalMethod BuildLableWithFrame:CGRectMake(alarmView.right + 8, 18, 120, 16)
                                           withFont:[UIFont systemFontOfSize:15]
                                           withText:@"限时抢购"];
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
    if(rushProArr.count%2 == 0){
        return rushProArr.count/2;
    }else{
        return rushProArr.count/2 + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(rushProArr.count == 0){
        return [[UITableViewCell alloc] init];
    }
    
    static NSString *indifiter = @"rush_product_cell";
    ProductRushListCell *cell = [tableView dequeueReusableCellWithIdentifier:indifiter];
    if(!cell){
        cell = [[ProductRushListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indifiter];
        [cell set_delegate:self];
    }
    
    if(rushProArr.count%2 == 0){
        [cell reuserTableViewLeftCell:rushProArr[indexPath.row*2]
                              AtIndex:indexPath.row*2
                         AndRightCell:rushProArr[indexPath.row*2 + 1]
                              AtIndex:indexPath.row*2 + 1
                               AtType:RUSH_PRODUCT];
    }else{
        if(indexPath.row < rushProArr.count/2){
            [cell reuserTableViewLeftCell:rushProArr[indexPath.row*2]
                                  AtIndex:indexPath.row*2
                             AndRightCell:rushProArr[indexPath.row*2 + 1]
                                  AtIndex:indexPath.row*2 + 1
                                   AtType:RUSH_PRODUCT];
        }else
        {
            [cell reuserTableViewLeftCell:rushProArr[indexPath.row*2] AtIndex:indexPath.row*2 AtType:RUSH_PRODUCT];
        }
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 260.0f;
}


#pragma mark ProductRushCellDelegate
- (void)clickToRushProductDetail:(NSInteger)index
{
    DLog(@"查看下标为 %d 商品详情",index);

    ProductDetailViewController *proDVC = [ProductDetailViewController shareInstance];
    [proDVC setProductId:[(ProductObj *)rushProArr[index] productId]];
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
        [headView setFrame:CGRectMake(0, [GlobalMethod AdapterIOS6_7ByIOS6Float:0 - headView_height - StatusBar_Height], Main_Size.width, headView_height)];
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
