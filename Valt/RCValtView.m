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
{
    CABasicAnimation * open;
    CABasicAnimation * close;
    void (^doneBlock)();
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.image = [UIImage imageNamed:@"vault"];
        self.userInteractionEnabled = YES;
        self.layer.anchorPoint = CGPointMake(.5, .646);
    }
    return self;
}

-(void)shake
{
    self.image = [[UIImage imageNamed:@"vault"] tintedImageWithColorOverlay:[UIColor redColor]];
    [UIView animateWithDuration:.05 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.transform =CGAffineTransformMakeRotation(degreesToRadians(6));
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.05 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.transform =CGAffineTransformMakeRotation(degreesToRadians(-6));
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.05 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.transform =CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
            }];
        }];
    }];
    [UIView animateWithDuration:.3 animations:^{
        self.image = [UIImage imageNamed:@"vault"];
    }];
}

-(void)openWithCompletionBlock:(void(^)())completion
{
    [UIView animateWithDuration:.34 delay:0 usingSpringWithDamping:.677 initialSpringVelocity:.1 options:UIViewAnimationOptionCurveEaseInOut  animations:^{
        self.image = [[UIImage imageNamed:@"vault"] tintedImageWithColorOverlay:[UIColor yellowColor]];
        CGAffineTransform tf = CGAffineTransformConcat(CGAffineTransformRotate(self.transform, degreesToRadians(-60)), CGAffineTransformMakeScale(1.14, 1.14));
        self.transform = tf;
    }completion:^(BOOL finished) {
        completion();
    }];
}


-(void)openNotAnimated
{
    self.image = [[UIImage imageNamed:@"vault"] tintedImageWithColorOverlay:[UIColor yellowColor]];
}

-(void)lockWithCompletionBlock:(void(^)())completion
{
    [UIView animateWithDuration:.4 delay:0 usingSpringWithDamping:.677 initialSpringVelocity:.1 options:UIViewAnimationOptionCurveEaseInOut  animations:^{
        self.image = [UIImage imageNamed:@"vault"];
        self.transform = CGAffineTransformIdentity;
    }completion:^(BOOL finished) {
        completion();
    }];
}




@end
