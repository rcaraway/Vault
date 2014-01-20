//
//  RCListViewController.h
//  Valt
//
//  Created by Rob Caraway on 12/10/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCViewController.h"
#define NORMAL_CELL_FINISHING_HEIGHT 60

@class RCPassword;
@class RCTableView;
@interface RCListViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) RCTableView * tableView;
@property(nonatomic) NSIndexPath * viewPath;
@property(nonatomic, strong) UIButton * syncButton;
-(void)removePassword:(RCPassword *)password;


@end


@interface RCTableView : UITableView

@property (nonatomic) BOOL shouldAllowMovement;

@end
