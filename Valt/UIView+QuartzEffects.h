//
//  UIView+QuartzEffects.h
//  Memorandom
//
//  Created by Robert Caraway on 12/27/12.
//  Copyright (c) 2012 Memorandom. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView (QuartzEffects)

-(void)setShadowWidth:(CGFloat)width offset:(CGSize)point color:(UIColor *)color opacity:(CGFloat)opacity drawPath:(BOOL)shouldDrawPath;
-(void)setBorderWidth:(CGFloat)width withColor:(UIColor *)color;
-(void)setShouldRasterize;
-(void)setCornerRadius:(CGFloat)cornerRadius;

@end
