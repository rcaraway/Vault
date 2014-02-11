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
#import "HTAutocompleteTextField.h"
#import "RCRootViewController+passcodeSegues.h"
#import "RCNetworkListener.h"

#import "LBActionSheet.h"
#import "RCMessageView.h"

@interface RCPasscodeViewController () <UITextFieldDelegate, MLAlertViewDelegate, LBActionSheetDelegate>
{
    BOOL isNewUser;
    NSString * confirmString;
    NSString * loginPassword;
}

@property(nonatomic, strong) MLAlertView * alertView;
@property(nonatomic, strong) LBActionSheet * actionSheet;
@property (nonatomic) BOOL premiumLogin;
@property (nonatomic) BOOL valtLogin;

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
    if (![[RCNetworking sharedNetwork] loggedIn]){
        [self setupLoginButton];
    }
    [self addMotionEffects];
    [self addNotifications];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
    if (self.opened){
        [self setToOpenState];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (self.opened){
        [self freeAllMemory];
    }
}

-(void)dealloc
{
    [self freeAllMemory];
}

-(void)freeAllMemory
{
    [self removeNotifications];
    self.fieldBackView = nil;
    self.valtView = nil;
    self.passwordField = nil;
    self.loginButton = nil;
    self.alertView = nil;
    self.view = nil;
}

#pragma mark - Status Bar

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationFade;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIView * view = [[touches anyObject] view];
    if (view == self.valtView){
        self.valtLogin = YES;
        [self didFinishTypingPassword];
    }
}


#pragma mark - NSNotifications

-(void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailToLogIn:) name:networkingDidFailToLogin object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogIn:) name:networkingDidLogin object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSucceedEnteringPassword) name:passwordManagerAccessGranted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDenyAccess) name:passwordManagerAccessFailedToGrant object:nil];
}

-(void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:networkingDidLogin object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:networkingDidFailToLogin object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:passwordManagerAccessGranted object:nil];
    [[NSNotificationCenter defaultCenter ]removeObserver:self name:passwordManagerAccessFailedToGrant object:nil];
}

-(void)didSucceedEnteringPassword
{
    self.fieldBackView.alpha = 0;
    isNewUser = NO;
    self.valtLogin = NO;
    [self.passwordField resignFirstResponder];
    self.loginButton.alpha = 0;
    if (loginPassword && ![loginPassword isEqualToString:[[RCPasswordManager defaultManager] masterPassword]]){
        [self showWhichPasswordActionSheet];
    }else{
        [self.valtView openWithCompletionBlock:^{
            [[APP rootController] seguePasscodeToList];
        }];
    }
}

-(void)didFailToLogIn:(NSNotification *)notification
{
    self.premiumLogin = NO;
    NSString * message = notification.object;
    [self.alertView showFailWithTitle:[message capitalizedString]];
    [self.alertView.loginTextField becomeFirstResponder];
}

-(void)didLogIn:(NSNotification *)notification
{
    if (self.premiumLogin){
        self.premiumLogin = NO;
        loginPassword = self.alertView.passwordTextField.text;
        [self.alertView dismissWithSuccessTitle:@"Login Successful"];
        [[[APP rootController] messageView] showMessage:@"You are now Logged In." autoDismiss:YES];
        self.loginButton.alpha = 0;
        [self.passwordField becomeFirstResponder];
    }
}

-(void)didDenyAccess
{
    if (self.valtLogin){
         [self.valtView shake];
        self.valtLogin = NO;
    }else{
        [UIView animateWithDuration:.08 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.fieldBackView setFrame:CGRectMake(self.fieldBackView.frame.origin.x-10, self.fieldBackView.frame.origin.y, self.fieldBackView.frame.size.width, self.fieldBackView.frame.size.height)];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.08 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self.fieldBackView setFrame:CGRectMake(self.fieldBackView.frame.origin.x+20, self.fieldBackView.frame.origin.y, self.fieldBackView.frame.size.width, self.fieldBackView.frame.size.height)];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:.08 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.fieldBackView setFrame:CGRectMake(self.fieldBackView.frame.origin.x-10, self.fieldBackView.frame.origin.y, self.fieldBackView.frame.size.width, self.fieldBackView.frame.size.height)];
                } completion:^(BOOL finished) {
                }];
            }];
        }];
    }
}


#pragma mark - ActionSheet

-(void)showWhichPasswordActionSheet
{
    self.actionSheet = [[LBActionSheet  alloc] initWithTitle:@"Would you like to change your master password to the same one as your premium account?" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Update master password" otherButtonTitles:@"Don't Update", nil];
    [self.actionSheet showInView:self.view];
}

-(void)actionSheet:(LBActionSheet *)actionSheet clickedButtonAtIndex:(NSUInteger)buttonIndex
{
    if (buttonIndex == 0){
        
    }
        
    [self.valtView openWithCompletionBlock:^{
        [[APP rootController] seguePasscodeToList];
    }];
}


#pragma mark - View Setup

-(void)setupValtView
{
    self.valtView = [[RCValtView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0-55, CGRectGetMinY(self.fieldBackView.frame)/2.0-(98/2.0), 110, 98)];
    [self.view addSubview:self.valtView];
    
}

-(void)setupFieldBackView
{
    CGFloat keyboardHeight = (IS_IPHONE ? 216:264);
    self.fieldBackView = [[UIView alloc] initWithFrame:CGRectMake(11, self.view.frame.size.height-keyboardHeight-17-50, self.view.frame.size.width-22, 50)];
    [self.fieldBackView setBackgroundColor:[UIColor passcodeForeground]];
    [self.fieldBackView setCornerRadius:5];
    [self.view addSubview:self.fieldBackView];
}

-(void)setupNumberField
{
    self.passwordField = [[UITextField  alloc] initWithFrame:CGRectMake(12, 4, self.view.frame.size.width-36, 44)];
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
    if (!self.opened){
         [self.passwordField becomeFirstResponder];
    }
    [self.fieldBackView addSubview:self.passwordField];
}

-(void)setupLoginButton
{
    self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat width = [@"Premium User? Log in here." sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12] constrainedToSize:CGSizeMake(self.view.frame.size.height, 44)].width;
    [self.loginButton setFrame:CGRectMake(self.view.frame.size.width/2.0, CGRectGetMinY(self.fieldBackView.frame)-9-26, self.view.frame.size.width-width-20, 44)];
    [self.loginButton setTitle:@"Premium User? Log in here." forState:UIControlStateNormal];
    self.loginButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    [self.loginButton.titleLabel setTextAlignment:NSTextAlignmentRight];
    [self.loginButton addTarget:self action:@selector(didTapLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.loginButton setTitleColor:[UIColor passcodeForeground] forState:UIControlStateNormal];
    [self.view addSubview:self.loginButton];
}

-(void)addMotionEffects
{
    UIInterpolatingMotionEffect *verticalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.y"
     type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(-5);
    verticalMotionEffect.maximumRelativeValue = @(5);
    UIInterpolatingMotionEffect *horizontalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.x"
     type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(-5);
    horizontalMotionEffect.maximumRelativeValue = @(5);
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    [self.fieldBackView addMotionEffect:group];
    [self.valtView addMotionEffect:group];
}



#pragma mark - Alert View Delegate

-(void)alertViewTappedCancel:(MLAlertView *)alertView
{
    [self.passwordField becomeFirstResponder];
}

-(void)alertView:(MLAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.passwordField becomeFirstResponder];
}

-(void)alertView:(MLAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex withEmail:(NSString *)email password:(NSString *)password
{
    if (buttonIndex ==1){
        self.premiumLogin = YES;
        [alertView loadWithText:@"Logging in"];
        [[RCNetworking sharedNetwork] loginWithEmail:email password:password];
        [RCNetworkListener setShouldMerge];
    }
}

-(void)alertView:(MLAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex withText:(NSString *)text
{
    if ([confirmString isEqualToString:text]){
        [self.alertView dismiss];
        [[RCPasswordManager defaultManager] setMasterPassword:text];
        [self didSucceedEnteringPassword];
    }else{
        [self.alertView showFailWithTitle:@"Passwords don't match"];
        [self.alertView clearText];
    }
}

#pragma mark - State Handling

-(void)setToOpenState
{
    UIView * view = self.view;
    view.layer.anchorPoint=CGPointMake(0, .5);
    view.center = CGPointMake(0, view.center.y);
    view.transform = CGAffineTransformMakeTranslation(0,0);
    CATransform3D _3Dt = CATransform3DIdentity;
    _3Dt =CATransform3DMakeRotation(3.141f/2.0f,0.0f,-1.0f,0.0f);
    _3Dt.m34 = 0.001f;
    _3Dt.m14 = -0.0015f;
    view.layer.transform =_3Dt;
    self.fieldBackView.alpha = 0;
    self.loginButton.alpha = 0;
    [self.valtView openNotAnimated];
}

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
    self.alertView.loginTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    self.alertView.passwordTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    [self.alertView show];
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

-(void)didFinishTypingPassword
{
    if (isNewUser && self.passwordField.text.length > 0){
        confirmString = self.passwordField.text;
        self.alertView = [[MLAlertView  alloc] initWithTextfieldWithPlaceholder:@"Retype Password" title:@"Confirm Password" delegate:self cancelButtonTitle:@"Cancel" confirmButtonTitle:@"Confirm"];
        [self.alertView show];
    }else{
        [[RCPasswordManager defaultManager] attemptToUnlockWithCodeInBackground:self.passwordField.text];
    }
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
    [self didFinishTypingPassword];
    return YES;
}


-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

@end
