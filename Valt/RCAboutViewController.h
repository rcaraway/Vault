//
//  RCAboutViewController.h
//  Valt
//
//  Created by Robert Caraway on 12/19/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCAboutViewController : UIViewController
@property (strong, nonatomic) IBOutlet UINavigationBar *navbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UITextView *descriptionView;
@property (strong, nonatomic) IBOutlet UIButton *followRobButton;
@property (strong, nonatomic) IBOutlet UIButton *feedbackButton;

- (IBAction)sendFeedback:(id)sender;
- (IBAction)followTapped:(id)sender;
@end
