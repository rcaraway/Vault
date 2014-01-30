//
//  RCMessageView.h
//  Valt
//
//  Created by Rob Caraway on 1/30/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RCMessageView : UIView

@property(nonatomic, strong) UILabel * messageLabel;
@property(nonatomic) BOOL messageShowing;

-(void)showMessage:(NSString *)message autoDismiss:(BOOL)autoDismiss;
-(void)hideMessage;

@end


extern NSString * const messageViewWillShow;
extern NSString * const messageViewWillHide;