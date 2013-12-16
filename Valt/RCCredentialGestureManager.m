//
//  RCCredentialGestureManager.m
//  Valt
//
//  Created by Robert Caraway on 12/13/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCCredentialGestureManager.h"

#define DELETION_LENGTH 100

@interface RCCredentialGestureManager () <UIGestureRecognizerDelegate>

@property(nonatomic, weak) id<RCCredentialGestureManagerDelegate> delegate;
@property(nonatomic, weak) UITableView * tableView;
@property(nonatomic, strong) UITapGestureRecognizer * tapGesture;
@property(nonatomic, strong) UIPanGestureRecognizer * panGesture;
@property (nonatomic)BOOL deletionState;

@end

@implementation RCCredentialGestureManager


#pragma mark - Initialization

-(id)initWithTableView:(UITableView *)tableView delegate:(id<RCCredentialGestureManagerDelegate>)delgate
{
    self = super.init;
    if (self){
        self.tableView = tableView;
        self.delegate = delgate;
        [self setupTapGesture];
    }
    return self;
}


#pragma mark - Tap Gesture

-(void)setupTapGesture
{
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    self.tapGesture.delegate = self;
    [self.tableView addGestureRecognizer:self.tapGesture];
}

-(void)tapped:(UITapGestureRecognizer *)tapGesture
{
    CGPoint location = [tapGesture locationInView:self.tableView];
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:location];
    if (indexPath && indexPath.row == [self.tableView numberOfRowsInSection:0]-1 && [self.delegate gestureManagerShouldAllowNewCellAtBottom:self]){
        [self.delegate gestureManager:self needsNewRowAtIndexPath:indexPath];
        [self addNewCellAtBottom];
    }else if (!indexPath){
        [self.delegate gestureManagerDidTapOutsideRows:self];
    }
}

-(void)addNewCellAtBottom
{
    [self.tableView reloadData];
}


#pragma mark - Pan Gesture

-(void)setupPanGesture
{
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    self.panGesture.delegate = self;
    [self.tableView addGestureRecognizer:self.panGesture];
}

-(void)panned:(UIPanGestureRecognizer *)panGesture
{
    CGPoint location = [panGesture locationInView:self.tableView];
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:location];
    if ([self.delegate gestureManagerShouldAllowEditingAtIndexPath:indexPath]){
        if (panGesture.state == UIGestureRecognizerStateBegan || panGesture.state == UIGestureRecognizerStateChanged){
            [self dragCellAtIndexPath:indexPath];
        }else if (panGesture.state == UIGestureRecognizerStateEnded){
            if (self.deletionState){
                [self.delegate gestureManager:self needsDeletionAtIndexPath:indexPath];
                [self deleteCellAtIndexPath:indexPath];
                self.deletionState = NO;
            }else{
                [self resetCellToOriginalPositionAtIndexPath:indexPath];
            }
        }
    }
}

-(void)resetCellToOriginalPositionAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [UIView animateWithDuration:.22 delay:0 usingSpringWithDamping:.3 initialSpringVelocity:.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
        cell.contentView.frame = cell.contentView.bounds;
    } completion:nil];
}

-(void)deleteCellAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView reloadData];
}

-(void)dragCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
    CGPoint translation = [self.panGesture translationInView:self.tableView];
    cell.contentView.frame = CGRectOffset(cell.frame, translation.x, 0);
    if (fabsf(translation.x) >= DELETION_LENGTH && !self.deletionState){
        self.deletionState = YES;
        [self.delegate gestureManager:self didMoveToDeletionState:YES atIndexPath:indexPath];
    }else if (self.deletionState){
        self.deletionState = NO;
        [self.delegate gestureManager:self didMoveToDeletionState:NO atIndexPath:indexPath];
    }
}


#pragma mark - Gesture Delegate

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.panGesture){
        return [self panGestureInAllowedDraggingArea];
    }
    return YES;
}

-(BOOL)panGestureInAllowedDraggingArea
{
    CGPoint point = [self.panGesture translationInView:self.tableView];
    CGPoint location = [self.panGesture locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (!indexPath || !cell){
        return NO;
    }
    if (cell.contentView.frame.origin.x + point.x > 320){
        return NO;
    }
    return YES;
}


@end
