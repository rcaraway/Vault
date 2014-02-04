//
//  RCBackupView.m
//  Valt
//
//  Created by Robert Caraway on 2/3/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCBackupView.h"

#import "UIView+QuartzEffects.h"

@implementation RCBackupView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        [self setupImageView];
        [self setupBackupLabel];
        [self setupYesButton];
        [self setupNoButton];
    }
    return self;
}

-(id)init
{
    return  [self initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 60)];
}


#pragma mark - Subview Setup

-(void)setupImageView
{
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 15, 30, 30)];
    self.imageView.image = [UIImage imageNamed:@"backup"];
    [self addSubview:self.imageView];
}

-(void)setupBackupLabel
{
    self.backupLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.imageView.frame)+12, 12, [UIScreen mainScreen].bounds.size.width-200, 36)];
    self.backupLabel.text = @"Would you like to backup your data?";
    self.backupLabel.numberOfLines = 2;
    [self.backupLabel setBackgroundColor:self.backgroundColor];
    [self.backupLabel setTextColor:[UIColor darkGrayColor]];
    [self.backupLabel setFont:[UIFont boldSystemFontOfSize:12]];
    [self addSubview:self.backupLabel];
}

-(void)setupYesButton
{
    self.yesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.yesButton setTitle:@"Yes" forState:UIControlStateNormal];
    [self.yesButton setBackgroundColor:[UIColor darkGrayColor]];
    [self.yesButton setFrame:CGRectMake(CGRectGetMaxX(self.backupLabel.frame)+12, 6, 60, 48)];
    [self.yesButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.yesButton setCornerRadius:5];
    [self.yesButton addTarget:self action:@selector(didTapYes) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.yesButton];
}

-(void)setupNoButton
{
    self.noButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.noButton setTitle:@"No" forState:UIControlStateNormal];
    [self.noButton setBackgroundColor:[UIColor darkGrayColor]];
    [self.noButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.noButton setFrame:CGRectMake(CGRectGetMaxX(self.yesButton.frame)+6, 6, 60, 48)];
    [self.noButton setCornerRadius:5];
    [self.noButton addTarget:self action:@selector(didTapNo) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.noButton];
}


#pragma mark - Event Handling

-(void)didTapYes
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(backupViewDidTapYes:)]){
        [self.delegate backupViewDidTapYes:self];
    }
}

-(void)didTapNo
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(backupViewDidTapNo:)]){
        [self.delegate backupViewDidTapNo:self];
    }
}


@end
