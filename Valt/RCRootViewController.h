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
@class RCSearchViewController;
@class RCSearchBar;
@class RCMenuViewController;
@class MFMailComposeViewController;
@class RCAboutViewController;
@class RCPurchaseViewController;
@class RCWebViewController;

@interface RCRootViewController : RCViewController 

@property(nonatomic, strong) RCPasscodeViewController * passcodeController;
@property(nonatomic, strong) RCListViewController * listController;
@property(nonatomic, strong) RCSingleViewController * singleController;
@property(nonatomic, strong) RCSearchViewController * searchController;
@property(nonatomic, strong) RCSearchBar * searchBar;
@property(nonatomic, strong) RCMenuViewController * menuController;
@property(nonatomic, strong) MFMailComposeViewController * mailController;
@property(nonatomic, strong) RCAboutViewController * aboutController;
@property(nonatomic, strong) RCPurchaseViewController * purchaseController;
@property(nonatomic, strong) RCWebViewController * webController;
@property(nonatomic, strong) UINavigationBar * navBar;
@property(nonatomic, strong) UIView * snapshotView;
@property (nonatomic, weak) UIViewController * currentSideController;

@property(nonatomic, strong) UITapGestureRecognizer * snapTap;
@property(nonatomic, strong) UIPanGestureRecognizer * snapPan;

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehavior;
@property (nonatomic, strong) UIGravityBehavior *gravityBehavior;


-(void)launchPasscode;
-(void)launchFeedback;
-(BOOL)canSendFeedback;

-(void)setNavBarMain;
-(void)setNavBarAlternateWithTitle:(NSString *)title;

-(void)launchBrowserWithPassword:(RCPassword *)password;

@end
