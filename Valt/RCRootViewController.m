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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self launchPassCode];
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

-(void)launchPassCode
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
    
}

@end
