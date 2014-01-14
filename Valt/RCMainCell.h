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

-(void)setFocused;
-(void)setGreenColored;
-(void)removeFocus;
-(void)setRedColored;


@end
