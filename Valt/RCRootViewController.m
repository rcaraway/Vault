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
#import "RCAboutViewController.h"
#import "RCPurchaseViewController.h"
#import "RCWebViewController.h"
#import <MessageUI/MessageUI.h>
#import "RCSearchBar.h"
#import "RCRootViewController+passcodeSegues.h"
#import "RCCloseView.h"
#import "RCRootViewController+searchSegue.h"

@interface RCRootViewController () <MFMailComposeViewControllerDelegate, RCSearchBarDelegate, RCCloseViewDelegate>

@property(nonatomic, strong) MFMailComposeViewController * mailController;
@property(nonatomic, strong) RCAboutViewController * aboutController;
@property(nonatomic, strong) RCPurchaseViewController * purchaseController;
@property(nonatomic, strong) RCWebViewController * webController;


@end

@implementation RCRootViewController


#pragma mark - View LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupViewControllers];
    [self setupSearchBar];
    [self setupCloseView];
    [self launchPasscode];
    self.view.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(BOOL)shouldAutorotate
{
    return NO;
}

-(BOOL)prefersStatusBarHidden
{
    return NO;
}

-(UIViewController *)childViewControllerForStatusBarHidden
{
    if (self.childViewControllers.count > 0)
        return self.childViewControllers[0];
    return nil;
}

-(UIViewController *)childViewControllerForStatusBarStyle
{
    if (self.childViewControllers.count > 0)
        return self.childViewControllers[0];
    return nil;
}


-(void)setupViewControllers
{
    self.listController = [[RCListViewController  alloc] initWithNibName:nil bundle:nil];
    self.searchController = [[RCSearchViewController  alloc] initWithNibName:nil bundle:nil];
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

-(void)launchAbout
{
    if (!self.aboutController){
        self.aboutController = [[RCAboutViewController alloc] init];
    }
    [self presentViewController:self.aboutController animated:YES completion:nil];
}

-(void)launchPurchaseScreen
{
    if (!self.purchaseController){
        self.purchaseController = [[RCPurchaseViewController alloc] initWithNibName:@"PurchaseController" bundle:nil];
    }
    [self presentViewController:self.purchaseController animated:YES completion:nil];
}

-(void)launchBrowserWithPassword:(RCPassword *)password
{
    self.webController = [[RCWebViewController alloc] initWithPassword:password];
    [self presentViewController:self.webController animated:YES completion:nil];
}


#pragma mark - Close View

-(void)setupCloseView
{
    self.closeView = [[RCCloseView alloc] initWithFrame:CGRectMake(0, 44.0/2.0-28.0/2.0+CGRectGetMinY(self.searchBar.frame), 33, 28)];
    self.closeView.delegate = self;
    [self.view addSubview:self.closeView];
}


#pragma mark - Search Bar

-(void)setupSearchBar
{
    self.searchBar = [[RCSearchBar  alloc] initWithFrame:CGRectMake(0, -44, 320, 44)];
    self.searchBar.delegate =self;
    [self.view addSubview:self.searchBar];
}

-(void)searchBarDidBeginEditing:(RCSearchBar *)searchBar
{
    [self setSearchBarSelected];
    self.searchBar.showsCancelButton = YES;
    [self segueListToSearch];
}

-(void)searchBarDidEndEditing:(RCSearchBar *)searchBar
{
 [self setSearchBarUnselected];
}

-(void)searchBar:(RCSearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.searchController filterSearchWithText:searchText];
}

-(void)searchBarCancelTapped:(RCSearchBar *)searchBar
{
    self.searchBar.showsCancelButton = NO;
    [self.view endEditing:YES];
    [self segueSearchToList];
}

-(void)setSearchBarSelected
{
    UITextField *txfSearchField = [_searchBar valueForKey:@"_searchField"];
    txfSearchField.textColor = [UIColor whiteColor];
    txfSearchField.attributedPlaceholder = [[NSAttributedString  alloc] initWithString:@"Search Valt" attributes:@{NSForegroundColorAttributeName: [UIColor cellUnselectedForeground]}];
}

-(void)setSearchBarUnselected
{
    UITextField *txfSearchField = [_searchBar valueForKey:@"_searchField"];
    txfSearchField.textColor = [UIColor whiteColor];
    txfSearchField.attributedPlaceholder = [[NSAttributedString  alloc] initWithString:@"Search Valt" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
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
    if ([self.view.subviews containsObject:self.passcodeController.view]){
        [self.view insertSubview:self.searchBar belowSubview:self.passcodeController.view];
        [self.view insertSubview:self.closeView belowSubview:self.passcodeController.view];
    }else{
         [self.view bringSubviewToFront:self.searchBar];   
    }
    [self.searchBar setFrame:CGRectMake(0, 20, 320, 44)];
    [self.closeView setFrame:CGRectMake(self.closeView.frame.origin.x, 44.0/2.0-28.0/2.0+CGRectGetMinY(self.searchBar.frame), self.closeView.frame.size.width, self.closeView.frame.size.height)];
}

-(void)hideSearch
{
    [self.view bringSubviewToFront:self.searchBar];
    [self.searchBar setFrame:CGRectMake(0, -80, 320, 44)];
    [self.closeView setFrame:CGRectMake(self.closeView.frame.origin.x, self.closeView.frame.origin.y-80, self.closeView.frame.size.width, self.closeView.frame.size.height)];
}


#pragma mark - Feedback

-(void)launchFeedback
{
    if ([MFMailComposeViewController canSendMail]) {
        self.mailController = [[MFMailComposeViewController alloc] init];
        [self.mailController setSubject:@"Valt Feedback"];
        [self.mailController setToRecipients:@[@"rob@getvalt.com"]];
        self.mailController.mailComposeDelegate = self;
        [self presentViewController:self.mailController animated:YES completion:nil];
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)canSendFeedback
{
    return [MFMailComposeViewController canSendMail];
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
