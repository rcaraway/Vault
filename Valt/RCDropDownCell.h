//
//  RCDropDownCell.h
//  Valt
//
//  Created by Rob Caraway on 12/11/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCDropDownCell : UITableViewCell

@property(nonatomic, strong) UITextField * textField;

-(void)setTitle:(NSString *)title placeHolder:(NSString *)placeHolder;
-(void)setAddMoreState;

@end
