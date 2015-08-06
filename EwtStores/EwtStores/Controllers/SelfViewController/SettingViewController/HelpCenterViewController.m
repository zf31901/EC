//
//  HelpCenterViewController.m
//  Shop
//
//  Created by Harry on 14-1-7.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "HelpCenterViewController.h"
#import "HTTPRequest.h"
#import "JSONKit.h"
#import "HelpCenterDetailViewController.h"

#define ROW_TITLE       @"rowTitle"
#define ROW_LINKURL     @"rowLinkUrl"

@interface HelpCenterViewController ()
{
    HelpCenterDetailViewController *helpDetailVC;
    
    NSMutableArray  *rowTitleArr;
    NSMutableArray  *sectionTitleArr;
    
    UITableView     *tView;
}

@end

@implementation HelpCenterViewController

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
    
    [self setNavBarTitle:@"帮助中心"];
    [self hiddenRightBtn];
    
    sectionTitleArr = [NSMutableArray arrayWithCapacity:6];
    rowTitleArr     = [NSMutableArray arrayWithCapacity:6];
    
    [self showHUDInView:self.view WithText:NETWORKLOADING];
    BLOCK_SELF(HelpCenterViewController);
    HTTPRequest *hq = [HTTPRequest shareInstance];
    [hq GETURLString:HELP_CENTER parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObj) {
        NSDictionary *rqDic = (NSDictionary *)responseObj;
        
        if([rqDic[HTTP_STATE] boolValue]){
            
            NSArray *dataArr = (NSArray *)[rqDic[HTTP_DATA] objectFromJSONString];
            
            //section的个数
            for(int i=0; i<dataArr.count; i++){
                
                NSDictionary *sectionTitleDic = (NSDictionary *)dataArr[i];
                
                NSString *sectionTitle = sectionTitleDic[@"ATName"];
                [sectionTitleArr addObject:sectionTitle];
                
                NSArray *rowArr = [sectionTitleDic[@"ATArticleData"] objectFromJSONString];
                NSMutableArray *currentRowTitleArr = [NSMutableArray arrayWithCapacity:rowArr.count];
                //该section下row个数
                for(int i=0; i<rowArr.count; i++){
                    NSDictionary *rowTitleDic = (NSDictionary *)rowArr[i];
                    
                    NSDictionary *rowInfo = @{ROW_TITLE:rowTitleDic[@"ATitle"],ROW_LINKURL:rowTitleDic[@"AContentUrl"]};
                    [currentRowTitleArr addObject:rowInfo];
                }
                
                [rowTitleArr addObject:currentRowTitleArr];
            }
            
            [self refreshTableView];
            [self hideHUDInView:block_self.view];
            
        }else{
            [self refreshTableView];
            [self hideHUDInView:block_self.view];
            [self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self refreshTableView];
        [self hideHUDInView:block_self.view];
        [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
    }];
    
    tView = [[UITableView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(0, Navbar_Height, Main_Size.width, Main_Size.height - StatusBar_Height - Navbar_Height)] style:UITableViewStylePlain];
    [tView setDelegate:self];
    [tView setDataSource:self];
    [self.view addSubview:tView];
    
    helpDetailVC = [HelpCenterDetailViewController shareInstance];
}

//网络连接成功，则保持最近数据，失败则读取上次保存数据
- (void)refreshTableView
{
    if(rowTitleArr.count == 0){
        sectionTitleArr = [GlobalMethod getObjectForKey:HELPCENTER_SECTION];
        rowTitleArr = [GlobalMethod getObjectForKey:HELPCENTER_ROW];
    }else{
        if( ![rowTitleArr isEqualToArray:[GlobalMethod getObjectForKey:HELPCENTER_ROW]] ){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                [GlobalMethod saveObject:sectionTitleArr withKey:HELPCENTER_SECTION];
                [GlobalMethod saveObject:rowTitleArr withKey:HELPCENTER_ROW];
            });
        }
    }
    
    [tView reloadData];
}

#pragma mark UItableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sectionTitleArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(NSArray *)rowTitleArr[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return sectionTitleArr[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    NSDictionary *currentRowTitleArr = (NSDictionary *)[rowTitleArr[indexPath.section] objectAtIndex:indexPath.row];
    
    [cell.textLabel setText:[NSString stringWithFormat:@"\t%@",currentRowTitleArr[ROW_TITLE]]];
    [cell.textLabel setFont:[UIFont systemFontOfSize:16]];
    [cell.textLabel setTextColor:RGBS(59)];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *currentRowTitleDic = (NSDictionary *)[rowTitleArr[indexPath.section] objectAtIndex:indexPath.row];
    
    [helpDetailVC setDetailTitle:currentRowTitleDic[ROW_TITLE]];
    [helpDetailVC setDetailURL:[NSURL URLWithString:currentRowTitleDic[ROW_LINKURL]]];
    
    [self.navigationController pushViewController:helpDetailVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
