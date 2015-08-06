//
//  BaseRefreshTableViewController.h
//  Shop
//
//  Created by Harry on 13-12-19.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

/********************************************************
 *  1.所有有刷新或者追加界面的基类；
 *
 *  2.子类继承该类需要实现相应的TableView代理；
 *
 *  3.刷新后实现refreshView方法及追加后的getNextPageView方法； //见ProductSortViewController
 *
 *  4.必须在子类实现finishReloadingData方法重新布局；
 *
 *  5.可以调用hiddenFooterView方法 删除追加界面和方法。         //见HomeViewController
 *********************************************************/

#import "BaseViewController.h"

#import "EGORefreshTableFooterView.h"
#import "EGORefreshTableHeaderView.h"

@interface BaseRefreshTableViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,EGORefreshTableDelegate>
{
    EGORefreshTableHeaderView   *egoHeaderView;
    EGORefreshTableFooterView   *egoFooterView;
    
    BOOL                        _isLoading;
    BOOL                        _isShowFooterView;  //默认显示
}

@property (nonatomic, strong) UITableView  *mainTableView;
@property (nonatomic, assign) BOOL          hasMore;


//不提供追加界面及方法
- (void)hiddenHeaderView;
- (void)hiddenFooterView;

//完成刷新或者追加后操作 必须实现
- (void)finishReloadingData;

//刷新或追加方法
- (void)refreshView;
- (void)getNextPageView;

- (BOOL)isLoading;

@end
