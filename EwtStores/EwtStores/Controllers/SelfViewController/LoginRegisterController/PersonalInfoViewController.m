//
//  PersonalInfoViewController.m
//  Shop
//
//  Created by Harry on 14-1-7.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "PersonalInfoViewController.h"
#import "CouponViewController.h"

#import "EGOImageView.h"

@interface PersonalInfoViewController ()
{
    EGOImageView        *headerIView;
}

@end

@implementation PersonalInfoViewController

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
    [self setNavBarTitle:@"个人信息"];
    [self hiddenRightBtn];
    
    UITableView *tView = [[UITableView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(0, Navbar_Height, Main_Size.width, Main_Size.height - StatusBar_Height - Navbar_Height)] style:UITableViewStyleGrouped];
    [tView setDelegate:self];
    [tView setDataSource:self];
    [tView setBackgroundView:nil];
    [tView setBackgroundColor:RGBS(238)];
    [self.view addSubview:tView];
    
    [MobClick event:GRZX];
}

#pragma mark UItableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];

    if(indexPath.section == 0){
        UserObj *user= [GlobalMethod getObjectForKey:USEROBJECT];
        
        
        UILabel *nameLb = [GlobalMethod BuildLableWithFrame:CGRectMake(10, 30, 200, 20)
                                                   withFont:[UIFont systemFontOfSize:18]
                                                   withText:user.userName];
        [cell.contentView addSubview:nameLb];
        
        headerIView = [[EGOImageView alloc] initWithFrame:CGRectMake(nameLb.right + 30, 5, 70, 70)];
        [headerIView setPlaceholderImage:[UIImage imageNamed:@"profile-no-avatar-icon"]];
        [headerIView setImageURL:[NSURL URLWithString:user.headPic]];
        [cell.contentView addSubview:headerIView];
        [headerIView setUserInteractionEnabled:YES];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ChangeHeadView)];
        [headerIView addGestureRecognizer:tap];
    }else{
        UILabel *niceLb = [GlobalMethod BuildLableWithFrame:CGRectMake(10, 12, 200, 20)
                                                   withFont:[UIFont systemFontOfSize:16]
                                                   withText:@"优惠券"];
        [niceLb setTextColor:RGBS(59)];
        [cell.contentView addSubview:niceLb];
        
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 80;
    }
    
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        [self ChangeHeadView];
    }else{
        [self.navigationController pushViewController:[CouponViewController shareInstance] animated:YES];
    }
}

- (void)ChangeHeadView{
    
    UIActionSheet *aSheet = [[UIActionSheet alloc] initWithTitle:@"更换头像?"
                                                        delegate:self
                                               cancelButtonTitle:@"取消"
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"拍照",@"相机选取", nil];
    [aSheet showInView:self.tabBarController.view];
    
    [MobClick event:GRXS];
}

#pragma mark UIAcionSheet Methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == actionSheet.cancelButtonIndex){
        
    }else if (buttonIndex == 0){
        
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){ //相机能用
            UIImagePickerController *imagePC = [[UIImagePickerController alloc] init];
            [imagePC setSourceType:UIImagePickerControllerSourceTypeCamera];
            [imagePC setDelegate:self];
            [self presentViewController:imagePC animated:YES completion:Nil];
        }
    }else{
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){//相册可用
            UIImagePickerController *imagePC = [[UIImagePickerController alloc] init];
            [imagePC setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            [imagePC setDelegate:self];
            [imagePC setAllowsEditing:YES];
            [self presentViewController:imagePC animated:YES completion:Nil];
        }
    }
}

#pragma mark UIImagePickerVC Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *editImg = [info objectForKey:UIImagePickerControllerEditedImage];
    
    [headerIView setImage:editImg];
    
    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
