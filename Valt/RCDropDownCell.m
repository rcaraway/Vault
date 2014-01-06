//
//  RCDropDownCell.m
//  Valt
//
//  Created by Rob Caraway on 12/11/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCDropDownCell.h"
#import "UIColor+RCColors.h"
#import "HTAutocompleteTextField.h"
#import "HTAutocompleteManager.h"

@interface RCDropDownCell ()
{
    UIView * separator;
}

@property(nonatomic, strong) UILabel * label;

@end

@implementation RCDropDownCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor dropDownColor];
        [self setupTextField];
        [self setupLabel];
    }
    return self;
}

-(void)layoutSubviews
{
    if (!separator){
        separator = [[UIView  alloc] initWithFrame:CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1)];
        separator.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
        [self addSubview:separator];
    }
}


-(void)setupTextField
{
    self.textField = [[HTAutocompleteTextField alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    self.textField.autocompleteDataSource = [HTAutocompleteManager sharedManager];
    self.textField.autocompleteType = RCAutocompleteTypeUsername;
    [self.textField setBackgroundColor:self.contentView.backgroundColor];
    self.textField.returnKeyType = UIReturnKeyNext;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.textColor = [UIColor blackColor];
    self.textField.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:self.textField];
}

-(void)setupLabel
{
    self.label = [[UILabel alloc] initWithFrame:self.contentView.bounds];
    [self.label setText:@"+ Tap to add another field."];
    self.label.alpha = 0;
    [self addSubview:self.label];
}

-(void)setPlaceHolder:(NSString *)placeholder
{
    self.textField.placeholder = placeholder;
}

-(void)setTitle:(NSString *)title placeHolder:(NSString *)placeHolder
{
    self.textField.placeholder = placeHolder;
    if ([placeHolder isEqualToString:@"Password"]){
        self.textField.autocompleteType = RCAutocompleteTypePassword;
    }else if ([placeHolder isEqualToString:@"URL"]){
        self.textField.autocompleteType = RCAutocompleteTypeURL;
        self.textField.keyboardType = UIKeyboardTypeURL;
    }else if ([placeHolder isEqualToString:@"Email or Username"]){
        self.textField.autocompleteType = RCAutocompleteTypeUsername;
        self.textField.keyboardType = UIKeyboardTypeEmailAddress;
    }else{
        self.textField.autocompleteType = RCAutoCompleteTypeNone;
    }
    self.textField.text = title;
}

-(void)setAddMoreState
{
    self.label.alpha = 1;
    self.textField.alpha = 0;
}

-(void)prepareForReuse
{
    self.textField.autocompleteType = RCAutocompleteTypeUsername;
    self.textField.placeholder = @"Notes";
    self.textField.text = @"";
    self.textField.alpha = 1;
    self.textField.keyboardType = UIKeyboardTypeDefault;
    self.label.alpha = 0;
    [self layoutSubviews];
}


@end
