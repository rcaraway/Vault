//
//  RCPasscodeViewController.m
//  Valt
//
//  Created by Rob Caraway on 12/10/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCPasscodeViewController.h"
#import "SPLockScreen.h"
#import "RCAppDelegate.h"
#import "RCRootViewController.h"
#import "RCPasswordManager.h"

@interface RCPasscodeViewController () <LockScreenDelegate, UITextFieldDelegate>{
    BOOL isNewUser;
    NSString * confirmString;
}

@end


@implementation RCPasscodeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithNewUser:(BOOL)newUser
{
    self = [super initWithNibName:nil bundle:nil];
    if (self){
        isNewUser = newUser;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:.05 alpha:1];
    [self setupLabel];
    [self setupNumberField];
    if (isNewUser){
        [self setupConfirmField];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)willMoveToParentViewController:(UIViewController *)parent
{
    [parent.view addSubview:self.view];
}

-(void)didMoveToParentViewController:(UIViewController *)parent
{
    [self.view removeFromSuperview];
}

-(void)setupLockScreen
{
    self.lockscreen = [[SPLockScreen  alloc] initWithDelegate:self];
    [self.view addSubview:self.lockscreen];
}

-(void)setupNumberField
{
    self.numberField = [[UITextField  alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/3.0, self.view.frame.size.width, self.view.frame.size.height/8.0)];
    self.numberField.delegate = self;
    [self.numberField setBackgroundColor:[UIColor colorWithWhite:.2 alpha:1]];
    if (isNewUser)
        self.numberField.placeholder = @"New Master Password";
    else
        self.numberField.placeholder = @"Master Password";
    self.numberField.attributedPlaceholder = [[NSAttributedString  alloc] initWithString:self.numberField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    [self.numberField setFont:[UIFont systemFontOfSize:20]];
    self.numberField.keyboardAppearance = UIKeyboardAppearanceDark;
    self.numberField.keyboardType = UIKeyboardTypeNumberPad;
    [self.numberField setTextAlignment:NSTextAlignmentCenter];
    [self.numberField setTextColor:[UIColor whiteColor]];
    self.numberField.secureTextEntry = YES;
    [self.numberField becomeFirstResponder];
    [self.view addSubview:self.numberField];
}

-(void)setupConfirmField
{
    self.confirmField = [[UITextField  alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/3.0+self.view.frame.size.height/8.0, self.view.frame.size.width, self.view.frame.size.height/8.0)];
    self.confirmField.delegate = self;
    [self.confirmField setBackgroundColor:[UIColor colorWithWhite:.2 alpha:1]];
    self.confirmField.placeholder = @"Confirm Password";
    self.confirmField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.confirmField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    [self.confirmField setFont:[UIFont systemFontOfSize:20]];
    self.confirmField.keyboardAppearance = UIKeyboardAppearanceDark;
    self.confirmField.keyboardType = UIKeyboardTypeNumberPad;
    [self.confirmField setTextAlignment:NSTextAlignmentCenter];
    [self.confirmField setTextColor:[UIColor whiteColor]];
    self.confirmField.secureTextEntry = YES;
    self.confirmField.alpha = .5;
    [self.confirmField becomeFirstResponder];
    [self.view addSubview:self.confirmField];
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
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
    [self.doneButton setFrame:CGRectMake(self.numberField.frame.origin.x, CGRectGetMaxY(self.numberField.frame)+2, self.numberField.frame.size.width, 0)];
    [self.doneButton setBackgroundColor:[UIColor blueColor]];
    [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [self.doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.doneButton.alpha = 0;
    [self.doneButton addTarget:self action:@selector(didTapButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.doneButton];
}

-(void)showDoneButton
{
    [self.doneButton setFrame:CGRectMake(0, CGRectGetMaxY(self.numberField.frame)+2, self.numberField.frame.size.width, 0)];
    [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.doneButton.alpha = 1;
        [self.doneButton setFrame:CGRectMake(0, CGRectGetMaxY(self.numberField.frame)+2, self.numberField.frame.size.width, self.numberField.frame.size.height+4)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.2 delay:.12 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.doneButton setFrame:CGRectMake(0, CGRectGetMaxY(self.numberField.frame)+2, self.numberField.frame.size.width, self.numberField.frame.size.height)];
        } completion:nil];
    }];
}

-(void)hideDoneButton
{
    [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.doneButton setFrame:CGRectMake(0, CGRectGetMaxY(self.numberField.frame)+2, self.numberField.frame.size.width, self.numberField.frame.size.height+4)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.2 delay:.08 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.doneButton.alpha = 0;
            [self.doneButton setFrame:CGRectMake(0, CGRectGetMaxY(self.numberField.frame)+2, self.numberField.frame.size.width, 0)];
        } completion:nil];
    }];
}

-(void)didTapButton
{
    if (isNewUser && !confirmString){
        [self setConfirmMode];
    }else{
        if (confirmString && [confirmString isEqualToString:self.numberField.text]){
            [self didEnterCorrectData];
        }else if (confirmString && ![confirmString isEqualToString:self.numberField.text]){
            [self didFailConfirmation];
        }else{
            if ([[[RCPasswordManager defaultManager] masterPassword] isEqualToString:self.numberField.text]){
                [self didEnterCorrectData];
            }else{
                [self didEnterIncorrectPassword];
            }
        }
    }
}

-(void)didEnterCorrectData
{
    //Animate then launchlist
    if (isNewUser){
        [[RCPasswordManager defaultManager] setMasterPassword:self.numberField.text];
    }
    [[APP rootController] moveFromPasscodeToList];
}

-(void)setConfirmMode
{
    confirmString = self.numberField.text;
    self.enterPassword.text = @"Confirm Password";
    self.numberField.text = @"";
    self.numberField.placeholder = @"Type same password";
    self.enterPassword.backgroundColor = [UIColor blueColor];
    self.numberField.attributedPlaceholder = [[NSAttributedString  alloc] initWithString:self.numberField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    [self.doneButton setTitle:@"Confirm" forState:UIControlStateNormal];
    [self hideDoneButton];
    [UIView animateWithDuration:1 animations:^{
        self.enterPassword.backgroundColor = [UIColor clearColor];
    }completion:^(BOOL finished) {
    }];
}

-(void)didFailConfirmation
{
    self.enterPassword.backgroundColor = [UIColor redColor];
    self.enterPassword.text = @"Did not match previous password";
    self.numberField.placeholder = @"New Master Password";
    self.numberField.attributedPlaceholder = [[NSAttributedString  alloc] initWithString:self.numberField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    self.numberField.text = @"";
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
    self.numberField.placeholder = @"Master Password";
    self.numberField.attributedPlaceholder = [[NSAttributedString  alloc] initWithString:self.numberField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    self.numberField.text = @"";
    [UIView animateWithDuration:1 animations:^{
        self.enterPassword.backgroundColor = [UIColor clearColor];
    }completion:^(BOOL finished) {
        self.enterPassword.text = @"Enter password";
    }];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * fullString;
    if (string.length > 0){
        fullString = [textField.text stringByAppendingString:string];
    }else{
        fullString = [textField.text stringByReplacingCharactersInRange:range withString:@""];
    }
    if (textField == self.numberField){
        if (fullString.length >= 6){
            if (isNewUser){
                [UIView animateWithDuration:.23 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    self.confirmField.alpha = .5;
                } completion:nil];
            }else{
                if ([fullString isEqualToString:[[RCPasswordManager defaultManager] masterPassword]]){
                    [self didEnterCorrectData];
                }
            }
        }else{
            [UIView animateWithDuration:.23 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.confirmField.alpha = 0;
            } completion:nil];
        }
    }else{
        if (![fullString isEqualToString:self.numberField.text]){
            self.enterPassword.text = @"Not the same";
        }else{
            [self didEnterCorrectData];
        }
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.numberField){
        [UIView animateWithDuration:.18 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.numberField.alpha = 1;
            if (textField.text.length > 5){
                 self.confirmField.alpha = .5;
            }else{
                self.confirmField.alpha = 0;
            }
        } completion:^(BOOL finished) {
            
        }];
    }else{
        [UIView animateWithDuration:.18 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.numberField.alpha = .5;
            self.confirmField.alpha = 1;
        } completion:^(BOOL finished) {
            
        }];
    }
}

@end
