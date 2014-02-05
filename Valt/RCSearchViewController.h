//
//  RCSearchViewController.h
//  Valt
//
//  Created by Robert Caraway on 12/17/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RCSearchBar;
@class RCTableView;
@class RCSearchGestureManager;

@interface RCSearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) RCTableView * tableView;
@property(nonatomic, strong) RCSearchBar * searchBar;
@property(nonatomic, strong) RCSearchGestureManager * gestureManager;
@property(nonatomic, strong) NSIndexPath * viewPath;


@end
