//
//  RCRootViewController+passwordSegues.m
//  Valt
//
//  Created by Robert Caraway on 1/16/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCRootViewController+passwordSegues.h"
#import "RCSingleViewController.h"
#import "RCListViewController.h"
#import "RCPassword.h"
#import "RCPasswordManager.h"

@implementation RCRootViewController (passwordSegues)



#pragma mark - Segues


-(void)segueSingleToList
{
    [self addChildViewController:self.listController];
    [self.singleController removeFromParentViewController];
    [self transitionFromSingleToList];
}

-(void)segueSingleToListWithRemovedPassword
{
    
}


-(void)segueToSingleWithPassword:(RCPassword *)password
{
    self.singleController = [[RCSingleViewController alloc] initWithPassword:password];
    [self addChildViewController:self.singleController];
    [self.listController removeFromParentViewController];
    [self transitionFromListToSingleWithPassword:password];
}

-(void)segueToSingleWithNewPasswordAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(void)segueToSingleWithNewPasswordAtLocation:(CGPoint)location
{
    
}

#pragma mark - Transitions


-(void)transitionFromSingleToList
{
    NSIndexPath * indexPath = [self.listController.viewPath copy];
    self.listController.viewPath = nil;
    NSInteger index = [[[RCPasswordManager defaultManager] passwords] indexOfObject:self.singleController.password];
    CGRect cellRect = [self rectForCellAtIndex:index];
    self.singleController.isTransitioning = YES;
    [UIView animateWithDuration:.26 animations:^{
        [self.singleController.tableView setFrame:CGRectMake(0, cellRect.origin.y+64, self.singleController.tableView.frame.size.width, self.singleController.tableView.frame.size.height)];
        [self.listController.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        [self.singleController.tableView deleteRowsAtIndexPaths:[self dropDownPaths] withRowAnimation:UITableViewRowAnimationAutomatic];
        self.singleController.view.alpha=0;
            [self.listController.tableView setContentSize:CGSizeMake(self.listController.tableView.contentSize.width, self.listController.tableView.contentSize.height-188)];
    }completion:^(BOOL finished) {
        [self.singleController.view removeFromSuperview];
    }];
}

-(void)transitionFromListToSingleWithPassword:(RCPassword *)password
{
    NSInteger index =[[[RCPasswordManager defaultManager] passwords] indexOfObject:password];
    self.singleController.isTransitioning = YES;
    self.singleController.view.backgroundColor = [UIColor clearColor];
    [self.singleController.tableView reloadData];
    CGRect cellRect = [self rectForCellAtIndex:index];
    CGRect originalRect = self.singleController.tableView.frame;
    [self.singleController.tableView setFrame:CGRectMake(0, cellRect.origin.y+64, self.singleController.tableView.frame.size.width, self.singleController.tableView.frame.size.height)];
    
    self.listController.viewPath = [NSIndexPath indexPathForRow:[[[RCPasswordManager defaultManager] passwords] indexOfObject:password]+1 inSection:0];
    [self.view addSubview:self.singleController.view];
    
    [self.listController.tableView setContentSize:CGSizeMake(self.listController.tableView.contentSize.width, self.listController.tableView.contentSize.height+188)];
    [UIView animateWithDuration:.26 animations:^{
        [self.listController.tableView insertRowsAtIndexPaths:@[self.listController.viewPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        self.singleController.view.backgroundColor = [UIColor colorWithWhite:.1 alpha:.75];
        [self.listController.tableView setContentOffset:CGPointMake(0, cellRect.origin.y+64)];
        self.singleController.isTransitioning = NO;
        [self.singleController.tableView insertRowsAtIndexPaths:[self dropDownPaths] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.singleController.tableView setFrame:originalRect];
    }];
}

-(CGRect)rectForCellAtIndex:(NSInteger)index
{
    CGRect cellRect = [self.listController.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
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
