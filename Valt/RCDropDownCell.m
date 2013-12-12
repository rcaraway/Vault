//
//  RCDropDownCell.m
//  Valt
//
//  Created by Rob Caraway on 12/11/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCDropDownCell.h"
#import "UIColor+RCColors.h"

@implementation RCDropDownCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor dropDownColor];
        [self setupTextField];
    }
    return self;
}

-(void)setupTextField
{
    self.textField = [[UITextField  alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    [self.textField setBackgroundColor:self.contentView.backgroundColor];
    self.textField.placeholder = @"Login Title";
    self.textField.textColor = [UIColor blackColor];
    self.textField.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:self.textField];
}

-(void)setPlaceHolder:(NSString *)placeholder
{
    self.textField.placeholder = placeholder;
}

-(void)setTitle:(NSString *)title placeHolder:(NSString *)placeHolder
{
    self.textField.placeholder = placeHolder;
    self.textField.text = title;
}

-(void)prepareForReuse
{
    self.textField.placeholder = @"Notes";
    self.textField.text = @"";
}


@end
