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

+(UIColor *)valtPurple
{
    return [UIColor colorWithRed:178.0/255.0 green:103.0/255.0 blue:250.0/255.0 alpha:1];
}

+(UIColor *)listBackground
{
    return [UIColor colorWithRed:227.0/255.0 green:229.0/255.0 blue:234.0/255.0 alpha:1];
}

+(UIColor *)dropDownColor
{
    return [UIColor colorWithWhite:.85 alpha:1];
}

+(UIColor *)passcodeBackground
{
    return [UIColor colorWithRed:30.0/255.0 green:30.0/255.0 blue:30.0/255.0 alpha:1];
}

+(UIColor *)passcodeForeground
{
    return [UIColor colorWithRed:96.0/255.0 green:96.0/255.0 blue:96.0/255.0 alpha:1];
}


#pragma mark -  Cell States

+(UIColor *)browserGreen
{
    return [UIColor colorWithRed:0 green:178.0/255.0 blue:95.0/255.0 alpha:1];
}

+(UIColor *)deleteRed
{
    return [UIColor redColor];
}

#pragma mark - Menu Colors

+(UIColor *)myValtColor
{
    return [UIColor colorWithRed:200.0/255.0 green:115.0/255.0 blue:232.0/255.0 alpha:1];
}

+(UIColor *)goPlatinumColor
{
    return [UIColor colorWithRed:255.0/255.0 green:70.0/255.0 blue:0.0/255.0 alpha:1];
}

+(UIColor *)lockVaultColor
{
     return [UIColor colorWithRed:157.0/255.0 green:152.0/255.0 blue:0.0/255.0 alpha:1];
}

+(UIColor *)aboutColor
{
     return [UIColor colorWithRed:0.0/255.0 green:174.0/255.0 blue:77.0/255.0 alpha:1];
}

+(UIColor *)tweetColor
{
     return [UIColor colorWithRed:0.0/255.0 green:176.0/255.0 blue:240.0/255.0 alpha:1];
}

+(UIColor *)contactSupportColor
{
     return [UIColor colorWithRed:216.0/255.0 green:115.0/255.0 blue:166.0/255.0 alpha:1];
}



@end
