//
//  RCAutofillCell.m
//  Valt
//
//  Created by Rob Caraway on 4/16/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCAutofillCell.h"
#import "UIColor+RCColors.h"

@interface RCAutofillCell ()

@property(nonatomic, strong) UILabel * autofillLabel;

@end


@implementation RCAutofillCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupAutofillLabel];
        self.contentView.backgroundColor = [UIColor navColor];
    }
    return self;
}


-(void)setupAutofillLabel
{
    UILabel * label = [[UILabel  alloc] initWithFrame:self.contentView.bounds];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 1;
    label.font = [UIFont systemFontOfSize:15];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor darkGrayColor];
    self.autofillLabel= label;
    [self.contentView addSubview:label];
}

-(void)setAutofillText:(NSString *)autofillText
{
    _autofillText = [autofillText copy];
    CGFloat width = [autofillText sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15]}].width;
    [self.autofillLabel setFrame:CGRectMake(0, 0, width+22, 43)];
    self.autofillLabel.text = self.autofillText;
}

@end
