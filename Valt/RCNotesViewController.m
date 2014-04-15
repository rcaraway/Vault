//
//  RCNotesViewController.m
//  Valt
//
//  Created by Robert Caraway on 4/9/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCNotesViewController.h"
#import "RCRootViewController.h"

#import "RCAppDelegate.h"
#import "RCMessageView.h"

#import "RCNetworking.h"
#import "RCPasswordManager.h"
#import "RCSecureNoteFiller.h"

#import "UIView+QuartzEffects.h"
#import "UIColor+RCColors.h"

#import <SAMTextView/SAMTextView.h>

@interface RCNotesViewController () <NSLayoutManagerDelegate>

@property(nonatomic, assign)NSRange latestRange;
@property(nonatomic, copy) NSString * latestText;
@property (nonatomic, copy) NSString * originalNotes;

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
    CALayer * layer = [self separatorAtOrigin:0];
    [self.autofillView.layer addSublayer:layer];
    self.autofillView.backgroundColor = [UIColor navColor];
    [self.tipView setCornerRadius:10];
    [self.autofillButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self setupNotesView];
    self.tipView.alpha = 0;
    [[[APP rootController] view] bringSubviewToFront:[[APP rootController] messageView]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.notesView.text = [[RCPasswordManager defaultManager] secureNotes];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.notesView becomeFirstResponder];
    if ([APP secureNoteTip]){
        [UIView animateWithDuration:.24 animations:^{
            self.tipView.alpha = 1;
        }];
    }else{
        [self.view sendSubviewToBack:self.tipView];
    }
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

- (IBAction)tipPressed:(UIButton *)sender {
    [UIView animateWithDuration:.24 animations:^{
        self.tipView.alpha = 0;
    }completion:^(BOOL finished) {
        [self.view sendSubviewToBack:self.tipView];
        [APP setSecureNoteTip:NO];
    }];
}

- (IBAction)infoTapped:(UIButton *)sender
{
    if (self.tipView.alpha == 0){
        [self.view bringSubviewToFront:self.tipView];
        [UIView animateWithDuration:.24 animations:^{
            self.tipView.alpha = 1;
        }];
    }else{
        [UIView animateWithDuration:.24 animations:^{
            self.tipView.alpha = 0;
        }completion:^(BOOL finished) {
            [self.view sendSubviewToBack:self.tipView];
        }];
    }
}

- (IBAction)autoFillTapped:(UIButton *)sender
{
    if (self.latestRange.location != NSNotFound){
        NSString * addedText = self.autofillButton.titleLabel.text;
        NSInteger uniqueText = 1;
        while (uniqueText != -1) {
            if ([self.notesView.text rangeOfString:addedText].location != NSNotFound){
                uniqueText++;
                addedText = [NSString stringWithFormat:@"%@ %d", addedText, uniqueText];
            }else{
                uniqueText = -1;
            }
        }
        addedText = [NSString stringWithFormat:@"%@ : ", addedText];
        NSString * filledText = [self.notesView.text stringByReplacingCharactersInRange:self.latestRange withString:addedText];
        self.notesView.text = filledText;
        NSRange range = [self.notesView.text rangeOfString:addedText];
        [self.notesView setSelectedRange:NSMakeRange(range.location+range.length, 0)];
        [self hideFillView];
    }
}


#pragma mark - TextView


-(void)setupNotesView
{
    self.notesView = [[SAMTextView alloc] initWithFrame:CGRectMake(20, 74, [UIScreen mainScreen].bounds.size.width-40, [UIScreen mainScreen].bounds.size.height-340)];
    self.notesView.delegate = self;
    self.notesView.font = [UIFont systemFontOfSize:16];
    self.notesView.layoutManager.delegate = self;
    self.notesView.placeholder = @"Notes (Ex: Address: 123 Valt Lane)";
    self.notesView.showsVerticalScrollIndicator = YES;
    self.notesView.autocorrectionType = UITextAutocorrectionTypeNo;
    self.notesView.editable = YES;
    self.notesView.textColor = [UIColor darkGrayColor];
    [self.view insertSubview:self.notesView belowSubview:self.autofillView];
}

-(void)textViewDidChange:(UITextView *)textView
{
    __block NSRange selection = [self.notesView selectedRange];
    self.latestText = nil;
    self.latestRange = NSMakeRange(0, 0);
    if (self.notesView.text.length > 0){
        [self.notesView.text enumerateSubstringsInRange:[self.notesView.text rangeOfString:self.notesView.text] options:NSStringEnumerationByLines | NSStringEnumerationReverse usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
            if (selection.location >= substringRange.location && selection.location <= (substringRange.location + substringRange.length)){
                self.latestText = substring;
                self.latestRange = substringRange;
                *stop = YES;
            }
        }];
        if (self.latestText){
            NSString * title = [[RCSecureNoteFiller sharedFiller] autoFilledTitleForLine:self.latestText];
            [UIView setAnimationsEnabled:NO];
            [self.autofillButton setTitle:title forState:UIControlStateNormal];
            [UIView setAnimationsEnabled:YES];
            [self showFillView];
        }else{
            [self hideFillView];
        }
    }else{
        [self hideFillView];
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if (![self.notesView.text isEqualToString:self.originalNotes]){
        [[RCPasswordManager defaultManager] saveSecureNotes:self.notesView.text];
        [[RCNetworking sharedNetwork] saveToCloud];
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    self.originalNotes = [[RCPasswordManager defaultManager] secureNotes];
}

-(CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect
{
    return 8;
}

#pragma mark - Convenience

-(void)showFillView
{
    if (self.autofillButton.frame.origin.x != 20){
        [UIView animateWithDuration:.3 delay:0 usingSpringWithDamping:.8 initialSpringVelocity:.8 options:UIViewAnimationOptionCurveLinear animations:^{
            self.autofillButton.frame = CGRectMake(20, self.autofillButton.frame.origin.y, self.autofillButton.frame.size.width, self.autofillButton.frame.size.height);
            self.autofillButton.alpha = 1;
        } completion:^(BOOL finished) {
        }];
    }
}

-(void)hideFillView
{
    [UIView animateWithDuration:.3 delay:0 usingSpringWithDamping:.8 initialSpringVelocity:.8 options:UIViewAnimationOptionCurveLinear animations:^{
        self.autofillButton.frame = CGRectMake(-self.autofillButton.frame.size.width, self.autofillButton.frame.origin.y, self.autofillButton.frame.size.width, self.autofillButton.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
}

-(CALayer *)separatorAtOrigin:(CGFloat)yOrigin
{
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, yOrigin, [UIScreen mainScreen].bounds.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor colorWithWhite:0.83f
                                                     alpha:1.0f].CGColor;
    return bottomBorder;
}


@end
