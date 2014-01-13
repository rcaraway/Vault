//
//  RCPasscodeViewController.m
//  Valt
//
//  Created by Rob Caraway on 12/10/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCPasscodeViewController.h"
#import "RCAppDelegate.h"
#import "RCRootViewController.h"
#import "RCPasswordManager.h"
#import "RCNetworking.h"
#import "MLAlertView.h"
#import "UIColor+RCColors.h"
#import "UIView+QuartzEffects.h"
#import "RCValtView.h"

@interface RCPasscodeViewController () <UITextFieldDelegate, MLAlertViewDelegate>
{
    BOOL isNewUser;
    NSString * confirmString;
}

@property(nonatomic, strong) UIView * fieldBackView;
@property(nonatomic, strong) MLAlertView * alertView;

@end


@implementation RCPasscodeViewController


#pragma mark - Initialization

-(id)initWithNewUser:(BOOL)newUser
{
    self = [super initWithNibName:nil bundle:nil];
    if (self){
        isNewUser = newUser;
    }
    return self;
}


#pragma mark - View LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor passcodeBackground];
    [self setupFieldBackView];
    [self setupValtView];
    [self setupNumberField];
//    if (![[RCNetworking sharedNetwork] loggedIn]){
        [self setupLoginButton];
//    }
    [self addNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self removeNotifications];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIView * view = [[touches anyObject] view];
    if (view == self.valtView){
        [self.valtView shake];
    }
}


#pragma mark - VC Transitions

-(void)willMoveToParentViewController:(UIViewController *)parent
{
    [parent.view addSubview:self.view];
}

-(void)didMoveToParentViewController:(UIViewController *)parent
{
    [self.view removeFromSuperview];
}

#pragma mark - NSNotifications

-(void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailToLogIn:) name:networkingDidFailToLogin object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogIn:) name:networkingDidLogin object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSucceedEnteringPassword) name:passwordManagerAccessGranted object:nil];
}

-(void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:networkingDidLogin object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:networkingDidFailToLogin object:nil];
}

-(void)didSucceedEnteringPassword
{
    self.fieldBackView.alpha = 0;
    [self.passwordField resignFirstResponder];
    self.loginButton.alpha = 0;
    [self.valtView openCompletion:^{
        [[APP rootController] moveFromPasscodeToList];
    }];
}

-(void)didFailToLogIn:(NSNotification *)notification
{
    NSString * message = notification.object;
    [self.alertView showFailWithTitle:[message capitalizedString]];
}

-(void)didLogIn:(NSNotification *)notification
{
    [self.alertView dismissWithSuccessTitle:@"Login Successful"];
}



#pragma mark - View Setup

-(void)setupValtView
{
    self.valtView = [[RCValtView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0-55, CGRectGetMinY(self.fieldBackView.frame)/2.0-(98/2.0), 110, 98)];
    [self.view addSubview:self.valtView];
}

-(void)setupFieldBackView
{
    self.fieldBackView = [[UIView alloc] initWithFrame:CGRectMake(11, self.view.frame.size.height-216-17-50, self.view.frame.size.width-22, 50)];
    [self.fieldBackView setBackgroundColor:[UIColor passcodeForeground]];
    [self.fieldBackView setCornerRadius:5];
    [self.view addSubview:self.fieldBackView];
}

-(void)setupNumberField
{
    self.passwordField = [[UITextField  alloc] initWithFrame:CGRectMake(12, 4, self.view.frame.size.width-33, 44)];
    self.passwordField.delegate = self;
    [self.passwordField setBackgroundColor:[UIColor passcodeForeground]];
    [self.passwordField setCornerRadius:5];
    if (isNewUser)
        self.passwordField.placeholder = @"New Master Password";
    else
        self.passwordField.placeholder = @"Master Password";
    self.passwordField.attributedPlaceholder = [[NSAttributedString  alloc] initWithString:self.passwordField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    [self.passwordField setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:20]];
    self.passwordField.keyboardAppearance = UIKeyboardAppearanceDark;
    self.passwordField.returnKeyType = UIReturnKeyDone;
    [self.passwordField setTextColor:[UIColor whiteColor]];
    self.passwordField.secureTextEntry = YES;
    [self.passwordField becomeFirstResponder];
    [self.fieldBackView addSubview:self.passwordField];
}

-(void)setupLoginButton
{
    self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.loginButton setFrame:CGRectMake(self.view.frame.size.width/2.0, CGRectGetMinY(self.fieldBackView.frame)-9-26, self.view.frame.size.width/2.0-11, 44)];
    [self.loginButton setTitle:@"Premium User? Log in here." forState:UIControlStateNormal];
    self.loginButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    [self.loginButton.titleLabel setTextAlignment:NSTextAlignmentRight];
    [self.loginButton addTarget:self action:@selector(didTapLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.loginButton setTitleColor:[UIColor passcodeForeground] forState:UIControlStateNormal];
    [self.view addSubview:self.loginButton];
}



#pragma mark - Alert View Delegate

-(void)alertView:(MLAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.passwordField becomeFirstResponder];
}

-(void)alertView:(MLAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex withEmail:(NSString *)email password:(NSString *)password
{
    if (buttonIndex ==1){
        [[RCNetworking sharedNetwork] loginWithEmail:email password:password];
        [alertView loadWithText:@"Logging in"];
        [self.view.window endEditing:YES];
    }
}

-(void)alertView:(MLAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex withText:(NSString *)text
{
    if ([confirmString isEqualToString:text]){
        [self.alertView dismiss];
        [[RCPasswordManager defaultManager] setMasterPassword:text];
        [[APP rootController] moveFromPasscodeToList];
    }else{
        [self.alertView showFailWithTitle:@"Passwords don't match"];
        [self.alertView clearText];
    }
}

#pragma mark - State Handling

-(void)didTapButton
{
    if (isNewUser && !confirmString){

    }else{
        if (confirmString && [confirmString isEqualToString:self.passwordField.text]){
            [self didEnterCorrectData];
        }else if (confirmString && ![confirmString isEqualToString:self.passwordField.text]){
            [self didFailConfirmation];
        }else{
            if ([[[RCPasswordManager defaultManager] masterPassword] isEqualToString:self.passwordField.text]){
                [self didEnterCorrectData];
            }else{
                [self didEnterIncorrectPassword];
            }
        }
    }
}

-(void)didEnterCorrectData
{
    if (isNewUser){
        [[RCPasswordManager defaultManager] setMasterPassword:self.passwordField.text];
    }
   //TODO: rewrite to use attemptToAccessPasswords
}

-(void)launchConfirmField
{
    
}

#pragma mark - Event Handling

-(void)didTapLogin
{
    self.alertView = [[MLAlertView  alloc] initWithTitle:@"Premium Login" textFields:YES delegate:self cancelButtonTitle:@"Cancel" confirmButtonTitle:@"Login"];
    [self.alertView show];
    [self.passwordField resignFirstResponder];
}

-(void)didFailConfirmation
{
    self.passwordField.placeholder = @"New Master Password";
    self.passwordField.attributedPlaceholder = [[NSAttributedString  alloc] initWithString:self.passwordField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    self.passwordField.text = @"";
}

-(void)didEnterIncorrectPassword
{
    self.passwordField.placeholder = @"Master Password";
    self.passwordField.attributedPlaceholder = [[NSAttributedString  alloc] initWithString:self.passwordField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    self.passwordField.text = @"";
}

#pragma mark - TextField Delegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * fullString;
    if (string.length > 0){
        fullString = [textField.text stringByAppendingString:string];
    }else{
        fullString = [textField.text stringByReplacingCharactersInRange:range withString:@""];
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (isNewUser && textField.text.length > 0){
        confirmString = textField.text;
        self.alertView = [[MLAlertView  alloc] initWithTextfieldWithPlaceholder:@"Retype Password" title:@"Confirm Password" delegate:self cancelButtonTitle:@"Cancel" confirmButtonTitle:@"Confirm"];
        [self.alertView show];
    }else{
        [[RCPasswordManager defaultManager] attemptToUnlockWithCodeInBackground:textField.text];
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

@end
