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

@interface RCRootViewController ()

@end

@implementation RCRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self launchPasscode];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate
{
    return NO;
}

-(BOOL)prefersStatusBarHidden
{
    return NO;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

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
    [self.view addSubview:self.passcodeController.view];
}


-(void)launchSingleWithPassword:(RCPassword *)password
{
    [self.listController removeFromParentViewController];
    [self.listController.view removeFromSuperview];
    self.singleController = [[RCSingleViewController alloc] initWithPassword:password];
    [self addChildViewController:self.singleController];
    [self.view addSubview:self.singleController.view];
}

-(void)launchList
{
    if (self.passcodeController.isViewLoaded && self.passcodeController.view.window){
        [self.passcodeController removeFromParentViewController];
        [self.passcodeController.view removeFromSuperview];
    }
    if (!self.listController){
        self.listController = [[RCListViewController  alloc] initWithNibName:nil bundle:nil];
    }
    [self addChildViewController:self.listController];
    [self.view addSubview:self.listController.view];
}

-(void)launchSingle
{
    [self.listController removeFromParentViewController];
    [self.listController.view removeFromSuperview];
    self.singleController = [[RCSingleViewController alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:self.singleController];
    [self.view addSubview:self.singleController.view];
}

@end
