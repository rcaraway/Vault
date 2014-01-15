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
#import "RCCloseView.h"
#import "RCNetworking.h"

@interface RCSegueManager () <RCCloseViewDelegate>

@end

static RCSegueManager * sharedManager;

@implementation RCSegueManager


+(void)initialize
{
    sharedManager= [[RCSegueManager alloc] init];
}

+(RCSegueManager *)sharedManager
{
    return sharedManager;
}

-(void)transitionFromPasscodeToList
{
    [[APP rootController] showSearchAnimated:NO];
    [[[APP rootController] listController].view setFrame:CGRectMake(0, 64, 320, [UIScreen mainScreen].bounds.size.height-64)];
    [[APP rootController].view insertSubview:[[APP rootController] listController].view belowSubview:[[APP rootController] passcodeController].view];
    [self openUpPasscodeCompletion:^{
    }];
}

-(void)transitionBackToPasscode
{
    [self closePasscodeCompletion:^{
        [UIView animateWithDuration:.23 animations:^{
            [[[[APP rootController]passcodeController] passwordField] setAlpha:1];
            [[[[APP rootController]passcodeController] passwordField] becomeFirstResponder];
            if (![[RCNetworking sharedNetwork] loggedIn]){
                [[[[APP rootController]passcodeController] loginButton] setAlpha:1];
            }
        }];
    }];
}

#pragma mark - Close View Delegate

-(void)closeView:(RCCloseView *)closeView didFinishWithClosing:(BOOL)closing atOrigin:(CGFloat)xOrigin
{
    if (closing){
        [self transitionBackToPasscode];
    }else{
        [self openPasscodeFromOrigin:xOrigin];
    }
}

-(void)closeView:(RCCloseView *)closeView didChangeXOrigin:(CGFloat)xOrigin
{
    UIView * view = [[APP rootController] passcodeController].view;
    CATransform3D _3Dt = [self tranformForXOrigin:xOrigin];
    view.layer.transform =_3Dt;
}

-(void)closeViewDidBegin:(RCCloseView *)closeView
{
    
}


#pragma mark - Class Convenience

-(CGFloat)adjustedOriginFromX:(CGFloat)xOrigin
{
    CGFloat divider =  1 - xOrigin / [UIScreen mainScreen].bounds.size.width;
    CGFloat angle =3.141f*divider/2.0f;
    CGFloat distance = sinf(angle)*[UIScreen mainScreen].bounds.size.width;
    return distance;
}

-(CGFloat)adjustedAngleForX:(CGFloat)xOrigin
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat sinValue = xOrigin * sinf(3.141/2.0);
    CGFloat finalValue = screenWidth/sinValue;
    return finalValue;
}

-(CATransform3D)tranformForXOrigin:(CGFloat)xOrigin
{
    CGFloat divider =  1 - xOrigin / [UIScreen mainScreen].bounds.size.width;
    CATransform3D _3Dt = CATransform3DIdentity;
    CGFloat rotateValue =3.141f*divider/2.0f;
    _3Dt =CATransform3DMakeRotation(rotateValue,0.0f,-1.0f,0.0f);
      NSLog(@"ORIGIN %f ADJUSTED ANGLE %f", xOrigin, [self adjustedAngleForX:xOrigin]);
    _3Dt.m34 = 0.001f*divider;
    _3Dt.m14 = -0.0015f*divider;
    return _3Dt;
}

-(void)openPasscodeFromOrigin:(CGFloat)xOrigin
{
    UIView * view = [[APP rootController] passcodeController].view;
    view.layer.transform = [self tranformForXOrigin:xOrigin];
    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut  animations:^{
        CATransform3D _3Dt = CATransform3DIdentity;
        _3Dt =CATransform3DMakeRotation(3.141f/2.0f,0.0f,-1.0f,0.0f);
        _3Dt.m34 = 0.001f;
        _3Dt.m14 = -0.0015f;
        view.layer.transform =_3Dt;
    } completion:^(BOOL finished){
    }];
}

-(void)openUpPasscodeCompletion:(void(^)())completion
{
    UIView * view = [[APP rootController] passcodeController].view;
        view.layer.anchorPoint=CGPointMake(0, .5);
        view.center = CGPointMake(view.center.x - view.bounds.size.width/2.0f, view.center.y);
    [UIView animateWithDuration:.6 delay:0 options:UIViewAnimationOptionCurveEaseInOut  animations:^{
        view.transform = CGAffineTransformMakeTranslation(0,0);
        CATransform3D _3Dt = CATransform3DIdentity;
        _3Dt =CATransform3DMakeRotation(3.141f/2.0f,0.0f,-1.0f,0.0f);
        _3Dt.m34 = 0.001f;
        _3Dt.m14 = -0.0015f;
        view.layer.transform =_3Dt;
    } completion:^(BOOL finished){
        if (finished) {
            if (completion){
                 completion();
            }
        }
    }];
}

-(void)closePasscodeCompletion:(void(^)())completion
{
    UIView * view = [[APP rootController] passcodeController].view;
    [[APP rootController].view bringSubviewToFront:view];
    [UIView animateWithDuration:.6 delay:0 options:UIViewAnimationOptionCurveEaseInOut  animations:^{
          CATransform3D _3Dt = CATransform3DIdentity;
        view.layer.transform =_3Dt;
    } completion:^(BOOL finished){
        if (finished) {
            view.layer.anchorPoint=CGPointMake(.5, .5);
            view.center = CGPointMake(view.center.x + view.bounds.size.width/2.0f, view.center.y);
            completion();
        }
    }];
}

@end
