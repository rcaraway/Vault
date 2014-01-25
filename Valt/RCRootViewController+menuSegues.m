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
    [self.listController removeFromParentViewController];
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
    [self closeMenu];
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
            [self closeMenu];
        }else{
            [UIView animateWithDuration:.46 delay:0 usingSpringWithDamping:.8 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseIn animations:^{
                CGAffineTransform tranform =CGAffineTransformTranslate(CGAffineTransformIdentity, -280, 0);
                self.snapshotView.transform = tranform;
            } completion:^(BOOL finished) {
            }];
        }
        NSLog(@"FINAL %f %f %f", self.snapshotView.transform.tx, self.snapshotView.transform.ty, [self.snapPan velocityInView:self.snapshotView].x);
    }
}

-(void)closeMenu
{
    [UIView animateWithDuration:.46 delay:0 usingSpringWithDamping:.8 initialSpringVelocity:.8 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.snapshotView.transform =CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self.menuController removeFromParentViewController];
        [self.menuController.view removeFromSuperview];
        [self addChildViewController:self.listController];
        [self.view addSubview:self.listController.view];
        [self setNeedsStatusBarAppearanceUpdate];
        [self.snapshotView removeFromSuperview];
        self.snapshotView = nil;
    }];
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
