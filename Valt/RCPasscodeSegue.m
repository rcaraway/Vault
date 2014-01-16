//
//  RCSegueManager.m
//  Valt
//
//  Created by Robert Caraway on 1/14/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCPasscodeSegue.h"
#import "RCPasscodeViewController.h"
#import "RCListViewController.h"
#import "RCRootViewController.h"
#import "RCAppDelegate.h"
#import "RCCloseView.h"
#import "RCValtView.h"
#import "RCSearchViewController.h"
#import "RCNetworking.h"
#import "RCPasswordManager.h"

@interface RCPasscodeSegue () <RCCloseViewDelegate>

@end


@implementation RCPasscodeSegue


#pragma mark - Life Cycle

-(id)initWithRootController:(RCRootViewController *)root
{
    self = [super initWithRootController:root];
    if (self){
        [self addNotifications];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(segueToList) name:valtViewDidOpen object:nil];
}


#pragma mark - Segues

-(void)segueToList
{
    [self.rootVC addChildViewController:self.rootVC.listController];
    [self.rootVC.passcodeController removeFromParentViewController];
    [[APP rootController] showSearchAnimated:NO];
    [[[APP rootController] listController].view setFrame:CGRectMake(0, 64, 320, [UIScreen mainScreen].bounds.size.height-64)];
    [[APP rootController].view insertSubview:[[APP rootController] listController].view belowSubview:[[APP rootController] passcodeController].view];
    [self openUpPasscodeCompletion:^{
    }];
}

-(void)returnToPasscodeFromList
{
    [self.rootVC addChildViewController:self.rootVC.passcodeController];
    [self.rootVC.listController removeFromParentViewController];
    [[RCPasswordManager defaultManager] lockPasswordsCompletion:^{
    }];
    [self transitionBackToPasscodeCompletion:^{
        [self.rootVC.listController.view removeFromSuperview];
    }];
}

-(void)returnToPasscodeFromSearch
{
    [self.rootVC addChildViewController:self.rootVC.passcodeController];
    [self.rootVC.searchController removeFromParentViewController];
    [[RCPasswordManager defaultManager] lockPasswordsCompletion:^{
    }];
    [self transitionBackToPasscodeCompletion:^{
        [self.rootVC.searchController.view removeFromSuperview];
    }];
}


#pragma mark - Transition

-(void)transitionBackToPasscodeCompletion:(void(^)())completion
{
    [self closePasscodeCompletion:^{
        [[[[APP rootController]passcodeController] passwordField] setText:@""];
        [UIView animateWithDuration:.23 animations:^{
            [[[[APP rootController]passcodeController] fieldBackView] setAlpha:1];
            [[[[APP rootController]passcodeController] passwordField] becomeFirstResponder];
            if (![[RCNetworking sharedNetwork] loggedIn]){
                [[[[APP rootController]passcodeController] loginButton] setAlpha:1];
            }
            [[[[APP rootController] passcodeController] valtView] lock];
            if (completion)
                completion();
        }];
    }];
}

-(void)transitionFromSearchToList
{
    UIView * searchView = [[[APP rootController] searchController] view];
    UIView * listView = [[[APP rootController] listController]view];
    [UIView transitionFromView:searchView toView:listView duration:.3 options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
        [searchView removeFromSuperview];
    }];
}

-(void)transitionFromListToSearch
{
    UIView * searchView = [[[APP rootController] searchController] view];
    UIView * listView = [[[APP rootController] listController]view];
    [UIView transitionFromView:searchView toView:listView duration:.3 options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
        [searchView removeFromSuperview];
    }];
}

#pragma mark - Close View Delegate

-(void)closeView:(RCCloseView *)closeView didFinishWithClosing:(BOOL)closing atOrigin:(CGFloat)xOrigin
{
    if (closing){
        [self returnToPasscodeFromList];
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

-(void)closeViewDidTap:(RCCloseView *)closeView
{
    [self showPasscodeHint];
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
    UIView * view = [[APP rootController] passcodeController].view;
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
            [[[APP rootController] closeView] setFrame:CGRectMake(0, 30, 28, 28)];
            completion();
        }
    }];
}

@end
