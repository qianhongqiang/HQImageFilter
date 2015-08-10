//
//  ViewController.m
//  imageFilter
//
//  Created by qianhongqiang on 15/8/10.
//  Copyright (c) 2015年 qianhongqiang. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+filter.h"

#import <CoreImage/CoreImage.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *modeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageFilterImage;
@property (nonatomic, assign) BOOL useCoreImage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)onGaussianBlur:(UIButton *)sender {
    if (self.useCoreImage) {
        UIImage *needSepia = [UIImage imageNamed:@"beauty"];
        CIImage *beginImage = [[CIImage alloc] initWithCGImage:needSepia.CGImage];
        
        CIFilter *filter = [CIFilter filterWithName:@"CIGlassDistortion"];
        [filter setValue:beginImage forKey:kCIInputImageKey];
        [filter setValue:@(100) forKey:@"inputScale"];
        
        CIImage *outputImage = [filter outputImage];
        CIContext *context = [CIContext contextWithOptions: nil];
        CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
        UIImage *newImg = [UIImage imageWithCGImage:cgimg];
        self.imageFilterImage.image = newImg;
        
        CGImageRelease(cgimg);
        
    }else {
        UIImage *needFilterImage = [UIImage imageNamed:@"beauty"];
        UIImage *filteredImage = [needFilterImage gaussianBlur:3];
        self.imageFilterImage.image = filteredImage;
    }
}

- (IBAction)onSharpenFilter:(UIButton *)sender {
    if (self.useCoreImage) {
        UIImage *needSepia = [UIImage imageNamed:@"sharpen"];
        CIImage *beginImage = [[CIImage alloc] initWithCGImage:needSepia.CGImage];
        
        CIFilter *filter = [CIFilter filterWithName:@"CISharpenLuminance"];
        [filter setValue:beginImage forKey:kCIInputImageKey];
        [filter setValue:@(0.8) forKey:@"inputSharpness"];
        
        CIImage *outputImage = [filter outputImage];
        CIContext *context = [CIContext contextWithOptions: nil];
        CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
        UIImage *newImg = [UIImage imageWithCGImage:cgimg];
        self.imageFilterImage.image = newImg;
        
        CGImageRelease(cgimg);
    }else {
        UIImage *needSharpen = [UIImage imageNamed:@"sharpen"];
        UIImage *filteredImage = [needSharpen sharpen];
        self.imageFilterImage.image = filteredImage;
    }
}

- (IBAction)onSepiaFilter:(UIButton *)sender {
    if (self.useCoreImage) {
        UIImage *needSepia = [UIImage imageNamed:@"sharpen"];
        CIImage *beginImage = [[CIImage alloc] initWithCGImage:needSepia.CGImage];
        
        CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone"];
        [filter setValue:beginImage forKey:kCIInputImageKey];
        [filter setValue:@(0.8) forKey:@"inputIntensity"];
        
        CIImage *outputImage = [filter outputImage];
        CIContext *context = [CIContext contextWithOptions: nil];
        CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
        UIImage *newImg = [UIImage imageWithCGImage:cgimg];
        self.imageFilterImage.image = newImg;
        
        CGImageRelease(cgimg);
    }else {
        UIImage *needSepia = [UIImage imageNamed:@"sharpen"];
        UIImage *filteredImage = [needSepia sepia];
        self.imageFilterImage.image = filteredImage;
    }
}

- (IBAction)onReset:(UIButton *)sender {
    self.imageFilterImage.image = [UIImage imageNamed:@"beauty"];
}
- (IBAction)onResetSharpen:(UIButton *)sender {
    self.imageFilterImage.image = [UIImage imageNamed:@"sharpen"];
}
- (IBAction)onResetSepia:(UIButton *)sender {
    self.imageFilterImage.image = [UIImage imageNamed:@"sharpen"];
}

- (IBAction)onModeChangeClick:(UIButton *)sender {
    _useCoreImage = !_useCoreImage;
}

-(void)setUseCoreImage:(BOOL)useCoreImage {
    _useCoreImage = useCoreImage;
    self.modeLabel.text = _useCoreImage ? @"使用CI滤镜" : @"使用HQ滤镜";
}

@end
