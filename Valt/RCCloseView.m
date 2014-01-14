//
//  RCCloseView.m
//  Valt
//
//  Created by Robert Caraway on 1/14/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCCloseView.h"
#import "UIColor+RCColors.h"

@interface RCCloseView () <UIGestureRecognizerDelegate>

@property(nonatomic, strong) UIPanGestureRecognizer * panGesture;

@end


@implementation RCCloseView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor passcodeBackground];
        [self addCornerMask];
        [self setupPanGesture];
    }
    return self;
}

-(void)addCornerMask
{
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:(UIRectCornerBottomRight | UIRectCornerTopRight) cornerRadii:CGSizeMake(5.0, 5.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

-(void)setupPanGesture
{
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan)];
    self.panGesture.delegate =self;
    [self addGestureRecognizer:self.panGesture];
}

-(void)didPan
{
    
}

@end
