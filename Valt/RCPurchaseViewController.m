//
//  RCPurchaseViewController.m
//  Valt
//
//  Created by Robert Caraway on 12/19/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCPurchaseViewController.h"
#import "MLAlertView.h"
#import "RCNetworking.h"
#import "RCInAppPurchaser.h"
#import "HTAutocompleteTextField.h"
#import "RCPasswordManager.h"

@interface RCPurchaseViewController () <MLAlertViewDelegate>

@property(nonatomic, strong) MLAlertView * alertView;
@property(nonatomic) BOOL wantsFullYear;

@end

@implementation RCPurchaseViewController


#pragma mark - View LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.cancelButton addTarget:self action:@selector(didTapCancel) forControlEvents:UIControlEventTouchUpInside];
    [self.monthlyButton addTarget:self action:@selector(didTapMonthlyPurchase) forControlEvents:UIControlEventTouchUpInside];
    [self.yearlyButton addTarget:self action:@selector(didTapYearlyPurchase) forControlEvents:UIControlEventTouchUpInside];
    [self.restorePurchaseButton addTarget:self action:@selector(didTapLogin) forControlEvents:UIControlEventTouchUpInside];
    [self addNotifications];
    [[RCInAppPurchaser sharePurchaser] loadProducts];
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

- (void)didReceiveMemoryWarning
{
    [self removeNotifications];
    [super didReceiveMemoryWarning];
}


#pragma mark - Event Handling

-(void)didTapCancel
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)didTapLogin
{
    self.alertView = [[MLAlertView  alloc] initWithTitle:@"Login" textFields:YES delegate:self cancelButtonTitle:nil confirmButtonTitle:@"Create Account"];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSignup) name:networkingDidSignup object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailSignup:) name:networkingDidFailToSignup object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBeginSigningUp) name:networkingDidBeginSigningUp object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailToPurchase) name:purchaserDidFail object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(didSucceedPurchasingProduct) name:purchaserDidPayMonthly object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(didSucceedPurchasingProduct) name:purchaserDidPayYearly object:nil];
}

-(void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:networkingDidSignup object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:networkingDidFailToSignup object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:networkingDidBeginSigningUp object:nil];
}

-(void)didBeginPurchasing
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

-(void)didSucceedPurchasingProduct
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
    [self.alertView dismiss];
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
