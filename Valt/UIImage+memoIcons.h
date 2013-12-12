//
//  UIImage+memoIcons.h
//  Memorandom
//
//  Created by Robert Caraway on 3/5/13.
//  Copyright (c) 2013 Memorandom. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImage (MemoImage)


-(UIImage *)tintedImageWithColorOverlay:(UIColor *)tintColor;
-(UIImage *)tintedIconWithColor:(UIColor *)color;
-(UIImage *)gradientImageColor1:(UIColor *)color1 color2:(UIColor *)color2;


@end
