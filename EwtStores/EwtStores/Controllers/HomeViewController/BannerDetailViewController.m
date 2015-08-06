//
//  BannerDetailViewController.m
//  Shop
//
//  Created by Harry on 14-1-2.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "BannerDetailViewController.h"
#import "ProductRushListCell.h"
#import "EGOImageView.h"
#import "ProductDetailViewController.h"
#import "ProductObj.h"


static const float headView_height = 105.0f;

@interface BannerDetailViewController ()<ProductRushListCellDelegate>
{
    UIView          *headView;
    EGOImageView    *bannerImgView;
    
    NSMutableArray  *rushProArr;
    
    CGFloat         scrollHeight;
}

@end

@implementation BannerDetailViewController


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
    rushProArr = [NSMutableArray arrayWithCapacity:10];
    for (int i=0; i<21; i++) {
        ProductObj *obj = [ProductObj shareInstance];
        [obj setImgUrl:nil];
        [obj setName:[NSString stringWithFormat:@"新款仿兔毛皮草大毛领外套_%d",i+1]];
        [obj setOldPrice:[NSString stringWithFormat:@"%d23.32",i+1]];
        [obj setSalePrice:@"158"];
        
        [rushProArr addObject:obj];
    }
    
    scrollHeight = 0;
}



- (void)buildHeadView
{
    headView = [[UIView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(0, Navbar_Height, Main_Size.width, headView_height)]];
    [headView setBackgroundColor:RGBS(238)];
    [self.view addSubview:headView];
    
    bannerImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(0, 0, Main_Size.width, headView_height)];
    [bannerImgView setPlaceholderImage:[UIImage imageNamed:@"default_img_640x210"]];
    [bannerImgView setImageURL:nil];
    [headView addSubview:bannerImgView];
}

- (void)resetMainTableView
{
    [self.mainTableView setFrame:CGRectMake(0, headView.bottom, Main_Size.width, Main_Size.height - Navbar_Height - headView_height - StatusBar_Height)];
    [self.mainTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self finishReloadingData];
}


#pragma mark Action
#pragma mark ViewAction


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
                               AtType:BANNER_PRODUCT];
    }else{
        if(indexPath.row < rushProArr.count/2){
            [cell reuserTableViewLeftCell:rushProArr[indexPath.row*2]
                                  AtIndex:indexPath.row*2
                             AndRightCell:rushProArr[indexPath.row*2 + 1]
                                  AtIndex:indexPath.row*2 + 1
                                   AtType:BANNER_PRODUCT];
        }else
        {
            [cell reuserTableViewLeftCell:rushProArr[indexPath.row*2] AtIndex:indexPath.row*2 AtType:BANNER_PRODUCT];
        }
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 240.0f;
}


#pragma mark ProductRushCellDelegate
- (void)clickToRushProductDetail:(NSInteger)index
{
    DLog(@"查看下标为 %d 商品详情",index);
    
    [self.navigationController pushViewController:[ProductDetailViewController shareInstance] animated:YES];
}

#pragma mark EgoTableView Method
- (void)refreshView
{
    [self finishReloadingData];
}

- (void)getNextPageView
{
    [self finishReloadingData];
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
    } completion:^(BOOL finished) {
        if(finished){
            [self.mainTableView setFrame:CGRectMake(0, headView.bottom, Main_Size.width, [GlobalMethod AdapterIOS6_7ByIOS6Float:Main_Size.height - StatusBar_Height])];
        }
    }];
}

- (void)ShowHeadView
{

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
