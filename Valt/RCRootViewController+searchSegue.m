//
//  RCRootViewController+searchSegue.m
//  Valt
//
//  Created by Robert Caraway on 1/16/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCRootViewController+searchSegue.h"
#import "RCCloseView.h"
#import "RCSearchViewController.h"
#import "RCListViewController.h"
#import "RCSearchBar.h"
#import <objc/runtime.h>

static void * DimViewKey;

@implementation RCRootViewController (searchSegue)


#pragma mark - Segue

-(void)segueListToSearch
{
     self.searchController = [[RCSearchViewController alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:self.searchController];
    [self.listController removeFromParentViewController];
    [self transitionFromListToSearch];
}

-(void)segueSearchToList
{
    [self addChildViewController:self.listController];
    [self.searchController removeFromParentViewController];
    [self transitionFromSearchToList];
}

-(void)segueSearchToSingleWithPassword:(RCPassword *)password indexPath:(NSIndexPath *)path
{
    
}

-(void)segueSearchToSingleWithNewPassword
{
    
}


#pragma mark - Transition Code

-(void)transitionFromListToSearch
{
    self.searchController.view.backgroundColor = [UIColor clearColor];
    self.searchController.tableView.backgroundColor = [UIColor clearColor];
    [self.searchController.tableView setFrame:CGRectMake(self.searchController.tableView.frame.origin.x, [UIScreen mainScreen].bounds.size.height, self.searchController.tableView.frame.size.width, self.searchController.tableView.frame.size.height)];
    [self.view addSubview:self.searchController.view];
    [self setupDimView];
    [UIView animateWithDuration:.52 delay:0 usingSpringWithDamping:.8 initialSpringVelocity:.7 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.listController.tableView.transform = CGAffineTransformMakeScale(.96, .96);
        [[self dimView] setAlpha:1];
        [self.searchBar.searchBack setBackgroundColor:[UIColor purpleColor]];
        self.searchController.view.backgroundColor = [UIColor whiteColor];
        self.searchController.tableView.backgroundColor = [UIColor whiteColor];
        [self.searchController.tableView setFrame:CGRectMake(self.searchController.tableView.frame.origin.x, 64, self.searchController.tableView.frame.size.width, self.searchController.tableView.frame.size.height)];
    }completion:^(BOOL finished) {

    }];
}

-(void)transitionFromSearchToList
{
    [UIView animateWithDuration:.26 animations:^{
        self.listController.tableView.transform = CGAffineTransformIdentity;
        self.searchController.view.backgroundColor = [UIColor clearColor];
        [self.searchBar.searchBack setBackgroundColor:[UIColor colorWithWhite:.82 alpha:1]];
        [[self dimView] setAlpha:0];
        self.searchController.tableView.backgroundColor = [UIColor clearColor];
        [self.searchController.tableView setFrame:CGRectMake(self.searchController.tableView.frame.origin.x, [UIScreen mainScreen].bounds.size.height, self.searchController.tableView.frame.size.width, self.searchController.tableView.frame.size.height)];
    } completion:^(BOOL finished) {
        [self.searchController.view removeFromSuperview];
        [[self dimView] removeFromSuperview];
        self.searchController = nil;
    }];
}


#pragma mark - Fake Properties

-(void)setupDimView
{
    UIView * dimView = [[UIView  alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64)];
    dimView.backgroundColor = [UIColor colorWithWhite:.1 alpha:.5];
    [self setDimView:dimView];
    dimView.alpha = 0;
    [self.view addSubview:dimView];
    [self.view bringSubviewToFront:self.searchController.view];
}

-(UIView *)dimView
{
    return objc_getAssociatedObject(self, DimViewKey);
}

-(void)setDimView:(UIView *)dimView
{
    objc_setAssociatedObject(self, DimViewKey, dimView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
