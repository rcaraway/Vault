//
//  RCPasswordSegue.m
//  Valt
//
//  Created by Rob Caraway on 1/16/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCPasswordSegue.h"
#import "RCListGestureManager.h"
#import "RCRootViewController.h"
#import "RCSingleViewController.h"
#import "RCListViewController.h"

@implementation RCPasswordSegue


#pragma mark - Life Cycle

-(id)initWithRootController:(RCRootViewController *)root
{
    self = [super initWithRootController:root];
    if (self){
        [self addNotifications];
    }
    return self;
}

-(void)dealloc
{
    [self removeNotifications];
}

-(void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(segueToSingle:) name:listGestureManagerDidTapRow object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(segueToSingle:) name:listGestureManagerDidTapBelowRows object:nil];
}

-(void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Segue

-(void)segueToList
{
    
}

-(void)segueToSingle:(NSNotification *)notification
{
    [self.rootVC addChildViewController:self.rootVC.singleController];
    [self.rootVC.listController removeFromParentViewController];
    NSIndexPath * indexPath = notification.object;
    NSValue * value =notification.userInfo[@"location"];
    CGPoint point = [value CGPointValue];
    if (indexPath){
        [self transitionToSingleFromIndexPath:indexPath completion:^{
            
        }];
    }else{
        [self transitionToSingleFromLocation:point completion:^{
            
        }];
    }
}


#pragma mark - Transitions

-(void)transitionToSingleFromIndexPath:(NSIndexPath *)indexPath completion:(void(^)())completion
{
    //Get exact location of the cell
    //Add dummycell one below indexpath
    //Dummy cell is same color as single background
    //same height as TitleCell plus 4 dropdown Cells
    //the single.view && tableview back IS the darkView
    //the list is not removed from the background
}

-(void)transitionToSingleFromLocation:(CGPoint)location completion:(void(^)())completion
{
    //Fade the background color
    //dismiss the dropdown cells animated
    //delete the dummy cell from the list table view animated
    //animate color change of the title cell
    //when back in position, remove the single VC
}


#pragma mark - Convenience



@end
