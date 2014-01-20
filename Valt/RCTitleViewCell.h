//
//  RCTableViewCell.h
//  Valt
//
//  Created by Rob Caraway on 12/11/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HTAutocompleteTextField;
@interface RCTitleViewCell : UITableViewCell

@property(nonatomic, strong) HTAutocompleteTextField * textField;

-(void)setNormalColored;
-(void)setPurpleColoed;

@end


