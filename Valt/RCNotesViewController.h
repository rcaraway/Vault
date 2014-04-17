//
//  RCNotesViewController.h
//  Valt
//
//  Created by Robert Caraway on 4/9/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SAMTextView;
@interface RCNotesViewController : UIViewController <UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;
@property(nonatomic, strong) SAMTextView * notesView;
@property (strong, nonatomic) IBOutlet UIView *autofillView;
@property (strong, nonatomic) IBOutlet UIButton *autofillButton;
@property (strong, nonatomic) IBOutlet UILabel *tipLabel;
@property (strong, nonatomic) IBOutlet UILabel *noColonLabel;
@property (strong, nonatomic) IBOutlet UIView *tipView;
@property (strong, nonatomic) IBOutlet UIButton *tipButton;

- (IBAction)tipPressed:(UIButton *)sender;
- (IBAction)infoTapped:(UIButton *)sender;
- (IBAction)autoFillTapped:(UIButton *)sender;

-(void)reshowKeyboard;


@end
