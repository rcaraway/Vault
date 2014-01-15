//
//  RCSearchBar.m
//  Valt
//
//  Created by Robert Caraway on 1/14/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCSearchBar.h"
#import "UIView+QuartzEffects.h"

@interface RCSearchBar ()

@property(nonatomic, strong) UIButton * cancelButton;

@end



@implementation RCSearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:254.0/255.0 green:246.0/255.0 blue:255.0/255.0 alpha:1];
        [self setupSearchBack];
        [self setupSearchField];
        [self setupCancelButton];
    }
    return self;
}


#pragma mark - View Setup

-(void)setupSearchBack
{
    self.searchBack = [[UIView alloc] initWithFrame:CGRectMake(40, 10, self.frame.size.width-50, 28)];
    [self.searchBack setCornerRadius:5];
    [self.searchBack setBackgroundColor:[UIColor colorWithRed:177.0/255.0 green:90.0/255.0 blue:250.0/255.0 alpha:1]];
    [self addSubview:self.searchBack];
}

-(void)setupSearchField
{
    self.searchField = [[UITextField alloc] initWithFrame:CGRectMake(11, 1, self.searchBack.frame.size.width-22, self.searchBack.frame.size.height)];
    self.searchField.delegate = self;
    self.searchField.textColor = [UIColor whiteColor];
    self.searchField.backgroundColor = [UIColor clearColor];
    self.searchField.textAlignment = NSTextAlignmentCenter;
    self.searchField.attributedPlaceholder = [[NSAttributedString  alloc] initWithString:@"Search Valt" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.searchField.font = [UIFont systemFontOfSize:13];
    [self.searchBack addSubview:self.searchField];
}

-(void)setupCancelButton
{
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelButton setTitle:@"X" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.cancelButton setFrame:CGRectMake(CGRectGetWidth(self.frame)-40, CGRectGetHeight(self.frame)-40, 40, 40)];
    [self.cancelButton addTarget:self action:@selector(didTapCancel) forControlEvents:UIControlEventTouchUpInside];
    self.cancelButton.alpha = 0;
    [self addSubview:self.cancelButton];
}

#pragma mark - TextField Delegate

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:.3 animations:^{
        self.searchField.textAlignment = NSTextAlignmentLeft;
    }];
    [self.delegate searchBarDidBeginEditing:self];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:.3 animations:^{
        self.searchField.textAlignment = NSTextAlignmentCenter;
    }];
    [self.delegate searchBarDidEndEditing:self];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * searchText ;
    if (range.length == 0 && string.length > 0){
        searchText = [NSString stringWithFormat:@"%@%@", textField.text, string];
    }else{
        searchText =[textField.text stringByReplacingCharactersInRange:range withString:@""];
    }
    [self.delegate searchBar:self textDidChange:searchText];
    return YES;
}


#pragma mark - State Handling

-(void)showCancelButton
{
    [UIView animateWithDuration:.3 animations:^{
        [self.cancelButton setFrame:CGRectMake(CGRectGetWidth(self.frame)-40, CGRectGetHeight(self.frame)-40, 40, 40)];
        self.cancelButton.alpha = 1;
        [self.searchBack setFrame:CGRectMake(10, self.searchBack.frame.origin.y, self.searchBack.frame.size.width, self.searchBack.frame.size.height)];
    }];
}

-(void)hideCancelButton
{
    [UIView animateWithDuration:.3 animations:^{
        self.cancelButton.alpha = 0;
        [self.searchBack setFrame:CGRectMake(40, self.searchBack.frame.origin.y, self.searchBack.frame.size.width, self.searchBack.frame.size.height)];
    }];
}

#pragma mark - Event Handling

-(void)didTapCancel
{
    [self.delegate searchBarCancelTapped:self];
}

#pragma mark - Property

-(void)setShowsCancelButton:(BOOL)showsCancelButton
{
    _showsCancelButton = showsCancelButton;
    if (showsCancelButton){
        [self showCancelButton];
    }else{
        [self hideCancelButton];
    }
}

-(NSString *)text
{
    return self.searchField.text;
}

@end
