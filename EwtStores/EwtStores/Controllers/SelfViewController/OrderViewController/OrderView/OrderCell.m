//
//  CartOfProductCell.m
//  Shop
//
//  Created by Harry on 14-1-2.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "OrderCell.h"
#import "OrderObj.h"
#import "ProductObj.h"

@implementation OrderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        OrderObj *obj = [GlobalMethod getObjectForKey:ORDEROBJECT];
        DLog(@"initWithStyle_productNum:%d",obj.products.count);
        // Initialization code
        UIView *space = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
        [space setBackgroundColor:RGBS(235)];
        [self.contentView addSubview:space];
        //leftView
        self.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, self.width, self.height)];
        [self.contentView addSubview:self.leftView];
        
        self.orderId = [GlobalMethod BuildLableWithFrame:CGRectMake(8, 15, 300, 27)
                                                withFont:[UIFont systemFontOfSize:16]
                                                withText:nil];
        //[self.priceLb setTextColor:[UIColor redColor]];
        [self.leftView addSubview:self.orderId];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(8, self.orderId.bottom + 6, 284, 0.5)];
        [line setBackgroundColor:RGBS(202)];
        [self.leftView addSubview:line];
        
        /*self.productImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(8, line.bottom + 8, 70, 70)];
        [self.productImgView setPlaceholderImage:[UIImage imageNamed:@"default_img_140"]];
        [self.leftView addSubview:self.productImgView];
        
        self.nameLb = [GlobalMethod BuildLableWithFrame:CGRectMake(self.productImgView.right + 8, line.bottom + 4, 200, 45) withFont:[UIFont systemFontOfSize:15] withText:nil];
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
        
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(8, 75*obj.products.count + line.bottom +6, 284, 0.5)];
        [line2 setBackgroundColor:RGBS(202)];
        [self.leftView addSubview:line2];
        
        self.orderTime = [GlobalMethod BuildLableWithFrame:CGRectMake(8, line2.bottom + 8, 250, 35) withFont:[UIFont systemFontOfSize:12] withText:nil];
        //[self.numLb setTextColor:[UIColor grayColor]];
        [self.leftView addSubview:self.orderTime];
        
        self.orderState = [GlobalMethod BuildLableWithFrame:CGRectMake(160, line2.bottom + 8, 130, 35) withFont:[UIFont systemFontOfSize:15] withText:nil];
        [self.orderState setTextColor:[UIColor redColor]];
        [self.orderState setTextAlignment:NSTextAlignmentRight];
        [self.leftView addSubview:self.orderState];
        
        /*UIView *sepLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.orderState.bottom + 10.5, self.width, 0.5)];
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
    NSDictionary *statusDic = [data objectForKey:@"status"];
    NSDictionary *stateDic = [data objectForKey:@"repState"];
    
    [self.orderId           setText:[NSString stringWithFormat:@"订单编号：%@",obj.orderId,nil]];
    /*[self.priceLb           setText:[NSString stringWithFormat:@"价格：¥%.2f",[pro.salePrice floatValue]]];
    [self.nameLb            setText:pro.name];
    [self.productImgView    setImageURL:pro.imgUrl];
    [self.numLb             setText:[NSString stringWithFormat:@"数量：%@",pro.number]];*/
    [self.orderTime         setText:[GlobalMethod convertJsonDateToIOSDate:obj.orderTime]];
    if (obj.repType != 0) { //退换货订单
        [self.orderState         setText:[stateDic objectForKey:[NSString stringWithFormat:@"repState_%d",obj.status]]];
    } else {
        [self.orderState         setText:[statusDic objectForKey:[NSString stringWithFormat:@"status_%d",obj.status]]];
    }
    NSLog(@"%@",self.orderState.text);
}

- (void)removeProduct:(UIButton *)bt
{
    if(self._delegate && [self._delegate respondsToSelector:@selector(removeProductAtIndex:)]){
        [self._delegate removeProductAtIndex:bt.tag];
    }
}

- (void)showRightView
{
    [self.leftView setFrame:CGRectMake(0 - self.width/2, 0, self.width, self.height)];
    [self.rightView setFrame:CGRectMake(self.width/2, 0, self.width/2, self.height - 2)];
}

- (void)hideRightView
{
    [self.leftView setFrame:CGRectMake(0, 0, self.width, self.height)];
    [self.rightView setFrame:CGRectMake(self.width, 0, self.width/2, self.height - 2)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
