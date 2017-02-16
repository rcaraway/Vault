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
#import "RCNetworkListener.h"

#import "UIColor+RCColors.h"
#import "UIView+QuartzEffects.h"
#import "RCRootViewController+passcodeSegues.h"
#import "UIImage+memoIcons.h"

#import "MLAlertView.h"
#import "RCValtView.h"
#import "HTAutocompleteTextField.h"
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
@property(nonatomic, strong) UIImageView * hintArrowView;
@property (nonatomic) BOOL platinumLogin;
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
    [self addMotionEffects];
    [self addNotifications];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (isNewUser){
        [self showHintView];
    }
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


#pragma mark - Orientation

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
    CGRect bounds = CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width);
    if (orientation == UIInterfaceOrientationPortrait)
        self.fieldBackView.frame =  CGRectMake(11, bounds.size.height-264-12-50, bounds.size.width-22, 50);
    else
        self.fieldBackView.frame =  CGRectMake(11, bounds.size.height-352-12-50, bounds.size.width-22, 50);
    self.passwordField.frame =  CGRectMake(24, 3, bounds.size.width-60, 44);
    self.valtView.frame = CGRectMake(bounds.size.width/2.0-55, CGRectGetMinY(self.fieldBackView.frame)/2.0-(98/2.0), 110, 110);
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
    if (isNewUser && [[RCNetworking sharedNetwork] loggedIn]){
        [[RCNetworking sharedNetwork] fetchFromServer];
    }
    isNewUser = NO;
    self.valtLogin = NO;
    self.hintArrowView.alpha = 0;
    [self.hintArrowView removeFromSuperview];
    self.hintArrowView = nil;
    [self.passwordField resignFirstResponder];
    self.passwordField.placeholder = @"Master Password";
    self.passwordField.attributedPlaceholder = [[NSAttributedString  alloc] initWithString:self.passwordField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:0 green:.5 blue:.5 alpha:1]}];
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
    self.platinumLogin = NO;
    NSString * message = notification.object;
    [self.alertView showFailWithTitle:[message capitalizedString]];
    [self.alertView.loginTextField becomeFirstResponder];
}

-(void)didLogIn:(NSNotification *)notification
{
    if (self.platinumLogin){
        self.platinumLogin = NO;
        loginPassword = self.alertView.passwordTextField.text;
        [APP setSwipeRightHint:NO];
        [APP setAutofillHints:NO];
        if (isNewUser){
            [self.alertView dismissWithSuccessCompletion:^{
                [[RCPasswordManager defaultManager] setMasterPassword:loginPassword];
                [self didSucceedEnteringPassword];
            }];
        }else{
             [self.passwordField becomeFirstResponder];
            [self.alertView dismissWithSuccess];
            [[[APP rootController] messageView] showMessage:@"You are now Logged In." autoDismiss:YES];
        }
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
    self.actionSheet = [[LBActionSheet  alloc] initWithTitle:@"Would you like to change your master password to the same one as your Platinum account?" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Update master password" otherButtonTitles:@"Don't Update", nil];
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
    self.valtView = [[RCValtView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0-55, CGRectGetMinY(self.fieldBackView.frame)/2.0-(98/2.0), 110, 110)];
    [self.view addSubview:self.valtView];
    
}

-(void)setupFieldBackView
{
    CGFloat keyboardHeight = (IS_IPHONE ? 216:264);
    self.fieldBackView = [[UIView alloc] initWithFrame:CGRectMake(11, self.view.frame.size.height-keyboardHeight-12-50, self.view.frame.size.width-22, 50)];
    [self.fieldBackView setBackgroundColor:[UIColor colorWithWhite:25.0/255.0 alpha:1]];
    [self.fieldBackView setCornerRadius:25];
    [self.fieldBackView setBorderWidth:1 withColor:[UIColor colorWithRed:40.0/255.0 green:40.0/255.0 blue:40.0/255.0 alpha:1]];
    [self.view addSubview:self.fieldBackView];
}

-(void)setupNumberField
{
    self.passwordField = [[UITextField  alloc] initWithFrame:CGRectMake(24, 3, self.view.frame.size.width-60, 44)];
    self.passwordField.delegate = self;
    [self.passwordField setBackgroundColor:[UIColor colorWithWhite:25.0/255.0 alpha:1]];
    [self.passwordField setCornerRadius:5];
    if (isNewUser)
        self.passwordField.placeholder = @"New Master Password";
    else
        self.passwordField.placeholder = @"Master Password";
    self.passwordField.attributedPlaceholder = [[NSAttributedString  alloc] initWithString:self.passwordField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:0 green:.5 blue:.5 alpha:1]}];
    [self.passwordField setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:20]];
    self.passwordField.keyboardAppearance = UIKeyboardAppearanceDark;
    self.passwordField.returnKeyType = UIReturnKeyDone;
    [self.passwordField setTextColor:[UIColor cyanColor]];
    self.passwordField.secureTextEntry = YES;
    if (!self.opened){
         [self.passwordField becomeFirstResponder];
    }
    [self.fieldBackView addSubview:self.passwordField];
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
        self.platinumLogin = YES;
        [alertView loadWithText:@"Logging in"];
        [[RCNetworking sharedNetwork] loginWithEmail:email password:password];
        [RCNetworkListener setShouldMerge];
    }
}

-(void)alertView:(MLAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex withText:(NSString *)text
{
    if ([confirmString isEqualToString:text]){
        [self.alertView dismissWithSuccessCompletion:^{
            [[RCPasswordManager defaultManager] setMasterPassword:text];
            [self didSucceedEnteringPassword];
        }];
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
    [self.valtView openNotAnimated];
}

-(void)showHintView
{
    self.hintArrowView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"down"] tintedIconWithColor:[UIColor yellowColor]]];
    [self.hintArrowView setFrame:CGRectMake(12, CGRectGetMinY(self.fieldBackView.frame)-82, 64, 64)];
    [self.view addSubview:self.hintArrowView];
    [self animateHintView];
}

-(void)animateHintView
{
    [UIView animateWithDuration:.4 animations:^{
        [self.hintArrowView setFrame:CGRectMake(12, CGRectGetMinY(self.fieldBackView.frame)-68, 64, 64)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.4 animations:^{
             [self.hintArrowView setFrame:CGRectMake(12, CGRectGetMinY(self.fieldBackView.frame)-82, 64, 64)];
        } completion:^(BOOL finished) {
            [self animateHintView];
        }];
    }];
}





#pragma mark - Event Handling

-(void)didTapLogin
{
    self.alertView = [[MLAlertView  alloc] initWithTitle:@"Platinum Login" textFields:YES delegate:self cancelButtonTitle:@"Cancel" confirmButtonTitle:@"Login"];
    self.alertView.loginTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    self.alertView.passwordTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    [self.alertView show];
}

-(void)didFailConfirmation
{
    self.passwordField.placeholder = @"New Master Password";
    self.passwordField.attributedPlaceholder = [[NSAttributedString  alloc] initWithString:self.passwordField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:0 green:.5 blue:.5 alpha:1]}];
    self.passwordField.text = @"";
}

-(void)didEnterIncorrectPassword
{
    self.passwordField.placeholder = @"Master Password";
    self.passwordField.attributedPlaceholder = [[NSAttributedString  alloc] initWithString:self.passwordField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:0 green:.5 blue:.5 alpha:1]}];
    self.passwordField.text = @"";
}

-(void)didFinishTypingPassword
{
    if (isNewUser && self.passwordField.text.length > 0){
        confirmString = self.passwordField.text;
        self.alertView = [[MLAlertView  alloc] initWithTextfieldWithPlaceholder:@"Retype Password" title:@"Confirm Password" delegate:self cancelButtonTitle:@"Cancel" confirmButtonTitle:@"Confirm"];
        self.alertView.passwordTextField.keyboardAppearance = UIKeyboardAppearanceDark;
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
