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

@interface RCValtView ()

@property(nonatomic, strong) UIImageView * handleView;

@end

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
        self.image = [UIImage imageNamed:@"backValt"];
        self.userInteractionEnabled = YES;
        UIImage * valtClosed =[UIImage imageNamed:@"valtClosed"];
        self.handleView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, valtClosed.size.width/2.0, valtClosed.size.height/2.0)];
        self.handleView.center = CGPointMake(frame.size.width/2.0, frame.size.height/2.0);
        [self.handleView setImage:valtClosed];
        self.handleView.layer.anchorPoint = CGPointMake(.5, .378);
        [self addSubview:self.handleView];
        [self addMotionEffects];
    }
    return self;
}

-(void)shake
{
    [UIView animateWithDuration:.05 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.handleView.transform =CGAffineTransformMakeRotation(degreesToRadians(4));
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.05 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.handleView.transform =CGAffineTransformMakeRotation(degreesToRadians(-4));
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.05 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                self.handleView.transform =CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
            }];
        }];
    }];
}

-(void)openWithCompletionBlock:(void(^)())completion
{
    [UIView animateWithDuration:.26 delay:0 options:UIViewAnimationOptionCurveEaseOut  animations:^{
        self.handleView.image = [UIImage imageNamed:@"valtOpen"];
        CGAffineTransform transform = CGAffineTransformConcat(CGAffineTransformRotate(self.transform, degreesToRadians(-60)), CGAffineTransformMakeScale(1.08, 1.08));
        self.handleView.transform = transform;
    }completion:^(BOOL finished) {
        completion();
    }];
}

-(void)openNotAnimated
{
    self.handleView.image = [UIImage imageNamed:@"valtOpen"];
}

-(void)lockWithCompletionBlock:(void(^)())completion
{
    [UIView animateWithDuration:.34 delay:0 usingSpringWithDamping:.9 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut  animations:^{
        self.handleView.image = [UIImage imageNamed:@"valtClosed"];
        self.handleView.transform = CGAffineTransformIdentity;
    }completion:^(BOOL finished) {
        completion();
    }];
}

-(void)addMotionEffects
{
    UIInterpolatingMotionEffect *verticalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.y"
     type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(-6);
    verticalMotionEffect.maximumRelativeValue = @(6);
    UIInterpolatingMotionEffect *horizontalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.x"
     type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(-6);
    horizontalMotionEffect.maximumRelativeValue = @(6);
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    [self addMotionEffect:group];
}



@end
