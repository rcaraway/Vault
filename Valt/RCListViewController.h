//
//  RCListViewController.h
//  Valt
//
//  Created by Rob Caraway on 12/10/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCViewController.h"
#define NORMAL_CELL_FINISHING_HEIGHT 60
#define COMMITING_CREATE_CELL_HEIGHT 60

@class RCPassword;
@class RCTableView;
@class RCListGestureManager;

@interface RCListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) RCTableView * tableView;
@property(nonatomic, strong) RCListGestureManager * gestureManager;
@property(nonatomic, strong) NSIndexPath * viewPath;
@property(nonatomic, strong) NSIndexPath * webPath;


-(void)removePassword:(RCPassword *)password;


@end


@interface RCTableView : UITableView

@property (nonatomic) BOOL shouldAllowMovement;
@property (nonatomic) BOOL extendedSize;

@end
