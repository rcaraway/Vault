//
//  UIColor+RCColors.m
//  Valt
//
//  Created by Rob Caraway on 12/11/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "UIColor+RCColors.h"

@implementation UIColor (RCColors)

+(UIColor *)cellUnselectedForeground
{
    return [UIColor colorWithWhite:.95 alpha:1];
}

+(UIColor *)cellSelectedForeground
{
    return [UIColor colorWithWhite:.3 alpha:1];
}

+(UIColor *)listBackground
{
    return [UIColor colorWithWhite:.9 alpha:1];
}

+(UIColor *)dropDownColor
{
    return [UIColor colorWithWhite:.85 alpha:1];
}

@end
