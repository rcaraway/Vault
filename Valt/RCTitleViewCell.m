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
{
    UIView * separator;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor listBackground];
        self.contentView.backgroundColor = [UIColor cellUnselectedForeground];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupTextField];
        separator = [[UIView  alloc] initWithFrame:CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1)];
        separator.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
        [self addSubview:separator];
    }
    return self;
}

-(void)didMoveToSuperview
{
    [separator setFrame:CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1)];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    if (self.textField.text.length > 0){
        CGFloat width = [self.textField.text sizeWithFont:self.textField.font constrainedToSize:CGSizeMake(self.frame.size.width, self.frame.size.height)].width;
        [self.textField setFrame:CGRectMake(self.textField.frame.origin.x, self.textField.frame.origin.y, width+10, self.textField.frame.size.height)];
    }else{
        if (self.textField.placeholder.length > 0){
            CGFloat width = [self.textField.placeholder sizeWithFont:self.textField.font constrainedToSize:CGSizeMake(self.frame.size.width, self.frame.size.height)].width;
            [self.textField setFrame:CGRectMake(self.textField.frame.origin.x, self.textField.frame.origin.y, width+10, self.textField.frame.size.height)];
        }
    }
}

-(void)setRedColored
{
    [UIView animateWithDuration:.23 animations:^{
        self.contentView.backgroundColor = [UIColor redColor];
        self.textLabel.backgroundColor = [UIColor redColor];
        self.textLabel.textColor = [UIColor whiteColor];
    } completion:nil];
}

-(void)setFocused
{
    [UIView animateWithDuration:.23 animations:^{
        self.contentView.backgroundColor = [UIColor cellSelectedForeground];
        self.textLabel.backgroundColor = [UIColor cellSelectedForeground];
        self.textLabel.textColor = [UIColor whiteColor];
    } completion:nil];
}

-(void)removeFocus
{
    [UIView animateWithDuration:.23 animations:^{
        self.contentView.backgroundColor = [UIColor cellUnselectedForeground];
        self.textLabel.backgroundColor = [UIColor cellUnselectedForeground];
        self.textLabel.textColor = [UIColor blackColor];
    } completion:nil];
}

-(void)prepareForReuse
{
    [self layoutSubviews];
    [self removeFocus];
}

-(void)setupTextField
{
    self.textField = [[HTAutocompleteTextField alloc] initWithFrame:CGRectMake(12,0, 320, 60)];
    [self.textField setBackgroundColor:self.contentView.backgroundColor];
    self.textField.placeholder = @"Login Title";
    self.textField.autocompleteDataSource = [HTAutocompleteManager sharedManager];
    self.textField.autocompleteType = RCAutocompleteTypeTitle;
    self.textField.returnKeyType = UIReturnKeyNext;
    self.textLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:self.textField];
}




@end
