//
//  PromotionActivityViewController.m
//  Shop
//
//  Created by Harry on 13-12-30.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

@class EGOImageView;
@class ActivityObj;
@interface ActivityListCell : UITableViewCell

@property (nonatomic, strong) EGOImageView  *activityImgView;
@property (nonatomic, strong) UILabel       *activityNameLb;

- (void)reuserTableViewCell:(ActivityObj *)obj;

@end

#import "EGOImageView.h"
#import "ActivityObj.h"
#import "UIImageView+WebCache.h"

#define BannerView_Height 150

@implementation ActivityListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        
        [self setBackgroundColor:RGBS(238)];
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 8, Main_Size.width, BannerView_Height + 38)];
        [bgView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:bgView];
        
        self.activityImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(8, 8, 304, BannerView_Height)];
        [self.activityImgView setPlaceholderImage:[UIImage imageNamed:@"default_img_608x200"]];
        [bgView addSubview:self.activityImgView];
        
        self.activityNameLb = [GlobalMethod BuildLableWithFrame:CGRectMake(8, self.activityImgView.bottom + 8, 304, 13)
                                                       withFont:[UIFont systemFontOfSize:12]
                                                       withText:nil];
        [self.activityNameLb setTextColor:RGBS(51)];
        [self.activityNameLb setNumberOfLines:1];
        [bgView addSubview:self.activityNameLb];
    }
    return self;
}

- (void)reuserTableViewCell:(ActivityObj *)obj
{
    //[self.activityImgView setImageURL:obj.activityImgUrl];
    [self.activityImgView setImageWithURL:obj.activityImgUrl];
    [self.activityNameLb setText:obj.activityName];
}

@end



#import "PromotionActivityViewController.h"
#import "ActivityDetailViewController.h"
#import "ActivityObj.h"


@interface PromotionActivityViewController ()
{
    CGFloat             scrollHeight;
    
    ActivityDetailViewController    *actDetailVC;
}

@end

@implementation PromotionActivityViewController

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
    
    [self setNavBarTitle:@"促销活动专场"];
    [self hiddenRightBtn];
    
    [self resetMainTableView];
    
    actDetailVC = [ActivityDetailViewController shareInstance];
}

- (void)resetMainTableView
{
    [self.mainTableView setFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(0, Navbar_Height, Main_Size.width, Main_Size.height - StatusBar_Height - Navbar_Height)]];
    [self.mainTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    [self finishReloadingData];
}


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
    return self.activityArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indifiter = @"activity_list_cell";
    ActivityListCell *cell = [tableView dequeueReusableCellWithIdentifier:indifiter];
    if(!cell){
        cell = [[ActivityListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indifiter];
    }

    [cell reuserTableViewCell:self.activityArr[indexPath.row]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return BannerView_Height + 48;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ActivityObj *currentObj = (ActivityObj *)self.activityArr[indexPath.row];
    [actDetailVC setActivtyDetailUrl:currentObj.activityLinkUrl];
    [actDetailVC setActTitle:currentObj.activityName];
    [self.navigationController pushViewController:actDetailVC animated:YES];
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
        [self setNavBarHiddenWithAnimation:NO];
        [self.mainTableView setFrame:CGRectMake(0, 0, Main_Size.width, [GlobalMethod AdapterIOS6_7ByIOS6Float:Main_Size.height - StatusBar_Height])];
    }];
}

- (void)ShowHeadView
{
    [UIView animateWithDuration:0.5 animations:^{
        [self setNavBarShowWithAnimation:NO];
        [self.mainTableView setFrame:CGRectMake(0, [GlobalMethod AdapterIOS6_7ByIOS6Float:Navbar_Height], Main_Size.width, Main_Size.height - Navbar_Height - StatusBar_Height)];
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end





