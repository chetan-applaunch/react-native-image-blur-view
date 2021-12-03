//
//  HBScrollableImageView.h
//  HBScrollableImageView
//
//  Created by Hitesh Boricha on 24/11/2021.
//  Copyright (c) 2021 Applaunch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HBScrollableImageView : UIView <UIScrollViewDelegate>

@property (nonatomic, assign) CGFloat minimumZoomScale;
@property (nonatomic, assign) CGFloat maximumZoomScale;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (assign) BOOL isFirst;
+ (CGSize)filledImageSizeWithImageSize:(CGSize)imageSize containerSize:(CGSize)containerSize;

@end
