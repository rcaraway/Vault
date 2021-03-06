//
//  RCMainCell.m
//  Valt
//
//  Created by Robert Caraway on 12/17/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCMainCell.h"

#import "RCPassword.h"

#import "UIColor+RCColors.h"
#import "UIImage+memoIcons.h"


static UIImage * deleteIcon;
static UIImage * loginIcon;

@implementation RCMainCell
{
}


+(void)initialize
{
    deleteIcon = [UIImage imageNamed:@"cross"];
    loginIcon = [UIImage imageNamed:@"login"];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor listBackground];
        self.contentView.backgroundColor = [UIColor mainCellColor];
        [self setupCustomLabel];
        [self setupIconView];
        [self setupColorView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetWebColor:) name:passwordDidGrabWebColor object:nil];
    }
    return self;
}

-(void)didGetWebColor:(NSNotification *)notification
{
    RCPassword * password = notification.object;
    if ([password isEqual:self.password]){
        [UIView animateWithDuration:.3 animations:^{
          [self.colorView setBackgroundColor:password.webColor];
        }];
    }
}

-(void)setupColorView
{
    self.colorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 60)];
    [self.colorView setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:self.colorView];
}

-(void)setRedColored
{
    [UIView animateWithDuration:.23 animations:^{
        self.backgroundColor = [UIColor deleteRed];
    } completion:nil];
}

-(void)setGreenColored
{
    [UIView animateWithDuration:.23 animations:^{
        self.backgroundColor = [UIColor browserGreen];
    } completion:nil];
}

-(void)setDummyStyle
{
    self.contentView.backgroundColor = [UIColor listBackground];
}

-(void)setCompletelyGreen
{
    self.contentView.backgroundColor = [UIColor browserGreen];
    self.backgroundColor = [UIColor browserGreen];
}

-(void)setFinishedGreen
{
    self.backgroundColor = [UIColor browserGreen];
    [self.contentView setFrame:CGRectOffset(self.contentView.frame, self.frame.size.width, 0)];
    self.iconView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2.0, self.iconView.center.y);
}

-(void)setPassword:(RCPassword *)password
{
    _password = password;
    [self.customLabel setText:password.title];
}

-(void)showLoginIconWithScale:(CGFloat)scale translation:(CGFloat)translation
{
    self.iconView.alpha = 1;
    if (scale ==1 ){
        self.iconView.image = [loginIcon tintedIconWithColor:[UIColor whiteColor]];
    }else
        self.iconView.image = loginIcon;
    self.iconView.transform = CGAffineTransformMakeScale(scale, scale);
    [self.iconView setCenter:CGPointMake(0+translation/2.0, self.frame.size.height/2.0)];
}

-(void)showDeleteIconWithScale:(CGFloat)scale translation:(CGFloat)translation
{
    self.iconView.alpha = 1;
    if (scale ==1 ){
        self.iconView.image = [deleteIcon tintedIconWithColor:[UIColor whiteColor]];
    }else
        self.iconView.image = deleteIcon;
    self.iconView.transform = CGAffineTransformMakeScale(scale, scale);
    [self.iconView setCenter:CGPointMake(self.frame.size.width  - fabsf(translation)/2.0, self.frame.size.height/2.0)];
}

-(void)removeFocus
{
    [UIView animateWithDuration:.23 animations:^{
        self.backgroundColor = [UIColor listBackground];
    } completion:nil];
}

-(void)setNormalColored
{
    self.backgroundColor = [UIColor listBackground];
    self.contentView.backgroundColor = [UIColor mainCellColor];
    [self.customLabel setBackgroundColor:[UIColor clearColor]];
}

-(void)setupCustomLabel
{
    self.customLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 15, [UIScreen mainScreen].bounds.size.width-36, 30)];
    [self.customLabel setBackgroundColor:[UIColor clearColor]];
    [self.customLabel setNumberOfLines:1];
    UIFont * helvetica =[UIFont fontWithName:@"HelveticaNeue" size:20];
    [self.customLabel setFont:helvetica];
    [self.customLabel setTextColor:[UIColor colorWithWhite:.2 alpha:1]];
    [self.contentView addSubview:self.customLabel];
}

-(void)setupIconView
{
    self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    self.iconView.image = loginIcon;
    self.iconView.alpha = 0;
    [self insertSubview:self.iconView aboveSubview:self.contentView];
}

@end
