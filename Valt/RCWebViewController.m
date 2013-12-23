//
//  RCWebViewController.m
//  Valt
//
//  Created by Robert Caraway on 12/19/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCWebViewController.h"
#import "RCPassword.h"
#import "TWMessageBarManager.h"

@interface RCWebViewController () <UIWebViewDelegate, UIGestureRecognizerDelegate>
{
    CGPoint touchLocation;
}

@property(nonatomic, strong) RCPassword * password;
@property(nonatomic) BOOL usernameFilled;
@property(nonatomic) BOOL passwordFilled;
@property(nonatomic) BOOL firstPage;
@property(nonatomic) BOOL didLogin;

@end

@implementation RCWebViewController


-(id)initWithPassword:(RCPassword *)password
{
    self = [super initWithNibName:@"RCWebViewController" bundle:nil];
    if (self){
        self.password = password;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.delegate = self;
    self.firstPage = YES;
    NSURL * url = [NSURL URLWithString:self.password.urlName];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    [self.usernameField setTitle:self.password.username forState:UIControlStateNormal];
    [self.passwordButton setTitle:self.password.password forState:UIControlStateNormal];
    [self.usernameField addTarget:self action:@selector(usernameTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.passwordButton addTarget:self action:@selector(passwordTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.webView loadRequest:request];
}

-(void)printURLLog
{
    NSLog(@"URL %@", self.webView.request.URL.absoluteString);
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.credentialView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height+100, 320, 44)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCredentialView) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideCredentialView) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];    
}

#pragma mark - Event Hanlding

-(void)didFailFillingBothFields
{
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Could not fill out forms" description:@"Tell the developer and he'll get it working in a future update." type:TWMessageBarMessageTypeError];
}

-(void)didFailFillingUsername
{
//    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Could not fill out username" description:@"Tell the developer and he'll get it working in a future update." type:TWMessageBarMessageTypeInfo];
}

-(void)didFailFillingPassword
{
//    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Could not fill out password" description:@"Tell the developer and he'll get it working in a future update." type:TWMessageBarMessageTypeInfo];
}

- (IBAction)forwardTapped:(id)sender
{
    if (self.webView.canGoForward){
        [self.webView goForward];
    }
}

- (IBAction)refreshTapped:(id)sender
{
    [self.webView reload];
}

- (IBAction)doneTapped:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)backTapped:(id)sender {
    if (self.webView.canGoBack){
        [self.webView goBack];
    }
}

-(void)usernameTapped
{
    [self fillSelectedFormWithText:self.password.username];
}

-(void)passwordTapped
{
    [self fillSelectedFormWithText:self.password.password];
}


#pragma mark - State Handling

-(void)printHTML
{
    NSString *html = [self.webView stringByEvaluatingJavaScriptFromString: @"document.body.innerHTML"];
    NSLog(@"HTML %@", html);
}


-(BOOL)tryToFillOutAllForms
{
    self.passwordFilled =  [self fillOutPassword];
    if (self.passwordFilled){
        self.usernameFilled = [self fillOutUsername];
    }else if (!self.usernameFilled){
        self.usernameFilled = [self fillOutUsername];
    }
    if (self.usernameFilled && self.passwordFilled){
        return YES;
    }else if (self.passwordFilled){
        [self didFailFillingUsername];
        return YES;
    }else if (self.usernameFilled){
        [self didFailFillingPassword];
        return YES;
    }else{
        return NO;
    }
}

-(BOOL)fillSelectedFormWithText:(NSString *)text
{
    NSString *js = [NSString stringWithFormat:@"var field = document.activeElement;\
                    field.value ='%@'", text];
   NSString * string =  [self.webView stringByEvaluatingJavaScriptFromString:js];
    if (!string){
        return NO;
    }
    return YES;
}

-(BOOL)fillOutPassword
{
    NSString *loadPasswordJS =[NSString stringWithFormat:@"var passFields = document.querySelectorAll(\"input[type='password']\"); \
                               for (var i = passFields.length>>> 0; i--;) { passFields[i].value ='%@';}", self.password.password];
    NSString * password = [self.webView stringByEvaluatingJavaScriptFromString:loadPasswordJS];
    NSLog(@"PASSWORD %@", password);
    return  ([password isEqualToString:self.password.password]);
}

-(BOOL)fillOutUsername
{
    NSString *loadEmailJS = [NSString stringWithFormat:@"var inputFields = document.querySelectorAll(\"input[type*='email']\"); \
                             for (var i = inputFields.length >>> 0; i--;) { inputFields[i].value = '%@';}", self.password.username];
    
    NSString *loadUsernameJS = [NSString stringWithFormat:@"var inputFields = document.querySelectorAll(\"input[type*='text']\"); \
                                for (var i = inputFields.length >>> 0; i--;) { inputFields[i].value = '%@';}", self.password.username];
    NSString *loadUsername2JS = [NSString stringWithFormat:@"var inputFields = document.querySelectorAll(\"input[name*='User']\"); \
                                 for (var i = inputFields.length >>> 0; i--;) { inputFields[i].value = '%@';}", self.password.username];
    NSString * email = [self.webView stringByEvaluatingJavaScriptFromString:loadEmailJS];
    NSString * username = [self.webView stringByEvaluatingJavaScriptFromString:loadUsernameJS];
    NSString * username2 = [self.webView stringByEvaluatingJavaScriptFromString:loadUsername2JS];
    return ([email isEqualToString:self.password.username] || [username isEqualToString:self.password.username] || [username2 isEqualToString:self.password.username]);
}

-(void)showCredentialView
{
    [self tryToFillOutAllForms];
    [UIView animateWithDuration:.4 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.credentialView setFrame:CGRectMake(0, self.view.frame.size.height-300, 320, 44)];
    } completion:nil];
}

-(void)hideCredentialView
{
    [UIView animateWithDuration:.26 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.credentialView setFrame:CGRectMake(0, self.view.frame.size.height+100, 320, 44)];
    } completion:nil];
}


#pragma mark - Webview Delegate

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    switch (navigationType) {
        case UIWebViewNavigationTypeOther:
            if (self.usernameFilled && self.passwordFilled && ![self.webView.request.URL.absoluteString isEqualToString:request.URL.absoluteString]){
                self.didLogin = YES;
            }
            break;
        case UIWebViewNavigationTypeFormResubmitted:
            if (self.usernameFilled && self.passwordFilled && ![self.webView.request.URL.absoluteString isEqualToString:request.URL.absoluteString]){
                self.didLogin = YES;
            }
            break;
        case UIWebViewNavigationTypeFormSubmitted:
            if (self.usernameFilled && self.passwordFilled && ![self.webView.request.URL.absoluteString isEqualToString:request.URL.absoluteString]){
                self.didLogin = YES;
            }
            break;;
        default:{
            break;
        }
            
    }
    [self performSelector:@selector(tryToFillOutAllForms) withObject:nil afterDelay:.5];
    return YES;
}



-(void)webViewDidFinishLoad:(UIWebView *)webView
{
        [self tryToFillOutAllForms];
        self.firstPage = NO;
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
//    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Failed to Load page" description:@"Check your internet connection and try again" type:TWMessageBarMessageTypeError];
}


@end
