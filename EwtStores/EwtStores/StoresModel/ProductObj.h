//
//  ProductObj.h
//  Shop
//
//  Created by Harry on 13-12-25.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "BaseModel.h"

@interface ProductObj : BaseModel

@property (nonatomic, strong) NSURL     *listImgUrl;    //列表图片url
@property (nonatomic, strong) NSURL     *imgUrl;        //商品详情图片url
@property (nonatomic, strong) NSArray   *detailImgUrl;  //大图片地址string (数组)
@property (nonatomic, strong) NSString  *name;          //商品名
@property (nonatomic, strong) NSString  *oldPrice;      //原价
@property (nonatomic, strong) NSString  *salePrice;     //最新价
@property (nonatomic, strong) NSString  *beginTime;     //抢购商品开始时间  时间戳
@property (nonatomic, strong) NSString  *endTime;       //抢购商品结束时间  时间戳
@property (nonatomic, strong) NSString  *timeLimit;     //限时时间
@property (nonatomic, strong) NSString  *introduction;  //商品介绍
@property (nonatomic, strong) NSString  *saleMonthNum;  //月销售
@property (nonatomic, strong) NSString  *starNum;       //好评度
@property (nonatomic, strong) NSString  *totalComment;  //评论总数
@property (nonatomic, strong) NSString  *color;         //商品颜色
@property (nonatomic, strong) NSString  *size;          //商品尺寸
@property (nonatomic, strong) NSString  *productNum;    //商品个数
@property (nonatomic, strong) NSString  *productId;     //商品ID
@property (nonatomic, strong) NSString  *productCode;   //商品编号
@property (nonatomic, strong) NSString  *linkUrl;       //商品详情（URL）
@property (nonatomic, strong) NSString  *stockNum;      //库存数量
@property (nonatomic, strong) NSString  *goodCommentNum;//好评数
@property (nonatomic, strong) NSString  *midCommentNum; //中评数
@property (nonatomic, strong) NSString  *lowCommentNum; //差评数

//购物车商品信息
@property (nonatomic, strong) NSString  *productCId;    //标识ID
@property (nonatomic, strong) NSString  *userLogin;     //所属用户
@property (nonatomic, strong) NSString  *productScrial; //商品编号
@property (nonatomic, strong) NSString  *number;        //购买的商品件数
@property (nonatomic, strong) NSString  *productBarCode;//条形码
@property (nonatomic, strong) NSString  *prefer;        //优惠面值
@property (nonatomic, strong) NSString  *integral;      //积分
@property (nonatomic, strong) NSString  *coupon;        //增送的优惠券面值
@property (nonatomic, assign) BOOL      priceUnKnow;    //是否已修改面议价格
@property (nonatomic, strong) NSString  *weight;        //商品重量

@property (nonatomic, getter = isShowRightView) BOOL  showRightView;    //购物车界面，是否显示rightView标志
@property (nonatomic, getter = isChoiceToSettle) BOOL choiceToSettle;   //购物车界面，是否被选中到购物车中

@end