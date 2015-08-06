//
//  RequestPostUploadHelper.h
//  Shop
//
//  Created by Jacob on 14-2-19.
//  Copyright (c) 2014年 Harry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestPostUploadHelper : NSObject

/**
 *POST 提交 并可以上传图片目前只支持单张
 */
+ (NSString *)postRequestWithURL: (NSString *)url
                      postParems: (NSMutableDictionary *)postParems // 提交参数据集合
                     picFilePath: (NSString *)picFilePath  // 上传图片路径
                     picFileName: (NSString *)picFileName;  // 上传图片名称

/**
 * 修改图片大小
 */
+ (UIImage *) imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize) newSize;
/**
 * 将Image裁剪成圆形
 */
+ (UIImage*) circleImage:(UIImage*) image withParam:(CGFloat) inset;
/**
 * 保存图片
 */
+ (NSString *)saveImage:(UIImage *)tempImage WithName:(NSString *)imageName;
/**
 * 生成GUID
 */
+ (NSString *)generateUuidString;

@end
