//
//  RCRootViewController.m
//  Valt
//
//  Created by Rob Caraway on 12/10/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

//VCs
#import "RCRootViewController.h"
#import "RCPasscodeViewController.h"
#import "RCListViewController.h"
#import "RCSingleViewController.h"
#import "RCSearchViewController.h"
#import "RCAboutViewController.h"
#import "RCPurchaseViewController.h"
#import "RCWebViewController.h"
#import "RCMenuViewController.h"
#import "RCNotesViewController.h"

//Model
#import "RCPasswordManager.h"

//Categories
#import "UIColor+RCColors.h"
#import "RCRootViewController+menuSegues.h"
#import "RCRootViewController+passcodeSegues.h"
#import "RCRootViewController+searchSegue.h"
#import "UIImage+memoIcons.h"

//View
#import "RCMessageView.h"
#import "RCTableView.h"

//Frameworks
#import <MessageUI/MessageUI.h>


@interface RCRootViewController () <MFMailComposeViewControllerDelegate>


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
    [self setupNavbar];
    [self setupMessageView];
    [self launchPasscode];
    [self addNotifications];
    self.view.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    if (IS_IPAD && (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight || self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft)){
        [self fitViewsToBoundsWithNewOrientation:self.interfaceOrientation];
    }
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


#pragma mark - Orientation

-(NSUInteger)supportedInterfaceOrientations
{
//    if (IS_IPAD){
//        return UIInterfaceOrientationMaskAll;
//    }else
        return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

-(BOOL)shouldAutorotate
{
//    if (IS_IPAD){
//        return YES;
//    }
    return NO;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (IS_IPAD){
        [UIView animateWithDuration:.3 animations:^{
            [self fitViewsToBoundsWithNewOrientation:toInterfaceOrientation];
        }];
    }
}

-(void)fitViewsToBoundsWithNewOrientation:(UIInterfaceOrientation)orientation
{
    CGRect bounds;
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown){
         bounds = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    }else{
         bounds = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    }
    self.view.frame = CGRectMake(0,0, bounds.size.width, bounds.size.height);
    [self.messageView setFrame:CGRectMake(0, 0, bounds.size.width, 20)];
    [self.navBar setFrame:CGRectMake(0, 20, bounds.size.width, 44)];
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
    if (self.passcodeController.isViewLoaded){
        [self.passcodeController.view removeFromSuperview];
        self.passcodeController = nil;
    }
    [self removeAllChildren];
    

    [self setStatusLightContentAnimated:NO];
    if ([UIApplication sharedApplication].statusBarHidden){
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    
    if ([[RCPasswordManager defaultManager] masterPasswordExists]){
        self.passcodeController = [[RCPasscodeViewController  alloc] initWithNewUser:NO];
    }else{
        self.passcodeController = [[RCPasscodeViewController  alloc] initWithNewUser:YES];
    }
    self.passcodeController.opened = NO;
    [self addChildViewController:self.passcodeController];
    [self.view addSubview:self.passcodeController.view];
    [self.view addSubview:self.messageView];
}

-(void)resetViewsForPasscode
{
    if (self.listController.isViewLoaded){
        [self.listController.view removeFromSuperview];
        self.listController = nil;
        self.listController = [[RCListViewController  alloc] initWithNibName:nil bundle:nil];
    }
    if (self.singleController.isViewLoaded){
        [self.singleController.view removeFromSuperview];
        self.singleController = nil;
    }
    [self setNavBarMain];
    self.navBar.alpha = 1;
    self.navBar.transform = CGAffineTransformIdentity;
}

-(void)removeAllChildren
{
    if (self.snapshotView){
        [self.snapshotView removeFromSuperview];
        self.snapshotView = nil;
    }
    if (self.childViewControllers.count > 0){
        NSMutableArray * children = [self.childViewControllers mutableCopy];
        for (UIViewController * vc in children) {
            if (vc.isViewLoaded){
                [vc.view removeFromSuperview];
                [vc removeFromParentViewController];
            }
        }
    }
}

-(void)setStatusLightContentAnimated:(BOOL)animated
{
    void (^messageChange)() = ^(){
        self.messageView.backgroundColor = [UIColor passcodeBackground];
        self.messageView.messageLabel.textColor = [UIColor whiteColor];
    };
    if (animated){
        [UIView animateWithDuration:.2 animations:^{
            messageChange();
        }];
    }else{
        messageChange();
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
}

-(void)setStatusDarkContentAnimated:(BOOL)animated
{
    void (^messageChange)() = ^(){
        self.messageView.backgroundColor = [UIColor navColor];
        self.messageView.messageLabel.textColor = [UIColor blackColor];
    };
    if (animated){
        [UIView animateWithDuration:.2 animations:^{
            messageChange();
        }];
    }else{
        messageChange();
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:animated];
}

-(void)setupViewControllers
{
    self.listController = [[RCListViewController  alloc] initWithNibName:nil bundle:nil];
    self.searchController = [[RCSearchViewController  alloc] initWithNibName:nil bundle:nil];
}


#pragma mark - Nav bar

-(void)setupNavbar
{
    self.navBar = [[UINavigationBar  alloc] initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 44)];
    UINavigationItem * item = [[UINavigationItem  alloc] initWithTitle:@"Valt"];
    [self setupNavButtons];
    
    [item setRightBarButtonItems:@[[[UIBarButtonItem  alloc] initWithCustomView:self.menuButton], [[UIBarButtonItem  alloc] initWithCustomView:self.searchButton]]];
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
    self.searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.menuButton setImage:[[UIImage imageNamed:@"list"] tintedIconWithColor:[UIColor valtPurple]] forState:UIControlStateNormal];
    self.lockButton= [UIButton buttonWithType:UIButtonTypeCustom];
    [self.lockButton setImage:[[UIImage imageNamed:@"lock"] tintedIconWithColor:[UIColor valtPurple]] forState:UIControlStateNormal];
    [self.searchButton setImage:[[UIImage imageNamed:@"search"] tintedIconWithColor:[UIColor valtPurple]] forState:UIControlStateNormal];
    [self.searchButton setFrame:CGRectMake(0, 0, 35, 44)];
    [self.lockButton setFrame:CGRectMake(0, 0, 44, 44)];
    [self.menuButton setFrame:CGRectMake(50, 0, 35, 44)];
    [self.menuButton setImageEdgeInsets:UIEdgeInsetsMake(0, 14, 0, 0)];
    [self.searchButton setImageEdgeInsets:UIEdgeInsetsMake(11, 13, 11, 0)];
    [self.lockButton setImageEdgeInsets:UIEdgeInsetsMake(11, 0, 11, 22)];
    [self.menuButton addTarget:self action:@selector(listTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.lockButton addTarget:self action:@selector(lockTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.searchButton addTarget:self action:@selector(searchTapped) forControlEvents:UIControlEventTouchUpInside];
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
    [button setImage:[[UIImage imageNamed:@"home"] tintedIconWithColor:color] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(closeTapped) forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 60, 44)];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 35)];
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
        [self.menuButton2 setFrame:CGRectMake(0, 0, 60, 44)];
        [self.menuButton2 addTarget:self action:@selector(listTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.menuButton2 setImage:[[UIImage imageNamed:@"list"] tintedIconWithColor:color] forState:UIControlStateNormal];
    [self.menuButton2 setImageEdgeInsets:UIEdgeInsetsMake(0, 39, 0, 0)];
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


#pragma mark - Event Handling

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


#pragma mark - Properties

-(RCNotesViewController *)notesController
{
    if (!_notesController){
        _notesController = [[RCNotesViewController alloc] init];
    }
    return _notesController;
}


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
        if (IS_IPHONE){
            if (IS_IPHONE_5){
                  _purchaseController = [[RCPurchaseViewController alloc] initWithNibName:@"PurchaseController" bundle:nil];
            }else{
                  _purchaseController = [[RCPurchaseViewController alloc] initWithNibName:@"PurchaseControllerSmall" bundle:nil];
            }
        }else{
            _purchaseController = [[RCPurchaseViewController alloc] initWithNibName:@"PurchaseControllerIpad" bundle:nil];
        }
    }
    return _purchaseController;
}

-(RCWebViewController *)webController
{
    if (!_webController){
        if (IS_IPHONE){
            if (IS_IPHONE_5){
                 _webController = [[RCWebViewController  alloc] initWithNibName:@"RCWebViewController" bundle:nil];
            }else{
                 _webController = [[RCWebViewController  alloc] initWithNibName:@"RCWebViewControllerSmall" bundle:nil];
            }
            
        }else{
                 _webController = [[RCWebViewController  alloc] initWithNibName:@"RCWebViewControllerIpad" bundle:nil];            
        }
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
