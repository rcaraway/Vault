//
//  RCMainCell.h
//  Valt
//
//  Created by Robert Caraway on 12/17/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RCPassword;

@interface RCMainCell : UITableViewCell

@property(nonatomic, strong) UILabel * customLabel;
@property(nonatomic, strong) UIImageView * iconView;
@property(nonatomic, strong) UIView * colorView;
@property(nonatomic, strong) RCPassword * password;


-(void)showLoginIconWithScale:(CGFloat)scale translation:(CGFloat)translation;
-(void)showDeleteIconWithScale:(CGFloat)scale translation:(CGFloat)translation;
-(void)setGreenColored;
-(void)setCompletelyGreen;
-(void)setNormalColored;
-(void)setFinishedGreen;
-(void)removeFocus;
-(void)setRedColored;


@end
