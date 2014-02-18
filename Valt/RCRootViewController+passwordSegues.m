//
//  RCRootViewController+passwordSegues.m
//  Valt
//
//  Created by Robert Caraway on 1/16/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCRootViewController+passwordSegues.h"
#import "UIColor+RCColors.h"

#import "RCSingleViewController.h"
#import "RCListViewController.h"

#import "RCAppDelegate.h"
#import "RCPassword.h"
#import "RCPasswordManager.h"

#import "RCMessageView.h"
#import "RCTableView.h"
#import "RCTitleViewCell.h"
#import "HTAutocompleteTextField.h"
#import "RCMainCell.h"

#import <objc/runtime.h>

static void * OffsetKey;
static void * ContentSizeKey;

@implementation RCRootViewController (passwordSegues)



#pragma mark - Segues


-(void)segueSingleToList
{
    [self addChildViewController:self.listController];
    [self.singleController removeFromParentViewController];
    [self transitionFromSingleToList];
}

-(void)segueToSingleWithPassword:(RCPassword *)password
{
    self.singleController = [[RCSingleViewController alloc] initWithPassword:password];
    [self addChildViewController:self.singleController];
    [self.listController removeFromParentViewController];
    [self.listController hideHintLabels];
    [self transitionFromListToSingleWithPassword:password];
}

-(void)segueToSingleWithNewPasswordAtLocation:(CGPoint)location
{
    RCPassword * password = [[RCPassword alloc] init];
    [[RCPasswordManager defaultManager] addPassword:password];
    self.singleController = [[RCSingleViewController alloc] initWithPassword:password];
    [self addChildViewController:self.singleController];
    [self.listController hideHintLabels];
    [self.listController removeFromParentViewController];
    [self transitionToSingleWithNewCellAtLocation:location];
}


#pragma mark - Transitions

-(void)transitionToSingleWithNewCellAtLocation:(CGPoint)location
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    CGRect ogRect = self.singleController.view.frame;
    CGRect bottomRect = [self.listController.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.listController.tableView numberOfRowsInSection:0]-1 inSection:0]];
    CGRect adjustRect = CGRectMake(bottomRect.origin.x, bottomRect.origin.y - self.listController.tableView.contentOffset.y, bottomRect.size.width, bottomRect.size.height);
    [self setOriginalSize:self.listController.tableView.contentSize];
    [self setOriginalOffset:self.listController.tableView.contentOffset];
    [self.singleController.view setFrame:CGRectMake(0, adjustRect.origin.y+bottomRect.size.height, self.singleController.view.frame.size.width, self.singleController.view.frame.size.height)];
    self.singleController.view.backgroundColor = [UIColor clearColor];
    self.singleController.view.alpha = 0;
    [self.view addSubview:self.singleController.view];
    [self.singleController.tableView reloadData];
    
    RCTitleViewCell * cell = (RCTitleViewCell *)[self.singleController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    self.listController.viewPath = [NSIndexPath indexPathForRow:[[RCPasswordManager defaultManager] passwords].count inSection:0];
    NSIndexPath * addPath = [NSIndexPath indexPathForRow:[[RCPasswordManager defaultManager] passwords].count-1 inSection:0];
    NSArray * paths = @[self.listController.viewPath, addPath];
    
    [UIView animateWithDuration:.14 animations:^{
        self.singleController.view.alpha = 1;
    }completion:^(BOOL finished) {
        [self.listController.tableView setExtendedSize:YES];
        [UIView animateWithDuration:.3 animations:^{
            [self setStatusLightContentAnimated:YES];
            self.navBar.transform = CGAffineTransformTranslate(self.navBar.transform, 0, -64);
            [self.listController.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
            [self.listController.tableView setContentOffset:CGPointMake(0, bottomRect.origin.y+bottomRect.size.height)];
            self.singleController.isTransitioningTo = NO;
            [self.listController.tableView setShouldAllowMovement:NO];
            self.singleController.view.backgroundColor = [UIColor colorWithWhite:.1 alpha:.75];
            self.singleController.view.frame = ogRect;
            [cell setPurpleColoed];
            [self.singleController.tableView insertRowsAtIndexPaths:[self dropDownPaths] withRowAnimation:UITableViewRowAnimationFade];
            [self.singleController setAllTextFieldDelegates];
            [cell.textField becomeFirstResponder];
            [[APP rootController].view bringSubviewToFront:self.messageView];
        }completion:^(BOOL finished) {
            if ([APP autofillHints]){
                [[[APP rootController] messageView] showMessage:@"Begin Typing..." autoDismiss:NO];
            }
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }];
    }];
}

-(void)transitionFromSingleToList
{
    if (self.singleController.tableView.contentOffset.y == 0){
        [self transitionNormallyFromSingleToList];
    }else{
        [self transitionPullUpFromSingleToList];
    }
}

-(void)transitionFromListToSingleWithPassword:(RCPassword *)password
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    NSInteger index =[[[RCPasswordManager defaultManager] passwords] indexOfObject:password];
    self.singleController.view.backgroundColor = [UIColor clearColor];
    CGRect cellRect = [self rectForCellAtIndex:index];
    CGRect cellRectAdjusted = CGRectOffset(cellRect, -self.listController.tableView.contentOffset.x, -self.listController.tableView.contentOffset.y-self.listController.tableView.contentInset.top);
    CGRect originalRect = self.singleController.tableView.frame;
    [self setOriginalSize:self.listController.tableView.contentSize];
    [self.singleController.tableView reloadData];
    [self setOriginalOffset:self.listController.tableView.contentOffset];
    [self.singleController.tableView setFrame:CGRectMake(0, cellRectAdjusted.origin.y+64, self.singleController.tableView.frame.size.width, self.singleController.tableView.frame.size.height)];
    self.listController.viewPath = [NSIndexPath indexPathForRow:index+1 inSection:0];
    [self.view addSubview:self.singleController.view];
    [self.listController.tableView setExtendedSize:YES];

    [UIView animateWithDuration:.3 animations:^{
        [self setStatusLightContentAnimated:YES];
        self.navBar.transform = CGAffineTransformTranslate(self.navBar.transform, 0, -64);
        [self.listController.tableView insertRowsAtIndexPaths:@[self.listController.viewPath] withRowAnimation:UITableViewRowAnimationFade];
        self.singleController.view.backgroundColor = [UIColor colorWithWhite:.1 alpha:.75];
        [self.listController.tableView setContentOffset:CGPointMake(0, cellRect.origin.y)];
        [self.listController.tableView setShouldAllowMovement:NO];
        self.singleController.isTransitioningTo = NO;
        [self.singleController.tableView insertRowsAtIndexPaths:[self dropDownPaths] withRowAnimation:UITableViewRowAnimationBottom];
        [self.singleController.tableView setFrame:originalRect];
        [(RCTitleViewCell *)[self.singleController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] setPurpleColoed];
        UITextField * field = (UITextField *)[(RCTitleViewCell *)[self.singleController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] textField];
        [field becomeFirstResponder];
        [[APP rootController].view bringSubviewToFront:self.messageView];
    }completion:^(BOOL finished) {
        if ([APP autofillHints]){
            [[[APP rootController] messageView] showMessage:@"Begin Typing..." autoDismiss:NO];
        }
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}



#pragma mark - Extra Properties

-(void)setOriginalOffset:(CGPoint)offset
{
    objc_setAssociatedObject(self, OffsetKey, [NSValue valueWithCGPoint:offset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(CGPoint)originalOffset
{
    NSValue * value = objc_getAssociatedObject(self, OffsetKey);
    return [value CGPointValue];
}

-(void)setOriginalSize:(CGSize)size
{
    objc_setAssociatedObject(self,ContentSizeKey, [NSValue valueWithCGSize:size], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(CGSize)originalSize
{
    NSValue * value = objc_getAssociatedObject(self, ContentSizeKey);
    return [value CGSizeValue];
}

#pragma mark - Convenience

-(void)transitionPullUpFromSingleToList
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    NSIndexPath * indexPath = [self.listController.viewPath copy];
    self.listController.viewPath = nil;
    NSInteger index = [[[RCPasswordManager defaultManager] passwords] indexOfObject:self.singleController.password];
    CGRect cellRect = [self rectForCellAtIndex:index];
    CGRect cellRectAdjusted = CGRectOffset(cellRect, -[self originalOffset].x, -[self originalOffset].y-self.listController.tableView.contentInset.top);
    CGPoint offset = [self originalOffset];
    self.singleController.isTransitioningTo = YES;
    [self.listController.tableView setShouldAllowMovement:YES];
    [self removeHintsIfNeeded];
    [UIView animateWithDuration:.3 animations:^{
        [self setStatusDarkContentAnimated:YES];
        self.navBar.transform = CGAffineTransformIdentity;
        [self.singleController.tableView setFrame:CGRectMake(0, cellRectAdjusted.origin.y+57, self.singleController.tableView.frame.size.width, self.singleController.tableView.frame.size.height)];
        self.singleController.view.alpha = 0;
        [self.listController.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        [self.listController.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [(RCTitleViewCell *)[self.singleController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] setNormalColored];
        [self.singleController.tableView deleteRowsAtIndexPaths:[self dropDownPaths] withRowAnimation:UITableViewRowAnimationFade];
        [self.listController.tableView setContentOffset:offset];
    [self.listController.tableView setExtendedSize:NO];
        self.view.backgroundColor = [UIColor listBackground];
    }completion:^(BOOL finished) {
        [self.singleController.view removeFromSuperview];
        [self performSelector:@selector(removeCellIfNeeded) withObject:nil afterDelay:.05];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}

-(void)transitionNormallyFromSingleToList
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    NSIndexPath * indexPath = [self.listController.viewPath copy];
    self.listController.viewPath = nil;
    NSInteger index = [[[RCPasswordManager defaultManager] passwords] indexOfObject:self.singleController.password];
    CGRect cellRect = [self rectForCellAtIndex:index];
     CGRect cellRectAdjusted = CGRectOffset(cellRect, -[self originalOffset].x, -[self originalOffset].y-self.listController.tableView.contentInset.top);
    CGPoint offset = [self originalOffset];
    self.singleController.isTransitioningTo = YES;
    [self.listController.tableView setShouldAllowMovement:YES];
    [self removeHintsIfNeeded];
    [UIView animateWithDuration:.3  animations:^{
        [self setStatusDarkContentAnimated:YES];
        self.navBar.transform = CGAffineTransformIdentity;
        [self.singleController.tableView setFrame:CGRectMake(0, cellRectAdjusted.origin.y+64, self.singleController.tableView.frame.size.width, self.singleController.tableView.frame.size.height)];
        [self.listController.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        [self.listController.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [(RCTitleViewCell *)[self.singleController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] setNormalColored];
        [self.singleController.tableView deleteRowsAtIndexPaths:[self dropDownPaths] withRowAnimation:UITableViewRowAnimationFade];
        self.singleController.view.backgroundColor = [UIColor clearColor];
        [self.listController.tableView setContentOffset:offset];
        [self.listController.tableView setExtendedSize:NO];
        self.view.backgroundColor = [UIColor listBackground];
    } completion:^(BOOL finished) {
        self.singleController.view.alpha = 0;
        [self.singleController.view removeFromSuperview];
        [self performSelector:@selector(removeCellIfNeeded) withObject:nil afterDelay:.05];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}

-(void)removeCellIfNeeded
{
    if ([self.singleController.password isEmpty]){
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:[[[RCPasswordManager defaultManager] passwords] indexOfObject:self.singleController.password] inSection:0];
        [[RCPasswordManager defaultManager] removePassword:self.singleController.password];
        [self.listController.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        if ([RCPasswordManager defaultManager].passwords.count == 0){
            [self.listController showPullDownViews];
        }
    }else if ([APP swipeRightHint]){
        [self.listController hideHintLabels];
        [self.listController showSwipeRightViews];
    }
}

-(void)removeHintsIfNeeded
{
    if ([APP autofillHints]){
        if (![self.singleController.password isEmpty]){
            [APP setAutofillHints:NO];
            [self.messageView hideMessage];
        }
    }
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
