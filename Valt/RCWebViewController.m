//
//  RCWebViewController.m
//  Valt
//
//  Created by Robert Caraway on 12/19/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCWebViewController.h"
#import "RCPassword.h"

@interface RCWebViewController () <UIWebViewDelegate>

@property(nonatomic, strong) RCPassword * password;

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
    NSURL * url = [NSURL URLWithString:self.password.urlName];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];    
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

#pragma mark - Webview Delegate

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
//    NSString *html = [self.webView stringByEvaluatingJavaScriptFromString: @"document.body.user.value"];
    NSString *loadUsernameJS = [NSString stringWithFormat:@"var inputFields = document.querySelectorAll(\"input[type='text']\"); \
                                for (var i = inputFields.length >>> 0; i--;) { inputFields[i].value = '%@';}", self.password.username];
    NSString *loadEmailJS = [NSString stringWithFormat:@"var inputFields = document.querySelectorAll(\"input[type='email']\"); \
                             for (var i = inputFields.length >>> 0; i--;) { inputFields[i].value = '%@';}", self.password.username];
    NSString *loadPasswordJS =[NSString stringWithFormat:@"var passFields = document.querySelectorAll(\"input[type='password']\"); \
                               for (var i = passFields.length>>> 0; i--;) { passFields[i].value ='%@';}", self.password.password];
    NSString * email = [self.webView stringByEvaluatingJavaScriptFromString:loadEmailJS];
    NSString * password = [self.webView stringByEvaluatingJavaScriptFromString:loadPasswordJS];
    NSString * username = [self.webView stringByEvaluatingJavaScriptFromString:loadUsernameJS];
    NSLog(@"HTML EMAIL %@ USERNAME %@ PASSWORD %@", email, username, password);
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}


@end
