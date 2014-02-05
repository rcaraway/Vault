//
//  RCRootViewController+searchSegue.h
//  Valt
//
//  Created by Robert Caraway on 1/16/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCRootViewController.h"

@interface RCRootViewController (searchSegue)

-(void)segueListToSearch;
-(void)segueSearchToList;
-(void)segueSearchToSingleWithPassword:(RCPassword *)password indexPath:(NSIndexPath *)path;
-(void)segueSingleToSearch;

@end
