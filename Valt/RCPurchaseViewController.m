//
//  RCPurchaseViewController.m
//  Valt
//
//  Created by Robert Caraway on 12/19/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCPurchaseViewController.h"

#import "RCAppDelegate.h"
#import "RCRootViewController.h"
#import "RCRootViewController+menuSegues.h"

#import "MLAlertView.h"
#import "HTAutocompleteTextField.h"
#import "RCMessageView.h"

#import "UIView+QuartzEffects.h"
#import "UIColor+RCColors.h"
#import "UIImage+memoIcons.h"

#import "RCNetworking.h"
#import "RCPasswordManager.h"
#import "RCInAppPurchaser.h"

@interface RCPurchaseViewController () <MLAlertViewDelegate>

@property(nonatomic, strong) MLAlertView * alertView;
@property(nonatomic) BOOL wantsFullYear;

@end

@implementation RCPurchaseViewController


#pragma mark - View LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64)];
    [self setupBannerButtons];
    self.monthlyButton.alpha = 0;
    self.yearlyButton.alpha = 0;
    self.yearLabel.alpha = 0;
    self.monthLabel.alpha = 0;

    [self.bannerView setBackgroundColor:[UIColor colorWithPatternImage:[[UIImage imageNamed:@"checker.jpg"] tintedImageWithColorOverlay:[UIColor colorWithRed:1 green:0 blue:0 alpha:.7]]]];
    [self.cancelButton addTarget:self action:@selector(didTapCancel) forControlEvents:UIControlEventTouchUpInside];
    [self.monthlyButton addTarget:self action:@selector(didTapMonthlyPurchase) forControlEvents:UIControlEventTouchUpInside];
    [self.yearlyButton addTarget:self action:@selector(didTapYearlyPurchase) forControlEvents:UIControlEventTouchUpInside];
    [self.restorePurchaseButton addTarget:self action:@selector(didTapLogin) forControlEvents:UIControlEventTouchUpInside];
    [self addNotifications];
    [[RCInAppPurchaser sharePurchaser] loadProducts];
    if ([RCNetworking sharedNetwork].premiumState == RCPremiumStateExpired){
        self.titleLabel.text = @"Renew Platinum Today?";
        UILabel * label =  (UILabel *)[[[[APP rootController] navBar] topItem] titleView];
        label.text = @"Renew Platinum";
    }
    [self.loader startAnimating];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[RCNetworking sharedNetwork] loggedIn]){
        self.restorePurchaseButton.alpha = 0;
    }else{
        self.restorePurchaseButton.alpha = 1;
    }
}

-(void)didLoadProducts
{
    [self.loader stopAnimating];
    [self setupBannerLabels];
    self.monthlyButton.alpha = 1;
    self.yearlyButton.alpha = 1;
    self.yearLabel.alpha = 1;
    self.monthLabel.alpha = 1;
}

-(void)setupBannerButtons
{
    [self.monthlyButton setCornerRadius:5];
    [self.yearlyButton setCornerRadius:5];
    [[self.monthlyButton layer] setBorderWidth:2.0f];
    [[self.monthlyButton layer] setBorderColor:[UIColor colorWithRed:253/255.0 green:246/255.0 blue:146/255.0 alpha:1].CGColor];
    [[self.yearlyButton layer] setBorderWidth:2.0f];
    [[self.yearlyButton layer]setBorderColor:[UIColor colorWithRed:253/255.0 green:246/255.0 blue:146/255.0 alpha:1].CGColor];
    [self addMotionEffects];
}


-(BOOL)shouldAutorotate
{
    return NO;
}

- (void)didReceiveMemoryWarning
{
    if (!self.parentViewController && self.isViewLoaded && !self.view.window){
        [self freeAllMemory];
    }
    [super didReceiveMemoryWarning];
}

-(void)freeAllMemory
{
    [self removeNotifications];
    self.titleLabel = nil;
    self.monthLabel = nil;
    self.monthlyButton = nil;
    self.yearLabel = nil;
    self.yearlyButton =nil;
    self.multiDeviceLabel = nil;
    self.restorePurchaseButton = nil;
    self.cancelButton = nil;
    self.bannerView = nil;
    self.cloudImageView = nil;
    self.deviceImageView = nil;
    self.supportImageView = nil;
    self.alertView = nil;
    self.loader = nil;
    self.view = nil;
}

-(void)dealloc
{
    [self freeAllMemory];
}


#pragma mark - Event Handling

- (IBAction)didPan:(UIPanGestureRecognizer *)sender {
    
    CGFloat translation =[sender translationInView:self.view].x;
    if (sender.state == UIGestureRecognizerStateBegan){
        [[APP rootController] beginDragToMenu];
    }else if (sender.state == UIGestureRecognizerStateChanged){
        
        if (translation <= 20){
            [[APP rootController] dragSideToXOrigin:translation];
        }
    }else if (sender.state == UIGestureRecognizerStateEnded){
        CGFloat velocity = [sender velocityInView:self.view].x;
        if (velocity <= -180.0 || translation <= -160.0){
            [[APP rootController] finishDragWithSegue];
        }else{
            [[APP rootController] finishDragWithClose];
        }
    }
    
}

-(void)didTapCancel
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)didTapLogin
{
    self.alertView = [[MLAlertView  alloc] initWithTitle:@"Login" textFields:YES delegate:self cancelButtonTitle:@"Cancel" confirmButtonTitle:@"Login"];
    [self.alertView show];
}

-(void)didTapMonthlyPurchase
{
    self.wantsFullYear = NO;
    if ([[RCNetworking sharedNetwork] loggedIn]){
        if ([[RCNetworking sharedNetwork] premiumState] == RCPremiumStateCurrent){
            MLAlertView * alert = [[MLAlertView alloc] initWithTitle:@"You've already paid" message:@"Your current subscription is active." cancelButtonTitle:nil otherButtonTitles:@[@"OK"]];
            [alert show];
        }else{
            [self payForYear];
        }
    }else{
        [self showSignup];
    }
}

-(void)didTapYearlyPurchase
{
    self.wantsFullYear = YES;
    if ([[RCNetworking sharedNetwork] loggedIn]){
        if ([[RCNetworking sharedNetwork] premiumState] == RCPremiumStateCurrent){
            MLAlertView * alert = [[MLAlertView alloc] initWithTitle:@"You've already paid" message:@"Your current subscription is active." cancelButtonTitle:nil otherButtonTitles:@[@"OK"]];
            [alert show];
        }else{
            [self payForYear];
        }
    }else{
         [self showSignup];
    }
}

-(void)payForYear
{
    if ([[RCInAppPurchaser sharePurchaser] canMakePurchases] && [[RCInAppPurchaser sharePurchaser] productsExist]){
        [[RCInAppPurchaser sharePurchaser] purchaseYear];
    }
}

-(void)payForMonth
{
    if ([[RCInAppPurchaser sharePurchaser] canMakePurchases] && [[RCInAppPurchaser sharePurchaser] productsExist]){
        [[RCInAppPurchaser sharePurchaser] purchaseMonth];
    }
}


#pragma mark - NSNotifications

-(void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoadProducts) name:purchaseDidLoadProducts object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSignup) name:networkingDidSignup object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailSignup:) name:networkingDidFailToSignup object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBeginSigningUp) name:networkingDidBeginSigningUp object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin) name:networkingDidLogin object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailToLogin) name:networkingDidFailToLogin object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailToPurchase) name:purchaserDidFail object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(didSucceedPurchasingProduct) name:purchaserDidPayMonthly object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(didSucceedPurchasingProduct) name:purchaserDidPayYearly object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailToGetProducts) name:purchaserDidFailToLoadProducts object:nil];
}

-(void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:purchaseDidLoadProducts object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:networkingDidLogin object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:networkingDidFailToLogin object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:purchaserDidFail object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:purchaserDidPayMonthly object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:purchaserDidPayYearly object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:networkingDidSignup object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:networkingDidFailToSignup object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:networkingDidBeginSigningUp object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:purchaserDidPayMonthly object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:purchaserDidPayYearly object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:purchaserDidFailToLoadProducts object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:purchaserDidFail object:nil];
}

-(void)didFailToGetProducts
{
    [self.loader stopAnimating];
    [[[APP rootController] messageView] showMessage:@"Could not get upgrades" autoDismiss:YES];
}

-(void)didBeginLoggingIn
{
    [self.alertView loadWithText:@"Logging in..."];
}

-(void)didLogin
{
    [self.alertView dismissWithSuccess];
    [APP setSwipeRightHint:NO];
    [APP setAutofillHints:NO];
    if ([[RCNetworking sharedNetwork] premiumState] == RCPremiumStateCurrent && self.parentViewController && self.isViewLoaded && self.view.window){
        [[APP rootController] goHome];
    }else if ([RCNetworking sharedNetwork].premiumState == RCPremiumStateExpired){
        self.titleLabel.text = @"Renew Platinum Today?";
        UILabel * label =  (UILabel *)[[[[APP rootController] navBar] topItem] titleView];
        label.text = @"Renew Platinum";
    }
}

-(void)didFailToLogin
{
    [self.alertView showFailWithTitle:@"Login Failed"];
}

-(void)didBeginPurchasing
{
}

-(void)didSucceedPurchasingProduct
{
    [[APP rootController] goHome];
}

-(void)didFailToPurchase
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self.alertView = [[MLAlertView  alloc] initWithTitle:@"Failed to Purchase" message:@"Could not complete purchase at this time." cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [self.alertView showFailWithTitle:@"Failed To Purchase"];
    [self.alertView show];
}

-(void)didBeginSigningUp
{
    [self.alertView loadWithText:@"Signing up..."];
}

-(void)didSignup
{
    [self.alertView dismissWithSuccess];
    
    if (self.wantsFullYear){
        [self payForYear];
    }else{
        [self payForMonth];
    }
    self.restorePurchaseButton.alpha = 0;
}

-(void)didFailSignup:(NSNotification *)notification
{
    NSString * message = notification.object;
    [self.alertView showFailWithTitle:message];
}


#pragma mark - View setup

-(void)setupBannerLabels
{
    NSString * month = [NSString stringWithFormat:@"%@ Monthly", [[RCInAppPurchaser sharePurchaser] localizedPriceForMonthly]];
    NSString * year = [NSString stringWithFormat:@"%@ Yearly",  [[RCInAppPurchaser sharePurchaser] localizedPriceForYearly]];
    NSMutableAttributedString * monthString = [[NSMutableAttributedString alloc] initWithString:month];
    NSMutableAttributedString * yearString = [[NSMutableAttributedString alloc] initWithString:year];
    NSDictionary * atts1 = @{NSFontAttributeName: [UIFont fontWithName:@"GillSans" size:23]};
    NSDictionary * atts2 = @{NSFontAttributeName: [UIFont fontWithName:@"GillSans" size:16]};
    [monthString addAttributes:atts1 range:[month rangeOfString:[[RCInAppPurchaser sharePurchaser] localizedPriceForMonthly]]];
    [monthString addAttributes:atts2 range:[month rangeOfString:@"Monthly"]];
    [yearString addAttributes:atts1 range:[year rangeOfString:[[RCInAppPurchaser sharePurchaser] localizedPriceForYearly]]];
    [yearString addAttributes:atts2 range:[year rangeOfString:@"Yearly"]];
    self.monthLabel.attributedText = monthString;
    self.yearLabel.attributedText = yearString;
}

-(void)addMotionEffects
{
    UIInterpolatingMotionEffect *verticalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.y"
     type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(-10);
    verticalMotionEffect.maximumRelativeValue = @(10);
    UIInterpolatingMotionEffect *horizontalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.x"
     type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(-10);
    horizontalMotionEffect.maximumRelativeValue = @(10);
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    [self.monthlyButton addMotionEffect:group];
    [self.yearlyButton addMotionEffect:group];
    [self.monthLabel addMotionEffect:group];
    [self.yearLabel addMotionEffect:group];
}

#pragma mark - Alert View

-(void)showSignup
{
    self.alertView = [[MLAlertView  alloc] initWithTitle:@"Signup for Premium" textFields:YES delegate:self cancelButtonTitle:@"Cancel" confirmButtonTitle:@"Signup"];
    self.alertView.passwordTextField.placeholder = @"Your Master Password";
    [self.alertView show];
}

-(void)alertView:(MLAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
}

-(void)alertView:(MLAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex withText:(NSString *)text
{
}

-(void)alertView:(MLAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex withEmail:(NSString *)email password:(NSString *)password
{
    if (![alertView.titleLabel.text isEqualToString:@"Login"]){
        [self.alertView loadWithText:@"Signing Up"];
        [self signupWithEmail:email password:password];
    }else{
        [self loginWithEmail:email password:password];
        [self.alertView loadWithText:@"Logging In"];
    }
}

-(void)alertViewTappedCancel:(MLAlertView *)alertView
{
    
}


#pragma mark - Actions / State Handling

-(void)loginWithEmail:(NSString *)email password:(NSString *)password
{
    [[RCNetworking sharedNetwork] loginWithEmail:email password:password];
}

-(void)signupWithEmail:(NSString *)email password:(NSString *)password
{
    if ([self isValidEmail]){
        if ([self isValidPassword]){
            [[RCNetworking sharedNetwork] signupWithEmail:email password:password];
        }else{
            [self.alertView showFailWithTitle:@"Invalid Master Password"];
        }
    }else{
        [self.alertView showFailWithTitle:@"Invalid Email"];
    }
}


#pragma mark - Convenience 

-(BOOL)isValidEmail
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self.alertView.loginTextField.text];
}

-(BOOL)isValidPassword
{
    return [self.alertView.passwordTextField.text isEqualToString:[[RCPasswordManager defaultManager] masterPassword]];
}

@end
