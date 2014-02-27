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
#import "UIImage+memoIcons.h"

#import "LBActionSheet.h"
#import "RCMessageView.h"

#import "RCPassword.h"
#import "RCPasswordManager.h"
#import "RCNetworking.h"



@interface RCWebViewController () <UIWebViewDelegate, UIGestureRecognizerDelegate, LBActionSheetDelegate>
{
    CGPoint touchLocation;
}

@property(nonatomic, strong) LBActionSheet * actionSheet;
@property(nonatomic, copy) NSString * currentFormURL;

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
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [[NSURLCache sharedURLCache] setDiskCapacity:0];
        [[NSURLCache sharedURLCache] setMemoryCapacity:0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.webView.delegate = self;
    [self.doneButton setTitleColor:[UIColor webColor] forState:UIControlStateNormal];
    [self.usernameField setTitle:self.password.username forState:UIControlStateNormal];
    [self.passwordButton setTitle:self.password.password forState:UIControlStateNormal];
    [self.usernameField addTarget:self action:@selector(usernameTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.passwordButton addTarget:self action:@selector(passwordTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.topView.layer addSublayer:[self separatorAtOrigin:43.0f]];
    [self.bottomView.layer addSublayer:[self separatorAtOrigin:0.0f]];
    [self.backButton setImage:[self.backButton.imageView.image tintedIconWithColor:[UIColor webColor]] forState:UIControlStateNormal];
    [self.forwardButton setImage:[self.forwardButton.imageView.image tintedIconWithColor:[UIColor webColor]] forState:UIControlStateNormal];
    [self.refreshButton setImage:[self.refreshButton.imageView.image tintedIconWithColor:[UIColor webColor]] forState:UIControlStateNormal];
    [self.pasteButton setImage:[self.pasteButton.imageView.image tintedIconWithColor:[UIColor webColor]] forState:UIControlStateNormal];
    self.topView.backgroundColor = [UIColor navColor];
    self.credentialView.backgroundColor = [UIColor navColor];
    [self.credentialView.layer addSublayer:[self separatorAtOrigin:43.0f]];
    self.titleLabel.textColor = [UIColor webColor];
    self.urlLabel.textColor = [UIColor webColor];
    self.bottomView.backgroundColor = [UIColor navColor];
    [self.passwordButton setTitle:self.password.password forState:UIControlStateNormal];
    [self.usernameField setTitle:self.password.username forState:UIControlStateNormal];
    self.webView.backgroundColor = [UIColor navColor];
    self.view.backgroundColor = [UIColor navColor];
    [self.credentialView setFrame:CGRectMake(0, -44, [UIScreen mainScreen].bounds.size.width, 44)];
    [self.usernameField setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width/2.0, 44)];
    [self.passwordButton setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2.0, 0, [UIScreen mainScreen].bounds.size.width/2.0, 44)];
    [self loadPasswordRequest];
}

-(void)deleteAllCookies
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSHTTPCookie *cookie;
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (cookie in [storage cookies]) {
            [storage deleteCookie:cookie];
        }
    });
}

-(CALayer *)separatorAtOrigin:(CGFloat)yOrigin
{
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, yOrigin, [UIScreen mainScreen].bounds.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor colorWithWhite:0.83f
                                                     alpha:1.0f].CGColor;
    return bottomBorder;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.topView.backgroundColor = [UIColor navColor];
    self.titleLabel.backgroundColor = [UIColor navColor];
    self.doneButton.backgroundColor = [UIColor navColor];
    self.bottomView.backgroundColor = [UIColor navColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCredentialView) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideCredentialView) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter ]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter ]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [self deleteAllCookies];
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
    if (self.password.notes.length > 0){
        self.actionSheet = [[LBActionSheet  alloc] initWithTitle:@"Copy to Clipboard:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:self.password.username, self.password.password, self.password.notes, nil];
    }else{
        self.actionSheet = [[LBActionSheet  alloc] initWithTitle:@"Copy to Clipboard:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:self.password.username, self.password.password, nil];
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
            [[RCNetworking sharedNetwork] saveToCloud];
        }
    }
}



#pragma mark - State Handling

-(void)loadPasswordRequest
{
    self.firstPage = YES;
    NSURL * url = [NSURL URLWithString:self.password.urlName];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
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
        if (self.currentFormURL && [self.currentFormURL isEqualToString:self.webView.request.mainDocumentURL.absoluteString]){
        }else{
             [self tryToSubmitForm];
        }
        self.currentFormURL = self.webView.request.mainDocumentURL.absoluteString;
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
    NSString *loadUsername3JS = [NSString stringWithFormat:@"var inputFields = document.querySelectorAll(\"input[name*='user']\"); \
                                 for (var i = inputFields.length >>> 0; i--;) { inputFields[i].value = '%@';}", self.password.username];
    NSString * email = [self.webView stringByEvaluatingJavaScriptFromString:loadEmailJS];
    NSString * username = [self.webView stringByEvaluatingJavaScriptFromString:loadUsernameJS];
    NSString * username2 = [self.webView stringByEvaluatingJavaScriptFromString:loadUsername2JS];
    NSString * username3 = [self.webView stringByEvaluatingJavaScriptFromString:loadUsername3JS];
    return ([email isEqualToString:self.password.username] || [username isEqualToString:self.password.username] || [username2 isEqualToString:self.password.username]||[username3 isEqualToString:self.password.username]);
}

-(void)tryToSubmitForm
{
    NSString *submit =@"var submits = document.querySelectorAll(\"input[type='submit']\"); for (var i = submits.length >>> 0; i--;){ if (submits[i].value.toLowerCase().indexOf(\"submit\") != -1 || submits[i].value.toLowerCase().indexOf(\"login\") != -1 || submits[i].value.toLowerCase().indexOf(\"log in\") != -1 || submits[i].value.toLowerCase().indexOf(\"sign in\") != -1 || submits[i].value.toLowerCase().indexOf(\"log on\") != -1){submits[i].click();}}";
    [self.webView stringByEvaluatingJavaScriptFromString:submit];
}


-(void)showCredentialView
{
    [self.view addSubview:self.credentialView];
        self.credentialView.alpha =1;
    self.topView.clipsToBounds = YES;
    [UIView animateWithDuration:.4 delay:0 usingSpringWithDamping:.7 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.credentialView setFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 44)];
        CGAffineTransform transform = CGAffineTransformMakeTranslation(0, 44);
        self.titleLabel.transform = transform;
        self.urlLabel.transform = transform;
        self.doneButton.transform = transform;
    } completion:nil];
}

-(void)hideCredentialView
{
    [UIView animateWithDuration:.4 delay:0 usingSpringWithDamping:.7 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.credentialView setFrame:CGRectMake(0, -44, [UIScreen mainScreen].bounds.size.width, 44)];
        CGAffineTransform transform = CGAffineTransformIdentity;
        self.titleLabel.transform = transform;
        self.urlLabel.transform = transform;
        self.doneButton.transform = transform;

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
    [self performSelector:@selector(tryToFillOutAllForms) withObject:nil afterDelay:.24];
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
