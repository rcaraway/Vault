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


@interface RCPasscodeViewController () <UITextFieldDelegate, MLAlertViewDelegate>
{
    BOOL isNewUser;
    NSString * confirmString;
}

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
    self.view.backgroundColor = [UIColor colorWithWhite:.05 alpha:1];
    [self setupLabel];
    [self setupNumberField];
    if (![[RCNetworking sharedNetwork] loggedIn]){
        [self setupLoginButton];
    }
    [self addNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self removeNotifications];
}


-(BOOL)prefersStatusBarHidden
{
    return YES;
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
    [[APP rootController] moveFromPasscodeToList];
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

-(void)setupNumberField
{
    self.passwordField = [[UITextField  alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/3.0, self.view.frame.size.width, self.view.frame.size.height/8.0)];
    self.passwordField.delegate = self;
    [self.passwordField setBackgroundColor:[UIColor colorWithWhite:.2 alpha:1]];
    if (isNewUser)
        self.passwordField.placeholder = @"New Master Password";
    else
        self.passwordField.placeholder = @"Master Password";
    self.passwordField.attributedPlaceholder = [[NSAttributedString  alloc] initWithString:self.passwordField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    [self.passwordField setFont:[UIFont systemFontOfSize:20]];
    self.passwordField.keyboardAppearance = UIKeyboardAppearanceLight;
    self.passwordField.returnKeyType = UIReturnKeyDone;
    [self.passwordField setTextAlignment:NSTextAlignmentCenter];
    [self.passwordField setTextColor:[UIColor whiteColor]];
    self.passwordField.secureTextEntry = YES;
    [self.passwordField becomeFirstResponder];
    [self.view addSubview:self.passwordField];
}

-(void)setupLoginButton
{
    self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.loginButton setFrame:CGRectMake(0, CGRectGetMaxY(self.passwordField.frame), 320, 44)];
    [self.loginButton setTitle:@"Premium User? Log in here." forState:UIControlStateNormal];
    [self.loginButton addTarget:self action:@selector(didTapLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.loginButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.view addSubview:self.loginButton];
}

-(void)setupLabel
{
    self.enterPassword = [[UILabel  alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/3.0-20, self.view.frame.size.width, 20)];
    self.enterPassword.numberOfLines = 1;
    self.enterPassword.backgroundColor = [UIColor colorWithWhite:.2 alpha:1];
    self.enterPassword.textColor = [UIColor whiteColor];
    if (isNewUser){
        self.enterPassword.text = @"Enter new password";
    }else{
        self.enterPassword.text = @"Enter password";
    }
    [self.enterPassword setFont:[UIFont systemFontOfSize:13]];
    [self.view addSubview:self.enterPassword];
}

-(void)setupDoneButton
{
    self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.doneButton setFrame:CGRectMake(self.passwordField.frame.origin.x, CGRectGetMaxY(self.passwordField.frame)+2, self.passwordField.frame.size.width, 0)];
    [self.doneButton setBackgroundColor:[UIColor blueColor]];
    [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [self.doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.doneButton.alpha = 0;
    [self.doneButton addTarget:self action:@selector(didTapButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.doneButton];
}


#pragma mark - Alert View Delegate

-(void)alertView:(MLAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.passwordField becomeFirstResponder];
}

-(void)alertView:(MLAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex withEmail:(NSString *)email password:(NSString *)password
{
    [[RCNetworking sharedNetwork] loginWithEmail:email password:password];
    [alertView loadWithText:@"Logging in"];
    [self.view.window endEditing:YES];
}

#pragma mark - State Handling

-(void)showDoneButton
{
    [self.doneButton setFrame:CGRectMake(0, CGRectGetMaxY(self.passwordField.frame)+2, self.passwordField.frame.size.width, 0)];
    [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.doneButton.alpha = 1;
        [self.doneButton setFrame:CGRectMake(0, CGRectGetMaxY(self.passwordField.frame)+2, self.passwordField.frame.size.width, self.passwordField.frame.size.height+4)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.2 delay:.12 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.doneButton setFrame:CGRectMake(0, CGRectGetMaxY(self.passwordField.frame)+2, self.passwordField.frame.size.width, self.passwordField.frame.size.height)];
        } completion:nil];
    }];
}

-(void)hideDoneButton
{
    [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.doneButton setFrame:CGRectMake(0, CGRectGetMaxY(self.passwordField.frame)+2, self.passwordField.frame.size.width, self.passwordField.frame.size.height+4)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.2 delay:.08 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.doneButton.alpha = 0;
            [self.doneButton setFrame:CGRectMake(0, CGRectGetMaxY(self.passwordField.frame)+2, self.passwordField.frame.size.width, 0)];
        } completion:nil];
    }];
}

-(void)didTapButton
{
    if (isNewUser && !confirmString){
        [self setConfirmMode];
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
    self.enterPassword.text = @"Decrypting Data";
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
    self.enterPassword.backgroundColor = [UIColor redColor];
    self.enterPassword.text = @"Did not match previous password";
    self.passwordField.placeholder = @"New Master Password";
    self.passwordField.attributedPlaceholder = [[NSAttributedString  alloc] initWithString:self.passwordField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    self.passwordField.text = @"";
    [UIView animateWithDuration:1 animations:^{
        self.enterPassword.backgroundColor = [UIColor clearColor];
    }completion:^(BOOL finished) {
        self.enterPassword.text = @"Enter new password";
    }];
}

-(void)didEnterIncorrectPassword
{
    self.enterPassword.backgroundColor = [UIColor redColor];
    self.enterPassword.text = @"Incorrect Password";
    self.passwordField.placeholder = @"Master Password";
    self.passwordField.attributedPlaceholder = [[NSAttributedString  alloc] initWithString:self.passwordField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    self.passwordField.text = @"";
    [UIView animateWithDuration:1 animations:^{
        self.enterPassword.backgroundColor = [UIColor clearColor];
    }completion:^(BOOL finished) {
        self.enterPassword.text = @"Enter password";
    }];
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
        
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

@end
