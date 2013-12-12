//
//  UIImage+memoIcons.m
//  Memorandom
//
//  Created by Robert Caraway on 3/5/13.
//  Copyright (c) 2013 Memorandom. All rights reserved.
//

#import "UIImage+memoIcons.h"

@implementation UIImage (MemoImage)


#pragma mark - Custom Tints

-(UIImage *)tintedImageWithColorOverlay:(UIColor *)tintColor
{
    return [self tintedImageWithColor:tintColor blendingMode:kCGBlendModeOverlay];
}

-(UIImage *)tintedIconWithColor:(UIColor *)color
{
    return [self tintedImageWithColor:color blendingMode:kCGBlendModeDestinationIn];
}


#pragma mark - Tint Convenience

-(UIImage *)whiteGradient
{
    return [self gradientImageColor1:[UIColor whiteColor] color2:[UIColor colorWithWhite:.9 alpha:1]];
}


-(UIImage *)gradientImageColor1:(UIColor *)color1 color2:(UIColor *)color2
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    
    // Create gradient
    NSArray *colors = [NSArray arrayWithObjects:(id)color2.CGColor, (id)color1.CGColor, nil];
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)colors, NULL);
    
    // Apply gradient
    CGContextClipToMask(context, rect, self.CGImage);
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0,0), CGPointMake(0, self.size.height), 0);
    UIImage *gradientImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(space);
    
    return gradientImage;
}

- (UIImage *)tintedImageWithColor:(UIColor *)tintColor blendingMode:(CGBlendMode)blendMode
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    [self drawInRect:bounds blendMode:blendMode alpha:1.0f];
    
    if (blendMode != kCGBlendModeDestinationIn)
        [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0];
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}


@end
