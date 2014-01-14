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
@class RCCloseView;

@interface RCRootViewController : RCViewController 

@property(nonatomic, strong) RCPasscodeViewController * passcodeController;
@property(nonatomic, strong) RCListViewController * listController;
@property(nonatomic, strong) RCSingleViewController * singleController;
@property(nonatomic, strong) RCSearchViewController * searchController;
@property(nonatomic, strong) RCSearchBar * searchBar;
@property(nonatomic, strong) RCCloseView * closeView;

-(void)launchPasscode;
-(void)moveFromPasscodeToList;
-(void)returnToPasscode;
-(void)returnToListAndRemovePassword:(RCPassword *)password;
-(void)returnToListFromSingle;
-(void)launchSingleWithPassword:(RCPassword *)password;
-(void)moveFromListToSearch;
-(void)moveFromSearchToList;
-(void)moveFromSearchToSingleWithPassword:(RCPassword *)password;
-(void)launchAbout;
-(void)launchPurchaseScreen;
-(void)launchFeedback;

-(BOOL)canSendFeedback;

-(void)launchBrowserWithPassword:(RCPassword *)password;

-(void)showSearchAnimated:(BOOL)animated;
-(void)hideSearchAnimated:(BOOL)animated;

@end
