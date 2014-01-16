//
//  RCRootViewController+passwordSegues.h
//  Valt
//
//  Created by Robert Caraway on 1/16/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCRootViewController.h"
@class RCPassword;

@interface RCRootViewController (passwordSegues)

-(void)segueSingleToList;
-(void)segueSingleToListWithRemovedPassword;
-(void)segueToSingleWithPassword:(RCPassword *)password;
-(void)segueToSingleWithNewPasswordAtIndexPath:(NSIndexPath *)indexPath;
-(void)segueToSingleWithNewPasswordAtLocation:(CGPoint)location;

@end
