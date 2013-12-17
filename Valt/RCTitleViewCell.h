//
//  RCTableViewCell.h
//  Valt
//
//  Created by Rob Caraway on 12/11/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCTitleViewCell : UITableViewCell

@property(nonatomic, strong) UITextField * textField;

-(void)setFocused;
-(void)removeFocus;
-(void)setRedColored;

@end


