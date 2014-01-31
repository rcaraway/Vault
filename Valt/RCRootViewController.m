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
#import "RCMessageView.h"

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
    [self setupMessageView];
    [self addNotifications];
    self.view.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
}

- (void)didReceiveMemoryWarning
{
    [self freeAvailableMemory];
    [super didReceiveMemoryWarning];
}

-(void)freeAvailableMemory
{
    if (self.mailController && !self.presentedViewController){
        self.mailController = nil;
    }
    if (self.snapshotView && !self.snapshotView.superview){
        self.snapshotView = nil;
    }
}


#pragma mark - Settings

-(BOOL)shouldAutorotate
{
    return NO;
}

-(void)setupMessageView
{
    self.messageView = [[RCMessageView  alloc] init];
}


#pragma mark - NSNotification Events

-(void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willUpdateMessage) name:messageViewWillShow object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willUpdateMessage) name:messageViewWillHide object:nil];
}

-(void)willUpdateMessage
{
    [self setNeedsStatusBarAppearanceUpdate];
}


#pragma mark - State Handling

-(void)launchPasscode
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    if (!self.passcodeController){
        if ([[RCPasswordManager defaultManager] masterPasswordExists]){
            self.passcodeController = [[RCPasscodeViewController  alloc] initWithNewUser:NO];
        }else{
            self.passcodeController = [[RCPasscodeViewController  alloc] initWithNewUser:YES];
        }
    }
    self.passcodeController.opened = NO;
    [self addChildViewController:self.passcodeController];
    [self.view addSubview:self.passcodeController.view];
}

-(void)setupViewControllers
{
    self.listController = [[RCListViewController  alloc] initWithNibName:nil bundle:nil];
    self.searchController = [[RCSearchViewController  alloc] initWithNibName:nil bundle:nil];
}


#pragma mark - Nav bar

-(void)setupNavbar
{
    self.navBar = [[UINavigationBar  alloc] initWithFrame:CGRectMake(0, 20, 320, 44)];
    UINavigationItem * item = [[UINavigationItem  alloc] initWithTitle:@"Valt"];
    [self setupNavButtons];
    
    [item setRightBarButtonItem:[[UIBarButtonItem  alloc] initWithCustomView:self.buttonView]];
    [item setLeftBarButtonItem:[[UIBarButtonItem  alloc] initWithCustomView:self.lockButton]];
    [item setTitleView:[self navLabelWithTitle:@"Logins" color:[UIColor valtPurple]]];
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, 43.0f, self.navBar.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor colorWithWhite:0.96f
                                                     alpha:1.0f].CGColor;
    [self.navBar.layer addSublayer:bottomBorder];
    self.navBar.translucent = NO;
    [self.navBar setBarTintColor:[UIColor navColor]];
    [self.navBar pushNavigationItem:item animated:NO];
}

-(void)setupNavButtons
{
    self.buttonView = [[UIView  alloc] initWithFrame:CGRectMake(0, 0, 88, 44)];
    self.searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.menuButton setImage:[[UIImage imageNamed:@"list"] tintedIconWithColor:[UIColor valtPurple]] forState:UIControlStateNormal];
    self.lockButton= [UIButton buttonWithType:UIButtonTypeCustom];
    [self.lockButton setImage:[[UIImage imageNamed:@"lock"] tintedIconWithColor:[UIColor valtPurple]] forState:UIControlStateNormal];
    [self.searchButton setImage:[[UIImage imageNamed:@"search"] tintedIconWithColor:[UIColor valtPurple]] forState:UIControlStateNormal];
    [self.searchButton setFrame:CGRectMake(0, 0, 44, 44)];
    [self.lockButton setFrame:CGRectMake(0, 0, 44, 44)];
    [self.menuButton setFrame:CGRectMake(50, 0, 44, 44)];
    [self.menuButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.searchButton setImageEdgeInsets:UIEdgeInsetsMake(11, 22, 11, 0)];
    [self.lockButton setImageEdgeInsets:UIEdgeInsetsMake(11, 0, 11, 22)];
    [self.menuButton addTarget:self action:@selector(listTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.lockButton addTarget:self action:@selector(lockTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.searchButton addTarget:self action:@selector(searchTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonView addSubview:self.searchButton];
    [self.buttonView addSubview:self.menuButton];
}

-(UILabel *)navLabelWithTitle:(NSString *)title color:(UIColor *)color
{
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    [label setFont:[UIFont boldSystemFontOfSize:17]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setText:title];
    [label setTextColor:color];
    [label setBackgroundColor:[UIColor navColor]];
    return label;
}

-(UIButton *)navHomeIconWithColor:(UIColor *)color
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[[UIImage imageNamed:@"valtSmall"] tintedImageWithColorOverlay:color] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(closeTapped) forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 44, 44)];
    return button;
}

-(void)setNavBarMain
{
    if (self.navBar.items.count >= 2){
        [self.navBar popNavigationItemAnimated:YES];
    }
}

-(void)setNavBarAlternateWithTitle:(NSString *)title color:(UIColor *)color
{
    if (!self.menuButton2){
        self.menuButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.menuButton2 setFrame:CGRectMake(0, 0, 30, 44)];
        [self.menuButton2 addTarget:self action:@selector(listTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.menuButton2 setImage:[[UIImage imageNamed:@"list"] tintedIconWithColor:color] forState:UIControlStateNormal];
    UINavigationItem * item = [[UINavigationItem alloc] initWithTitle:title];
    UIBarButtonItem * close = [[UIBarButtonItem alloc] initWithCustomView:[self navHomeIconWithColor:color]];
    [item setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:self.menuButton2]];
    [item setLeftBarButtonItem:close];
    [item setTitleView:[self navLabelWithTitle:title color:color]];
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
    [self segueListToSearch];
}




#pragma mark - Search Bar

-(void)setupSearchBar
{
    self.searchBar = [[RCSearchBar  alloc] initWithFrame:CGRectMake(0, 20, 320, 44)];
    self.searchBar.delegate =self;
}

-(void)searchBarDidBeginEditing:(RCSearchBar *)searchBar
{
   
}

-(void)searchBarDidEndEditing:(RCSearchBar *)searchBar
{

}

-(void)searchBar:(RCSearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.searchController filterSearchWithText:searchText];
}

-(void)searchBarCancelTapped:(RCSearchBar *)searchBar
{
    [self.view endEditing:YES];
    [self segueSearchToList];
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

-(RCWebViewController *)webController
{
    if (!_webController){
        _webController = [[RCWebViewController  alloc] initWithNibName:@"RCWebViewController" bundle:nil];
    }
    return _webController;
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


@end
