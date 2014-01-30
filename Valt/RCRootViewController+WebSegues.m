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

#import "RCPasswordManager.h"
#import "RCPassword.h"

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@implementation RCRootViewController (WebSegues)


#pragma mark - Segues

-(void)segueToWebFromIndexPath:(NSIndexPath *)indexPath
{
    RCPassword * password = [[RCPasswordManager defaultManager] passwords][indexPath.row];
    CGRect cellRect = [self.listController.tableView rectForRowAtIndexPath:indexPath];
    [self addChildViewController:self.webController];
    self.webController.password = password;
    [self.webController loadPasswordRequest];
    [self.view insertSubview:self.webController.view belowSubview:self.listController.view];
    [self.webController.bottomView setFrame:CGRectOffset(self.webController.bottomView.frame, 0, self.webController.bottomView.frame.size.height)];
    [self.webController.topView setFrame:CGRectOffset(self.webController.topView.frame, 0, -self.webController.topView.frame.size.height-20)];
    self.listController.webPath = indexPath;
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.listController.tableView setContentOffset:CGPointMake(0, cellRect.origin.y)];
        [self.listController.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        self.navBar.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.23 animations:^{
            self.listController.view.alpha = 0;
            [self.webController.bottomView setFrame:CGRectOffset(self.webController.bottomView.frame, 0, -self.webController.bottomView.frame.size.height)];
            [self.webController.topView setFrame:CGRectOffset(self.webController.topView.frame, 0, self.webController.topView.frame.size.height+20)];
        }completion:^(BOOL finished) {
            [self.view bringSubviewToFront:self.webController.view];
            [self.view bringSubviewToFront:self.messageView];
            self.listController.view.alpha = 1;
        }];
    }];
}

-(void)closeWeb
{
    [self.webController removeFromParentViewController];
    [self.webController.webView stopLoading];
        NSIndexPath * copy = [self.listController.webPath copy];
    self.listController.webPath = nil;

    [UIView animateWithDuration:.23 animations:^{
        [self.webController.bottomView setFrame:CGRectOffset(self.webController.bottomView.frame, 0, self.webController.bottomView.frame.size.height)];
        [self.webController.topView setFrame:CGRectOffset(self.webController.topView.frame, 0, -self.webController.topView.frame.size.height-20)];
        self.webController.view.alpha = 0;
    }completion:^(BOOL finished) {
        [self.webController.view removeFromSuperview];
        [UIView animateWithDuration:.3 animations:^{
            [self.listController.tableView reloadRowsAtIndexPaths:@[copy] withRowAnimation:UITableViewRowAnimationAutomatic];
            self.navBar.alpha = 1;
        }completion:^(BOOL finished) {
            self.webController.webView.delegate = nil;
            [self.webController freeAllMemory];
            self.webController = nil;
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
