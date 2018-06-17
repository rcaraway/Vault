//
//  RCRootViewController.h
//  Valt
//
//  Created by Rob Caraway on 12/10/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCViewController.h"
@class RCPasscodeViewController;
@class RCListViewController;
@class RCSingleViewController;
@class RCPassword;
@class RCMenuViewController;
@class MFMailComposeViewController;
@class RCAboutViewController;
@class RCPurchaseViewController;
@class RCWebViewController;
@class RCMessageView;
@class RCNotesViewController;

@interface RCRootViewController : RCViewController 

@property(nonatomic, strong) RCPasscodeViewController * passcodeController;
@property(nonatomic, strong) RCListViewController * listController;
@property(nonatomic, strong) RCSingleViewController * singleController;

@property(nonatomic, strong) RCMenuViewController * menuController;
@property(nonatomic, strong) MFMailComposeViewController * mailController;

@property(nonatomic, strong) RCWebViewController * webController;
@property(nonatomic, strong) RCNotesViewController * notesController;
@property(nonatomic, strong) UINavigationBar * navBar;
@property(nonatomic, strong) UIView * snapshotView;
@property(nonatomic, strong) RCMessageView * messageView;
@property (nonatomic, weak) UIViewController * currentSideController;

@property(nonatomic, strong) UITapGestureRecognizer * snapTap;
@property(nonatomic, strong) UIPanGestureRecognizer * snapPan;

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehavior;
@property (nonatomic, strong) UIGravityBehavior *gravityBehavior;


-(void)launchFeedback;
-(BOOL)canSendFeedback;
-(void)launchPasscode;

-(void)removeAllChildren;
-(void)resetViewsForPasscode;

-(void)setStatusLightContentAnimated:(BOOL)animated;
-(void)setStatusDarkContentAnimated:(BOOL)animated;

-(void)setNavBarMain;
-(void)setNavBarAlternateWithTitle:(NSString *)title color:(UIColor *)color;

@end
