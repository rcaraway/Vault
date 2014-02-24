//
//  RCBackupView.m
//  Valt
//
//  Created by Robert Caraway on 2/3/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCBackupView.h"

#import "UIColor+RCColors.h"
#import "UIView+QuartzEffects.h"


@interface RCBackupView ()

@property (nonatomic) NSInteger textSet;

@end

@implementation RCBackupView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor navColor];
        self.textSet = arc4random()%3;
        [self.layer addSublayer:[self separatorAtOrigin:0.0f]];
        [self setupImageView];
        [self setupBackupLabel];
        [self setupNoButton];
        [self setupYesButton];
    }
    return self;
}

-(CALayer *)separatorAtOrigin:(CGFloat)yOrigin
{
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, yOrigin, [UIScreen mainScreen].bounds.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor colorWithWhite:0.83f
                                                     alpha:1.0f].CGColor;
    return bottomBorder;
}

-(id)init
{
    return  [self initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 60)];
}


#pragma mark - Subview Setup

-(void)setupImageView
{
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 15, 30, 30)];
    NSArray * imageNames = @[@"backup", @"developer", @"multiDevice"];
    self.imageView.image = [UIImage imageNamed:imageNames[self.textSet]];
    [self addSubview:self.imageView];
}

-(void)setupBackupLabel
{
    self.backupLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.imageView.frame)+12, 12, [UIScreen mainScreen].bounds.size.width-200, 36)];
    NSArray * texts = @[@"Would you like to backup your data?", @"Care to support the developer?", @"Access passwords from any device?"];
    self.backupLabel.text = texts[self.textSet];
    self.backupLabel.numberOfLines = 2;
    [self.backupLabel setBackgroundColor:self.backgroundColor];
    [self.backupLabel setTextColor:[UIColor colorWithWhite:.2 alpha:1]];
    [self.backupLabel setFont:[UIFont boldSystemFontOfSize:12]];
    [self addSubview:self.backupLabel];
}

-(void)setupYesButton
{
    self.yesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.yesButton setTitle:@"Yes" forState:UIControlStateNormal];
    [self.yesButton setBackgroundColor:[UIColor goPlatinumColor]];
    [self.yesButton setFrame:CGRectMake(CGRectGetMinX(self.noButton.frame)-60-6, 7, 60, 48)];
    [self.yesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.yesButton setCornerRadius:5];
    [self.yesButton addTarget:self action:@selector(didTapYes) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.yesButton];
}

-(void)setupNoButton
{
    self.noButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.noButton setTitle:@"No" forState:UIControlStateNormal];
    CGFloat red = 0, blue = 0, green = 0, alpha = 0;
    [[UIColor goPlatinumColor] getRed:&red green:&green blue:&blue alpha:&alpha];
    blue = MIN(1, blue+.05);
    red = MIN(1, red+.05);
    green = MIN(1, green+.05);
    [self.noButton setBackgroundColor:[UIColor colorWithRed:red green:green blue:blue alpha:1]];
    [self.noButton setTitleColor:[UIColor colorWithWhite:.9 alpha:1] forState:UIControlStateNormal];
    [self.noButton setFrame:CGRectMake(CGRectGetMaxX(self.frame)-60-6, 7, 60, 48)];
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
