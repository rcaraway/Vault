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


@interface RCRootViewController : RCViewController 

@property(nonatomic, strong) RCPasscodeViewController * passcodeController;
@property(nonatomic, strong) RCListViewController * listController;
@property(nonatomic, strong) RCSingleViewController * singleController;
@property(nonatomic, strong) RCSearchViewController * searchController;
@property(nonatomic, strong) RCSearchBar * searchBar;
@property(nonatomic, strong) RCMenuViewController * menuController;
@property(nonatomic, strong) UINavigationBar * navBar;
@property(nonatomic, strong) UIView * snapshotView;

@property(nonatomic, strong) UITapGestureRecognizer * snapTap;
@property(nonatomic, strong) UIPanGestureRecognizer * snapPan;


-(void)launchPasscode;
-(void)launchAbout;
-(void)launchPurchaseScreen;
-(void)launchFeedback;


-(BOOL)canSendFeedback;

-(void)launchBrowserWithPassword:(RCPassword *)password;

@end
