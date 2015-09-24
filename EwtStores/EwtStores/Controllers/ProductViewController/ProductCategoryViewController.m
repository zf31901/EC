//
//  ProductCategoryViewController.m
//  Shop
//
//  Created by Harry on 13-12-20.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "ProductCategoryViewController.h"
#import "ProductSortViewController.h"

#import "HTTPRequest.h"
#import "JSONKit.h"
#import "ProductCategory.h"
#import "RADataObject.h"

@interface ProductCategoryViewController ()
{
    RADataObject *selectObj;
}

@end

@implementation ProductCategoryViewController

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
    
    [self setNavBarTitle:self.categoryName];
    [self hiddenRightBtn];
    
    [self buildProductListView];
    
    [self showHUDInView:self.view WithText:NETWORKLOADING];
    [self loadDataSource];
    [MobClick event:EJLM];
}

- (void)loadDataSource
{
    proCateArr = [NSMutableArray arrayWithCapacity:10];
    static int i=0;
    i++;
    NSLog(@"<=== %d ===>",i);
    
    BLOCK_SELF(ProductCategoryViewController);
    HTTPRequest *hq = [HTTPRequest shareInstance];
    NSDictionary *dic = [NSDictionary dictionaryWithObject:self.cpId?self.cpId:@"" forKey:@"catecode"];
    [hq GETURLString:FIRST_PRODUCT_CATEGORY userCache:NO parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObj) {
        NSDictionary *rqDic = (NSDictionary *)responseObj;
        if([rqDic[HTTP_STATE] boolValue]){
            
            NSArray *dataArr = (NSArray *)[rqDic[HTTP_DATA] objectFromJSONString];
            if (dataArr.count == 0 || dataArr == nil) {
                [self hideHUDInView:block_self.view];
            }
            for(int i=0; i<dataArr.count; i++){
                NSDictionary *parentDic = dataArr[i];
                
                NSDictionary *dic = [NSDictionary dictionaryWithObject:parentDic[@"CId"]?parentDic[@"CId"]:@"" forKey:@"catecode"];
                HTTPRequest *hq = [HTTPRequest shareInstance];
                [hq GETURLString:FIRST_PRODUCT_CATEGORY userCache:NO parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObj) {
                    NSDictionary *rqDic = (NSDictionary *)responseObj;
                    if([rqDic[HTTP_STATE] boolValue]){
                        
                        NSArray *sonDataArr = (NSArray *)[rqDic[HTTP_DATA] objectFromJSONString];
                        NSMutableArray *sonNameArr = [NSMutableArray arrayWithCapacity:10];
                        
                        for(int i=0; i<sonDataArr.count; i++){
                            NSDictionary *sonDic = sonDataArr[i];
                            
                            RADataObject *obj = [RADataObject dataObjectWithName:sonDic[@"CName"] pId:sonDic[@"CSerial"] children:nil];
                            [sonNameArr addObject:obj];
                        }
                        
                        RADataObject *proCate = [RADataObject dataObjectWithName:parentDic[@"CName"] children:sonNameArr];
                        [proCateArr addObject:proCate];
                        
                        if(proCateArr.count == dataArr.count){  //数据全部加载
                            
                            [self writeProductSortCache];
                            [proListTView reloadData];
                            [self hideHUDInView:block_self.view];
                            
                        }

                    }else{
                        NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
                        [self hideHUDInView:block_self.view];
                        [self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
                        [self readProductSortCache]; //网络失败，读取保存数据
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"%@ , %@",operation,error);
                    [self hideHUDInView:block_self.view];
                    [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];

                    [self readProductSortCache]; //网络失败，读取保存数据
                }];
            }
        }else{
            NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
            [self hideHUDInView:block_self.view];
            [self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];

            [self readProductSortCache]; //网络失败，读取保存数据
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@ , %@",operation,error);
        [self hideHUDInView:block_self.view];
        [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];

        [self readProductSortCache]; //网络失败，读取保存数据
    }];
}

- (void)writeProductSortCache
{
    BLOCK_SELF(ProductCategoryViewController);
    
    //异步保存分类数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if(![proCateArr isEqualToArray:[GlobalMethod getObjectForKey:SECONDSORTPRODUCTARR(block_self.cpId)]]){
            [GlobalMethod saveObject:proCateArr withKey:SECONDSORTPRODUCTARR(block_self.cpId)];
        }
    });
}

- (void)readProductSortCache
{
    proCateArr = [NSMutableArray arrayWithCapacity:10];
    proCateArr = [GlobalMethod getObjectForKey:SECONDSORTPRODUCTARR(self.cpId)];
    [proListTView reloadData];
}

- (void)buildProductListView
{
    proListTView = [[RATreeView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(0, Navbar_Height, Main_Size.width, Main_Size.height - StatusBar_Height - Navbar_Height)]];
    proListTView.delegate = self;
    proListTView.dataSource = self;
    proListTView.separatorStyle = RATreeViewCellSeparatorStyleNone;
    [proListTView reloadData];
    [self.view addSubview:proListTView];
}

#pragma mark TreeView Delegate methods
- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    return 48;
}

- (NSInteger)treeView:(RATreeView *)treeView indentationLevelForRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    return 3 * treeNodeInfo.treeDepthLevel;
}

- (void)treeView:(RATreeView *)treeView willDisplayCell:(UITableViewCell *)cell forItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    if (treeNodeInfo.treeDepthLevel == 0) {
        cell.backgroundColor = [UIColor whiteColor];
    } else if (treeNodeInfo.treeDepthLevel == 1) {
        cell.backgroundColor = RGBS(238);
    }
}

- (void)treeView:(RATreeView *)treeView didSelectRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    selectObj = (RADataObject *)item;
    
    if(selectObj.children==nil){
        DLog(@"进入物品详情");
        
        ProductSortViewController *proSVC = [ProductSortViewController shareInstance];
        [proSVC setCpId:selectObj.pId];
        [self.navigationController pushViewController:proSVC animated:YES];
        
        return ;
    }
    
    UITableViewCell *cell = [treeView cellForItem:item];
    UIImageView *statusIV = (UIImageView *)[cell.contentView viewWithTag:10001];
    if ([statusIV.image isEqual:[UIImage imageNamed:@"accsessory-arrow-down"]]) {
        [statusIV setImage:[UIImage imageNamed:@"accsessory-arrow-up"]];
    }else{
        [statusIV setImage:[UIImage imageNamed:@"accsessory-arrow-down"]];
    }
//    if (treeNodeInfo.expanded) {
//        [statusIV setImage:[UIImage imageNamed:@"accsessory-arrow-down"]];
//    }else{
//        [statusIV setImage:[UIImage imageNamed:@"accsessory-arrow-up"]];
//    }
    //三级类目 纪录
    [MobClick event:SJLM];
}

- (BOOL)treeView:(RATreeView *)treeView canEditRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    return NO;
}

#pragma mark TreeView Data Source
- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    RADataObject *data = item;
    
    //二级分类title
    if(data.children != 0){
        static NSString *cellString = @"product_second_cate_cell";
        UITableViewCell *cell = [treeView dequeueReusableCellWithIdentifier:cellString];
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellString];
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 1, Main_Size.width, 0.5)];
            [line setBackgroundColor:RGBS(201)];
            [cell.contentView addSubview:line];
            
            UIImageView *statusIV = [[UIImageView alloc] initWithFrame:CGRectMake(290, 20, 10, 8)];
            [statusIV setImage:[UIImage imageNamed:@"accsessory-arrow-down"]];
            [statusIV setTag:10001];
            [cell.contentView addSubview:statusIV];
        }
        cell.textLabel.text = data.name;
        [cell.textLabel setFont:[UIFont systemFontOfSize:16]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        return cell;
    }
    
    //三级分类列表
    static NSString *cellString = @"product_firth_cate_cell";
    UITableViewCell *cell = [treeView dequeueReusableCellWithIdentifier:cellString];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellString];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 1, Main_Size.width, 0.5)];
        [line setBackgroundColor:RGBS(201)];
        [cell.contentView addSubview:line];
    }
    cell.textLabel.text = ((RADataObject *)item).name;
    [cell.textLabel setFont:[UIFont systemFontOfSize:16]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    return cell;
}

- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item
{
    if (item == nil) {
        return [proCateArr count];
    }
    
    RADataObject *data = item;
    return [data.children count];
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item
{
    RADataObject *data = item;
    if (item == nil) {
        return [proCateArr objectAtIndex:index];
    }
    
    return [data.children objectAtIndex:index];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0001;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
