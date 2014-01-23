//
//  RCWebViewController.h
//  Valt
//
//  Created by Robert Caraway on 12/19/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RCPassword;

@interface RCWebViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *usernameField;
@property (strong, nonatomic) IBOutlet UIButton *passwordButton;

@property (strong, nonatomic) IBOutlet UIView *credentialView;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIButton *forwardButton;
@property (strong, nonatomic) IBOutlet UIButton *refreshButton;
@property (strong, nonatomic) IBOutlet UIButton *pasteButton;


@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *urlLabel;
@property (strong, nonatomic) IBOutlet UIButton *urlButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loader;

- (IBAction)forwardTapped:(id)sender;
- (IBAction)refreshTapped:(id)sender;
- (IBAction)doneTapped:(id)sender;
- (IBAction)pasteTapped:(id)sender;

- (IBAction)urlTapped:(id)sender;

- (IBAction)backTapped:(id)sender;

-(id)initWithPassword:(RCPassword *)password;
@end
