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

#import "RCPasswordManager.h"
#import "RCAppDelegate.h"

#import "RCValtView.h"
#import "RCTableView.h"
#import "RCMessageView.h"

static UIView * passDimView;

@implementation RCRootViewController (passcodeSegues)

-(void)seguePasscodeToList
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self addChildViewController:self.listController];
    [self.passcodeController removeFromParentViewController];
    [[self listController].view setFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-20)];
    [self.view insertSubview:[self listController].view belowSubview:[self passcodeController].view];
    [self.view insertSubview:self.navBar belowSubview:self.passcodeController.view];
    [self.view insertSubview:self.messageView belowSubview:self.passcodeController.view];
    [self openUpPasscodeCompletion:^{
        [self.passcodeController.view removeFromSuperview];
        self.passcodeController.opened = YES;
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}

-(void)returnToPasscodeFromList
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self addChildViewController:self.passcodeController];
    [self.listController removeFromParentViewController];
    [[RCPasswordManager defaultManager] lockPasswordsCompletion:^{
        [self.listController.tableView reloadData];
    }];
    [self transitionBackToPasscodeCompletion:^{
        self.passcodeController.opened = NO;
        [self.listController.view removeFromSuperview];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}

-(void)resetToOpen
{
    [UIView animateWithDuration:.3 animations:^{
        [self movePasscodeToXOrigin:0];
    } completion:^(BOOL finished) {
        [self.passcodeController.view removeFromSuperview];
        self.passcodeController.opened = YES;
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
    if (!view.superview){
        [self.view addSubview:view];
    }
    if (!passDimView){
        [self setupPassDimView];
        passDimView.alpha = xOrigin / [UIScreen mainScreen].bounds.size.width;
    }else
        passDimView.alpha = xOrigin / [UIScreen mainScreen].bounds.size.width;
    [self.view insertSubview:passDimView belowSubview:self.passcodeController.view];
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
    if (IS_IPHONE){
        _3Dt.m34 = 0.001f*divider;
        _3Dt.m14 = -0.0014f*divider;
    }else{
        _3Dt.m34 = .001f*divider;
        _3Dt.m14 = -.000176*divider;
    }
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
    [self setupPassDimView];
    [self.view insertSubview:passDimView belowSubview:self.passcodeController.view];
    view.layer.transform = [self tranformForXOrigin:xOrigin];
    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseOut  animations:^{
        CATransform3D _3Dt = CATransform3DIdentity;
        _3Dt =CATransform3DMakeRotation(3.141f/2.0f,0.0f,-1.0f,0.0f);
        if (IS_IPHONE){
            _3Dt.m34 = 0.001f;
            _3Dt.m14 = -0.0015f;
        }else{
            _3Dt.m34 = 0.001f;
            _3Dt.m14 = -0.000176f;
        }
        view.layer.transform =_3Dt;
    } completion:^(BOOL finished){
        [self didFinishWithDimView];
    }];
}

-(void)openUpPasscodeCompletion:(void(^)())completion
{
    UIView * view = [self passcodeController].view;
    [self setupPassDimView];
    [self.view insertSubview:passDimView belowSubview:self.passcodeController.view];
    view.layer.anchorPoint=CGPointMake(0, .5);
    view.center = CGPointMake(0, view.center.y);
    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseOut  animations:^{
        [self setStatusDarkContentAnimated:YES];
        view.transform = CGAffineTransformMakeTranslation(0,0);
        CATransform3D _3Dt = CATransform3DIdentity;
        _3Dt =CATransform3DMakeRotation(3.141f/2.0f,0.0f,-1.0f,0.0f);
        passDimView.alpha = 0;
        if (IS_IPHONE){
            _3Dt.m34 = 0.001f;
            _3Dt.m14 = -0.0015f;
        }else{
            _3Dt.m34 = 0.001f;
            _3Dt.m14 = -0.000176f;
        }
        view.layer.transform =_3Dt;
    } completion:^(BOOL finished){
        [self didFinishWithDimView];
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
    [self setupPassDimView];
    passDimView.alpha = 0;
    [self.view addSubview:view];
    [self.view insertSubview:passDimView belowSubview:self.passcodeController.view];
    [self.view bringSubviewToFront:view];
    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseOut  animations:^{
        CATransform3D _3Dt = CATransform3DIdentity;
        view.layer.transform =_3Dt;
        passDimView.alpha = 1;
        [self setStatusLightContentAnimated:YES];
    } completion:^(BOOL finished){
        if (finished) {
            [self didFinishWithDimView];
            [self.view bringSubviewToFront:self.messageView];
            view.layer.anchorPoint=CGPointMake(.5, .5);
            view.center = CGPointMake(view.bounds.size.width/2.0f, view.center.y);
            completion();
        }
    }];
}

-(void)setupPassDimView
{
    passDimView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    passDimView.backgroundColor = [UIColor blackColor];

}

-(void)didFinishWithDimView
{
    [passDimView removeFromSuperview];
    passDimView = nil;
}


@end
