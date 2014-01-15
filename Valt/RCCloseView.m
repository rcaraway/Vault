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
{
    CGFloat initialX;
    CGRect initalFrame;
}

@property(nonatomic, strong) UIPanGestureRecognizer * panGesture;
@property(nonatomic, strong) UITapGestureRecognizer * tapGesture;

@end


@implementation RCCloseView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor passcodeBackground];
        [self addCornerMask];
        [self setupPanGesture];
        [self setupTapGesture];
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

-(void)setupTapGesture
{
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
    self.tapGesture.delegate = self;
    [self addGestureRecognizer:self.tapGesture];
}


-(void)didTap
{
    if ([self delegateCanRespond:@selector(closeViewDidTap:)]){
        [self.delegate closeViewDidTap:self];
    }
}

-(void)didPan
{
    if (self.panGesture.state == UIGestureRecognizerStateBegan){
        initalFrame = self.frame;
        initialX = [self.panGesture locationInView:self].x;
        if ([self delegateCanRespond:@selector(closeViewDidBegin:)]){
            [self.delegate closeViewDidBegin:self];
        }
    }else if (self.panGesture.state == UIGestureRecognizerStateChanged){
        CGFloat x = [self.panGesture locationInView:self].x;
        CGFloat difference = x - initialX;
        [self setFrame:CGRectMake(self.frame.origin.x +difference, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
        if ([self delegateCanRespond:@selector(closeView:didChangeXOrigin:)]){
            [self.delegate closeView:self didChangeXOrigin:self.frame.origin.x];
        }
    }else if (self.panGesture.state == UIGestureRecognizerStateEnded){
        if (self.frame.origin.x >= initalFrame.origin.x+150){
            [UIView animateWithDuration:.23 animations:^{
               self.frame = CGRectMake([UIScreen mainScreen].bounds.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
            }];
            if ([self delegateCanRespond:@selector(closeView:didFinishWithClosing:atOrigin:)]){
                [self.delegate closeView:self didFinishWithClosing:YES atOrigin:self.frame.origin.x];
            }
        }else{
            if ([self delegateCanRespond:@selector(closeView:didFinishWithClosing:atOrigin:)]){
                [self.delegate closeView:self didFinishWithClosing:NO atOrigin:self.frame.origin.x];
            }
            [UIView animateWithDuration:.23 animations:^{
                self.frame = initalFrame;
            }];
        }
    }
}

-(BOOL)delegateCanRespond:(SEL)selector
{
    return (self.delegate && [self.delegate respondsToSelector:selector]);
}

@end
