//
//  RCSearchGestureManager.h
//  Valt
//
//  Created by Robert Caraway on 2/5/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCSearchGestureManager : NSObject

@property(nonatomic, weak) UITableView * tableView;

-(id)initWithTableView:(UITableView *)tableView delegate:(id)delegate;

@end


@protocol RCSearchGestureManagerDelegate <NSObject>

@optional
-(void)gestureManager:(RCSearchGestureManager *)manager didTapRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)gestureManager:(RCSearchGestureManager *)manager didChangeToWebState:(BOOL)webState forIndexPath:(NSIndexPath *)indexPath;
-(void)gestureManagerDidFinishWithWebState:(RCSearchGestureManager *)manager atIndexPath:(NSIndexPath *)indexPath;

@end
