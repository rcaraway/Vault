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

@class RCTableView;

@interface RCListGestureManager : NSObject <UITableViewDelegate>

@property(nonatomic, weak) RCTableView * tableView;
@property(nonatomic) BOOL didAddCell;
@property(nonatomic) BOOL menuMode;
@property(nonatomic, strong)NSIndexPath * webPath;

-(id)initWithTableView:(UITableView *)tableView delegate:(id)delegate;
-(void)reloadAllRowsExceptIndexPath:(NSIndexPath *)indexPath;
-(void)resetCellToCenterAtIndexPath:(NSIndexPath *)indexPath;

@end


@protocol RCListGestureManagerDelegate <NSObject>


-(void)gestureManagerDidTapInMenuMode:(RCListGestureManager *)manager;
-(BOOL)gestureManagerShouldAllowCellCreation:(RCListGestureManager *)manager;
-(void)gestureManager:(RCListGestureManager *)manager didTapRowAtIndexPath:(NSIndexPath *)indexPath atLocation:(CGPoint)location;
-(void)gestureManagerDidTapBelowCells:(RCListGestureManager *)manager atLocation:(CGPoint)location;
-(void)gestureManager:(RCListGestureManager *)manager needsNewRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)gestureManager:(RCListGestureManager *)manager needsRowMovedAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)updatedPath;
-(void)gestureManager:(RCListGestureManager *)manager needsPlaceholderRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)gestureManager:(RCListGestureManager *)manager needsReplacePlaceholderForRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)gestureManager:(RCListGestureManager *)manager needsFinishedNewRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)gestureManager:(RCListGestureManager *)manager needsRemovalOfRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)gestureManager:(RCListGestureManager *)manager didFinishAnimatingNewRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)gestureManager:(RCListGestureManager *)manager didChangeToState:(RCListGestureManagerPanState)state forIndexPath:(NSIndexPath *)indexPath;
-(void)gestureManager:(RCListGestureManager *)manager didFinishWithState:(RCListGestureManagerPanState)state forIndexPath:(NSIndexPath *)indexPath;

@end
