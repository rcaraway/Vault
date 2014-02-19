//
//  RCSingleViewController.h
//  Valt
//
//  Created by Rob Caraway on 12/10/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCViewController.h"

@class RCPassword;
@interface RCSingleViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) UITableView * tableView;
@property(nonatomic, strong) RCPassword * password;

@property (nonatomic) BOOL mayDeleteCell;
@property(nonatomic) BOOL isTransitioningTo;
@property(nonatomic) BOOL cameFromSearch;


-(id)initWithPassword:(RCPassword *)password;
-(void)setAllTextFieldDelegates;

@end
