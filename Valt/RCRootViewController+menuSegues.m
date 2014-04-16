//
//  RCRootViewController+menuSegues.m
//  Valt
//
//  Created by Rob Caraway on 1/24/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCRootViewController+menuSegues.h"
#import "UIColor+RCColors.h"
#import "UIView+QuartzEffects.h"

#import "RCListGestureManager.h"

#import "RCListViewController.h"
#import "RCMenuViewController.h"
#import "RCPurchaseViewController.h"
#import "RCAboutViewController.h"
#import "RCNotesViewController.h"

#import "RCMessageView.h"

#import <SAMTextView/SAMTextView.h>
#import <objc/runtime.h>

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)


static void * LatestPointKey;


@implementation RCRootViewController (menuSegues)

#pragma mark - Segue actions

-(void)segueToMenu
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
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
        [self.currentSideController.view removeFromSuperview];
    }
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [UIView animateWithDuration:.34 delay:0 usingSpringWithDamping:.8 initialSpringVelocity:.8 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGAffineTransform tranform =CGAffineTransformTranslate(CGAffineTransformIdentity, -280, 0);
        self.snapshotView.transform = tranform;
    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}

-(void)beginDragToMenu
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
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

-(void)dragSideToXOrigin:(CGFloat)xOrigin
{
    CGAffineTransform tranform =CGAffineTransformTranslate(CGAffineTransformIdentity, xOrigin, 0);
    self.snapshotView.transform = tranform;
}

-(void)finishDragWithClose
{
    [UIView animateWithDuration:.34 animations:^{
        self.snapshotView.transform = CGAffineTransformIdentity;
    }completion:^(BOOL finished) {
        [self.menuController removeFromParentViewController];
        [self addChildViewController:self.currentSideController];
        [self.view addSubview:self.currentSideController.view];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        [self.view addSubview:self.messageView];
        [self.view addSubview:self.navBar];
        [self.snapshotView removeFromSuperview];
        [self.menuController.view removeFromSuperview];
        if (self.currentSideController == self.notesController){
            [UIView setAnimationsEnabled:NO];
            [self.notesController reshowKeyboard];
            [UIView setAnimationsEnabled:YES];
        }
    }];

   [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

-(void)finishDragWithCloseCompletion:(void(^)())completion
{
    [UIView animateWithDuration:.34 animations:^{
        self.snapshotView.transform = CGAffineTransformIdentity;
    }completion:^(BOOL finished) {
        [self.menuController removeFromParentViewController];
        [self addChildViewController:self.currentSideController];
        [self.view addSubview:self.currentSideController.view];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        [self.view addSubview:self.messageView];
        [self.view addSubview:self.navBar];
        [self.snapshotView removeFromSuperview];
        [self.menuController.view removeFromSuperview];
        if (completion)
            completion();
    }];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

-(void)finishDragWithSegue
{
    [UIView animateWithDuration:.34 delay:0 usingSpringWithDamping:.8 initialSpringVelocity:.8 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGAffineTransform tranform =CGAffineTransformTranslate(CGAffineTransformIdentity, -280, 0);
        self.snapshotView.transform = tranform;
    } completion:^(BOOL finished) {
        if (self.currentSideController != self.listController){
            [self.currentSideController.view removeFromSuperview];
        }
    }];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

-(void)closeMenu
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    self.currentSideController = self.listController;
    [self.listController.view setFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-20)];
    UIView * subSnapView = [self.listController.view snapshotViewAfterScreenUpdates:YES];
    [subSnapView setFrame:self.listController.view.frame];
    [self.snapshotView addSubview:subSnapView];
    [self setNavBarMain];;
    [self.snapshotView addSubview:self.navBar];
    
    [UIView animateWithDuration:.34 delay:0 usingSpringWithDamping:.8 initialSpringVelocity:.8 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.snapshotView.transform =CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self.menuController removeFromParentViewController];
        [self.menuController.view removeFromSuperview];
        if (![self.messageView messageShowing]){
             [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        }
        [self addChildViewController:self.currentSideController];
        [self.view addSubview:self.currentSideController.view];
        [self.view addSubview:self.navBar];
        self.currentSideController = nil;
        [self.snapshotView removeFromSuperview];
        self.snapshotView = nil;
        
        [self.menuController changeFeelgoodMessage];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}

-(void)goHome
{
    [self.view endEditing:YES];
    if (self.childViewControllers[0] == self.notesController){
        [self goHomeWithForce];
    }else{
        [self goHomeWithNaturalGravity];
    }
}


-(void)didFinishGravityAnimation:(UIViewController *)controller
{
   
}

-(void)closeToNewViewController:(UIViewController *)controller title:(NSString *)title color:(UIColor *)color
{
    if (self.currentSideController == controller){
        [self finishDragWithClose];
    }else{
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        if ([controller isMemberOfClass:[RCNotesViewController class]]){
            [controller.view setFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-20)];
        }
        self.currentSideController = controller;
        UIView * subSnapView = [controller.view snapshotViewAfterScreenUpdates:YES];
        [subSnapView setFrame:controller.view.frame];
        [self.snapshotView addSubview:subSnapView];
        [self setNavBarAlternateWithTitle:title color:color];
        [self.snapshotView addSubview:self.navBar];
        [UIView animateWithDuration:.34 delay:0 usingSpringWithDamping:.8 initialSpringVelocity:.8 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.snapshotView.transform =CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [self.menuController removeFromParentViewController];
            [self.menuController.view removeFromSuperview];
            [self addChildViewController:self.currentSideController];
            [self.view addSubview:self.navBar];
            [self.view addSubview:self.currentSideController.view];
            [self.view bringSubviewToFront:self.navBar];
            self.currentSideController = nil;
            if (![self.messageView messageShowing]){
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
            }
            [self.snapshotView removeFromSuperview];
            self.snapshotView = nil;
            [self.menuController changeFeelgoodMessage];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            if (controller == self.notesController){
                [self.notesController.notesView becomeFirstResponder];
            }
        }];

    }
}

#pragma mark - GO HOME

-(void)goHomeWithNaturalGravity
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    UIViewController * current = self.childViewControllers[0];
    [current removeFromParentViewController];
    [self addChildViewController:self.listController];
    CGRect rect = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64);
    UIView * dimview = [[UIView alloc] initWithFrame:self.listController.view.frame];
    [self.view insertSubview:self.listController.view belowSubview:current.view];
    self.listController.view.transform = CGAffineTransformMakeScale(.97, .97);
    
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
    
    [self setNavBarMain];
    [self.view bringSubviewToFront:self.navBar];
    dimview.backgroundColor = [UIColor blackColor];
    dimview.alpha = .75;
    [self.view insertSubview:dimview belowSubview:current.view];
    CGFloat duration = (IS_IPHONE?.72:1);
    [UIView animateWithDuration:duration animations:^{
        [dimview setAlpha:0];
        self.listController.view.transform = CGAffineTransformIdentity;
    }completion:^(BOOL finished) {
        [self.animator removeBehavior:self.gravityBehavior];
        [self.animator removeBehavior:self.attachmentBehavior];
        self.animator = nil;
        current.view.transform = CGAffineTransformIdentity;
        current.view.frame = rect;
        [dimview removeFromSuperview];
        [current.view removeFromSuperview];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}

-(void)goHomeWithForce
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    UIViewController * current = self.childViewControllers[0];
    [current removeFromParentViewController];
    [self addChildViewController:self.listController];
    CGRect rect = current.view.frame;
    UIView * dimview = [[UIView alloc] initWithFrame:self.listController.view.frame];
    [self.view insertSubview:self.listController.view belowSubview:current.view];
    self.listController.view.transform = CGAffineTransformMakeScale(.97, .97);
    [self setNavBarMain];
    [self.view bringSubviewToFront:self.navBar];
    dimview.backgroundColor = [UIColor blackColor];
    dimview.alpha = .75;
    [self.view insertSubview:dimview belowSubview:current.view];
    [UIView animateWithDuration:.42 animations:^{
        [dimview setAlpha:0];
        [current.view setFrame:CGRectOffset(current.view.frame, 0, [UIScreen mainScreen].bounds.size.height)];
        self.listController.view.transform = CGAffineTransformIdentity;
    }completion:^(BOOL finished) {
        current.view.transform = CGAffineTransformIdentity;
        [current.view removeFromSuperview];
        current.view.frame = rect;
        [dimview removeFromSuperview];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
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
        [self closeToSideScreen];
    }
}

-(void)closeToSideScreen
{
    [self finishDragWithClose];
//    if (self.currentSideController == self.purchaseController)
//        [self closeToNewViewController:self.currentSideController title:self.navBar.topItem.title color:[UIColor goPlatinumColor]];
//    else if (self.currentSideController == self.aboutController){
//        [self closeToNewViewController:self.currentSideController title:self.navBar.topItem.title color:[UIColor aboutColor]];
//    }else{
//        [self closeToNewViewController:self.currentSideController title:self.navBar.topItem.title color:[UIColor darkGrayColor]];
//    }
    
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
                [self closeToSideScreen];
            }
        }else{
            [UIView animateWithDuration:.45  delay:0 usingSpringWithDamping:.7 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseIn animations:^{
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
