//
//  UIImage+filter.m
//  images
//
//  Created by qianhongqiang on 15/7/2.
//  Copyright (c) 2015年 qianhongqiang. All rights reserved.
//

#import "UIImage+filter.h"

typedef void (*FilterCallback)(UInt8 *pixelBuf, UInt32 offset, void *context);

//防止超出255
#define SAFECOLOR(color) MIN(255,MAX(0,color))

@implementation UIImage (filter)

- (UIImage*) gaussianBlur:(NSUInteger)radius
{
    return [self applyConvolve:[UIImage makeKernel:((radius*2)+1)]];
}

- (UIImage*) applyConvolve:(NSArray*)kernel
{
    CGImageRef inImage = self.CGImage;
    CFDataRef inImageDataRef = CGDataProviderCopyData(CGImageGetDataProvider(inImage));
    CFDataRef outImageDataRef = CGDataProviderCopyData(CGImageGetDataProvider(inImage));
    UInt8 *pixelBuffer = (UInt8 *) CFDataGetBytePtr(inImageDataRef);
    UInt8 *outPixelBuffer = (UInt8 *) CFDataGetBytePtr(outImageDataRef);
    
    u_long h = CGImageGetHeight(inImage);
    u_long w = CGImageGetWidth(inImage);
    
    long kh = [kernel count] / 2;
    long kw = [[kernel objectAtIndex:0] count] / 2;
    long i = 0, j = 0, n = 0, m = 0;
    
    for (i = 0; i < h; i++) {
        for (j = 0; j < w; j++) {
            long outIndex = (i*w*4) + (j*4);
            double r = 0, g = 0, b = 0;
            for (n = -kh; n <= kh; n++) {
                for (m = -kw; m <= kw; m++) {
                    if (i + n >= 0 && i + n < h) {
                        if (j + m >= 0 && j + m < w) {
                            double f = [[[kernel objectAtIndex:(n + kh)] objectAtIndex:(m + kw)] doubleValue];
                            if (f == 0) {continue;}
                            long inIndex = ((i+n)*w*4) + ((j+m)*4);
                            r += pixelBuffer[inIndex] * f;
                            g += pixelBuffer[inIndex + 1] * f;
                            b += pixelBuffer[inIndex + 2] * f;
                        }
                    }
                }
            }
            outPixelBuffer[outIndex]     = SAFECOLOR((int)r);
            outPixelBuffer[outIndex + 1] = SAFECOLOR((int)g);
            outPixelBuffer[outIndex + 2] = SAFECOLOR((int)b);
            outPixelBuffer[outIndex + 3] = 255;
        }
    }
    
    CGContextRef ctx = CGBitmapContextCreate(outPixelBuffer,
                                             CGImageGetWidth(inImage),
                                             CGImageGetHeight(inImage),
                                             CGImageGetBitsPerComponent(inImage),
                                             CGImageGetBytesPerRow(inImage),  
                                             CGImageGetColorSpace(inImage),  
                                             CGImageGetBitmapInfo(inImage) 
                                             ); 
    
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);  
    CGContextRelease(ctx);
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CFRelease(inImageDataRef);
    CFRelease(outImageDataRef);
    return finalImage;
    
}

+ (NSArray*) makeKernel:(long)length
{
    NSMutableArray *kernel = [[NSMutableArray alloc] initWithCapacity:10] ;
    long radius = length / 2;
    
    double m = 1.0f/(2*M_PI*radius*radius);
    double a = 2.0 * radius * radius;
    double sum = 0.0;
    
    for (long y = 0-radius; y < length-radius; y++)
    {
        NSMutableArray *row = [[NSMutableArray alloc] initWithCapacity:10];
        for (long x = 0-radius; x < length-radius; x++)
        {
            double dist = (x*x) + (y*y);
            double val = m*exp(-(dist / a));
            [row addObject:[NSNumber numberWithDouble:val]];
            sum += val;
        }
        [kernel addObject:row];
    }
    
    NSMutableArray *finalKernel = [[NSMutableArray alloc] initWithCapacity:length];
    for (int y = 0; y < length; y++)
    {
        NSMutableArray *row = [kernel objectAtIndex:y];
        NSMutableArray *newRow = [[NSMutableArray alloc] initWithCapacity:length];
        for (int x = 0; x < length; x++)
        {
            NSNumber *value = [row objectAtIndex:x];
            [newRow addObject:[NSNumber numberWithDouble:([value doubleValue] / sum)]];
        }
        [finalKernel addObject:newRow];
    }
    return finalKernel;
}


#pragma mark - sharpen
- (UIImage*) sharpen
{
    double dKernel[5][5]={
        {0, 0.0, -0.1,  0.0, 0},
        {0, -0.1, 1.4, -0.1, 0},
        {0, 0.0, -0.1,  0.0, 0}};
    
    NSMutableArray *kernel = [[NSMutableArray alloc] initWithCapacity:5];
    for (int i = 0; i < 5; i++) {
        NSMutableArray *row = [[NSMutableArray alloc] initWithCapacity:5];
        for (int j = 0; j < 5; j++) {
            [row addObject:[NSNumber numberWithDouble:dKernel[i][j]]];
        }
        [kernel addObject:row];
    }
    return [self applyConvolve:kernel];
}

#pragma mark - filter

void filterSepia(UInt8 *pixelBuf, UInt32 offset, void *context)
{
    int r = offset;
    int g = offset+1;
    int b = offset+2;
    
    int red = pixelBuf[r];
    int green = pixelBuf[g];
    int blue = pixelBuf[b];
    
    pixelBuf[r] = SAFECOLOR((red * 0.393) + (green * 0.769) + (blue * 0.189));
    pixelBuf[g] = SAFECOLOR((red * 0.349) + (green * 0.686) + (blue * 0.168));
    pixelBuf[b] = SAFECOLOR((red * 0.272) + (green * 0.534) + (blue * 0.131));
}

- (UIImage*)sepia
{
    return [self applyFilter:filterSepia context:nil];
}

- (UIImage*) applyFilter:(FilterCallback)filter context:(void*)context
{
    CGImageRef inImage = self.CGImage;
    CFDataRef inImageDataRef = CGDataProviderCopyData(CGImageGetDataProvider(inImage));
    UInt8 *pixelBuffer = (UInt8 *) CFDataGetBytePtr(inImageDataRef);
    
    long length = CFDataGetLength(inImageDataRef);
    
    for (int i=0; i<length; i+=4)
    {
        filter(pixelBuffer,i,context);
    }
    
    CGContextRef ctx = CGBitmapContextCreate(pixelBuffer,
                                             CGImageGetWidth(inImage),
                                             CGImageGetHeight(inImage),
                                             CGImageGetBitsPerComponent(inImage),
                                             CGImageGetBytesPerRow(inImage),
                                             CGImageGetColorSpace(inImage),
                                             CGImageGetBitmapInfo(inImage)
                                             ); 
    
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);  
    CGContextRelease(ctx);
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CFRelease(inImageDataRef);
    return finalImage;
    
}

@end
