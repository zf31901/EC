//
//  BaseRefreshTableViewController.m
//  Shop
//
//  Created by Harry on 13-12-19.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "BaseRefreshTableViewController.h"

@interface BaseRefreshTableViewController ()

@end

@implementation BaseRefreshTableViewController

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
    
    _isShowFooterView   = YES;
    self.hasMore        = YES;
    
    self.mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, [GlobalMethod AdapterIOS6_7ByIOS6Float:Navbar_Height], Main_Size.width, Main_Size.height) style:UITableViewStylePlain];
    [self.mainTableView setDelegate:self];
    [self.mainTableView setDataSource:self];
    [self.mainTableView setBackgroundView:nil];
    [self.mainTableView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.mainTableView];
    
    [self buildHeaderView];
    [self setFooterView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.mainTableView.delegate = nil;
    self.mainTableView.dataSource = nil;
}

//建立headerView
- (void)buildHeaderView
{
    if(egoHeaderView && [egoHeaderView superview])
    {
        [egoHeaderView removeFromSuperview];
    }
    
    egoHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0 - self.mainTableView.frame.size.height, self.view.frame.size.width, self.mainTableView.frame.size.height)];
    [egoHeaderView setDelegate:self];
    
    [self.mainTableView addSubview:egoHeaderView];
    
    [egoHeaderView refreshLastUpdatedDate];
}

//设置是否显示footerView
- (void)setFooterView
{
    if(_isShowFooterView == NO)
    {
        return ;
    }
    
    CGFloat height = MAX(self.mainTableView.contentSize.height, self.mainTableView.frame.size.height);
    
    if (egoFooterView && [egoFooterView superview])
    {
        // reset position
        egoFooterView.frame = CGRectMake(0.0f,height,Main_Size.width,self.mainTableView.bounds.size.height);
    }
    else
    {
        // create the footerView
        egoFooterView = [[EGORefreshTableFooterView alloc] initWithFrame:CGRectMake(0.0f, height, Main_Size.width, self.mainTableView.bounds.size.height)];
        egoFooterView.delegate = self;
        [self.mainTableView addSubview:egoFooterView];
    }
    
    if (egoFooterView)
    {
        [egoFooterView refreshLastUpdatedDate];
    }
}

- (void)hiddenHeaderView
{
    [self removeHeaderView];
}

- (void)hiddenFooterView
{
    _isShowFooterView = NO;
    
    [self removeFooterView];
}


#pragma mark UITableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (egoHeaderView)
    {
        [egoHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
	
	if (egoFooterView)
    {
        [egoFooterView egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if (egoHeaderView){
        [egoHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
	
	if (egoFooterView) {
        [egoFooterView egoRefreshScrollViewDidEndDragging:scrollView];
    }
}

#pragma mark -
#pragma mark EGORefreshTableDelegate Methods

- (void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos
{
	[self beginToReloadData:aRefreshPos];
}

- (BOOL)egoRefreshTableDataSourceIsLoading:(UIView*)view
{
	return _isLoading;   // should return if data source model is reloading
}


// if we don't realize this method, it won't display the refresh timestamp
- (NSDate*)egoRefreshTableDataSourceLastUpdated:(UIView*)view
{
	return [NSDate date]; // should return date data source was last changed
}

-(void)beginToReloadData:(EGORefreshPos)aRefreshPos   //刷新或追加开始
{
	_isLoading = YES;
    
    if (aRefreshPos == EGORefreshHeader)  // pull down to refresh data
    {
        [self performSelector:@selector(refreshView) withObject:nil afterDelay:0];
    }
    else if(aRefreshPos == EGORefreshFooter)  // pull up to load more data
    {
        [self performSelector:@selector(getNextPageView) withObject:nil afterDelay:0];
    }
}

- (void)refreshView
{
    [self finishReloadingData];
}

- (void)getNextPageView
{
    //[self removeFooterView];
    
    [self finishReloadingData];
}

- (void)finishReloadingData       //刷新或追加结束
{
	_isLoading = NO;
    
	if (egoHeaderView)
    {
        [egoHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.mainTableView];
    }
    
    if (egoFooterView)
    {
        [egoFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:self.mainTableView];
    }
    
    [self.mainTableView reloadData];
    
    [self setFooterView];
}

-(void)removeFooterView
{
    if (egoFooterView && [egoFooterView superview])
    {
        [egoFooterView removeFromSuperview];
    }
    egoFooterView = nil;
}

-(void)removeHeaderView
{
    if (egoHeaderView && [egoHeaderView superview])
    {
        [egoHeaderView removeFromSuperview];
    }
    egoHeaderView = nil;
}

- (BOOL)isLoading
{
    return _isLoading;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
