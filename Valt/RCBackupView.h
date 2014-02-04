//
//  RCBackupView.h
//  Valt
//
//  Created by Robert Caraway on 2/3/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RCBackupViewDelegate;

@interface RCBackupView : UIView

@property(nonatomic, weak) id<RCBackupViewDelegate> delegate;
@property(nonatomic, strong) UIImageView * imageView;
@property(nonatomic, strong) UILabel * backupLabel;
@property(nonatomic, strong) UIButton * yesButton;
@property(nonatomic, strong) UIButton * noButton;

@end

@protocol RCBackupViewDelegate <NSObject>

@optional
-(void)backupViewDidTapYes:(RCBackupView *)backupView;
-(void)backupViewDidTapNo:(RCBackupView *)backupView;

@end