//
//  RCRootViewController.m
//  Valt
//
//  Created by Rob Caraway on 12/10/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCRootViewController.h"
#import "RCPasscodeViewController.h"
#import "RCListViewController.h"
#import "RCSingleViewController.h"
#import "RCPasswordManager.h"
#import "UIColor+RCColors.h"

@interface RCRootViewController ()

@end

@implementation RCRootViewController


#pragma mark - View LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSearchBar];
    [self launchPasscode];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate
{
    return NO;
}

-(BOOL)prefersStatusBarHidden
{
    return NO;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


#pragma mark - VC Transitions

-(void)launchPasscode
{
    if (!self.passcodeController){
        if ([[RCPasswordManager defaultManager] masterPasswordExists]){
            self.passcodeController = [[RCPasscodeViewController  alloc] initWithNewUser:NO];
        }else{
            self.passcodeController = [[RCPasscodeViewController  alloc] initWithNewUser:YES];
        }
    }
    [self addChildViewController:self.passcodeController];
    [self.view addSubview:self.passcodeController.view];
}


-(void)launchSingleWithPassword:(RCPassword *)password
{
    self.singleController = [[RCSingleViewController alloc] initWithPassword:password];
    [self addChildViewController:self.singleController];
    [self.view addSubview:self.singleController.view];
}

-(void)launchList
{
    [self discardPasscode];
    [self discardSingle];
    if (!self.listController){
        self.listController = [[RCListViewController  alloc] initWithNibName:nil bundle:nil];
    }else{
        [self.listController.tableView reloadData];
    }
    [self addChildViewController:self.listController];
    [self.view addSubview:self.listController.view];
}

-(void)returnToListAndRemovePassword:(RCPassword *)password
{
    [self discardSingle];
    if (!self.listController){
        self.listController = [[RCListViewController  alloc] initWithNibName:nil bundle:nil];
    }else{
        [self.listController.tableView reloadData];
    }
    [self addChildViewController:self.listController];
    [self.view addSubview:self.listController.view];
    [self.listController removePassword:password];
}

-(void)launchSingle
{
    [self.listController removeFromParentViewController];
    [self.listController.view removeFromSuperview];
    self.singleController = [[RCSingleViewController alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:self.singleController];
    [self.view addSubview:self.singleController.view];
}


#pragma mark - Search Bar

-(void)setupSearchBar
{
    self.searchBar = [[UISearchBar  alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.searchBar.delegate =self;
    self.searchBar.barTintColor = [UIColor cellUnselectedForeground];
    [self setSearchBarUnselected];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self setSearchBarSelected];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self setSearchBarUnselected];
}

-(void)setSearchBarSelected
{
    UITextField *txfSearchField = [_searchBar valueForKey:@"_searchField"];
    txfSearchField.backgroundColor = [UIColor colorWithRed:234.0/255.0 green:120.0/255.0 blue:216.0/255.0 alpha:1];
    txfSearchField.textColor = [UIColor whiteColor];
    txfSearchField.attributedPlaceholder = [[NSAttributedString  alloc] initWithString:@"Search Vault" attributes:@{NSForegroundColorAttributeName: [UIColor cellUnselectedForeground]}];
}

-(void)setSearchBarUnselected
{
    UITextField *txfSearchField = [_searchBar valueForKey:@"_searchField"];
    txfSearchField.backgroundColor = [UIColor colorWithRed:175.0/255.0 green:112.0/255.0 blue:165.0/255.0 alpha:1];
    txfSearchField.textColor = [UIColor whiteColor];
    txfSearchField.attributedPlaceholder = [[NSAttributedString  alloc] initWithString:@"Search Vault" attributes:@{NSForegroundColorAttributeName: [UIColor cellUnselectedForeground]}];
}


#pragma mark - Convenience

-(void)discardPasscode
{
    if (self.passcodeController.isViewLoaded && self.passcodeController.view.window){
        [self.passcodeController removeFromParentViewController];
        [self.passcodeController.view removeFromSuperview];
    }
}

-(void)discardList
{
    if (self.listController.isViewLoaded && self.listController.view.window){
        [self.listController removeFromParentViewController];
        [self.listController.view removeFromSuperview];
    }
}

-(void)discardSingle
{
    if (self.singleController.isViewLoaded && self.singleController.view.window){
        [self.singleController removeFromParentViewController];
        [self.singleController.view removeFromSuperview];
    }
}

@end
