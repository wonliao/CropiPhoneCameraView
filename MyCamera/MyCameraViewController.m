//
//  MyCameraViewController.m
//  MyCamera
//
//  Created by wonliao on 2014/3/17.
//  Copyright (c) 2014年 wonliao. All rights reserved.
//

#import "MyCameraViewController.h"


@interface MyCameraViewController ()
{
    int screenWidth;
    int screenHeight;
    int imageStartY;
    UIImagePickerController *pickerController;
}
@end

@implementation MyCameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    screenWidth = (int) roundf([UIScreen mainScreen].bounds.size.width);
    screenHeight = (int) roundf([UIScreen mainScreen].bounds.size.height);
    imageStartY = 0;
    
    NSLog(@"screenWidth(%d) screenHeight(%d)", screenWidth, screenHeight);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 顯示照相
- (IBAction)showImagePicker:(id)sender {
    
    pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    pickerController.showsCameraControls = NO;
    
    // 上方遮擋用的黑色方塊 view
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, imageStartY)];
    [pickerController.cameraOverlayView addSubview:topView];
    topView.backgroundColor = [UIColor blackColor];
    
    // 下方遮擋用的黑色方塊 view
    int y = (int) roundf(topView.frame.origin.y +topView.frame.size.height + screenWidth*4/3);    // 3:4
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, y, screenWidth, [UIScreen mainScreen].bounds.size.height - y)];
    [pickerController.cameraOverlayView addSubview:bottomView];
    bottomView.backgroundColor = [UIColor blackColor];

    // 拍照鈕
    UIButton *takePhotoBut = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth/2-50, bottomView.frame.size.height/2 - 25, 100, 50)];
    [bottomView addSubview:takePhotoBut];
    [takePhotoBut setTitle:@"拍照" forState:UIControlStateNormal];
    [takePhotoBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [takePhotoBut addTarget:pickerController action:@selector(takePicture) forControlEvents:UIControlEventTouchUpInside];

    [self presentViewController:pickerController animated:YES completion:nil ];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
        CGImageRef imageRef = nil;

        // iPhone 5 以上
        if(screenHeight >= 568)
        {
            UIGraphicsBeginImageContext(CGSizeMake(640, 852));  // 640 x 852 是 iPhone 5 的相片尺寸
            [originalImage drawInRect: CGRectMake(0, 0, 640, 852)];
            UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            int y = imageStartY*2;
            int w = screenWidth*2;
            int h = (int) roundf(screenWidth*2*4/3);
            CGRect cropRect = CGRectMake(0, y, w, h); // 3:4
            imageRef = CGImageCreateWithImageInRect([smallImage CGImage], cropRect);
        }
        // iPones 4S 以下
        else if(screenHeight <= 480)
        {
            UIGraphicsBeginImageContext(CGSizeMake(720, 960));
            [originalImage drawInRect: CGRectMake(0, 0, 720, 960)];
            UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            int y = imageStartY*2;
            int w = screenWidth*2;
            int h = (int) roundf(screenWidth*2*4/3);
            CGRect cropRect = CGRectMake(40, y, w, h); // 3:4
            imageRef = CGImageCreateWithImageInRect([smallImage CGImage], cropRect);
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenWidth*4/3)];  // 3:4
        imageView.backgroundColor = [UIColor yellowColor];
        [imageView setImage:[UIImage imageWithCGImage:imageRef]];
        
        [self.view addSubview:imageView];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - touch
// 下列處理相機焦點框
-(void)removeFocusView:(UIView*)focusView
{
    [focusView removeFromSuperview];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:pickerController.cameraOverlayView];
    UIView *focusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    focusView.center = point;
    focusView.layer.borderColor = [UIColor redColor].CGColor;
    focusView.layer.borderWidth = 1;
    [pickerController.cameraOverlayView addSubview:focusView];
    
    
    [self performSelector:@selector(removeFocusView:) withObject:focusView afterDelay:0.3];
}


@end
