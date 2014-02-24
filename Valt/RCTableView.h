//
//  RCTableView.h
//  Valt
//
//  Created by Robert Caraway on 2/5/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCTableView : UITableView

@property (nonatomic) BOOL shouldAllowMovement;
@property (nonatomic) BOOL extendedSize;
@property (nonatomic) BOOL shouldAllowResize;

@end
