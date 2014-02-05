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
#import "RCTableView.h"
#import "RCTitleViewCell.h"

#import <objc/runtime.h>

static void * SearchSizeKey;
static void * SearchOffsetKey;
static NSInteger searchIndex;

@implementation RCRootViewController (searchSegue)


#pragma mark - Segue

-(void)segueListToSearch
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    self.searchController = [[RCSearchViewController alloc] initWithNibName:nil bundle:nil];
    [self.listController removeFromParentViewController];
    [self addChildViewController:self.searchController];
    [self.view insertSubview:self.searchController.view belowSubview:self.listController.view];
    [self.view insertSubview:self.searchController.searchBar belowSubview:self.navBar];
    [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.listController.view.alpha = 0;
        [self.view bringSubviewToFront:(UIView*)self.messageView];
        self.navBar.alpha=0;
    } completion:^(BOOL finished) {
        [self.listController.view removeFromSuperview];
        [self.view bringSubviewToFront:self.searchController.searchBar];
        self.navBar.alpha = 1;
        self.listController.view.alpha = 1;
        [self.searchController.searchBar.searchField becomeFirstResponder];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}

-(void)segueSearchToList
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self.searchController removeFromParentViewController];
    [self addChildViewController:self.listController];
    [self.view insertSubview:self.listController.view belowSubview:self.searchController.view];
    [self.view bringSubviewToFront:self.navBar];
    [self.view bringSubviewToFront:self.searchController.searchBar];
    [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.searchController.searchBar.searchField resignFirstResponder];
        self.searchController.searchBar.alpha = 0;
        self.searchController.searchBar.searchField.text = @"";
        self.searchController.view.alpha = 0;
        [self.view bringSubviewToFront:(UIView*)self.messageView];
    } completion:^(BOOL finished) {
        [self.searchController.view removeFromSuperview];
        [self.searchController.searchBar removeFromSuperview];
        self.searchController.view.alpha = 1;
        self.searchController.searchBar.alpha = 1;
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}

-(void)segueSearchToSingleWithPassword:(RCPassword *)password indexPath:(NSIndexPath *)path
{
    self.singleController = [[RCSingleViewController alloc] initWithPassword:password];
    [self.searchController removeFromParentViewController];
    [self addChildViewController:self.singleController];
    [self transitionFromSearchToSingleWithPassword:password indexPath:path];
}

-(void)segueSingleToSearch
{
    [self.singleController removeFromParentViewController];
    [self addChildViewController:self.searchController];
    [self transitionFromSingleToSearch];
}



#pragma mark - Transitions

-(void)transitionFromSingleToSearch
{
    if (self.singleController.tableView.contentOffset.y == 0){
        [self transitionNormallyFromSingleToSearch];
    }else{
        [self transitionPullDownFromSingleToSearch];
    }
}

-(void)transitionFromSearchToSingleWithPassword:(RCPassword *)password indexPath:(NSIndexPath *)indexPath
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    NSInteger index = indexPath.row;
    self.singleController.view.backgroundColor = [UIColor clearColor];
    CGRect cellRect = [self rectForCellAtIndex:index];
    CGRect originalRect = self.singleController.tableView.frame;
    searchIndex = index;
    [self setSearchSize:self.searchController.tableView.contentSize];
    [self setSearchOffset:self.searchController.tableView.contentOffset];
    [self.singleController.tableView reloadData];
    [self.singleController.tableView setFrame:CGRectMake(0, cellRect.origin.y+64, self.singleController.tableView.frame.size.width, self.singleController.tableView.frame.size.height)];
    self.searchController.viewPath = [NSIndexPath indexPathForRow:index+1 inSection:0];
    [self.view addSubview:self.singleController.view];
    [self.searchController.tableView setExtendedSize:YES];
    self.singleController.cameFromSearch = YES;
    self.navBar.alpha = 0;
    
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        [self.searchController.searchBar setFrame:CGRectOffset(self.searchController.searchBar.frame, 0, -64)];
        [self.searchController.tableView insertRowsAtIndexPaths:@[self.searchController.viewPath] withRowAnimation:UITableViewRowAnimationFade];
        self.singleController.view.backgroundColor = [UIColor colorWithWhite:.1 alpha:.75];
        [self.searchController.tableView setContentOffset:CGPointMake(0, cellRect.origin.y-20)];
        [self.searchController.tableView setShouldAllowMovement:NO];
        self.singleController.isTransitioningTo = NO;
        [self.singleController.tableView insertRowsAtIndexPaths:[self dropDownPaths] withRowAnimation:UITableViewRowAnimationFade];
        [self.singleController.tableView setFrame:originalRect];
        [(RCTitleViewCell *)[self.singleController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] setPurpleColoed];
        self.searchController.searchBar.searchField.text = @"";
        UITextField * field = (UITextField *)[(RCTitleViewCell *)[self.singleController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] textField];
        [field becomeFirstResponder];
    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}

-(void)transitionNormallyFromSingleToSearch
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    NSIndexPath * indexPath = [self.searchController.viewPath copy];
    self.searchController.viewPath = nil;
    NSInteger index = searchIndex;
    CGRect cellRect = [self rectForCellAtIndex:index];
    CGPoint offset = [self searchOffset];
    self.singleController.isTransitioningTo = YES;
    [self.searchController.tableView setShouldAllowMovement:YES];
    [UIView animateWithDuration:.3 animations:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        self.navBar.alpha = 1;
        [self.singleController.tableView setFrame:CGRectMake(0, cellRect.origin.y+64, self.singleController.tableView.frame.size.width, self.singleController.tableView.frame.size.height)];
        [self.searchController.searchBar setFrame:CGRectOffset(self.searchController.searchBar.frame, 0, 64)];
        [self.searchController.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        [self.searchController.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [(RCTitleViewCell *)[self.singleController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] setNormalColored];
        [self.singleController.tableView deleteRowsAtIndexPaths:[self dropDownPaths] withRowAnimation:UITableViewRowAnimationFade];
        self.singleController.view.backgroundColor = [UIColor clearColor];
        [self.searchController.tableView setContentOffset:offset];
        [self.searchController.tableView setExtendedSize:NO];
    }completion:^(BOOL finished) {
        self.singleController.view.alpha = 0;
        [self.searchController.tableView setShouldAllowMovement:YES];
        [self.singleController.view removeFromSuperview];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}

-(void)transitionPullDownFromSingleToSearch
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    NSIndexPath * indexPath = [self.searchController.viewPath copy];
    self.searchController.viewPath = nil;
    NSInteger index = searchIndex;
    CGRect cellRect = [self rectForCellAtIndex:index];
    CGPoint offset = [self searchOffset];
    self.singleController.isTransitioningTo = YES;
    [self.searchController.tableView setShouldAllowMovement:YES];
    [UIView animateWithDuration:.3 animations:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        self.navBar.alpha = 1;
        [self.searchController.searchBar setFrame:CGRectOffset(self.searchController.searchBar.frame, 0, 64)];
        [self.singleController.tableView setFrame:CGRectMake(0, cellRect.origin.y+57, self.singleController.tableView.frame.size.width, self.singleController.tableView.frame.size.height)];
        self.singleController.view.alpha = 0;
        [self.searchController.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        [self.searchController.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [(RCTitleViewCell *)[self.singleController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] setNormalColored];
        [self.singleController.tableView deleteRowsAtIndexPaths:[self dropDownPaths] withRowAnimation:UITableViewRowAnimationFade];
        [self.searchController.tableView setContentOffset:offset];
        [self.searchController.tableView setExtendedSize:NO];
    }completion:^(BOOL finished) {
        [self.singleController.view removeFromSuperview];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}

#pragma mark - Extra Properties

-(void)setSearchOffset:(CGPoint)offset
{
    objc_setAssociatedObject(self, SearchOffsetKey, [NSValue valueWithCGPoint:offset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(CGPoint)searchOffset
{
    NSValue * value = objc_getAssociatedObject(self, SearchOffsetKey);
    return [value CGPointValue];
}

-(void)setSearchSize:(CGSize)size
{
    objc_setAssociatedObject(self,SearchSizeKey, [NSValue valueWithCGSize:size], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(CGSize)searchSize
{
    NSValue * value = objc_getAssociatedObject(self, SearchSizeKey);
    return [value CGSizeValue];
}


#pragma mark - Convenience


-(CGRect)rectForCellAtIndex:(NSInteger)index
{
    CGRect cellRect = [self.searchController.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    return cellRect;
}

-(NSArray *)dropDownPaths
{
    NSMutableArray * indexPaths = [NSMutableArray arrayWithCapacity:4];
    for (int  i = 1; i < 5; i++) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [indexPaths addObject:indexPath];
    }
    return indexPaths;
}


@end
