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
    UIView * separator;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        separator = [[UIView  alloc] initWithFrame:CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1)];
        separator.backgroundColor = [UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:230.0/255.0 alpha:1];
        self.backgroundColor = [UIColor listBackground];
        self.contentView.backgroundColor = [UIColor colorWithRed:253.0/255.0 green:245.0/255.0 blue:254.0/255.0 alpha:1];
        [self setupCustomLabel];
        [self addSubview:separator];
    }
    return self;
}

-(void)didMoveToSuperview
{
    [separator setFrame:CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1)];
}

-(void)setRedColored
{
    [UIView animateWithDuration:.23 animations:^{
        self.backgroundColor = [UIColor redColor];
    } completion:nil];
}

-(void)setGreenColored
{
    [UIView animateWithDuration:.23 animations:^{
        self.backgroundColor = [UIColor colorWithRed:0 green:178.0/255.0 blue:95.0/255.0 alpha:1];
    } completion:nil];
}

-(void)setFocused
{

}

-(void)removeFocus
{
    [UIView animateWithDuration:.23 animations:^{
        self.backgroundColor = [UIColor listBackground];
    } completion:nil];
}


-(void)setupCustomLabel
{
    self.customLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 15, [UIScreen mainScreen].bounds.size.width-36, 30)];
    [self.customLabel setBackgroundColor:self.contentView.backgroundColor];
    [self.customLabel setNumberOfLines:1];
    UIFont * helvetica =[UIFont fontWithName:@"HelveticaNeue" size:20];
    [self.customLabel setFont:helvetica];
    [self.customLabel setTextColor:[UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:65.0/255.0 alpha:1]];
    [self.contentView addSubview:self.customLabel];
}


@end
