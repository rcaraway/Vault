//
//  UIView+QuartzEffects.m
//  Memorandom
//
//  Created by Robert Caraway on 12/27/12.
//  Copyright (c) 2012 Memorandom. All rights reserved.
//

#import "UIView+QuartzEffects.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (QuartzEffects)

-(void)setShadowWidth:(CGFloat)width offset:(CGSize)point color:(UIColor *)color opacity:(CGFloat)opacity drawPath:(BOOL)shouldDrawPath
{
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowOffset = point;
    self.layer.shadowOpacity = opacity;
    self.layer.shadowRadius = width;
    if (shouldDrawPath) self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
}

-(void)setBorderWidth:(CGFloat)width withColor:(UIColor *)color
{
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = width;
}

-(void)setCornerRadius:(CGFloat)cornerRadius
{
    self.layer.cornerRadius = cornerRadius;
}

-(void)setShouldRasterize
{
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
}

@end
