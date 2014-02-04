//
//  RCAboutViewController.h
//  Valt
//
//  Created by Robert Caraway on 12/19/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCAboutViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *followRobButton;
@property (strong, nonatomic) IBOutlet UIButton *feedbackButton;


@property (strong, nonatomic) IBOutlet UIView *bannerView;
@property (strong, nonatomic) IBOutlet UILabel *robLabel;
@property (strong, nonatomic) IBOutlet UIButton *websiteButton;
@property (strong, nonatomic) IBOutlet UIButton *blogButton;
@property (strong, nonatomic) IBOutlet UIButton *licensesButton;
@property (strong, nonatomic) IBOutlet UILabel *thankyouButton;
@property (strong, nonatomic) IBOutlet UILabel *versionLabel;

@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGesture;

- (IBAction)didPan:(UIPanGestureRecognizer *)sender;


- (IBAction)tappedWebsite:(id)sender;
- (IBAction)tappedBlog:(id)sender;
- (IBAction)tappedLicenses:(id)sender;


@end
