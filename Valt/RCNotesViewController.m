//
//  RCNotesViewController.m
//  Valt
//
//  Created by Robert Caraway on 4/9/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCNotesViewController.h"

@interface RCNotesViewController ()

@end

@implementation RCNotesViewController


-(id)init
{
    self = [super initWithNibName:@"RCNotesViewController" bundle:nil];
    if (self){
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.autofillView.alpha = 0;
    [self setupTextView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Actions

- (IBAction)infoTapped:(UIButton *)sender
{

}

- (IBAction)autoFillTapped:(UIButton *)sender
{

}


#pragma mark - TextView

-(void)setupTextView
{
    self.textView.delegate = self;
    [self.textView becomeFirstResponder];
    self.textView.text = @"Foobar placeholder";
    self.textView.textColor = [UIColor lightGrayColor];
    self.textView.tag = 0;
}


-(void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length > 0){
        if(textView.tag == 0) {
            textView.text = @"";
            textView.textColor = [UIColor blackColor];
            textView.tag = 1;
        }
    }
}


-(void)textViewDidEndEditing:(UITextView *)textView
{
    if([textView.text length] == 0)
    {
        textView.text = @"Foobar placeholder";
        textView.textColor = [UIColor lightGrayColor];
        textView.tag = 0;
    }
}




@end
