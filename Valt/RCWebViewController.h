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

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIButton *forwardButton;
@property (strong, nonatomic) IBOutlet UIButton *refreshButton;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;
- (IBAction)forwardTapped:(id)sender;
- (IBAction)refreshTapped:(id)sender;
- (IBAction)doneTapped:(id)sender;

- (IBAction)backTapped:(id)sender;

-(id)initWithPassword:(RCPassword *)password;
@end
