//
//  RCRootViewController+WebSegues.m
//  Valt
//
//  Created by Rob Caraway on 1/23/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCRootViewController+WebSegues.h"

#import "RCListViewController.h"
#import "RCWebViewController.h"

#import "RCMessageView.h"
#import "RCMainCell.h"
#import "RCTableView.h"

#import "RCPasswordManager.h"
#import "RCPassword.h"
#import "RCAppDelegate.h"
#import "RCListGestureManager.h"

#import "UIColor+RCColors.h"

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

static UIColor * ogColor;

@implementation RCRootViewController (WebSegues)


#pragma mark - Segues

-(void)segueToWebWithPassword:(RCPassword *)password
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self.view endEditing:YES];
    self.currentSideController = self.childViewControllers[0];
    [self.currentSideController removeFromParentViewController];
    [self addChildViewController:self.webController];
    [self setupSnapshotForWeb];
    [self.view addSubview:self.snapshotView];
    UIView * backView = [[UIView  alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [backView setBackgroundColor:[UIColor lightGrayColor]];
    self.webController.password = password;
    [self.currentSideController.view removeFromSuperview];
    if (self.currentSideController == self.listController){
        self.navBar.alpha = 0;
    }else{
    }
    self.webController.view.alpha = 0;
    [self.webController.topView setFrame:CGRectOffset(self.webController.topView.frame, 0, -64)];
    [self.webController.bottomView setFrame:CGRectOffset(self.webController.bottomView.frame, 0, 50)];
    [self.view addSubview:self.webController.view];
    [self.view insertSubview:backView  belowSubview:self.snapshotView];
    [self.view bringSubviewToFront:self.messageView];
    [self.listController hideHintLabels];
    [APP setSwipeRightHint:NO];
    [UIView animateWithDuration:.6 delay:0 usingSpringWithDamping:.7 initialSpringVelocity:.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.webController.view setAlpha:1];
        ogColor = self.view.backgroundColor;
        self.view.backgroundColor = [UIColor lightGrayColor];
        [self.webController.topView setFrame:CGRectOffset(self.webController.topView.frame, 0, 64)];
        [self.webController.bottomView setFrame:CGRectOffset(self.webController.bottomView.frame, 0, -50)];
        CGAffineTransform transform = CGAffineTransformMakeScale(.01, .01);
        self.snapshotView.transform = transform;
    } completion:^(BOOL finished) {
        [backView removeFromSuperview];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
    [self.webController loadPasswordRequest];
}

-(void)closeWeb
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self.webController removeFromParentViewController];
    [self addChildViewController:self.currentSideController];
    self.snapshotView.transform = CGAffineTransformMakeScale(.5, .5);
    [UIView animateWithDuration:.5 delay:0 usingSpringWithDamping:.94 initialSpringVelocity:.8 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.snapshotView.transform = CGAffineTransformIdentity;
        self.webController.view.alpha = 0;
        [self.webController.topView setFrame:CGRectOffset(self.webController.topView.frame, 0, -64)];
        [self.webController.bottomView setFrame:CGRectOffset(self.webController.bottomView.frame, 0, 50)];
    }completion:^(BOOL finished) {
       
        self.view.backgroundColor = ogColor;
        [self.view addSubview:self.currentSideController.view];
        if (self.currentSideController == self.listController){
            self.navBar.alpha = 1;
            [self.view bringSubviewToFront:self.navBar];
        }else{
        }
        [self.view bringSubviewToFront:self.messageView];
        [self.snapshotView removeFromSuperview];
        self.snapshotView = nil;
        [self.webController.webView stopLoading];
        [self.webController.view removeFromSuperview];
        [self.listController.gestureManager resetCellToCenterAtIndexPath:self.listController.gestureManager.webPath];
        [self.webController freeAllMemory];
        self.webController = nil;
        self.currentSideController = nil;

        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}

-(void)setupSnapshotForWeb
{
    self.snapshotView = [[UIScreen mainScreen] snapshotViewAfterScreenUpdates:YES];
    [self.snapshotView setFrame:[UIScreen mainScreen].bounds];
}
-(void)finishedGravityEffects
{
    [self.webController.view removeFromSuperview];
    self.webController.view.transform = CGAffineTransformIdentity;
    self.webController.view.frame = [UIScreen mainScreen].bounds;
    [self.webController.webView stopLoading];
    [self.webController.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
    [self.animator removeBehavior:self.gravityBehavior];
    [self.animator removeBehavior:self.attachmentBehavior];
    self.animator = nil;
}




@end
