//
//  RCValtView.m
//  Valt
//
//  Created by Robert Caraway on 1/13/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCValtView.h"
#import "UIImage+memoIcons.h"

#define degreesToRadians(x)(x * M_PI / 180)

@implementation RCValtView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.image = [UIImage imageNamed:@"vault"];
        self.userInteractionEnabled = YES;
    }
    return self;
}

-(void)shake
{
     self.image = [[UIImage imageNamed:@"vault"] tintedImageWithColorOverlay:[UIColor redColor]];
    [UIView animateWithDuration:.08 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.transform =CGAffineTransformMakeRotation(degreesToRadians(10));
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.08 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.transform =CGAffineTransformMakeRotation(degreesToRadians(-10));
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.08 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.transform =CGAffineTransformMakeRotation(degreesToRadians(0));
            } completion:^(BOOL finished) {
            }];
        }];
    }];
    [UIView animateWithDuration:.3 animations:^{
        self.image = [UIImage imageNamed:@"vault"];
    }];
}

-(void)openCompletion:(void(^)())completion
{
    [UIView animateWithDuration:.14 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.transform =CGAffineTransformMakeRotation(degreesToRadians(-10));
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.image = [[UIImage imageNamed:@"vault"] tintedImageWithColorOverlay:[UIColor yellowColor]];
            self.transform = CGAffineTransformRotate(self.transform, degreesToRadians(165));
        } completion:^(BOOL finished) {
            completion();
        }];
    }];
}

-(void)lockCompletion:(void(^)())completion
{
    
}



@end
