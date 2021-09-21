//
//  UIImage+Common.m
//  IosBlurPanGestureExample
//
//  Version 0.0.1
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 Paulo Miguel Almeida Rodenas <paulo.ubuntu@gmail.com>
//
//  Get the latest version from here:
//
//  https://github.com/pauloubuntu/ios-blur-pan-gesture
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "UIImage+Common.h"

@implementation UIImage (Common)

// credits : http://stackoverflow.com/a/21693491/832748
-(UIImage*) cropImage:(CGRect) rectOfInterest
{
    double (^rad)(double) = ^(double deg) {
        return deg / 180.0 * M_PI;
    };
    
    CGAffineTransform rectTransform;
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(90)), 0, -self.size.height);
            break;
        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-90)), -self.size.width, 0);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-180)), -self.size.width, -self.size.height);
            break;
        default:
            rectTransform = CGAffineTransformIdentity;
    };
    rectTransform = CGAffineTransformScale(rectTransform, self.scale, self.scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect( [self CGImage], CGRectApplyAffineTransform(rectOfInterest, rectTransform) );
    
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return croppedImage;
}

// credits :  http://stackoverflow.com/a/15523868/832748
- (UIImage *)drawImage:(UIImage *)inputImage inRect:(CGRect)frame {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
    [self drawInRect:CGRectMake(0.0, 0.0, self.size.width, self.size.height)];
    [inputImage drawInRect:frame];
    UIImage *newImage = nil;
    @autoreleasepool {
        // ...
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newImage;

//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return [newImage autorelease];
}

-(UIImage*) drawOverlayWithColor:(UIColor*) color
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
    [self drawInRect:CGRectMake(0.0, 0.0, self.size.width, self.size.height)];
    CGColorRef colorRef = [color CGColor];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, colorRef);
    CGContextFillRect(context, CGRectMake(0.0, 0.0, self.size.width, self.size.height));
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}
- ( UIImage  *)imageWithGaussianBlur9 {
     float  weight[5] = {0.2270270270, 0.2945945946, 0.2216216216, 0.1540540541, 0.1162162162};
     // Blur horizontally
     UIGraphicsBeginImageContextWithOptions ( self .size,  NO ,  self .scale);
     [ self  drawInRect:CGRectMake(0, 0,  self .size.width,  self .size.height) blendMode:kCGBlendModeNormal alpha:weight[0]];
     for  ( int  x = 1; x < 5; ++x) {
         [ self  drawInRect:CGRectMake(x, 0,  self .size.width,  self .size.height) blendMode:kCGBlendModeNormal alpha:weight[x]];
         [ self  drawInRect:CGRectMake(-x, 0,  self .size.width,  self .size.height) blendMode:kCGBlendModeNormal alpha:weight[x]];
     }
     UIImage  *horizBlurredImage =  UIGraphicsGetImageFromCurrentImageContext ();
     UIGraphicsEndImageContext ();
     // Blur vertically
     UIGraphicsBeginImageContextWithOptions ( self .size,  NO ,  self .scale);
     [horizBlurredImage drawInRect:CGRectMake(0, 0,  self .size.width,  self .size.height) blendMode:kCGBlendModeNormal alpha:weight[0]];
     for  ( int  y = 1; y < 5; ++y) {
         [horizBlurredImage drawInRect:CGRectMake(0, y,  self .size.width,  self .size.height) blendMode:kCGBlendModeNormal alpha:weight[y]];
         [horizBlurredImage drawInRect:CGRectMake(0, -y,  self .size.width,  self .size.height) blendMode:kCGBlendModeNormal alpha:weight[y]];
     }
     UIImage  *blurredImage =  UIGraphicsGetImageFromCurrentImageContext ();
     UIGraphicsEndImageContext ();
     //
     return  blurredImage;
}
@end
