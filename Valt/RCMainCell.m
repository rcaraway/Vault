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
        separator.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
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


@end
