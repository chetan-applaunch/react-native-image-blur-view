//
//  HBScrollableImageView.m
//  HBScrollableImageView
//
//  Created by Hitesh Boricha on 24/11/2021.
//  Copyright (c) 2021 Applaunch. All rights reserved.
//

#import "HBScrollableImageView.h"

@interface HBScrollableImageView ()

@property (nonatomic, retain) UIImageView *imageView;

- (void)update;

@end

@implementation HBScrollableImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self) {
        // Scroll View
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        scrollView.delegate = self;
        scrollView.clipsToBounds = YES;
        scrollView.pagingEnabled = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.scrollsToTop = NO;
        scrollView.decelerationRate = 0;
        
        [self addSubview:scrollView];
        self.scrollView = scrollView;
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        
        [self.scrollView addSubview:imageView];
        self.imageView = imageView;
        
        for(UIGestureRecognizer *gestureRecognizer in self.scrollView.gestureRecognizers) {
            if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
                UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
                panGestureRecognizer.minimumNumberOfTouches = 2;
            }
        }
        self.isFirst = NO;
        self.minimumZoomScale = 1.0;
        self.maximumZoomScale = 3.0;
    }
    return self;
}

- (void)setMinimumZoomScale:(CGFloat)minimumZoomScale
{
    self.scrollView.minimumZoomScale = minimumZoomScale;
}

- (CGFloat)minimumZoomScale
{
    return self.scrollView.minimumZoomScale;
}

- (void)setMaximumZoomScale:(CGFloat)maximumZoomScale
{
    self.scrollView.maximumZoomScale = maximumZoomScale;
}

- (CGFloat)maximumZoomScale
{
    return self.scrollView.maximumZoomScale;
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
    
    [self update];
}

- (UIImage *)image
{
    return self.imageView.image;
}

#pragma mark - 

- (void)update
{
    if(self.image == nil) return;
    if (self.isFirst == YES) return;;
    CGSize filledImageSize = [HBScrollableImageView filledImageSizeWithImageSize:self.image.size containerSize:self.bounds.size];
    filledImageSize.width = round(filledImageSize.width);
    filledImageSize.height = round(filledImageSize.height);
    
    self.scrollView.contentSize = filledImageSize;
    self.imageView.frame = CGRectMake(0, 0, filledImageSize.width, filledImageSize.height);
    
    CGFloat offsetX = round((filledImageSize.width - self.frame.size.width) / 2.0);
    CGFloat offsetY = round((filledImageSize.height - self.frame.size.height) / 2.0);
    self.scrollView.contentOffset = CGPointMake(offsetX, offsetY);
}

+ (CGSize)filledImageSizeWithImageSize:(CGSize)imageSize containerSize:(CGSize)containerSize
{
    CGSize filledImageSize;
    
    if(containerSize.width > containerSize.height) {
        filledImageSize = CGSizeMake(containerSize.width, (containerSize.width / imageSize.width) * imageSize.height);
        
        if(filledImageSize.height < containerSize.height) {
            filledImageSize = CGSizeMake((containerSize.height / imageSize.height) * imageSize.width, containerSize.height);
        }
    } else {
        filledImageSize = CGSizeMake((containerSize.height / imageSize.height) * imageSize.width, containerSize.height);
        
        if(filledImageSize.width < containerSize.width) {
            filledImageSize = CGSizeMake(containerSize.width, (containerSize.width / imageSize.width) * imageSize.height);
        }
    }
    return filledImageSize;
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end
