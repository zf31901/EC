//
//  CartOfProductCell.m
//  Shop
//
//  Created by Harry on 14-1-2.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import "CartOfProductCell.h"

#import "ProductObj.h"

#import "UIButton+Extensions.h"
#import "HarryButton.h"

@implementation CartOfProductCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        //leftView
        self.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        [self.contentView addSubview:self.leftView];
        
        self.isEditStatus = YES;
        
        _statusBt = [[HarryButton alloc] initWithFrame:CGRectMake(8, 34, 20, 20)
                                                         andOffImg:@"banndUnChoice"
                                                          andOnImg:@"autoLoginOn"
                                                         withTitle:nil];
        [_statusBt setUserInteractionEnabled:YES];
        [self.statusBt setButtonEdgeInsets:UIEdgeInsetsMake(-20, -8, -20, -100)];
        [self.statusBt addTarget:self action:@selector(backgroundColorChange:) forControlEvents:UIControlEventTouchUpInside];
        
        _productImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(self.statusBt.right + 12, 12, 70, 70)];
        [self.productImgView setPlaceholderImage:[UIImage imageNamed:@"default_img_140"]];
        [_productImgView setUserInteractionEnabled:NO];
        [self.leftView addSubview:self.productImgView];
        
        [self.leftView addSubview:self.statusBt];
        
        self.nameLb = [GlobalMethod BuildLableWithFrame:CGRectMake(self.productImgView.right + 10,  8, 180, 33) withFont:[UIFont systemFontOfSize:13] withText:nil];
        [self.nameLb setNumberOfLines:2];
        [self.leftView addSubview:self.nameLb];
        
        self.colorLb = [GlobalMethod BuildLableWithFrame:CGRectMake(self.productImgView.right + 10, self.nameLb.bottom + 8, 180, 14) withFont:[UIFont systemFontOfSize:11] withText:nil];
        [self.colorLb setTextColor:[UIColor grayColor]];
        [self.leftView addSubview:self.colorLb];
        
        self.numLb = [GlobalMethod BuildLableWithFrame:CGRectMake(self.productImgView.right + 10, self.colorLb.bottom + 8, 70, 12) withFont:[UIFont systemFontOfSize:11] withText:nil];
        [self.numLb setTextColor:[UIColor grayColor]];
        [self.leftView addSubview:self.numLb];
        
        self.priceLb = [GlobalMethod BuildLableWithFrame:CGRectMake(self.numLb.right + 10, self.colorLb.bottom + 6, 100, 15)
                                                withFont:[UIFont systemFontOfSize:14]
                                                withText:nil];
        [self.priceLb setTextColor:[UIColor redColor]];
        [self.priceLb setTextAlignment:NSTextAlignmentRight];
        [self.leftView addSubview:self.priceLb];
        
        //rightView
        self.rightView = [[UIView alloc] initWithFrame:CGRectMake(self.right, 0, 180, self.height - 2)];
        [self.rightView setBackgroundColor:RGBS(234)];
        [self.contentView addSubview:self.rightView];
        
        UIButton *plusBt = [GlobalMethod BuildButtonWithFrame:CGRectMake(10, 15, 44, 40)
                                                    andOffImg:@"shoppingcar_minus_off"
                                                     andOnImg:@"shoppingcar_minus_on"
                                                    withTitle:nil];
        [plusBt setButtonEdgeInsets:UIEdgeInsetsMake(-10, -20, -10, -20)];
        [plusBt addTarget:self action:@selector(plusProductNum) forControlEvents:UIControlEventTouchUpInside];
        [self.rightView addSubview:plusBt];
        
        self.choiceNumLb = [GlobalMethod BuildLableWithFrame:CGRectMake(plusBt.right + 8, 15, 70, 40)
                                                    withFont:[UIFont systemFontOfSize:14]
                                                    withText:@"1"];
        [self.choiceNumLb setBackgroundColor:[UIColor whiteColor]];
        [self.choiceNumLb setTextAlignment:NSTextAlignmentCenter];
        [self.choiceNumLb.layer setCornerRadius:4];
        [self.choiceNumLb.layer setMasksToBounds:YES];
        [self.rightView addSubview:self.choiceNumLb];
        
        UIButton *addBt = [GlobalMethod BuildButtonWithFrame:CGRectMake(self.choiceNumLb.right + 8, 15, 44, 40)
                                                   andOffImg:@"shoppingcar_add_off"
                                                    andOnImg:@"shoppingcar_add_on"
                                                   withTitle:nil];
        [addBt setButtonEdgeInsets:UIEdgeInsetsMake(-10, -20, -10, -20)];
        [addBt addTarget:self action:@selector(addProductNum) forControlEvents:UIControlEventTouchUpInside];
        [self.rightView addSubview:addBt];
        
        UILabel *lb = [GlobalMethod BuildLableWithFrame:CGRectMake(10, plusBt.bottom + 8, 40, 14) withFont:[UIFont systemFontOfSize:13] withText:@"价格:"];
        [self.rightView addSubview:lb];
        
        self.currentPriceLb = [GlobalMethod BuildLableWithFrame:CGRectMake(lb.right + 8, lb.top, 120, 14) withFont:[UIFont systemFontOfSize:13] withText:@"¥ 0"];
        [self.currentPriceLb setTextColor:[UIColor redColor]];
        [self.rightView addSubview:self.currentPriceLb];
        
        // tag by harry 20140418 百货二期 (禁用removeBt)
        self.removeBt = [GlobalMethod BuildButtonWithFrame:CGRectMake(30, 85, 100, 30)
                                                      andOffImg:@"shopping-cart-edit-remove-bg-grey"
                                                       andOnImg:@"shopping-cart-edit-remove-bg-grey"
                                                      withTitle:@"移出商品"];
        [self.removeBt.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [self.removeBt addTarget:self action:@selector(removeProduct:) forControlEvents:UIControlEventTouchUpInside];
        //[self.rightView addSubview:self.removeBt];
    
        
        UIView *sepLine = [[UIView alloc] initWithFrame:CGRectMake(0,  91.5, self.width, 0.5)];
        [sepLine setBackgroundColor:RGBS(59)];
        //[self.contentView addSubview:sepLine];
    }
    return self;
}

- (void)backgroundColorChange:(HarryButton *)button
{
    self.currentObj.choiceToSettle = !self.currentObj.choiceToSettle;
    
    button.choiceStatus = !self.currentObj.choiceToSettle;
    
    [button changeBackgroundImage];
    
    if(self._delegate && [self._delegate respondsToSelector:@selector(editProductAtIndex: AndCurrentNum: andIsChoicedTap:)]){
        [self._delegate editProductAtIndex:self.currentIndex AndCurrentNum:[self.choiceNumLb.text integerValue] andIsChoicedTap:YES];
    }
}

- (void)reuserTableViewCell:(ProductObj *)obj AtIndex:(NSInteger)index
{
    [self removeFromSuperview];
    self.currentObj = obj;
    
    self.totalNum = [obj.stockNum integerValue];
    [self.priceLb           setText:[NSString stringWithFormat:@"¥%0.2f元",[obj.salePrice floatValue] * obj.number.integerValue]];
    [self.currentPriceLb    setText:[NSString stringWithFormat:@"¥%0.2f元",[obj.salePrice floatValue] * obj.number.integerValue]];
    [self.nameLb            setText:obj.name];
    [self.productImgView    setImageURL:obj.listImgUrl];
    if([obj.color isKindOfClass:[NSNull class]] || obj.color == nil){
        
    }else{
        [self.colorLb           setText:[NSString stringWithFormat:@"%@",obj.color]];
    }
    
    [self.numLb             setText:[NSString stringWithFormat:@"数量：%@",obj.number]];
    [self.editBt            setTag:index];
    [self.removeBt          setTag:index];
    self.currentIndex = index;
    
    [self.choiceNumLb       setText:[NSString stringWithFormat:@"%@",obj.number]];
    self.productNum         = [obj.number integerValue];
    [self.editBt setTitle:@"编辑" forState:UIControlStateNormal];
    
    if(obj.showRightView){
        [self showRightView];
    }else{
        [self hideRightView];
    }
    
    if (obj.choiceToSettle) {
        [self.statusBt setBackgroundImage:[UIImage imageNamed:@"autoLoginOn"] forState:UIControlStateNormal];
    }else{
        [self.statusBt setBackgroundImage:[UIImage imageNamed:@"banndUnChoice"] forState:UIControlStateNormal];
    }
}

- (void)editCartOfProduct:(UIButton *)bt
{
    if(self.isEditStatus){
        [bt setTitle:@"完成" forState:UIControlStateNormal];
        
        [UIView animateWithDuration:0.3 animations:^{
            [self showRightView];
        }];
    }else{
        [bt setTitle:@"编辑" forState:UIControlStateNormal];
        
        [UIView animateWithDuration:0.3 animations:^{
            [self hideRightView];
        }];
    }
    
    self.isEditStatus = !self.isEditStatus;
    
    if(self._delegate && [self._delegate respondsToSelector:@selector(editProductAtIndex: AndEditStatus: AndCurrentNum:)]){
        [self._delegate editProductAtIndex:bt.tag AndEditStatus:!self.isEditStatus AndCurrentNum:[self.choiceNumLb.text integerValue]];
    }
}

- (void)plusProductNum
{
    if(self.productNum == 1){
        
    }else{
        self.productNum --;
    }
    
    self.currentObj.number = [NSString stringWithFormat:@"%d",self.productNum];
    [self.choiceNumLb setText:[NSString stringWithFormat:@"%ld",(long)self.productNum]];
    [self.numLb setText:[NSString stringWithFormat:@"数量：%ld",(long)self.productNum]];
    [self.currentPriceLb    setText:[NSString stringWithFormat:@"¥%0.2f元",[self.currentObj.salePrice floatValue] * self.productNum]];
    
    if(self._delegate && [self._delegate respondsToSelector:@selector(editProductAtIndex: AndCurrentNum: andIsChoicedTap:)]){
        [self._delegate editProductAtIndex:self.currentIndex AndCurrentNum:[self.choiceNumLb.text integerValue] andIsChoicedTap:NO];
    }
}

- (void)addProductNum
{
    if(self.productNum >= self.totalNum){
        [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"商品库存不足" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show];
    }else{
        self.productNum ++;
    }
    
    self.currentObj.number = [NSString stringWithFormat:@"%d",self.productNum];
    [self.choiceNumLb setText:[NSString stringWithFormat:@"%ld",(long)self.productNum]];
    [self.numLb setText:[NSString stringWithFormat:@"数量：%ld",(long)self.productNum]];
    [self.currentPriceLb    setText:[NSString stringWithFormat:@"¥%0.2f元",[self.currentObj.salePrice floatValue] * self.productNum]];
    
    if(self._delegate && [self._delegate respondsToSelector:@selector(editProductAtIndex: AndCurrentNum: andIsChoicedTap:)]){
        [self._delegate editProductAtIndex:self.currentIndex AndCurrentNum:[self.choiceNumLb.text integerValue] andIsChoicedTap:NO];
    }
}

- (void)removeProduct:(UIButton *)bt
{
    if(self._delegate && [self._delegate respondsToSelector:@selector(removeProductAtIndex:)]){
        [self._delegate removeProductAtIndex:bt.tag];
    }
}

- (void)showRightView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            [self.rightView setFrame:CGRectMake(self.nameLb.left - 2, 0, 200, self.height - 2)];
        }];
    });
}

- (void)hideRightView
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.rightView setFrame:CGRectMake(self.width, 0, 180, self.height - 2)];
    }];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
