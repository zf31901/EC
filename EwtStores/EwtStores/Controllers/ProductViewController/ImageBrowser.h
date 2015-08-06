//
//  SJAvatarBrowser.h
//  zhitu
//
//  Created by
//  Copyright (c) . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageBrowser : NSObject <UIScrollViewDelegate>
/**
 *	@brief	浏览图片
 *
 *	@param 	oldImageView 	图片所在的imageView
 */

@property (nonatomic, strong) UIScrollView              *mainSView;
@property (nonatomic, strong) UIScrollView              *bannerSView;
@property (nonatomic, strong) UIPageControl             *pageC;

+(void)showImage:(UIImageView*)avatarImageView;

@end
