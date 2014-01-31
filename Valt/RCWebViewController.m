//
//  RCWebViewController.m
//  Valt
//
//  Created by Robert Caraway on 12/19/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCAppDelegate.h"
#import "RCWebViewController.h"
#import "RCRootViewController.h"

#import "RCRootViewController+WebSegues.h"
#import "UIColor+RCColors.h"

#import "LBActionSheet.h"
#import "RCMessageView.h"

#import "TWMessageBarManager.h"
#import "RCPassword.h"
#import "RCPasswordManager.h"



@interface RCWebViewController () <UIWebViewDelegate, UIGestureRecognizerDelegate, LBActionSheetDelegate>
{
    CGPoint touchLocation;
}

@property(nonatomic, strong) LBActionSheet * actionSheet;

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
    [self.doneButton setTitleColor:[UIColor colorWithRed:18.0/255.0 green:214.0/255.0 blue:78.0/255.0 alpha:1] forState:UIControlStateNormal];
    [self.usernameField setTitle:self.password.username forState:UIControlStateNormal];
    [self.passwordButton setTitle:self.password.password forState:UIControlStateNormal];
    [self.usernameField addTarget:self action:@selector(usernameTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.passwordButton addTarget:self action:@selector(passwordTapped) forControlEvents:UIControlEventTouchUpInside];
    self.topView.backgroundColor = [UIColor navColor];
    self.bottomView.backgroundColor = [UIColor navColor];
    [self loadPasswordRequest];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.topView.backgroundColor = [UIColor navColor];
    self.titleLabel.backgroundColor = [UIColor navColor];
    self.doneButton.backgroundColor = [UIColor navColor];
    self.bottomView.backgroundColor = [UIColor navColor];
}

-(BOOL)shouldAutorotate
{
    return NO;
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
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
    if (!self.parentViewController && self.isViewLoaded && !self.view.window){
        [self freeAllMemory];
    }
    [super didReceiveMemoryWarning];    
}

-(void)freeAllMemory
{
    [self.webView stopLoading];
    self.usernameField = nil;
    self.passwordButton = nil;
    self.bottomView = nil;
    self.credentialView = nil;
    self.webView = nil;
    self.backButton = nil;
    self.forwardButton = nil;
    self.refreshButton = nil;
    self.pasteButton = nil;
    self.topView = nil;
    self.doneButton = nil;
    self.urlButton =nil;
    self.urlLabel = nil;
    self.titleLabel = nil;
    self.loader = nil;
    self.actionSheet = nil;
    self.view = nil;
}

#pragma mark - Event Hanlding

-(void)didFailFillingBothFields
{
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Could not fill out forms" description:@"Tell the developer and he'll get it working in a future update." type:TWMessageBarMessageTypeError];
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
    [[APP rootController] closeWeb];
}

- (IBAction)pasteTapped:(id)sender
{
    self.actionSheet = [[LBActionSheet  alloc] initWithTitle:@"Copy to Clipboard:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:self.password.username, self.password.password, nil];
    if (self.password.notes.length > 0){
        [self.actionSheet addButtonWithTitle:self.password.notes];
    }
    [self.actionSheet showInView:self.view];
}

- (IBAction)urlTapped:(id)sender
{
    self.actionSheet = [[LBActionSheet  alloc] initWithTitle:[NSString stringWithFormat:@"Change to this URL for %@?", self.password.title] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Update URL" otherButtonTitles:nil];
    [self.actionSheet showInView:self.view];
}

- (IBAction)backTapped:(id)sender
{
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

#pragma mark - Action Sheet

-(void)actionSheet:(LBActionSheet *)actionSheet clickedButtonAtIndex:(NSUInteger)buttonIndex
{
    if (buttonIndex != actionSheet.numberOfButtons-1){
    if ([actionSheet.title isEqualToString:@"Copy to Clipboard:"]){
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        [pb setString:[actionSheet buttonTitleAtIndex:buttonIndex]];
        [[[APP rootController] messageView] showMessage:@"Copied to Clipboard" autoDismiss:YES];
    }else{
            [[[APP rootController] messageView] showMessage:@"Updated URL" autoDismiss:YES];
            self.password.urlName = self.urlLabel.text;
            [[RCPasswordManager defaultManager] updatePassword:self.password];
        }
    }
}



#pragma mark - State Handling

-(void)loadPasswordRequest
{
    self.firstPage = YES;
    NSURL * url = [NSURL URLWithString:self.password.urlName];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

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
        [self tryToSubmitForm];
        return YES;
    }else if (self.passwordFilled){
        return YES;
    }else if (self.usernameFilled){
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

-(void)tryToSubmitForm
{
    NSString *submit =@"var submits = document.querySelectorAll(\"input[type='submit']\"); for (var i = submits.length >>> 0; i--;){ if (submits[i].value.toLowerCase().indexOf(\"submit\") != -1 || submits[i].value.toLowerCase().indexOf(\"login\") != -1 || submits[i].value.toLowerCase().indexOf(\"log in\") != -1 || submits[i].value.toLowerCase().indexOf(\"sign in\") != -1 || submits[i].value.toLowerCase().indexOf(\"log on\") != -1){submits[i].click();}}";
    [self.webView stringByEvaluatingJavaScriptFromString:submit];
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

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    self.titleLabel.alpha = 0;
    self.urlLabel.alpha = 0;
    self.urlButton.enabled = NO;
    [self.loader startAnimating];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *theTitle=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSString * url = self.webView.request.mainDocumentURL.absoluteString;
    self.titleLabel.text = theTitle;
    self.urlLabel.text = url;
    [self.loader stopAnimating];
    self.titleLabel.alpha = 1;
    self.urlLabel.alpha =1;
    self.urlButton.enabled = YES;
    [self tryToFillOutAllForms];
    self.firstPage = NO;
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.titleLabel.text = @"Failed to Load Page";
    NSString * url = self.webView.request.mainDocumentURL.absoluteString;
    self.urlLabel.text = url;
    [self.loader stopAnimating];
    self.titleLabel.alpha = 1;
    self.urlLabel.alpha =1;
    self.urlButton.enabled = YES;
}


@end
