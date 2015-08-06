//
//  ExchangeTypeViewController.m
//  Shop
//
//  Created by Jacob on 14-1-15.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "ExchangeTypeViewController.h"
#import "ExchangeViewController.h"

extern ExchangeViewController *exchangeVC;

@interface ExchangeTypeViewController ()
{
    NSArray     *exchangeArr;
    
    NSInteger   currentIndex;
}
@end

@implementation ExchangeTypeViewController

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
    
    [self setNavBarTitle:@"退换货方式"];
    [self hiddenRightBtn];
    
    currentIndex = -1;
    exchangeArr = [NSArray arrayWithObjects:@"退货",@"换货",@"维修",nil];
    currentIndex = [exchangeArr indexOfObject:self.exchangeType];
    
    UITableView *tView = [[UITableView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(0, Navbar_Height, Main_Size.width, Main_Size.height - StatusBar_Height - Navbar_Height)] style:UITableViewStyleGrouped];
    [tView setDataSource:self];
    [tView setDelegate:self];
    [tView setBackgroundView:nil];
    [tView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:tView];
}

#pragma mark
#pragma mark UItableView methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return exchangeArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"exchage_cell";
    UITableViewCell *cell = cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    
    UILabel *lb = [GlobalMethod BuildLableWithFrame:CGRectMake(10, 14, 140, 15)
                                           withFont:[UIFont systemFontOfSize:14]
                                           withText:exchangeArr[indexPath.row]];
    [cell.contentView addSubview:lb];
    
    if(indexPath.row == currentIndex){
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }else{
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    for(int i=0; i<exchangeArr.count; i++){
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    currentIndex = indexPath.row;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    
    [self performSelector:@selector(comeBack) withObject:nil afterDelay:0.5];
}

- (void)comeBack{
    exchangeVC.exchangeType = exchangeArr[currentIndex];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
