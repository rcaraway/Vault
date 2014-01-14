//
//  RCSegueManager.m
//  Valt
//
//  Created by Robert Caraway on 1/14/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCSegueManager.h"
#import "RCPasscodeViewController.h"
#import "RCListViewController.h"
#import "RCRootViewController.h"
#import "RCAppDelegate.h"

@implementation RCSegueManager


+(void)transitionFromPasscodeToList
{
    [[APP rootController] showSearchAnimated:NO];
    [[[APP rootController] listController].view setFrame:CGRectMake(0, 64, 320, [UIScreen mainScreen].bounds.size.height-64)];
    [[APP rootController].view insertSubview:[[APP rootController] listController].view belowSubview:[[APP rootController] passcodeController].view];
    [self openUpPasscodeCompletion:^{
    }];
}


#pragma mark - Class Convenience

+(void)openUpPasscodeCompletion:(void(^)())completion
{
    UIView * view = [[APP rootController] passcodeController].view;
    view.layer.anchorPoint=CGPointMake(0, .5);
    view.center = CGPointMake(view.center.x - view.bounds.size.width/2.0f, view.center.y);
    [UIView animateWithDuration:.8 delay:0 options:UIViewAnimationOptionCurveEaseInOut  animations:^{
        view.transform = CGAffineTransformMakeTranslation(0,0);
        CATransform3D _3Dt = CATransform3DIdentity;
        _3Dt =CATransform3DMakeRotation(3.141f/2.0f,0.0f,-1.0f,0.0f);
        _3Dt.m34 = 0.001f;
        _3Dt.m14 = -0.0015f;
        view.layer.transform =_3Dt;
    } completion:^(BOOL finished){
        if (finished) {
            [view removeFromSuperview];
            completion();
        }
    }];
}

@end
