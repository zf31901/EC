//
//  DelivementViewController.m
//  Shop
//
//  Created by Harry on 14-1-14.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "DelivementViewController.h"
#import "SettleViewController.h"

extern SettleViewController *settleVC;

@interface DelivementViewController ()
{
    UITableView     *tView;
    NSMutableArray  *dataArr1;
    NSMutableArray  *dataArr2;
    
    UISwitch        *sw;
}

@end

@implementation DelivementViewController

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
    
    [self setNavBarTitle:@"配送方式"];
    [self hiddenRightBtn];
    
    dataArr1 = [NSMutableArray arrayWithObjects:@"配送方式",@"运费",nil];
    dataArr2 = [NSMutableArray arrayWithObjects:@"快递",@"免运费",nil];
    
    tView = [[UITableView alloc] initWithFrame:CGRectMake(0, [GlobalMethod AdapterIOS6_7ByIOS6Float:Navbar_Height + 20], Main_Size.width, 87) style:UITableViewStylePlain];
    [tView setDelegate:self];
    [tView setDataSource:self];
    [tView setBackgroundView:nil];
    [tView setBackgroundColor:RGBS(238)];
    [self.view addSubview:tView];
    
    [MobClick event:PSFS];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArr1.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"cell"];
    
    [cell.textLabel setText:dataArr1[indexPath.row]];
    [cell.detailTextLabel setText:dataArr2[indexPath.row]];

    [cell.textLabel setTextColor:RGBS(59)];
    [cell.textLabel setTextAlignment:NSTextAlignmentLeft];
    [cell.textLabel setFont:[UIFont systemFontOfSize:16]];
    [cell.detailTextLabel setTextColor:RGBS(88)];
    [cell.detailTextLabel setFont:[UIFont systemFontOfSize:14]];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
