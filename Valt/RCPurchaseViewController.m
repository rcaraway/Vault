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

@interface RCPurchaseViewController () <MLAlertViewDelegate>

@property(nonatomic, strong) MLAlertView * alertView;

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

-(void)didTapMonthlyPurchase
{
    [self showSignup];
}

-(void)didTapLogin
{
    
}

-(void)didTapYearlyPurchase
{
    [self showSignup];
}

#pragma mark - NSNotifications

-(void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSignup) name:networkingDidSignup object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailSignup:) name:networkingDidFailToSignup object:nil];
}

-(void)removeNotifications
{
    
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

-(void)alertView:(MLAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex withEmail:(NSString *)email password:(NSString *)password
{
    [[RCNetworking sharedNetwork] signupWithEmail:email password:password];
}

@end
