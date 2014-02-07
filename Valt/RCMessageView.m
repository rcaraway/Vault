//
//  RCMessageView.m
//  Valt
//
//  Created by Rob Caraway on 1/30/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCMessageView.h"

#import "RCAppDelegate.h"
#import "RCRootViewController.h"
#import "RCPasscodeViewController.h"

#import "UIColor+RCColors.h"

NSString * const messageViewWillShow = @"messageViewWillShow";
NSString * const messageViewWillHide = @"messageViewWillHide";


@implementation RCMessageView


#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    return [self init];
}

-(id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
    if (self){
        self.clipsToBounds = YES;
        [self setupMessageLabel];
        self.messageShowing = NO;
        self.backgroundColor = [UIColor navColor];
    }
    return self;
}


#pragma mark - Main Methods

-(void)showMessage:(NSString *)message autoDismiss:(BOOL)autoDismiss
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (self.messageShowing){
        self.messageLabel.text = message;
        if (autoDismiss)
            [self performSelector:@selector(hideMessage) withObject:nil afterDelay:2];
    }else{
        self.messageShowing = YES;
        self.messageLabel.text = message;
  
        [UIView animateWithDuration:.2 animations:^{
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
            self.messageLabel.frame = self.frame;
        }completion:^(BOOL finished) {
            if (autoDismiss)
                [self performSelector:@selector(hideMessage) withObject:nil afterDelay:2];
        }];
    }
}

-(void)hideMessage
{
    self.messageShowing = NO;
    [UIView animateWithDuration:.2 animations:^{
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        self.messageLabel.frame = CGRectOffset(self.messageLabel.frame, 0, 20);
    }completion:^(BOOL finished) {
        self.messageLabel.text = @"";
    }];
}


#pragma mark - Setup

-(void)setupMessageLabel
{
    self.messageLabel = [[UILabel  alloc] initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 20)];
    self.messageLabel.numberOfLines = 1;
    self.messageLabel.textColor = [UIColor blackColor];
    self.messageLabel.textAlignment = NSTextAlignmentCenter;
    self.messageLabel.backgroundColor = [UIColor clearColor];
    self.messageLabel.font = [UIFont boldSystemFontOfSize:12];
    [self addSubview:self.messageLabel];
}




@end


