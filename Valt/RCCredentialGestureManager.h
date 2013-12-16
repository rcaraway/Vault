//
//  RCCredentialGestureManager.h
//  Valt
//
//  Created by Robert Caraway on 12/13/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol RCCredentialGestureManagerDelegate;

@interface RCCredentialGestureManager : NSObject

-(id)initWithTableView:(UITableView *)tableView delegate:(id<RCCredentialGestureManagerDelegate>)delgate;

@end



@protocol RCCredentialGestureManagerDelegate <NSObject>

-(BOOL)gestureManagerShouldAllowNewCellAtBottom:(RCCredentialGestureManager *)gestureManager;
-(void)gestureManager:(RCCredentialGestureManager *)gestureManager needsNewRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)gestureManagerDidTapOutsideRows:(RCCredentialGestureManager *)manager;
-(BOOL)gestureManagerShouldAllowEditingAtIndexPath:(NSIndexPath *)indexPath;
-(void)gestureManager:(RCCredentialGestureManager *)gestureManager didMoveToDeletionState:(BOOL)deletionState atIndexPath:(NSIndexPath*)indexPath;
-(void)gestureManager:(RCCredentialGestureManager *)gestureManager needsDeletionAtIndexPath:(NSIndexPath *)indexPath;

@end
