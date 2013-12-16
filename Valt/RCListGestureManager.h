//
//  RCListGestureManager.h
//  Valt
//
//  Created by Robert Caraway on 12/13/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
  RCListGestureManagerPanStateMiddle,
    RCListGestureManagerPanStateLeft,
    RCListGestureManagerPanStateRight
} RCListGestureManagerPanState;

@interface RCListGestureManager : NSObject <UITableViewDelegate>

-(id)initWithTableView:(UITableView *)tableView delegate:(id)delegate;


@end


@protocol RCListGestureManagerDelegate <NSObject>

-(void)gestureManager:(RCListGestureManager *)manager didTapRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)gestureManagerDidTapBelowCells:(RCListGestureManager *)manager;
-(void)gestureManager:(RCListGestureManager *)manager needsNewRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)gestureManager:(RCListGestureManager *)manager needsRowMovedAtIndexPath:(NSIndexPath *)indexPath;
-(void)gestureManager:(RCListGestureManager *)manager needsPlaceholderRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)gestureManager:(RCListGestureManager *)manager needsRemovalOfRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)gestureManager:(RCListGestureManager *)manager didChangeToState:(RCListGestureManagerPanState)state forIndexPath:(NSIndexPath *)indexPath;
-(void)gestureManager:(RCListGestureManager *)manager didFinishWithState:(RCListGestureManagerPanState)state forIndexPath:(NSIndexPath *)indexPath;

@end