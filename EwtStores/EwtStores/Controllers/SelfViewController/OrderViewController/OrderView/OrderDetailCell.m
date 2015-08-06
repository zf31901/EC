//
//  CartOfProductCell.m
//  Shop
//
//  Created by Harry on 14-1-2.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "OrderDetailCell.h"
#import "OrderObj.h"
#import "ProductObj.h"

@implementation OrderDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        OrderObj *obj = [GlobalMethod getObjectForKey:ORDEROBJECT];
        // Initialization code
        UIView *space = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
        [space setBackgroundColor:RGBS(238)];
        [self.contentView addSubview:space];
        //leftView
        self.leftView = [[UIView alloc] initWithFrame:CGRectMake(5, 10, self.width, self.height)];
        [self.contentView addSubview:self.leftView];
        
        self.orderId = [GlobalMethod BuildLableWithFrame:CGRectMake(5, 15, 300, 27)
                                                withFont:[UIFont systemFontOfSize:12]
                                                withText:nil];
        //[self.orderId setTextColor:RGBS(180)];
        [self.leftView addSubview:self.orderId];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(self.leftView.left, self.orderId.bottom + 6, 280, 0.5)];
        [line setBackgroundColor:RGBS(202)];
        [self.leftView addSubview:line];
        
        /*self.productImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(self.leftView.left, line.bottom + 8, 70, 70)];
        [self.productImgView setPlaceholderImage:[UIImage imageNamed:@"default_img_140"]];
        [self.leftView addSubview:self.productImgView];
        
        self.nameLb = [GlobalMethod BuildLableWithFrame:CGRectMake(self.productImgView.right + 8, line.bottom + 4, 200, 45) withFont:[UIFont systemFontOfSize:13] withText:nil];
        [self.nameLb setNumberOfLines:2];
        [self.leftView addSubview:self.nameLb];
        
        self.priceLb = [GlobalMethod BuildLableWithFrame:CGRectMake(self.productImgView.right + 8, self.nameLb.bottom + 8, 100, 12) withFont:[UIFont systemFontOfSize:11] withText:nil];
        [self.priceLb setTextColor:[UIColor grayColor]];
        [self.leftView addSubview:self.priceLb];
        
        self.numLb = [GlobalMethod BuildLableWithFrame:CGRectMake(self.priceLb.right + 50, self.nameLb.bottom + 8, 50, 12) withFont:[UIFont systemFontOfSize:11] withText:nil];
        [self.numLb setTextColor:[UIColor grayColor]];
        [self.leftView addSubview:self.numLb];*/
        
        for(int i=0; i<obj.products.count; i++){
            ProductObj *pro = obj.products[i];
            
            EGOImageView *productImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(8, line.bottom + 8 + 75*i, 70, 70)];
            [productImgView setPlaceholderImage:[UIImage imageNamed:@"default_img_140"]];
            [productImgView  setImageURL:pro.imgUrl];
            [self.leftView addSubview:productImgView];
            
            UILabel *nameLb = [GlobalMethod BuildLableWithFrame:CGRectMake(productImgView.right + 8, line.bottom + 4 + 75*i, 200, 45) withFont:[UIFont systemFontOfSize:15] withText:nil];
            [nameLb setNumberOfLines:2];
            [nameLb setText:pro.name];
            [self.leftView addSubview:nameLb];
            
            UILabel *priceLb = [GlobalMethod BuildLableWithFrame:CGRectMake(productImgView.right + 8, nameLb.bottom + 8, 100, 12) withFont:[UIFont systemFontOfSize:11] withText:nil];
            [priceLb setTextColor:[UIColor grayColor]];
            [priceLb setText:[NSString stringWithFormat:@"价格：¥%.2f",[pro.salePrice floatValue]]];
            [self.leftView addSubview:priceLb];
            
            UILabel *numLb = [GlobalMethod BuildLableWithFrame:CGRectMake(priceLb.right + 50, nameLb.bottom + 8, 50, 12) withFont:[UIFont systemFontOfSize:11] withText:nil];
            [numLb setTextColor:[UIColor grayColor]];
            [numLb setText:[NSString stringWithFormat:@"数量：%@",pro.number]];
            [self.leftView addSubview:numLb];
            
            if (i != obj.products.count-1) {
                UIView *cutLine = [[UIView alloc] initWithFrame:CGRectMake(80, productImgView.bottom + 4, 214, 0.5)];
                [cutLine setBackgroundColor:RGBS(202)];
                [self.leftView addSubview:cutLine];
            }
            
        }
        
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(self.leftView.left, 75*obj.products.count + line.bottom +6, 280, 0.5)];
        [line2 setBackgroundColor:RGBS(202)];
        [self.leftView addSubview:line2];
        
        UILabel *followLb = [GlobalMethod BuildLableWithFrame:CGRectMake(self.leftView.left, line2.bottom + 5, 250, 30) withFont:[UIFont systemFontOfSize:13] withText:nil];
        [followLb setTextColor:RGBS(180)];
        [followLb setText:@"订单跟踪"];
        [self.leftView addSubview:followLb];
        
        UILabel *timeLb = [GlobalMethod BuildLableWithFrame:CGRectMake(followLb.left+2, followLb.bottom + 5, 60, 30) withFont:[UIFont systemFontOfSize:14] withText:nil];
        [timeLb setText:@"处理时间"];
        [self.leftView addSubview:timeLb];
        self.orderTime = [GlobalMethod BuildLableWithFrame:CGRectMake(timeLb.right+10, followLb.bottom + 5, 300, 30) withFont:[UIFont systemFontOfSize:12] withText:nil];
        [self.leftView addSubview:self.orderTime];
        UIView *sepLine1 = [[UIView alloc] initWithFrame:CGRectMake(self.orderTime.left, self.orderTime.bottom + 5, 205, 0.5)];
        [sepLine1 setBackgroundColor:RGBS(202)];
        [self.contentView addSubview:sepLine1];
        
        UILabel *deliverLb = [GlobalMethod BuildLableWithFrame:CGRectMake(timeLb.left, sepLine1.bottom + 5, 60, 30) withFont:[UIFont systemFontOfSize:14] withText:nil];
        [deliverLb setText:@"送货方式"];
        [self.leftView addSubview:deliverLb];
        self.deliverType = [GlobalMethod BuildLableWithFrame:CGRectMake(timeLb.right+10, sepLine1.bottom + 5, 300, 30) withFont:[UIFont systemFontOfSize:12] withText:nil];
        [self.leftView addSubview:self.deliverType];
        
        UIView *sepLine2 = [[UIView alloc] initWithFrame:CGRectMake(self.deliverType.left, self.deliverType.bottom + 5, 205, 0.5)];
        [sepLine2 setBackgroundColor:RGBS(202)];
        [self.contentView addSubview:sepLine2];
        
        UILabel *stateLb = [GlobalMethod BuildLableWithFrame:CGRectMake(deliverLb.left, sepLine2.bottom + 5, 60, 35) withFont:[UIFont systemFontOfSize:14] withText:nil];
        [stateLb setText:@"配送状态"];
        [self.leftView addSubview:stateLb];
        self.orderState = [GlobalMethod BuildLableWithFrame:CGRectMake(deliverLb.right+10, sepLine2.bottom + 5, 300, 35) withFont:[UIFont systemFontOfSize:12] withText:nil];
        [self.leftView addSubview:self.orderState];
        
        
        /*self.orderState = [GlobalMethod BuildLableWithFrame:CGRectMake(240, line2.bottom + 8, 50, 17) withFont:[UIFont systemFontOfSize:16] withText:nil];
        [self.orderState setTextColor:[UIColor redColor]];
        [self.leftView addSubview:self.orderState];
        
        UIView *sepLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.orderState.bottom + 10.5, self.width, 0.5)];
        [sepLine setBackgroundColor:RGBS(59)];
        [self.contentView addSubview:sepLine];*/
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, self.orderState.bottom, 300, 30)];
        UIImageView *footerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 30)];
        [footerView setImage:[UIImage imageNamed:@"shopping-cart-body-bg-02"]];
        [bgView addSubview:footerView];
        [self.contentView addSubview:bgView];
    }
    return self;
}

- (void)reuserTableViewCell:(OrderObj *)obj AtIndex:(NSInteger)index
{
    [self removeFromSuperview];
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"type" ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    NSDictionary *deliveryDic = [data objectForKey:@"deliveryType"];
    NSDictionary *statusDic = [data objectForKey:@"status"];
    
    [self.orderId           setText:[NSString stringWithFormat:@"订单编号：%@(共%d件)",obj.orderId, obj.products.count,nil]];
    /*[self.priceLb           setText:[NSString stringWithFormat:@"价格：¥%.2f",[pro.salePrice floatValue]]];
    [self.nameLb            setText:pro.name];
    [self.productImgView    setImageURL:pro.imgUrl];
    [self.numLb             setText:[NSString stringWithFormat:@"数量：%@",pro.number]];*/
    [self.orderTime         setText:[NSString stringWithFormat:@"%@ 您提交了订单",[GlobalMethod convertJsonDateToIOSDate:obj.orderTime]]];
    [self.orderState         setText:[statusDic objectForKey:[NSString stringWithFormat:@"status_%d",obj.status]]];
    [self.deliverType        setText:[deliveryDic objectForKey:[NSString stringWithFormat:@"deliveryType_%d",obj.deliverType]]];
}


@end
