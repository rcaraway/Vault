//
//  RCMainCell.h
//  Valt
//
//  Created by Robert Caraway on 12/17/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCMainCell : UITableViewCell

@property(nonatomic, strong) UILabel * customLabel;
@property(nonatomic, strong) UIImageView * iconView;

-(void)showLoginIconWithScale:(CGFloat)scale translation:(CGFloat)translation;
-(void)showDeleteIconWithScale:(CGFloat)scale translation:(CGFloat)translation;
-(void)setGreenColored;
-(void)setCompletelyGreen;
-(void)removeFocus;
-(void)setRedColored;


@end
