#import <React/RCTViewManager.h>
#import "RCTEventDispatcher.h"
#import "UIImageView+CoordinateTransform.h"
#import "UIImage+Common.h"
#import "UIImage+ImageEffects.h"
#import "PureLayout.h"
typedef enum {
    DrawBlurContinuously,
    DrawBlurInARect
} InputMethod;

@interface ImageBlurViewManager: RCTViewManager

@property (strong, nonatomic) NSMutableArray* drawRectArray; //of CGRect
@property (strong, nonatomic) UIImage* baseImageToBeBlurred;
@property (strong, nonatomic) UIImage* tempImage;
@property (strong, nonatomic) UIImageView* imageView;
@property (strong, nonatomic) NSString *theNewFilePath;
@property (nonatomic, copy)  RCTDirectEventBlock onEnd;
@property (nonatomic) InputMethod inputMethod;

@end

@implementation ImageBlurViewManager

#define IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define DEFAULT_ROI_WIDTH   80
#define DEFAULT_ROI_HEIGHT   80

RCT_EXPORT_MODULE(ImageBlurView)


- (UIView *)view
{
    UIView *outerView = [[UIView alloc] init];

//    self.imageView = [[UIImageView alloc] init];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(14, UIScreen.mainScreen.bounds.size.height/2 - (UIScreen.mainScreen.bounds.size.width - 40)/2, UIScreen.mainScreen.bounds.size.width - 40 , UIScreen.mainScreen.bounds.size.width - 40)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;

//    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(UIScreen.mainScreen.bounds.size.width/2 - 300/2, UIScreen.mainScreen.bounds.size.height/2 - 300/2, 300, 300)];
    [self.imageView setUserInteractionEnabled:YES];
    [outerView addSubview:self.imageView];
    
//    [self.imageView configureForAutoLayout];
//    [self.imageView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20];
//    [self.imageView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:90];
//    [self.imageView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
//    [self.imageView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:20];
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
      
    _theNewFilePath = NULL;
    self.inputMethod = DrawBlurContinuously;

    return outerView;
}

RCT_CUSTOM_VIEW_PROPERTY(imagePath, NSString, UIView)
{
    if(json!=NULL){
        self.tempImage = [UIImage imageWithContentsOfFile:json];
        @autoreleasepool {
            self.baseImageToBeBlurred = self.tempImage;
            [self.imageView setImage: self.tempImage];
        }
        _theNewFilePath = NULL;
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [panGestureRecognizer setDelegate:nil];
        [self.imageView addGestureRecognizer:panGestureRecognizer];

    }else{
        [self buildAlert:@"Error" message:@"Image not available at path"];
    }
}


-(NSString*)getPathForFile:(NSString*)searchFilename {
    
    NSString *filePATH = @"";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSDirectoryEnumerator *direnum = [[NSFileManager defaultManager] enumeratorAtPath:documentsDirectory];

    NSString *documentsSubpath;
    while (documentsSubpath = [direnum nextObject])
    {
      if ([documentsSubpath.lastPathComponent isEqual:searchFilename]) {
          filePATH = documentsSubpath;
          NSLog(@"found %@", documentsSubpath);
          break;
      }

    }
        
    return filePATH;
}

//https://doc.ebichu.cc/react-native/releases/0.41/docs/native-modules-ios.html
- (void)buttonSavePressed:(UIButton *)button {
     NSLog(@"Save Button Pressed");
    // UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
     NSData *data = UIImageJPEGRepresentation(self.imageView.image,1.0);
    _theNewFilePath = [self persistFile:data];
     [self.bridge.eventDispatcher sendAppEventWithName:@"BlurImageEvent" body:@{@"path": _theNewFilePath}];
}

- (void)buttonResetPressed:(UIButton *)button {
        NSLog(@"Reset Button Pressed");
    self.imageView.image = nil;
    self.baseImageToBeBlurred = nil;
    self.baseImageToBeBlurred = UIImage.new;
    self.imageView.image = self.tempImage;
  }

- (NSString*) getTmpDirectory {
    NSString *TMP_DIRECTORY = @"react-native-image-blur-view/";
    NSString *tmpFullPath = [NSTemporaryDirectory() stringByAppendingString:TMP_DIRECTORY];
    BOOL isDir;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:tmpFullPath isDirectory:&isDir];
    if (!exists) {
        [[NSFileManager defaultManager] createDirectoryAtPath: tmpFullPath
                                  withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return tmpFullPath;
}


- (NSString*) persistFile:(NSData*)data {
    // create temp file
    NSString *tmpDirFullPath = [self getTmpDirectory];
    NSString *filePath = [tmpDirFullPath stringByAppendingString:[[NSUUID UUID] UUIDString]];
    filePath = [filePath stringByAppendingString:@".jpg"];
    
    // save cropped file
    BOOL status = [data writeToFile:filePath atomically:YES];
    if (!status) {
        return nil;
    }
    return filePath;
}


- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint pointTranslation = [recognizer locationInView:self.imageView];
    CGPoint imageTouchPoint = [self.imageView pixelPointFromViewPoint:pointTranslation];
    if(!CGPointEqualToPoint(imageTouchPoint, CGPointZero)){
        NSLog(@"%s It's inside image's bounds",__PRETTY_FUNCTION__);
        //Extract the region of interest of that image
        CGRect rectOfInterest = {imageTouchPoint, CGSizeMake(DEFAULT_ROI_WIDTH, DEFAULT_ROI_HEIGHT)};
        
        if(self.inputMethod == DrawBlurContinuously)
        {
            // Blur
            [self blurRegionOfInterest:rectOfInterest];
            
        }
        else if (self.inputMethod == DrawBlurInARect)
        {

            switch (recognizer.state) {
                case UIGestureRecognizerStateBegan:
                    self.drawRectArray = [[NSMutableArray alloc] init];
                case UIGestureRecognizerStateChanged:
                {
                    [self.drawRectArray addObject:[NSValue valueWithCGRect:rectOfInterest]];
                    rectOfInterest = [self calculateUnionRectOfInterest];
                    // Draw area selection overlay
                    [self blurRegionOfInterest:rectOfInterest];
//                    [self drawOverlayOnRegionOfInterest:rectOfInterest];
                    break;
                }
                case UIGestureRecognizerStateEnded:
                {
                    rectOfInterest = [self calculateUnionRectOfInterest];
                    // Blur
                    [self blurRegionOfInterest:rectOfInterest];
                    break;
                }
                default:
                    NSLog(@"Touch is outside image's bounds");
                    break;
            }
        }
    }else{
        NSLog(@"%s It's outside image's bounds",__PRETTY_FUNCTION__);
    }
    //Check if it's within UIImage's bounds
//    if(!CGPointEqualToPoint(imageTouchPoint, CGPointZero)){
//        //NSLog(@"%s It's inside image's bounds",__PRETTY_FUNCTION__);
//        //Extract the region of interest of that image
//        CGRect rectOfInterest = {imageTouchPoint, CGSizeMake(DEFAULT_ROI_WIDTH, DEFAULT_ROI_HEIGHT)};
//        [self blurRegionOfInterest:rectOfInterest];
//    }else{
//        NSLog(@"Touch is outside image's bounds");
//    }
}
-(CGRect) calculateUnionRectOfInterest
{
    //Retrieves the extreme points from each coordinate (x,y)
    CGFloat minx = [[self.drawRectArray valueForKeyPath:@"@min.x"] floatValue];
    CGFloat miny = [[self.drawRectArray valueForKeyPath:@"@min.y"] floatValue];
    CGFloat maxx = [[self.drawRectArray valueForKeyPath:@"@max.x"] floatValue];
    CGFloat maxy = [[self.drawRectArray valueForKeyPath:@"@max.y"] floatValue];
    
    // Calculate Rect we're going to blur later
    CGRect rectOfInterest = CGRectMake(minx, miny, DEFAULT_ROI_WIDTH + (maxx - minx), DEFAULT_ROI_HEIGHT + (maxy - miny));
    
    if(rectOfInterest.size.width < DEFAULT_ROI_WIDTH)
    {
        // Vertical Rect
        rectOfInterest = CGRectMake(minx, miny, DEFAULT_ROI_WIDTH, maxy - miny);
    }
    else if (rectOfInterest.size.height < DEFAULT_ROI_HEIGHT)
    {
        // Horizontal Rect
        rectOfInterest = CGRectMake(minx, miny, maxx - minx, DEFAULT_ROI_HEIGHT);
    }
    
    return rectOfInterest;
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
    UIImage *effectImage = [croppedImage applyCustomEffect];
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
