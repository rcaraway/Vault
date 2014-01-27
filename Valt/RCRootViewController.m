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
#import "RCRootViewController+searchSegue.h"
#import "UIImage+memoIcons.h"
#import "RCMenuViewController.h"
#import "RCRootViewController+menuSegues.h"

@interface RCRootViewController () <MFMailComposeViewControllerDelegate, RCSearchBarDelegate>


@property(nonatomic, strong) UIView * buttonView;
@property(nonatomic, strong) UIButton * searchButton;
@property(nonatomic, strong) UIButton * menuButton;
@property(nonatomic, strong) UIButton * menuButton2;
@property(nonatomic, strong) UIButton * lockButton;

@end

@implementation RCRootViewController


#pragma mark - View LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupViewControllers];
    [self setupSearchBar];
    [self launchPasscode];
    [self setupNavbar];
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


#pragma mark - Nav bar

-(void)setupNavbar
{
    self.navBar = [[UINavigationBar  alloc] initWithFrame:CGRectMake(0, 20, 320, 44)];
    UINavigationItem * item = [[UINavigationItem  alloc] initWithTitle:@"Valt"];
    [self setupNavButtons];
    [item setRightBarButtonItem:[[UIBarButtonItem  alloc] initWithCustomView:self.buttonView]];
    [item setLeftBarButtonItem:[[UIBarButtonItem  alloc] initWithCustomView:self.lockButton]];
    [item setTitle:@"Valt"];
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, 43.0f, self.navBar.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor colorWithWhite:0.95f
                                                     alpha:1.0f].CGColor;
    [self.navBar.layer addSublayer:bottomBorder];
    [self.navBar pushNavigationItem:item animated:NO];
}

-(void)setupNavButtons
{
    self.buttonView = [[UIView  alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    self.searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.menuButton setImage:[[UIImage imageNamed:@"list"] tintedIconWithColor:[UIColor valtPurple]] forState:UIControlStateNormal];
    self.lockButton= [UIButton buttonWithType:UIButtonTypeCustom];
    [self.lockButton setImage:[[UIImage imageNamed:@"lock"] tintedIconWithColor:[UIColor valtPurple]] forState:UIControlStateNormal];
    [self.searchButton setImage:[[UIImage imageNamed:@"search"] tintedIconWithColor:[UIColor valtPurple]] forState:UIControlStateNormal];
    [self.searchButton setFrame:CGRectMake(0, 0, 30, 44)];
    [self.lockButton setFrame:CGRectMake(0, 0, 30, 44)];
    [self.menuButton setFrame:CGRectMake(30, 0, 30, 44)];
    [self.menuButton addTarget:self action:@selector(listTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.lockButton addTarget:self action:@selector(lockTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonView addSubview:self.searchButton];
    [self.buttonView addSubview:self.menuButton];
}


-(void)setNavBarMain
{
    if (self.navBar.items.count >= 2){
        [self.navBar popNavigationItemAnimated:YES];
    }
}

-(void)setNavBarAlternateWithTitle:(NSString *)title
{
    if (!self.menuButton2){
        self.menuButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.menuButton2 setImage:[[UIImage imageNamed:@"list"] tintedIconWithColor:[UIColor valtPurple]] forState:UIControlStateNormal];
        [self.menuButton2 setFrame:CGRectMake(0, 0, 30, 44)];
        [self.menuButton2 addTarget:self action:@selector(listTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    UINavigationItem * item = [[UINavigationItem alloc] initWithTitle:title];
    UIBarButtonItem * close = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStylePlain target:self action:@selector(closeTapped)];
    [item setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:self.menuButton2]];
    [item setLeftBarButtonItem:close];
    if (self.navBar.items.count >= 2){
        [self.navBar popNavigationItemAnimated:NO];
    }
    [self.navBar pushNavigationItem:item animated:NO];
}

-(void)closeTapped
{
    [self goHome];
}

-(void)lockTapped
{
    [self returnToPasscodeFromList];
}

-(void)listTapped
{
    [self segueToMenu];
}

-(void)searchTapped
{
    
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
    txfSearchField.attributedPlaceholder = [[NSAttributedString  alloc] initWithString:@"Search Valt" attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
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
    }else{
         [self.view bringSubviewToFront:self.searchBar];   
    }
    [self.searchBar setFrame:CGRectMake(0, 20, 320, 44)];
}

-(void)hideSearch
{
    [self.view bringSubviewToFront:self.searchBar];
    [self.searchBar setFrame:CGRectMake(0, -80, 320, 44)];
}


#pragma mark - Properties

-(RCAboutViewController *)aboutController
{
    if (!_aboutController){
        _aboutController = [[RCAboutViewController alloc] init];
    }
    return _aboutController;
}

-(RCPurchaseViewController *)purchaseController
{
    if (!_purchaseController){
        _purchaseController = [[RCPurchaseViewController alloc] initWithNibName:@"PurchaseController" bundle:nil];
    }
    return _purchaseController;
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
