//
//  RCNotesViewController.m
//  Valt
//
//  Created by Robert Caraway on 4/9/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCNotesViewController.h"
#import "RCPasswordManager.h"
#import "RCRootViewController.h"
#import "RCAppDelegate.h"
#import "RCMessageView.h"
#import "RCSecureNoteFiller.h"
#import <SAMTextView/SAMTextView.h>

@interface RCNotesViewController ()

@property(nonatomic, assign)NSRange latestRange;
@property(nonatomic, copy) NSString * latestText;

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
    [self setupNotesView];
    [[[APP rootController] view] bringSubviewToFront:[[APP rootController] messageView]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.autofillView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 50)];
    self.notesView.text = [[RCPasswordManager defaultManager] secureNotes];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.notesView becomeFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
    if (self.latestRange.location != NSNotFound){
        NSString * filledText = [self.notesView.text stringByReplacingCharactersInRange:self.latestRange withString:self.autofillButton.titleLabel.text];
        self.notesView.text = filledText;
        NSRange range = [self.notesView.text rangeOfString:self.autofillButton.titleLabel.text];
        [self.notesView setSelectedRange:NSMakeRange(range.location+range.length, 0)];
        [self hideFillView];
    }
}


#pragma mark - TextView


-(void)setupNotesView
{
    self.notesView = [[SAMTextView alloc] initWithFrame:CGRectMake(20, 130, [UIScreen mainScreen].bounds.size.width-40, 438)];
    self.notesView.delegate = self;
//    self.notesView.placeholder = @"Secure Notes";
    //TODO:placeholder
    self.notesView.showsVerticalScrollIndicator = YES;
    self.notesView.autocorrectionType = UITextAutocorrectionTypeNo;
    self.notesView.editable = YES;
    self.notesView.textColor = [UIColor darkGrayColor];
    [self.view addSubview:self.notesView];
    [self.view bringSubviewToFront:self.autofillView];
}

-(void)textViewDidChange:(UITextView *)textView
{
    __block NSRange selection = [self.notesView selectedRange];
    self.latestText = nil;
    self.latestRange = NSMakeRange(0, 0);
    [self.notesView.text enumerateSubstringsInRange:[self.notesView.text rangeOfString:self.notesView.text] options:NSStringEnumerationByLines | NSStringEnumerationReverse usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        if (selection.location >= substringRange.location && selection.location <= (substringRange.location + substringRange.length)){
            self.latestText = substring;
            self.latestRange = substringRange;
            *stop = YES;
        }
    }];
    if (self.latestText){
        NSString * title = [[RCSecureNoteFiller sharedFiller] autoFilledTitleForLine:self.latestText];
        [self.autofillButton setTitle:title forState:UIControlStateNormal];
        [self showFillView];
    }else{
        [self hideFillView];
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    [[RCPasswordManager defaultManager] saveSecureNotes:self.notesView.text];
    [self.autofillView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 50)];
}


#pragma mark - Convenience

-(void)showFillView
{
    [UIView animateWithDuration:.5 delay:0 usingSpringWithDamping:.5 initialSpringVelocity:.8 options:UIViewAnimationOptionCurveLinear animations:^{
        [self.autofillView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-300, [UIScreen mainScreen].bounds.size.width, 50)];
    } completion:^(BOOL finished) {
        
    }];
}

-(void)hideFillView
{
    [UIView animateWithDuration:.5 delay:0 usingSpringWithDamping:.5 initialSpringVelocity:.8 options:UIViewAnimationOptionCurveLinear animations:^{
        [self.autofillView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 50)];
    } completion:^(BOOL finished) {
        
    }];
}


@end
