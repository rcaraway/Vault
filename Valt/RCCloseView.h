//
//  RCCloseView.h
//  Valt
//
//  Created by Robert Caraway on 1/14/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RCCloseViewDelegate;

@interface RCCloseView : UIView

@property(nonatomic, weak) id<RCCloseViewDelegate> delegate;
@property(nonatomic, strong) UIImageView * iconView;

@end


@protocol RCCloseViewDelegate <NSObject>

@optional
-(void)closeViewDidBegin:(RCCloseView *)closeView;
-(void)closeView:(RCCloseView *)closeView didChangeXOrigin:(CGFloat)xOrigin;
-(void)closeView:(RCCloseView *)closeView didFinishWithClosing:(BOOL)closing atOrigin:(CGFloat)xOrigin;

@end