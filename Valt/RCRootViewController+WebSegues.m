//
//  RCRootViewController+WebSegues.m
//  Valt
//
//  Created by Rob Caraway on 1/23/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCRootViewController+WebSegues.h"

#import "RCListViewController.h"
#import "RCWebViewController.h"

#import "RCMessageView.h"
#import "RCMainCell.h"
#import "RCTableView.h"

#import "RCPasswordManager.h"
#import "RCPassword.h"

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@implementation RCRootViewController (WebSegues)


#pragma mark - Segues

-(void)segueToWebFromIndexPath:(NSIndexPath *)indexPath
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    RCPassword * password = [[RCPasswordManager defaultManager] passwords][indexPath.row];
    CGRect cellRect = [self.listController.tableView rectForRowAtIndexPath:indexPath];
    [self addChildViewController:self.webController];
    self.webController.password = password;
    [self.view insertSubview:self.webController.view belowSubview:self.listController.view];
    [self.view insertSubview:self.webController.topView belowSubview:self.navBar];
    [self.webController.bottomView setFrame:CGRectOffset(self.webController.bottomView.frame, 0, self.webController.bottomView.frame.size.height)];
    self.listController.webPath = indexPath;
    RCMainCell * cell = (RCMainCell *)[self.listController.tableView cellForRowAtIndexPath:self.listController.webPath];

    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.listController.tableView setContentOffset:CGPointMake(0, cellRect.origin.y)];
        [self.listController.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.3 animations:^{
            self.listController.view.alpha = 0;
            self.navBar.alpha = 0;
            [self.webController.bottomView setFrame:CGRectOffset(self.webController.bottomView.frame, 0, -self.webController.bottomView.frame.size.height)];
        }completion:^(BOOL finished) {
            [self.webController.view addSubview:self.webController.topView];
            [self.webController loadPasswordRequest];
            [self.view bringSubviewToFront:self.webController.view];
            [self.view bringSubviewToFront:self.messageView];
            self.listController.view.alpha = 1;
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }];
    }];
    [cell setCompletelyGreen];
}

-(void)closeWeb
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self.webController removeFromParentViewController];
    [self.webController.webView stopLoading];
    NSIndexPath * copy = [self.listController.webPath copy];
    self.listController.webPath = nil;
    [self.view insertSubview:self.webController.topView belowSubview:self.navBar];
    [UIView animateWithDuration:.3 animations:^{
        [self.webController.bottomView setFrame:CGRectOffset(self.webController.bottomView.frame, 0, self.webController.bottomView.frame.size.height)];
        self.webController.view.alpha = 0;;
    }completion:^(BOOL finished) {
        [self.webController.view removeFromSuperview];
        [UIView animateWithDuration:.3 animations:^{
            self.navBar.alpha = 1;
            [self.listController.tableView reloadRowsAtIndexPaths:@[copy] withRowAnimation:UITableViewRowAnimationAutomatic];
        }completion:^(BOOL finished) {
            [self.webController.topView removeFromSuperview];
            self.webController.webView.delegate = nil;
            [self.webController freeAllMemory];
            self.webController = nil;
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }];
    }];
}


-(void)finishedGravityEffects
{
    [self.webController.view removeFromSuperview];
    self.webController.view.transform = CGAffineTransformIdentity;
    self.webController.view.frame = [UIScreen mainScreen].bounds;
    [self.webController.webView stopLoading];
    [self.webController.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
    [self.animator removeBehavior:self.gravityBehavior];
    [self.animator removeBehavior:self.attachmentBehavior];
    self.animator = nil;
}




@end
