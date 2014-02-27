//
//  RCTableViewCell.m
//  Valt
//
//  Created by Rob Caraway on 12/11/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCTitleViewCell.h"
#import "HTAutocompleteTextField.h"
#import "HTAutocompleteManager.h"
#import "UIColor+RCColors.h"




@implementation RCTitleViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupTextField];
        [self setNormalColored];
    }
    return self;
}

-(void)setRedColored
{
    [UIView animateWithDuration:.23 animations:^{
        self.contentView.backgroundColor = [UIColor redColor];
        self.textLabel.backgroundColor = [UIColor redColor];
        self.textLabel.textColor = [UIColor whiteColor];
    } completion:nil];
}

-(void)setNormalColored
{
    self.backgroundColor = [UIColor mainCellColor];
    self.contentView.backgroundColor = [UIColor mainCellColor];
    [self.textField setBackgroundColor:self.contentView.backgroundColor];
    [self.textField setTextColor:[UIColor colorWithWhite:.2 alpha:1]];
}

-(void)setPurpleColoed
{
    self.contentView.backgroundColor = [UIColor valtPurple];
    [self.textField setBackgroundColor:self.contentView.backgroundColor];
    [self.textField setTextColor:[UIColor whiteColor]];
}

-(void)setFocused
{
//    [UIView animateWithDuration:.23 animations:^{
//        self.contentView.backgroundColor = [UIColor cellSelectedForeground];
//        self.textLabel.backgroundColor = [UIColor cellSelectedForeground];
//        self.textLabel.textColor = [UIColor whiteColor];
//    } completion:nil];
}

-(void)removeFocus
{
//    [UIView animateWithDuration:.23 animations:^{
//        self.contentView.backgroundColor = [UIColor cellUnselectedForeground];
//        self.textLabel.backgroundColor = [UIColor cellUnselectedForeground];
//        self.textLabel.textColor = [UIColor blackColor];
//    } completion:nil];
}

-(void)prepareForReuse
{
    [self layoutSubviews];
    [self removeFocus];
}

-(void)setupTextField
{
    self.textField = [[HTAutocompleteTextField alloc] initWithFrame:CGRectMake(18,0, 320, 60)];
    [self.textField setBackgroundColor:self.contentView.backgroundColor];
    self.textField.placeholder = @"Login Title";
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.font = [UIFont fontWithName:@"HelveticaNeue" size:20];
    [self.textField setTextColor:[UIColor whiteColor]];
    self.textField.autocompleteDataSource = [HTAutocompleteManager sharedManager];
    self.textField.keyboardAppearance = UIKeyboardAppearanceDark;
    self.textField.autocompleteType = RCAutocompleteTypeTitle;
    self.textField.returnKeyType = UIReturnKeyNext;
    self.textLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:self.textField];
}




@end
