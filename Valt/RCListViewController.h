//
//  RCListViewController.h
//  Valt
//
//  Created by Rob Caraway on 12/10/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCViewController.h"

@class RCPassword;
@interface RCListViewController : UITableViewController <UISearchBarDelegate>

-(void)removePassword:(RCPassword *)password;

@end
