//
//  RCSearchGestureManager.m
//  Valt
//
//  Created by Robert Caraway on 2/5/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCSearchGestureManager.h"

#import "RCMainCell.h"

#define PAN_COMMIT_LENGTH 70
#define CELL_SNAPSHOT_TAG 100000

@interface RCSearchGestureManager () <UIGestureRecognizerDelegate>

@property(nonatomic, weak)id<RCSearchGestureManagerDelegate> delegate;

@property(nonatomic, strong) UIPanGestureRecognizer * panGesture;
@property(nonatomic, strong) UITapGestureRecognizer * tapGesture;
@property(nonatomic, strong) NSIndexPath * panningPath;

@property (nonatomic) BOOL panWebState;

@end



@implementation RCSearchGestureManager




#pragma mark - Setup / Initialization

-(id)initWithTableView:(UITableView *)tableView delegate:(id)delegate
{
    self = super.init;
    if (self){
        self.delegate = delegate;
        self.tableView=tableView;
        self.panWebState = NO;
        [self setupPanGesture];
        [self setupTapGesture];
    }
    return self;
}

-(void)setupPanGesture
{
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan)];
    self.panGesture.delegate = self;
    [self.tableView addGestureRecognizer:self.panGesture];
}

-(void)setupTapGesture
{
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
    self.tapGesture.delegate = self;
    [self.tableView addGestureRecognizer:self.tapGesture];
}


#pragma mark - Event Handling

-(void)didPan
{
    if (self.panGesture.state == UIGestureRecognizerStateBegan || self.panGesture.state == UIGestureRecognizerStateChanged){
        NSIndexPath * path = [self panGesturePath];
        [self translateCellAtIndexPath:path];
    }else if (self.panGesture.state == UIGestureRecognizerStateEnded)
    {
        [self handleFinalStateForIndexPath:self.panningPath];
    }
}

-(void)didTap
{
    CGPoint location = [self.tapGesture locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    if (indexPath){
        if (self.delegate && [self.delegate respondsToSelector:@selector(gestureManager:didTapRowAtIndexPath:)]){
            [self.delegate gestureManager:self didTapRowAtIndexPath:indexPath];
        }
    }
}


#pragma mark - Pan Convenience

-(NSIndexPath *)panGesturePath
{
    if (self.panGesture.numberOfTouches > 0){
        CGPoint location1 = [self.panGesture locationOfTouch:0 inView:self.tableView];
        NSIndexPath *indexPath = self.panningPath;
        if (!indexPath) {
            indexPath = [self.tableView indexPathForRowAtPoint:location1];
            self.panningPath = indexPath;
        }
    }
    return self.panningPath;
}

-(void)translateCellAtIndexPath:(NSIndexPath *)indexPath
{
    RCMainCell *cell = (RCMainCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    CGPoint translation = [self.panGesture translationInView:self.tableView];
    CGFloat fraction =  fminf(fabsf((translation.x)/PAN_COMMIT_LENGTH), 1.0);
    if (translation.x >= 0){
        [cell showLoginIconWithScale:fraction translation:translation.x];
        cell.contentView.frame = CGRectOffset(cell.contentView.bounds, translation.x, 0);
    }
    [self handleStateWithTranslation:translation.x indexPath:indexPath];
}

-(void)handleStateWithTranslation:(CGFloat)translation indexPath:(NSIndexPath *)indexPath
{
    if (translation >= PAN_COMMIT_LENGTH && !self.panWebState){
        self.panWebState = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(gestureManager:didChangeToWebState:forIndexPath:)]){
            [self.delegate gestureManager:self didChangeToWebState:self.panWebState forIndexPath:indexPath];
        }
    }else if (translation <= PAN_COMMIT_LENGTH && self.panWebState){
        self.panWebState = NO;
        if (self.delegate && [self.delegate respondsToSelector:@selector(gestureManager:didChangeToWebState:forIndexPath:)]){
            [self.delegate gestureManager:self didChangeToWebState:self.panWebState forIndexPath:indexPath];
        }
    }
}

-(void)handleFinalStateForIndexPath:(NSIndexPath *)indexPath
{
    CGPoint translation = [self.panGesture translationInView:self.tableView];
    if (translation.x >= PAN_COMMIT_LENGTH){
        RCMainCell * cell = (RCMainCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [UIView animateWithDuration:.2 animations:^{
            [cell.contentView setFrame:CGRectOffset(cell.contentView.frame, self.tableView.frame.size.width-translation.x, 0)];
            cell.iconView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2.0, cell.iconView.center.y);
        } completion:^(BOOL finished) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(gestureManagerDidFinishWithWebState:atIndexPath:)]){
                [self.delegate gestureManagerDidFinishWithWebState:self atIndexPath:indexPath];
            }
        }];
    }else{
        [self resetCellToCenterAtIndexPath:indexPath];
    }
    self.panWebState = NO;
    self.panningPath = nil;
}

-(void)resetCellToCenterAtIndexPath:(NSIndexPath *)indexPath
{
    RCMainCell *cell = (RCMainCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [UIView animateWithDuration:.22 animations:^{
        cell.iconView.transform = CGAffineTransformMakeScale(0, 0);
        if (cell.contentView.bounds.origin.x > cell.contentView.frame.origin.x){
            cell.iconView.center = CGPointMake(cell.frame.size.width, cell.iconView.center.y);
        }else{
            cell.iconView.center = CGPointMake(0, cell.iconView.center.y);
        }
        cell.contentView.frame = cell.contentView.bounds;
    }];
}

@end
