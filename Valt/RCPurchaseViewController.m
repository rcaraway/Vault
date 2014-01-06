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
}

-(void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:networkingDidSignup object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:networkingDidFailToSignup object:nil];
}

-(void)didSignup
{
    
}

-(void)didFailSignup:(NSNotification *)notification
{
    NSString * message = notification.object;
    [self.alertView showFailWithTitle:message];
}

#pragma mark - Alert View

-(void)showSignup
{
    self.alertView = [[MLAlertView  alloc] initWithTitle:@"Signup for Premium" textFields:YES delegate:self cancelButtonTitle:nil confirmButtonTitle:@"Create Account"];
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
    
    [[RCNetworking sharedNetwork] signupWithEmail:email password:password];
}

@end
