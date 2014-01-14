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
    void (^aBlock)(void);
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
    aBlock = completion;
    [UIView animateWithDuration:.2 animations:^{
        self.transform = CGAffineTransformRotate(self.transform, degreesToRadians(-10));
        self.image = [[UIImage imageNamed:@"vault"] tintedImageWithColorOverlay:[UIColor yellowColor]];
    } completion:^(BOOL finished) {
        CABasicAnimation* rotationAnimation;
        rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 * 1 * .6];
        rotationAnimation.duration = .6;
        rotationAnimation.cumulative = YES;
        rotationAnimation.additive = YES;
        rotationAnimation.repeatCount = 1.0;
        rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [rotationAnimation setDelegate:self];
        [self.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    }];
}

-(void)lockCompletion:(void(^)())completion
{

}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    aBlock();
}



@end
