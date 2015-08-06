//
//  EvaluateViewController.m
//  Shop
//
//  Created by Harry on 13-12-27.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "EvaluateViewController.h"

#import "XYPieChart.h"
#import <QuartzCore/QuartzCore.h>
#import "JSONKit.h"
#import "HTTPRequest.h"

#import "ProductObj.h"
#import "EvaluateObj.h"
#import "EvaluateCell.h"

@interface EvaluateViewController ()<XYPieChartDataSource,XYPieChartDelegate>
{
    NSInteger           niceCount;
    NSInteger           middleCount;
    NSInteger           badCount;
    CGFloat             totalCount;
    
    UILabel             *niceEvaluateLb;        //好评lb
    UILabel             *niceRateLb;            //好评率lb
    UILabel             *middleRateLb;          //中评率lb
    UILabel             *badRateLb;             //差评率lb
    
    UILabel             *niceCountLb;           //好评个数
    UILabel             *middleCountLb;         //中评个数
    UILabel             *badCountLb;            //差评个数
    
    NSMutableArray      *evaluateArr;           //评论数组
    
    NSInteger           currentPage;            //当前页数
}

@end

@implementation EvaluateViewController

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
    
    [self hiddenRightBtn];
    [self setNavBarTitle:@"评价"];
    
    currentPage = 1;
    evaluateArr = [NSMutableArray arrayWithCapacity:10];
    niceCount = [self.productObj.goodCommentNum integerValue];
    middleCount = [self.productObj.midCommentNum integerValue];
    badCount = [self.productObj.lowCommentNum integerValue];
    totalCount = niceCount + middleCount + badCount;
    if(totalCount == 0){
        niceCount = 1;
        totalCount = 1;
    }
    
    [self showHUDInView:self.view WithText:NETWORKLOADING];
    [self getDataSourceByNetwork:REQUEST_REFRSH];
    [self buildTableView];
}

- (void)getDataSourceByNetwork:(REQUEST_STATUS)status
{
    if(status == REQUEST_REFRSH){
        [evaluateArr removeAllObjects];
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
    
    BLOCK_SELF(EvaluateViewController);
    HTTPRequest *hq = [HTTPRequest shareInstance];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:4];
    [dic setObject:self.productObj.productId ? self.productObj.productId : @"" forKey:@"proid"];
    [dic setObject:[NSString stringWithFormat:@"%ld",(long)currentPage] forKey:@"page"];
    [dic setObject:@"8" forKey:@"pagesize"];
    
    [hq GETURLString:PRODUCT_EVALUATE parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObj) {
        NSDictionary *rqDic = (NSDictionary *)responseObj;
        if([rqDic[HTTP_STATE] boolValue]){
            
            NSArray *dataArr = (NSArray *)[rqDic[HTTP_DATA] objectFromJSONString];
            
            if(dataArr.count < 8){
                self.hasMore = NO;
            }
            
            for(int i=0; i<dataArr.count; i++){
                NSDictionary *evaluateDic = dataArr[i];
                EvaluateObj *obj = [EvaluateObj shareInstance];
                [obj setPersonId:evaluateDic[@"PA_UserLogin"]];
                [obj setArea:evaluateDic[@"PA_UserIpPlace"]];
                [obj setTime:evaluateDic[@"PA_CreateDate"]];
                [obj setNiceEvaluate:evaluateDic[@"PA_Advantage"]];
                [obj setBadEvaluate:evaluateDic[@"PA_Shortcoming"]];
                [obj setPersonImgUrl:[NSURL URLWithString:dic[@"PA_UserImage"]]];
                [evaluateArr addObject:obj];
            }
            
            [self.mainTableView reloadData];
            [self finishReloadingData];
            
            [self.niceChart reloadData];
            [self.middleChart reloadData];
            [self.badChart reloadData];
            
            [self hideHUDInView:block_self.view];
        }else{
            NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
            [self hideHUDInView:block_self.view];
            [self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
            [self finishReloadingData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@ , %@",operation,error);
        [self hideHUDInView:block_self.view];
        [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
        [self finishReloadingData];
    }];
}

- (void)buildTableView
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Main_Size.width, 140)];
    UILabel *lb = [GlobalMethod BuildLableWithFrame:CGRectMake(8, 10, 60, 13)
                                           withFont:[UIFont systemFontOfSize:12]
                                           withText:@"好评率："];
    [lb setTextColor:RGBS(51)];
    [headerView addSubview:lb];
    
    niceEvaluateLb = [GlobalMethod BuildLableWithFrame:CGRectMake(lb.right, 10, 60, 16)
                                              withFont:[UIFont systemFontOfSize:15]
                                              withText:[NSString stringWithFormat:@"%0.1f％",niceCount/totalCount/1.0 * 100]];
    [niceEvaluateLb setTextColor:RGB(250, 51, 0)];
    [headerView addSubview:niceEvaluateLb];
    
    //好评图
    self.niceChart = [[XYPieChart alloc] initWithFrame:CGRectMake(25, niceEvaluateLb.bottom + 10, 50, 50)
                                                Center:CGPointMake(25, 25)
                                                Radius:25];
    [self.niceChart setAnimationSpeed:1];
    [self.niceChart setDelegate:self];
    [self.niceChart setDataSource:self];
    [self.niceChart.layer setCornerRadius:25];
    [self.niceChart.layer setBorderWidth:0.5];
    [self.niceChart.layer setBorderColor:RGB(204, 0, 0).CGColor];
    [self.niceChart setUserInteractionEnabled:NO];
    niceRateLb = [GlobalMethod BuildLableWithFrame:CGRectMake(5, 5, 40, 40)
                                          withFont:[UIFont boldSystemFontOfSize:12]
                                          withText:[NSString stringWithFormat:@"%0.1f％",niceCount/totalCount/1.0 * 100]];
    niceRateLb.textAlignment = NSTextAlignmentCenter;
    niceRateLb.backgroundColor = RGBS(238);
    [niceRateLb.layer setCornerRadius:20];
    [self.niceChart addSubview:niceRateLb];
    [self.niceChart reloadData];
    [headerView addSubview:self.niceChart];
    
    niceCountLb = [GlobalMethod BuildLableWithFrame:CGRectMake(10, self.niceChart.bottom + 10, 100, 13)
                                           withFont:[UIFont systemFontOfSize:12]
                                           withText:[NSString stringWithFormat:@"好评数(%ld)",(long)niceCount]];
    niceCountLb.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:niceCountLb];
    
    //中评图
    self.middleChart = [[XYPieChart alloc] initWithFrame:CGRectMake(self.niceChart.right + 60, niceEvaluateLb.bottom + 10, 50, 50)
                                                Center:CGPointMake(25, 25)
                                                Radius:25];
    [self.middleChart setAnimationSpeed:1.5];
    [self.middleChart setDelegate:self];
    [self.middleChart setDataSource:self];
    [self.middleChart.layer setCornerRadius:25];
    [self.middleChart.layer setBorderWidth:0.5];
    [self.middleChart.layer setBorderColor:RGB(250, 85, 0).CGColor];
    [self.middleChart setUserInteractionEnabled:NO];
    middleRateLb = [GlobalMethod BuildLableWithFrame:CGRectMake(5, 5, 40, 40)
                                          withFont:[UIFont boldSystemFontOfSize:12]
                                          withText:[NSString stringWithFormat:@"%0.1f％",middleCount/totalCount/1.0 * 100]];
    middleRateLb.textAlignment = NSTextAlignmentCenter;
    middleRateLb.backgroundColor = RGBS(238);
    [middleRateLb.layer setCornerRadius:20];
    [self.middleChart addSubview:middleRateLb];
    [self.middleChart reloadData];
    [headerView addSubview:self.middleChart];
    
    middleCountLb = [GlobalMethod BuildLableWithFrame:CGRectMake(110, self.middleChart.bottom + 10, 100, 13)
                                           withFont:[UIFont systemFontOfSize:12]
                                           withText:[NSString stringWithFormat:@"中评数(%ld)",(long)badCount]];
    middleCountLb.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:middleCountLb];
    
    //差评图
    self.badChart = [[XYPieChart alloc] initWithFrame:CGRectMake(self.middleChart.right + 50, niceEvaluateLb.bottom + 10, 50, 50)
                                                  Center:CGPointMake(25, 25)
                                                  Radius:25];
    [self.badChart setAnimationSpeed:2];
    [self.badChart setDelegate:self];
    [self.badChart setDataSource:self];
    [self.badChart.layer setCornerRadius:25];
    [self.badChart.layer setBorderWidth:0.5];
    [self.badChart.layer setBorderColor:RGBS(102).CGColor];
    [self.badChart setUserInteractionEnabled:NO];
    badRateLb = [GlobalMethod BuildLableWithFrame:CGRectMake(5, 5, 40, 40)
                                            withFont:[UIFont boldSystemFontOfSize:12]
                                            withText:[NSString stringWithFormat:@"%0.1f％",badCount/totalCount/1.0 * 100]];
    badRateLb.textAlignment = NSTextAlignmentCenter;
    badRateLb.backgroundColor = RGBS(238);
    [badRateLb.layer setCornerRadius:20];
    [self.badChart addSubview:badRateLb];
    [self.badChart reloadData];
    [headerView addSubview:self.badChart];
    
    badCountLb = [GlobalMethod BuildLableWithFrame:CGRectMake(210, self.badChart.bottom + 10, 100, 13)
                                             withFont:[UIFont systemFontOfSize:12]
                                             withText:[NSString stringWithFormat:@"差评数(%d)",badCount]];
    badCountLb.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:badCountLb];
    
    [headerView setFrame:CGRectMake(0, 0, Main_Size.width, badCountLb.bottom + 10)];
    
    [self.mainTableView setFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(0, Navbar_Height, Main_Size.width, Main_Size.height - StatusBar_Height - Navbar_Height)]];
    [self.mainTableView setTableHeaderView:headerView];
    [self finishReloadingData];
}

#pragma mark Delegate
#pragma mark XYPieChart Methods
- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart
{
    return 2;
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
    if(pieChart == self.niceChart){
        if(index==0){
            return niceCount/totalCount/1.0;
        }else{
            return 1 - niceCount/totalCount/1.0;
        }
    }else if (pieChart == self.middleChart){
        if(index==0){
            return middleCount/totalCount/1.0;
        }else{
            return 1 - middleCount/totalCount/1.0;
        }
    }else if (pieChart == self.badChart){
        if(index==0){
            return badCount/totalCount/1.0;
        }else{
            return 1 - badCount/totalCount/1.0;
        }
    }else{
        return 0;
    }
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
    if(pieChart == self.niceChart){
        if(index==0){
            return RGB(204, 0, 0);
        }else{
            return RGBS(238);
        }
    }else if (pieChart == self.middleChart){
        if(index==0){
            return RGB(250, 85, 0);
        }else{
            return RGBS(238);
        }
    }else if (pieChart == self.badChart){
        if(index==0){
            return RGBS(102);
        }else{
            return RGBS(238);
        }
    }else{
        return 0;
    }
}

#pragma mark UITableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return evaluateArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellString = @"evaluate_cell_identifier";
    EvaluateCell *cell = [tableView dequeueReusableCellWithIdentifier:cellString];
    if(!cell){
        cell = [[EvaluateCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellString];
    }
    
    float cellHeight = [cell reuserTableViewCell:evaluateArr[indexPath.row]];
    [cell setFrame:CGRectMake(0, 0, Main_Size.width, cellHeight)];
    [cell setBackgroundColor:[UIColor whiteColor]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001f;
}


#pragma mark RefreshOrPull
- (void)refreshView
{
    [self getDataSourceByNetwork:REQUEST_REFRSH];
}

- (void)getNextPageView
{
    [self getDataSourceByNetwork:REQUEST_GETMORE];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
