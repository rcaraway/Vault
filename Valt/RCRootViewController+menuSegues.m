//
//  RCRootViewController+menuSegues.m
//  Valt
//
//  Created by Rob Caraway on 1/24/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCRootViewController+menuSegues.h"
#import "RCListViewController.h"
#import "RCMenuViewController.h"
#import "RCListGestureManager.h"
#import "UIView+QuartzEffects.h"
#import <objc/runtime.h>

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

static void * LatestPointKey;

@implementation RCRootViewController (menuSegues)

#pragma mark - Segue actions

-(void)segueToMenu
{
    if (!self.menuController){
        self.menuController = [[RCMenuViewController  alloc] initWithNibName:nil bundle:nil];
    }
    [self setupSnapshot];
    [self addChildViewController:self.menuController];
    [self.view addSubview:self.menuController.view];
    [self.menuController.view addSubview:self.snapshotView];
    if (self.childViewControllers.count > 0){
        self.currentSideController = self.childViewControllers[0];
        [self.currentSideController removeFromParentViewController];
    }
    [self setNeedsStatusBarAppearanceUpdate];
    [UIView animateWithDuration:.46 delay:0 usingSpringWithDamping:.8 initialSpringVelocity:.8 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGAffineTransform tranform =CGAffineTransformTranslate(CGAffineTransformIdentity, -280, 0);
        self.snapshotView.transform = tranform;
    } completion:^(BOOL finished) {
    }];
}

-(void)dragMainToXOrigin:(CGFloat)xOrigin
{
    CGAffineTransform tranform =CGAffineTransformTranslate(CGAffineTransformIdentity, xOrigin, 0);
    self.navBar.transform = tranform;
    self.listController.view.transform = tranform;
}

-(void)closeMenu
{
    self.currentSideController = self.listController;
    [self.listController.view setFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64)];
    UIView * subSnapView = [self.listController.view snapshotViewAfterScreenUpdates:YES];
    [subSnapView setFrame:self.listController.view.frame];
    [self.snapshotView addSubview:subSnapView];
    [self setNavBarMain];;
    [self.snapshotView addSubview:self.navBar];
    
    [UIView animateWithDuration:.46 delay:0 usingSpringWithDamping:.8 initialSpringVelocity:.8 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.snapshotView.transform =CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self.menuController removeFromParentViewController];
        [self.menuController.view removeFromSuperview];
        [self addChildViewController:self.currentSideController];
        [self.view addSubview:self.currentSideController.view];
        [self.view addSubview:self.navBar];
        self.currentSideController = nil;
        [self setNeedsStatusBarAppearanceUpdate];
        [self.snapshotView removeFromSuperview];
        self.snapshotView = nil;
        [self.menuController changeFeelgoodMessage];
    }];
}

-(void)goHome
{
    UIViewController * current = self.childViewControllers[0];
    [current removeFromParentViewController];
    [self addChildViewController:self.listController];
    UIView * dimview = [[UIView alloc] initWithFrame:self.listController.view.frame];
    [self.view insertSubview:self.listController.view belowSubview:current.view];
    self.listController.view.transform = CGAffineTransformMakeScale(.9, .9);
    
    UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    CGPoint squareCenterPoint = CGPointMake(CGRectGetMaxX(current.view.frame), CGRectGetMidY(current.view.frame));
    UIOffset attachmentPoint = UIOffsetMake(CGRectGetMinX(current.view.frame), CGRectGetMaxY(current.view.frame));
    UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:current.view offsetFromCenter:attachmentPoint attachedToAnchor:squareCenterPoint];
    [animator addBehavior:attachmentBehavior];
    self.attachmentBehavior = attachmentBehavior;
    UIGravityBehavior *gravityBeahvior = [[UIGravityBehavior alloc] initWithItems:@[current.view]];
    gravityBeahvior.magnitude = 3;
    gravityBeahvior.angle = DEGREES_TO_RADIANS(100);
    [animator addBehavior:gravityBeahvior];
    
    self.gravityBehavior = gravityBeahvior;
    self.animator = animator;
    [self performSelector:@selector(finishedAnimatedGraviry:) withObject:current afterDelay:.7];
    [self setNavBarMain];
    

    dimview.backgroundColor = [UIColor blackColor];
    dimview.alpha = .5;
    [self.view insertSubview:dimview belowSubview:current.view];
    [UIView animateWithDuration:.6 animations:^{
        [dimview setAlpha:0];
        self.listController.view.transform = CGAffineTransformIdentity;
        
    }completion:^(BOOL finished) {
        [dimview removeFromSuperview];
    }];
}

-(void)finishedAnimatedGraviry:(UIViewController *)controller
{
    [controller.view removeFromSuperview];
    controller.view.transform = CGAffineTransformIdentity;
    [self.animator removeBehavior:self.gravityBehavior];
    [self.animator removeBehavior:self.attachmentBehavior];
    self.animator = nil;
}

-(void)closeToNewViewController:(UIViewController *)controller title:(NSString *)title
{
    self.currentSideController = controller;
    [controller.view setFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64)];
    UIView * subSnapView = [controller.view snapshotViewAfterScreenUpdates:YES];
    [subSnapView setFrame:controller.view.frame];
    [self.snapshotView addSubview:subSnapView];
    [self setNavBarAlternateWithTitle:title];
    [self.snapshotView addSubview:self.navBar];
    [UIView animateWithDuration:.46 delay:0 usingSpringWithDamping:.8 initialSpringVelocity:.8 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.snapshotView.transform =CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self.menuController removeFromParentViewController];
        [self.menuController.view removeFromSuperview];
        [self addChildViewController:self.currentSideController];
        [self.view addSubview:self.navBar];
        [self.view addSubview:self.currentSideController.view];
        [self.view bringSubviewToFront:self.navBar];
        self.currentSideController = nil;
        [self setNeedsStatusBarAppearanceUpdate];
        [self.snapshotView removeFromSuperview];
        self.snapshotView = nil;
        [self.menuController changeFeelgoodMessage];
    }];
}


#pragma mark - Snapshot

-(void)setupSnapshot
{
    self.snapshotView = [[UIScreen mainScreen] snapshotViewAfterScreenUpdates:YES];
    [self.snapshotView setFrame:[UIScreen mainScreen].bounds];
    self.snapTap = [[UITapGestureRecognizer  alloc] initWithTarget:self action:@selector(snapshotTapped)];
    [self.snapshotView addGestureRecognizer:self.snapTap];
    self.snapPan = [[UIPanGestureRecognizer  alloc] initWithTarget:self action:@selector(snapShotPanned)];
    [self.snapshotView addGestureRecognizer:self.snapPan];
    [self.snapshotView setShadowWidth:2 offset:CGSizeMake(2, 0) color:[UIColor blackColor] opacity:.4 drawPath:YES];
}

-(void)snapshotTapped
{
    if (self.currentSideController == self.listController)
        [self closeMenu];
    else{
        [self closeToNewViewController:self.currentSideController title:self.navBar.topItem.title];
    }
}

-(void)snapShotPanned
{
    if (self.snapPan.state == UIGestureRecognizerStateBegan){
        [self setLatestPoint:[self.snapPan locationInView:self.snapshotView]];
    }else if (self.snapPan.state == UIGestureRecognizerStateChanged){
        CGPoint point = [self.snapPan locationInView:self.snapshotView];
        self.snapshotView.transform = CGAffineTransformTranslate(self.snapshotView.transform,point.x - [self latestPoint].x, 0);
    }else if (self.snapPan.state == UIGestureRecognizerStateEnded){
        CGFloat velocity = [self.snapPan velocityInView:self.snapshotView].x;
        if (velocity >= 180.0 || self.snapshotView.transform.tx >= -80.0){
            if (self.currentSideController == self.listController)
                [self closeMenu];
            else{
                [self closeToNewViewController:self.currentSideController title:self.navBar.topItem.title];
            }
        }else{
            [UIView animateWithDuration:.46 delay:0 usingSpringWithDamping:.8 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseIn animations:^{
                CGAffineTransform tranform =CGAffineTransformTranslate(CGAffineTransformIdentity, -280, 0);
                self.snapshotView.transform = tranform;
            } completion:^(BOOL finished) {
            }];
        }
    }
}


#pragma mark - Fake Properties

-(CGPoint)latestPoint
{
    NSValue * value = objc_getAssociatedObject(self, LatestPointKey);
    return [value CGPointValue];
}

-(void)setLatestPoint:(CGPoint )point
{
    NSValue * value = [NSValue valueWithCGPoint:point];
    objc_setAssociatedObject(self, LatestPointKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
