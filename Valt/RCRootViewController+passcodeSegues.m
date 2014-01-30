//
//  RCRootViewController+passcodeSegues.m
//  Valt
//
//  Created by Robert Caraway on 1/16/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCRootViewController+passcodeSegues.h"
#import "RCListViewController.h"
#import "RCPasscodeViewController.h"
#import "RCSearchViewController.h"
#import "RCPasswordManager.h"
#import "RCNetworking.h"
#import "RCValtView.h"
#import "RCMessageView.h"

@implementation RCRootViewController (passcodeSegues)

-(void)seguePasscodeToList
{
    [self addChildViewController:self.listController];
    [self.passcodeController removeFromParentViewController];
    [[self listController].view setFrame:CGRectMake(0, 20, 320, [UIScreen mainScreen].bounds.size.height-20)];
    [self.view insertSubview:[self listController].view belowSubview:[self passcodeController].view];
    [self.view insertSubview:self.navBar belowSubview:self.passcodeController.view];
    [self.view insertSubview:self.messageView belowSubview:self.passcodeController.view];
    [self openUpPasscodeCompletion:^{
    }];
}

-(void)returnToPasscodeFromList
{
    [self addChildViewController:self.passcodeController];
    [self.listController removeFromParentViewController];
    [[RCPasswordManager defaultManager] lockPasswordsCompletion:^{
    }];
    [self transitionBackToPasscodeCompletion:^{
        [self.listController.view removeFromSuperview];
    }];
}

#pragma mark - Transition

-(void)transitionBackToPasscodeCompletion:(void(^)())completion
{
    [self closePasscodeCompletion:^{
        [[[self passcodeController] passwordField] setText:@""];
        [UIView animateWithDuration:.23 animations:^{
            [[[self passcodeController] fieldBackView] setAlpha:1];
            [[[self passcodeController] passwordField] becomeFirstResponder];
            if (![[RCNetworking sharedNetwork] loggedIn]){
                [[[self passcodeController] loginButton] setAlpha:1];
            }
            [[[self passcodeController] valtView] lockWithCompletionBlock:^{
            }];;
            if (completion)
                completion();
        }];
    }];
}

-(void)movePasscodeToXOrigin:(CGFloat)xOrigin
{
    UIView * view = [self passcodeController].view;
    CATransform3D _3Dt = [self tranformForXOrigin:xOrigin];
    view.layer.transform =_3Dt;
}

#pragma mark - Convenience

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
    CGFloat finalValue = xOrigin/screenWidth;
    CGFloat angle = (M_PI/2.0) - asinhf(finalValue);
    return angle;
}

-(CATransform3D)tranformForXOrigin:(CGFloat)xOrigin
{
    CATransform3D _3Dt = CATransform3DIdentity;
    CGFloat divider =  1 - xOrigin/[UIScreen mainScreen].bounds.size.width;
    CGFloat rotateValue =3.141f*divider/2.0f;
    _3Dt =CATransform3DMakeRotation(rotateValue,0.0f,-1.0f,0.0f);
    _3Dt.m34 = 0.001f*divider;
    _3Dt.m14 = -0.0014f*divider;
    return _3Dt;
}


-(void)showPasscodeHint
{
    UIView * view = [self passcodeController].view;
    [UIView animateWithDuration:.2 animations:^{
        CATransform3D transform = [self tranformForXOrigin:20];
        view.layer.transform = transform;
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut  animations:^{
            CATransform3D _3Dt = CATransform3DIdentity;
            _3Dt =CATransform3DMakeRotation(3.141f/2.0f,0.0f,-1.0f,0.0f);
            _3Dt.m34 = 0.001f;
            _3Dt.m14 = -0.0015f;
            view.layer.transform =_3Dt;
        } completion:^(BOOL finished){
        }];
    }];
}

-(void)openPasscodeFromOrigin:(CGFloat)xOrigin
{
    UIView * view = [self passcodeController].view;
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
    UIView * view = [self passcodeController].view;
    view.layer.anchorPoint=CGPointMake(0, .5);
    view.center = CGPointMake(view.center.x - view.bounds.size.width/2.0f, view.center.y);
    [UIView animateWithDuration:.6 delay:0 options:UIViewAnimationOptionCurveEaseInOut  animations:^{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
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
    UIView * view = [self passcodeController].view;
    [self.view bringSubviewToFront:view];
    [UIView animateWithDuration:.6 delay:0 options:UIViewAnimationOptionCurveEaseInOut  animations:^{
        CATransform3D _3Dt = CATransform3DIdentity;
        view.layer.transform =_3Dt;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    } completion:^(BOOL finished){
        if (finished) {
            view.layer.anchorPoint=CGPointMake(.5, .5);
            view.center = CGPointMake(view.center.x + view.bounds.size.width/2.0f, view.center.y);
            completion();
        }
    }];
}


@end
