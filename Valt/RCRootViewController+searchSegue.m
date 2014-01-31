//
//  RCRootViewController+searchSegue.m
//  Valt
//
//  Created by Robert Caraway on 1/16/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCRootViewController+searchSegue.h"
#import "RCSearchViewController.h"
#import "RCSingleViewController.h"
#import "RCListViewController.h"
#import "RCSearchBar.h"
#import <objc/runtime.h>


@implementation RCRootViewController (searchSegue)


#pragma mark - Segue

-(void)segueListToSearch
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    self.searchController = [[RCSearchViewController alloc] initWithNibName:nil bundle:nil];
    [self.searchController.view setFrame:CGRectOffset(self.searchController.view.frame, 0, 44)];
    [self addChildViewController:self.searchController];
    [self.listController removeFromParentViewController];
    [self.view insertSubview:self.searchController.view belowSubview:self.listController.view];
    [self.view insertSubview:self.searchBar belowSubview:self.navBar];
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.listController.view.alpha = 0;
        self.navBar.alpha=0;
    } completion:^(BOOL finished) {
        [self.listController.view removeFromSuperview];
        [self.view bringSubviewToFront:self.searchBar];
        self.navBar.alpha = 1;
        self.listController.view.alpha = 1;
        [self.searchBar.searchField becomeFirstResponder];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}

-(void)segueSearchToList
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self addChildViewController:self.listController];
    [self.searchController removeFromParentViewController];
    [self.view insertSubview:self.listController.view belowSubview:self.searchController.view];
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.searchBar.searchField resignFirstResponder];
        self.searchBar.alpha = 0;
        self.searchBar.searchField.text = @"";
        self.searchController.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.searchController.view removeFromSuperview];
        [self.searchBar removeFromSuperview];
        self.searchController.view.alpha = 1;
        self.searchBar.alpha = 1;
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}

-(void)segueSearchToSingleWithPassword:(RCPassword *)password indexPath:(NSIndexPath *)path
{
    self.singleController = [[RCSingleViewController alloc] initWithPassword:password];
    [self addChildViewController:self.singleController];
    [self.searchController removeFromParentViewController];
    self.singleController.cameFromSearch = YES;
    self.singleController.view.alpha = 0;
    [self.view addSubview:self.singleController.view];
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.singleController.view.alpha = 1;
        self.searchBar.searchField.text = @"";
        [self.searchBar.searchField resignFirstResponder];
    } completion:^(BOOL finished) {
    }];
}

-(void)segueSingleToSearch
{
    [self addChildViewController:self.searchController];
    [self.singleController removeFromParentViewController];
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.singleController.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.singleController.view removeFromSuperview];
        [self.searchBar.searchField becomeFirstResponder];
    }];
}



@end
