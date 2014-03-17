CropiPhoneCameraView
====================

3.5-inch 及 4-inch 的 iPhone 皆顯示 3:4 的 camera view

主要處理部分如下：


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
