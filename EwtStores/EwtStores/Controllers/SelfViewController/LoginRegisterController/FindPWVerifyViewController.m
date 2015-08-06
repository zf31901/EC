//
//  FindPWVerifyViewController.m
//  EwtStores
//
//  Created by Harry on 13-12-3.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "FindPWVerifyViewController.h"
#import "FindPWVerifyByPhoneViewController.h"

@interface FindPWVerifyViewController ()

@end

@implementation FindPWVerifyViewController

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
    
    [self setNavBarTitle:@"验证方式"];
    [self hiddenRightBtn];
    
    [self loadBaseView];
}

#pragma mark viewBuild
- (void)loadBaseView
{
    UILabel *verifyLb = [GlobalMethod BuildLableWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(20, Navbar_Height + 20, 280, 30)] withFont:[UIFont systemFontOfSize:16] withText:@"请选择验证方式："];
    [self.view addSubview:verifyLb];
    
    UITableView *tView = [[UITableView alloc] initWithFrame:CGRectMake(0, verifyLb.frame.origin.y + verifyLb.frame.size.height + 20, Main_Size.width, 88) style:UITableViewStyleGrouped];
    [tView setDelegate:self];
    [tView setDataSource:self];
    [tView setScrollEnabled:NO];
    [self.view addSubview:tView];
}

#pragma mark UITablViewMethods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    if(indexPath.row == 0)
    {
        [cell.textLabel setText:@"手机验证"];
    }
    else
    {
        [cell.textLabel setText:@"邮箱验证"];
    }
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        DLog(@"手机验证");
        
        [self.navigationController pushViewController:[FindPWVerifyByPhoneViewController shareInstance] animated:YES];
    }
    else
    {
        DLog(@"邮箱验证");
        
        [self.navigationController pushViewController:[FindPWVerifyByPhoneViewController shareInstance] animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
