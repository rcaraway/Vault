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
#import "RCSearchViewController.h"

@interface RCRootView : UIView
@end

@implementation RCRootView
@end



@interface RCRootViewController ()

@end

@implementation RCRootViewController


#pragma mark - View LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSearchBar];
    [self launchPasscode];
    self.view.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
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
}

-(void)moveFromPasscodeToList
{
    self.listController = [[RCListViewController  alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:self.listController];
    [self.passcodeController removeFromParentViewController];
}

-(void)moveFromListToPasscode
{
    self.passcodeController = [[RCPasscodeViewController  alloc] initWithNewUser:NO];
    [self addChildViewController:self.passcodeController];
    [self.listController removeFromParentViewController];
}

-(void)launchSingleWithPassword:(RCPassword *)password
{
    self.singleController = [[RCSingleViewController alloc] initWithPassword:password];
    [self addChildViewController:self.singleController];
    [self.listController removeFromParentViewController];
}

-(void)returnToListAndRemovePassword:(RCPassword *)password
{
    if (!self.listController){
        self.listController = [[RCListViewController  alloc] initWithNibName:nil bundle:nil];
    }else{
        [self.listController.tableView reloadData];
    }
    [self addChildViewController:self.listController];
    [self.singleController removeFromParentViewController];
    [self.listController removePassword:password];
}

-(void)moveFromListToSearch
{
    if (!self.searchController){
        self.searchController = [[RCSearchViewController alloc] initWithNibName:nil bundle:nil];
    }
    [self addChildViewController:self.searchController];
    [self.listController removeFromParentViewController];
}

-(void)returnToListFromSingle
{
    if (!self.listController){
        self.listController = [[RCListViewController  alloc] initWithNibName:nil bundle:nil];
    }
    [self addChildViewController:self.listController];
    [self.singleController removeFromParentViewController];
}

-(void)moveFromSearchToList
{
    if (!self.listController){
        self.listController = [[RCListViewController  alloc] initWithNibName:nil bundle:nil];
    }
    [self addChildViewController:self.listController];
    [self.searchController removeFromParentViewController];
}


#pragma mark - Search Bar

-(void)setupSearchBar
{
    self.searchBar = [[UISearchBar  alloc] initWithFrame:CGRectMake(0, 20, 320, 0)];
    self.searchBar.delegate =self;
    self.searchBar.barTintColor = [UIColor colorWithWhite:.9 alpha:1];
    [self setSearchBarUnselected];
    [self.view addSubview:self.searchBar];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self setSearchBarSelected];
    self.searchBar.showsCancelButton = YES;
    [self moveFromListToSearch];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self setSearchBarUnselected];
    
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.searchController.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.searchBar.showsCancelButton = NO;
    [self.view endEditing:YES];
    [self moveFromSearchToList];
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

-(void)showSearchAnimated:(BOOL)animated
{
    if (animated){
        [UIView animateWithDuration:.22 animations:^{
            [self showSearch];
        }];
    }else{
        [self showSearch];
    }
}

-(void)hideSearchAnimated:(BOOL)animated
{
    if (animated){
        [UIView animateWithDuration:.22 animations:^{
            [self hideSearch];
        }];
    }else{
        [self hideSearch];
    }
}

-(void)showSearch
{
    [self.view bringSubviewToFront:self.searchBar];
    [self.searchBar setFrame:CGRectMake(0, 20, 320, 44)];
}

-(void)hideSearch
{
    [self.view bringSubviewToFront:self.searchBar];
    [self.searchBar setFrame:CGRectMake(0, 20, 320, 0)];
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
