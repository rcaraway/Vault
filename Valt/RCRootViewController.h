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

@interface RCRootViewController : RCViewController <UISearchBarDelegate>

@property(nonatomic, strong) RCPasscodeViewController * passcodeController;
@property(nonatomic, strong) RCListViewController * listController;
@property(nonatomic, strong) RCSingleViewController * singleController;
@property(nonatomic, strong) RCSearchViewController * searchController;
@property(nonatomic, strong) UISearchBar * searchBar;

-(void)launchList;
-(void)returnToListAndRemovePassword:(RCPassword *)password;
-(void)launchSingle;
-(void)launchSingleWithPassword:(RCPassword *)password;
-(void)launchPasscode;

@end
