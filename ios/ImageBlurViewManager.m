#import <React/RCTViewManager.h>
#import "UIImageView+CoordinateTransform.h"
#import "UIImage+Common.h"
#import "UIImage+ImageEffects.h"
#import "PureLayout.h"

@interface ImageBlurViewManager : RCTViewManager

@property (strong, nonatomic) NSMutableArray* drawRectArray; //of CGRect
@property (strong, nonatomic) UIImage* baseImageToBeBlurred;
@property (strong, nonatomic) UIImageView* imageView;

@end

@implementation ImageBlurViewManager

#define IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define DEFAULT_ROI_WIDTH   40
#define DEFAULT_ROI_HEIGHT   40

RCT_EXPORT_MODULE(ImageBlurView)

- (UIView *)view
{
    UIView *outerView = [[UIView alloc] init];

    self.imageView = [[UIImageView alloc] init];
    [self.imageView setUserInteractionEnabled:YES];
   
    [outerView addSubview:self.imageView];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.imageView configureForAutoLayout];
    [self.imageView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20];
    [self.imageView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:90];
    [self.imageView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
    [self.imageView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:20];
    
    UIImage *image = [UIImage imageNamed: @"abc.jpg"];
    [self.imageView setImage: image];
    [outerView setUserInteractionEnabled:YES];
    
    UIButton *buttonReset = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [outerView addSubview:buttonReset];
           
    [buttonReset configureForAutoLayout];
    [buttonReset autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];
    [buttonReset autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:100];
    
    [buttonReset autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:outerView withMultiplier:0.2];
    [buttonReset autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:outerView withMultiplier:0.2];
    
    UIButton *buttonSave = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [outerView addSubview:buttonSave];
   
    [buttonSave configureForAutoLayout];
    [buttonSave autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];
    [buttonSave autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:100];
    
    [buttonSave autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:outerView withMultiplier:0.2];
    [buttonSave autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:outerView withMultiplier:0.2];
        
    if (@available(iOS 13.0, *)) {
        UIImage *imageRefresh = [UIImage systemImageNamed: @"gobackward"];
        [buttonReset setImage:imageRefresh forState:UIControlStateNormal];
    }else{
        [buttonReset setTitle:@"Reset" forState: UIControlStateNormal];
    }
    
    if (@available(iOS 13.0, *)) {
        UIImage *imageCheck = [UIImage systemImageNamed: @"checkmark"];
        [buttonSave setImage:imageCheck forState:UIControlStateNormal];
    }else{
        [buttonSave setTitle:@"Save" forState: UIControlStateNormal];
    }
    
    [buttonReset addTarget:self action:@selector(buttonResetPressed:) forControlEvents:UIControlEventTouchUpInside];
    [buttonSave addTarget:self action:@selector(buttonSavePressed:) forControlEvents:UIControlEventTouchUpInside];
        
    return outerView;
}


- (void)buttonSavePressed:(UIButton *)button {
     NSLog(@"Save Button Pressed");
    UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)buttonResetPressed:(UIButton *)button {
     NSLog(@"Reset Button Pressed");
     self.imageView.image = [UIImage imageNamed:@"abc.jpg"];
     self.baseImageToBeBlurred = self.imageView.image;
}


- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
 
    CGPoint pointTranslation = [recognizer locationInView:self.imageView];
    CGPoint imageTouchPoint = [self.imageView pixelPointFromViewPoint:pointTranslation];
    //Check if it's within UIImage's bounds
    if(!CGPointEqualToPoint(imageTouchPoint, CGPointZero)){
        NSLog(@"%s It's inside image's bounds",__PRETTY_FUNCTION__);
        //Extract the region of interest of that image
        CGRect rectOfInterest = {imageTouchPoint, CGSizeMake(DEFAULT_ROI_WIDTH, DEFAULT_ROI_HEIGHT)};
        [self blurRegionOfInterest:rectOfInterest];

    }else{
        NSLog(@"Touch is outside image's bounds");
    }
}


RCT_CUSTOM_VIEW_PROPERTY(color, NSString, UIView)
{
   NSLog(@">>>>>>> color is %@",json);
   [view setBackgroundColor:[self hexStringToColor:json]];

   UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
   [panGestureRecognizer setDelegate:nil];
   [self.imageView addGestureRecognizer:panGestureRecognizer];
}

- hexStringToColor:(NSString *)stringToConvert
{
  NSString *noHashString = [stringToConvert stringByReplacingOccurrencesOfString:@"#" withString:@""];
  NSScanner *stringScanner = [NSScanner scannerWithString:noHashString];

  unsigned hex;
  if (![stringScanner scanHexInt:&hex]) return nil;
  int r = (hex >> 16) & 0xFF;
  int g = (hex >> 8) & 0xFF;
  int b = (hex) & 0xFF;

  return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
}

-(void) blurRegionOfInterest:(CGRect) rectOfInterest
{
    //Crop it
    UIImage *croppedImage = [self.baseImageToBeBlurred cropImage:rectOfInterest];
    //Apply a blur effect on it
    UIImage *effectImage = [croppedImage applyLightEffect];
    //Draw the blurred image on the original image
   
   // UIImageView * imageView=(UIImageView*)[self.view viewWithTag:111];
    
    UIImage* newImage = [self.imageView.image drawImage:effectImage inRect:rectOfInterest];
    //Save blurred image into another variable to preserve from unwanted modifications
    self.baseImageToBeBlurred = newImage;
    //Shows it up
    self.imageView.image = self.baseImageToBeBlurred;
}


#pragma mark - Delegate methods

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if(!error)
    {
        [self buildAlert:@"Info" message:@"Image has been saved to Camera Roll"];
    }
    else
    {
        [self buildAlert:@"Error" message:@"Something went wrong when saving it"];
    }
}

-(void) buildAlert:(NSString*) title message:(NSString*) message
{
 
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alert addAction:okButton];
        
        UIViewController* vc = RCTPresentedViewController();
        [vc presentViewController:alert animated:YES completion:nil];
}



@end