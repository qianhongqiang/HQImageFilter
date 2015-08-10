//
//  UIImage+filter.h
//  images
//
//  Created by qianhongqiang on 15/7/2.
//  Copyright (c) 2015年 qianhongqiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (filter)

- (UIImage*) gaussianBlur:(NSUInteger)radius;

- (UIImage*) sharpen;

- (UIImage*) sepia;

@end
