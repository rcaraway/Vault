//
//  RCMainCell.m
//  Valt
//
//  Created by Robert Caraway on 12/17/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCMainCell.h"
#import "UIColor+RCColors.h"

@implementation RCMainCell
{
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor listBackground];
        self.contentView.backgroundColor = [UIColor mainCellColor];
        [self setupCustomLabel];
    }
    return self;
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

-(void)setCompletelyGreen
{
    self.contentView.backgroundColor = [UIColor browserGreen];
    self.customLabel.backgroundColor = [UIColor browserGreen];
    self.backgroundColor = [UIColor browserGreen];
}

-(void)removeFocus
{
    [UIView animateWithDuration:.23 animations:^{
        self.backgroundColor = [UIColor listBackground];
    } completion:nil];
}

-(void)prepareForReuse
{
    self.backgroundColor = [UIColor listBackground];
    self.contentView.backgroundColor = [UIColor mainCellColor];
    [self.customLabel setBackgroundColor:self.contentView.backgroundColor];
}

-(void)setupCustomLabel
{
    self.customLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 15, [UIScreen mainScreen].bounds.size.width-36, 30)];
    [self.customLabel setBackgroundColor:self.contentView.backgroundColor];
    [self.customLabel setNumberOfLines:1];
    UIFont * helvetica =[UIFont fontWithName:@"HelveticaNeue" size:20];
    [self.customLabel setFont:helvetica];
    [self.customLabel setTextColor:[UIColor colorWithWhite:.2 alpha:1]];
    [self.contentView addSubview:self.customLabel];
}


@end
