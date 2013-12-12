//
//  RCTableViewCell.m
//  Valt
//
//  Created by Rob Caraway on 12/11/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCTableViewCell.h"
#import "UIColor+RCColors.h"

@implementation RCTableViewCell
{
    UIView * separator;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor listBackground];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
        self.contentView.backgroundColor = [UIColor cellUnselectedForeground];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupTextField];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    if (self.textField.text.length > 0){
        CGFloat width = [self.textField.text sizeWithFont:self.textField.font constrainedToSize:CGSizeMake(self.frame.size.width, self.frame.size.height)].width;
        [self.textField setFrame:CGRectMake(self.textField.frame.origin.x, self.textField.frame.origin.y, width+10, self.textField.frame.size.height)];
        if (!separator){
            separator = [[UIView  alloc] initWithFrame:CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1)];
            separator.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
            [self addSubview:separator];
        }

    }
}

-(void)didBeginEditing:(NSNotification *)notification
{
    if (self.textField == notification.object){
        [self setFocused];
    }else{
        [self removeFocus];
    }
}

-(void)setRedColored
{
    [UIView animateWithDuration:.23 animations:^{
        self.contentView.backgroundColor = [UIColor redColor];
        self.textField.backgroundColor = [UIColor redColor];
        self.textField.textColor = [UIColor whiteColor];
    } completion:nil];
}

-(void)setFocused
{
    [UIView animateWithDuration:.23 animations:^{
        self.contentView.backgroundColor = [UIColor cellSelectedForeground];
        self.textField.backgroundColor = [UIColor cellSelectedForeground];
        self.textField.textColor = [UIColor whiteColor];
    } completion:nil];
}

-(void)removeFocus
{
    [UIView animateWithDuration:.23 animations:^{
        self.contentView.backgroundColor = [UIColor cellUnselectedForeground];
        self.textField.backgroundColor = [UIColor cellUnselectedForeground];
        self.textField.textColor = [UIColor blackColor];
    } completion:nil];
}

-(void)prepareForReuse
{
    [self layoutSubviews];
    [self removeFocus];
}

-(void)setupTextField
{
    self.textField = [[UITextField  alloc] initWithFrame:CGRectMake(12,0, 320, 60)];
    [self.textField setBackgroundColor:self.contentView.backgroundColor];
    self.textField.placeholder = @"Login Title";
    self.textLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:self.textField];
}




@end
