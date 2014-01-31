//
//  RCListGestureManager.m
//  Valt
//
//  Created by Robert Caraway on 12/13/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCListGestureManager.h"
#import "RCMainCell.h"


typedef enum {
    RCListGestureManagerStateNone,
    RCListGestureManagerStateDragging,
    RCListGestureManagerStatePinching,
    RCListGestureManagerStatePanning,
    RCListGestureManagerStateMoving,
} RCListGestureManagerState;

#define PAN_COMMIT_LENGTH 70
#define CELL_SNAPSHOT_TAG 100000

#define TOP_INSET 44

@interface RCListGestureManager () <UIGestureRecognizerDelegate>
{
    CGPoint lastPinchOrigin;
}


@property(nonatomic, weak) id delegate;
@property(nonatomic, weak) id<UITableViewDelegate> tableViewDelegate;

@property (nonatomic, strong) UIPinchGestureRecognizer      *pinchGesture;
@property (nonatomic, strong) UIPanGestureRecognizer        *panGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer  *longPress;
@property (nonatomic, strong) UITapGestureRecognizer        *tapGesture;

@property (nonatomic) RCListGestureManagerState state;
@property(nonatomic) RCListGestureManagerPanState panState;

@property(nonatomic, strong) NSIndexPath * pendingPath;
@property(nonatomic, strong) NSTimer * scrollTimer;
@property (nonatomic) CGFloat pendingRowHeight;
@property (nonatomic) CGFloat scrollRate;

@end


@implementation RCListGestureManager


#pragma mark - Initialization

-(id)initWithTableView:(UITableView *)tableView delegate:(id)delegate
{
    self = super.init;
    if (self){
        self.tableView = tableView;
        self.delegate = delegate;
        self.tableViewDelegate = tableView.delegate;
        tableView.delegate = self;
        [self setupPinchGesture];
        [self setupPanGesture];
        [self setupTapGesture];
        self.panState = RCListGestureManagerPanStateMiddle;
        [self setupLongPress];
    }
    return self;
}

-(void)setupPinchGesture
{
    self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(didPinch)];
    self.pinchGesture.delegate = self;
    [self.tableView addGestureRecognizer:self.pinchGesture];
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

-(void)setupLongPress
{
    self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPress)];
    self.longPress.delegate = self;
    [self.tableView addGestureRecognizer:self.longPress];
}


#pragma mark - Event Handling

-(void)didPinch
{
    if (self.pinchGesture.state == UIGestureRecognizerStateEnded || self.pinchGesture.numberOfTouches < 2) {
        if (self.pendingPath) {
            [self determineFateOfPendingCell];
        }
        return;
    } else if (self.pinchGesture.state == UIGestureRecognizerStateBegan){
        self.state = RCListGestureManagerStatePinching;
        lastPinchOrigin = [self upperPinchPoint];
        self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.frame.size.height, 0, self.tableView.frame.size.height, 0);
        [self.delegate gestureManager:self needsNewRowAtIndexPath:self.pendingPath];
        [self.tableView reloadData];
    }else if (self.pinchGesture.state == UIGestureRecognizerStateChanged){
        [self adjustPendingHeightDuringPinch];
    }
}


-(void)didTap
{
    if (self.menuMode){
        [self.delegate gestureManagerDidTapInMenuMode:self];
    }else{
        CGPoint location = [self.tapGesture locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
        if (indexPath){
            [self.delegate gestureManager:self didTapRowAtIndexPath:indexPath atLocation:location];
        }
        else{
            [self.delegate gestureManagerDidTapBelowCells:self atLocation:location];
        }
    }
}

-(void)didPan
{
    if ((self.panGesture.state == UIGestureRecognizerStateBegan
         || self.panGesture.state == UIGestureRecognizerStateChanged)
        && [self.panGesture numberOfTouches] > 0) {
         NSIndexPath * indexPath = [self panGesturePath];
        self.state = RCListGestureManagerStatePanning;
        [self translateCellAtIndexPath:indexPath];
        [self determinePanStateForIndexPath:indexPath];
    }else if (self.panGesture.state == UIGestureRecognizerStateEnded){
        NSIndexPath * indexPath = self.pendingPath;
        self.pendingPath = nil;
        [self handleFinalStateForIndexPath:indexPath];
       
    }
}

-(void)didLongPress
{
    if (self.longPress.state == UIGestureRecognizerStateBegan){
        [self didEnterBeginMovingState];
    }else if (self.longPress.state == UIGestureRecognizerStateEnded){
        [self didFinishMovingCell];
    }else if (self.longPress.state == UIGestureRecognizerStateChanged){
        [self updatePositionOfFakeCell];
    }
}


#pragma mark - State Handling

-(void)reloadAllRowsExceptIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray * array = [[self.tableView indexPathsForVisibleRows] mutableCopy];
    [array removeObject:indexPath];
    [self.tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
}


-(void)adjustScrollDuringLongPress
{
    [self adjustTableYOffset];
    CGPoint location = [self.longPress locationInView:self.tableView];
    if (location.y >= 0) {
        UIImageView *cellSnapshotView = (id)[self.tableView viewWithTag:CELL_SNAPSHOT_TAG];
        cellSnapshotView.center = CGPointMake(self.tableView.center.x, location.y);
    }
    [self determinePendingPathForCurrentTouchLocation];
}

-(void)attachTimerToHandleScrolling
{
    self.scrollTimer = [NSTimer timerWithTimeInterval:1/8 target:self selector:@selector(adjustScrollDuringLongPress) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.scrollTimer forMode:NSDefaultRunLoopMode];
}

-(void)determinePendingPathForCurrentTouchLocation
{
    CGPoint location = [self.longPress locationInView:self.tableView];
    NSIndexPath *indexPath  = [self.tableView indexPathForRowAtPoint:location];
    if (indexPath && ![indexPath isEqual:self.pendingPath]){
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.pendingPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.delegate gestureManager:self needsRowMovedAtIndexPath:self.pendingPath toIndexPath:indexPath];
        self.pendingPath = indexPath;
        [self.tableView endUpdates];
    }
}

-(void)determineFateOfPendingCell
{
    if (self.pendingPath){
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:self.pendingPath];
        CGFloat requiredHeight = self.tableView.rowHeight;
        NSIndexPath * copy = [self.pendingPath copy];
        if (cell.frame.size.height >= requiredHeight){
            [CATransaction begin];
            [self.tableView beginUpdates];
            [CATransaction setCompletionBlock:^{
                if (self.didAddCell){
                    [self.delegate gestureManager:self didFinishAnimatingNewRowAtIndexPath:copy];
                    self.didAddCell = NO;
                }
            }];
            [self createCellFromPendingPath];
            [self.tableView endUpdates];
            [CATransaction commit];
        }else{
            [self discardCellAtPendingPath];
        }
        [UIView animateWithDuration:.26 animations:^{
           self.tableView.contentInset = UIEdgeInsetsMake(TOP_INSET, 0, 0, 0);
            self.tableView.contentOffset = CGPointMake(0, -TOP_INSET);
        }];
    }
    self.state = RCListGestureManagerStateNone;
}

-(void)didAddCellAtIndexPath:(NSIndexPath *)indexPath
{
   
}


#pragma mark - Gesture Delegate

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.panGesture){
        return [self panGestureInAllowedDraggingArea];
    }else if (gestureRecognizer == self.pinchGesture){
        NSIndexPath * middlePath = [self indexPathInMiddleOfPinch];
        if (!middlePath) {
            return NO;
        }
        self.pendingPath = middlePath;
    }
    return YES;
}


#pragma mark - TableView Delegate

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:self.pendingPath]
        && (self.state == RCListGestureManagerStatePinching || self.state == RCListGestureManagerStateDragging)) {
        return MAX(1, self.pendingRowHeight);
    }
    CGFloat normalCellHeight = aTableView.rowHeight;
    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
        normalCellHeight = [self.tableViewDelegate tableView:aTableView heightForRowAtIndexPath:indexPath];
    }
    return normalCellHeight;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.tableViewDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.tableViewDelegate scrollViewDidScroll:scrollView];
    }
    if ([self.delegate gestureManagerShouldAllowCellCreation:self]){
         [self handlePendingRowsDuringScrolling];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([self.tableViewDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.tableViewDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
    if (self.state == RCListGestureManagerStateDragging) {
        self.state = RCListGestureManagerStateNone;
        [self determineFateOfPendingCell];
    }
}


#pragma mark - Convenience

-(void)adjustTableYOffset
{
    CGPoint currentOffset = self.tableView.contentOffset;
    CGPoint adjustedOffset = CGPointMake(currentOffset.x, currentOffset.y+self.scrollRate);
    if (adjustedOffset.y < 0){
        adjustedOffset.y = 0;
    }else if (self.tableView.contentSize.height < self.tableView.frame.size.height){
        adjustedOffset = currentOffset;
    }else if (adjustedOffset.y > self.tableView.contentSize.height - self.tableView.frame.size.height){
        adjustedOffset.y = self.tableView.contentSize.height - self.tableView.frame.size.height;
    }
    [self.tableView setContentOffset:adjustedOffset];
}

-(void)createCellFromPendingPath
{
    NSIndexPath * copy = [self.pendingPath copy];
    self.pendingPath = nil;
    [self.delegate gestureManager:self needsFinishedNewRowAtIndexPath:copy];
}

-(void)discardCellAtPendingPath
{
    NSIndexPath * copy = [self.pendingPath copy];
    self.pendingPath = nil;
    [self.delegate gestureManager:self needsRemovalOfRowAtIndexPath:copy];
}

-(void)updatePositionOfFakeCell
{
    CGPoint location = [self.longPress locationInView:self.tableView];
    UIImageView *snapShotView = (UIImageView *)[self.tableView viewWithTag:CELL_SNAPSHOT_TAG];
    snapShotView.center = CGPointMake(self.tableView.center.x, location.y);
    [self determinePendingPathForCurrentTouchLocation];
    [self determineScrollRateDuringPress];
}

-(void)didFinishMovingCell
{
    UIImageView *snapShotView = (UIImageView *)[self.tableView viewWithTag:CELL_SNAPSHOT_TAG];
    NSIndexPath * indexPath = self.pendingPath;
    [self removeTimer];
    [UIView animateWithDuration:.26
                     animations:^{
                         CGRect rect = [self.tableView rectForRowAtIndexPath:indexPath];
                         snapShotView.transform = CGAffineTransformIdentity;
                         snapShotView.frame = CGRectOffset(snapShotView.bounds, rect.origin.x, rect.origin.y);
                     } completion:^(BOOL finished) {
                         [snapShotView removeFromSuperview];
                         [self reshowAtIndexPath:indexPath];
                     }];
}

-(void)removeTimer
{
    [self.scrollTimer invalidate];
    self.scrollRate = 0;
    self.scrollTimer = nil;
}

-(void)reshowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.delegate gestureManager:self needsReplacePlaceholderForRowAtIndexPath:indexPath];
    [self.tableView endUpdates];
    [self reloadAllRowsExceptIndexPath:indexPath];
    self.pendingPath = nil;
    self.state = RCListGestureManagerStateNone;
}

-(void)determineScrollRateDuringPress
{
    CGPoint location = [self.longPress locationInView:self.tableView];
    location.y -= self.tableView.contentOffset.y;
    CGFloat bottomDropZoneHeight = self.tableView.bounds.size.height / 6;
    CGFloat topDropZoneHeight    = bottomDropZoneHeight;
    CGFloat bottomDiff = location.y - (self.tableView.bounds.size.height - bottomDropZoneHeight);
    if (bottomDiff > 0) {
        self.scrollRate = bottomDiff / (bottomDropZoneHeight / 1);
    } else if (location.y <= topDropZoneHeight) {
        self.scrollRate = -(topDropZoneHeight - MAX(location.y, 0)) / bottomDropZoneHeight;
    } else {
        self.scrollRate = 0;
    }
}

-(void)didEnterBeginMovingState
{
    CGPoint location = [self.longPress locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    self.state = RCListGestureManagerStateMoving;
    UIImage * cellImage = [self imageOfCellAtIndexPath:indexPath];
    UIImageView * picView = [self fakeCellViewForImage:cellImage atIndexPath:indexPath];
    [UIView animateWithDuration:.2 animations:^{
        picView.transform = CGAffineTransformMakeScale(1.1, 1.1);
        picView.center = CGPointMake(self.tableView.center.x, location.y);
    }];
    [self.delegate gestureManager:self needsPlaceholderRowAtIndexPath:indexPath];
    [self.tableView reloadData];
    self.pendingPath = indexPath;
    [self attachTimerToHandleScrolling];
}

-(UIImageView *)fakeCellViewForImage:(UIImage *)cellImage atIndexPath:(NSIndexPath *)indexPath
{
    UIImageView *snapShotView = (UIImageView *)[self.tableView viewWithTag:CELL_SNAPSHOT_TAG];
    if (!snapShotView) {
        snapShotView = [[UIImageView alloc] initWithImage:cellImage];
        snapShotView.tag = CELL_SNAPSHOT_TAG;
        [self.tableView addSubview:snapShotView];
        CGRect rect = [self.tableView rectForRowAtIndexPath:indexPath];
        snapShotView.frame = CGRectOffset(snapShotView.bounds, rect.origin.x, rect.origin.y);
        
    }
    return snapShotView;
}

-(UIImage *)imageOfCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIGraphicsBeginImageContextWithOptions(cell.bounds.size, NO, 0);
    [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *cellImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return cellImage;
}

-(void)handleFinalStateForIndexPath:(NSIndexPath *)indexPath
{
    CGPoint translation = [self.panGesture translationInView:self.tableView];
    if (fabsf(translation.x) >= PAN_COMMIT_LENGTH){
        RCMainCell * cell = (RCMainCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [UIView animateWithDuration:.2 animations:^{
                if (translation.x > 0){
                    self.panState = RCListGestureManagerPanStateRight;
                    [cell.contentView setFrame:CGRectOffset(cell.contentView.frame, self.tableView.frame.size.width-translation.x, 0)];
                    cell.iconView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2.0, cell.iconView.center.y);
                }else{
                    self.panState = RCListGestureManagerPanStateLeft;
                    [cell.contentView setFrame:CGRectOffset(cell.contentView.frame, -(self.tableView.frame.size.width + translation.x), 0)];
                    cell.iconView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2.0, cell.iconView.center.y);
                }
            } completion:^(BOOL finished) {
                [self.delegate gestureManager:self didFinishWithState:self.panState forIndexPath:indexPath];
                self.panState = RCListGestureManagerPanStateMiddle;
                self.state = RCListGestureManagerStateNone;
            }];
    }else{
        [self resetCellToCenterAtIndexPath:indexPath];
        self.panState = RCListGestureManagerPanStateMiddle;
        self.state = RCListGestureManagerStateNone;
    }
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

-(void)determinePanStateForIndexPath:(NSIndexPath *)indexPath
{
    CGPoint translation = [self.panGesture translationInView:self.tableView];
    RCListGestureManagerPanState currentState = self.panState;
    if (fabsf(translation.x) >= PAN_COMMIT_LENGTH){
        if (self.panState == RCListGestureManagerPanStateMiddle){
            self.panState = translation.x > 0 ? RCListGestureManagerPanStateRight : RCListGestureManagerPanStateLeft;
        }
    }else if (self.panState != RCListGestureManagerPanStateMiddle){
        self.panState = RCListGestureManagerPanStateMiddle;
    }
    if (currentState != self.panState){
        [self.delegate gestureManager:self didChangeToState:self.panState forIndexPath:indexPath];
    }
}

-(NSIndexPath *)panGesturePath
{
    if (self.panGesture.numberOfTouches > 0){
        CGPoint location1 = [self.panGesture locationOfTouch:0 inView:self.tableView];
        NSIndexPath *indexPath = self.pendingPath;
        if (!indexPath) {
            indexPath = [self.tableView indexPathForRowAtPoint:location1];
            self.pendingPath = indexPath;
        }
    }
    return self.pendingPath;
}

-(void)translateCellAtIndexPath:(NSIndexPath *)indexPath
{
    RCMainCell *cell = (RCMainCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    CGPoint translation = [self.panGesture translationInView:self.tableView];
    CGFloat fraction =  fminf(fabsf((translation.x)/PAN_COMMIT_LENGTH), 1.0);
    if (translation.x >= 0){
        [cell showLoginIconWithScale:fraction translation:translation.x];
    }else{
        [cell showDeleteIconWithScale:fraction translation:translation.x];
    }
    cell.contentView.frame = CGRectOffset(cell.contentView.bounds, translation.x, 0);
}

-(void)adjustScrollDuringPinch
{
    CGPoint upperPoint = [self upperPinchPoint];
    CGFloat diffOffsetY = lastPinchOrigin.y - upperPoint.y;
    CGPoint newOffset   = (CGPoint){self.tableView.contentOffset.x, self.tableView.contentOffset.y+diffOffsetY};
    [self.tableView setContentOffset:newOffset animated:NO];
}

-(CGPoint)upperPinchPoint
{
    CGPoint location1 = [self.pinchGesture locationOfTouch:0 inView:self.tableView];
    CGPoint location2 = [self.pinchGesture locationOfTouch:1 inView:self.tableView];
    CGPoint upperPoint = location1.y < location2.y ? location1 : location2;
    return upperPoint;
}

-(void)adjustPendingHeightDuringPinch
{
    CGRect pinchRect = [self pinchRect];
    CGFloat difference = CGRectGetHeight(pinchRect) - CGRectGetHeight(pinchRect)/[self.pinchGesture scale];
    if (self.pendingRowHeight - difference >= 1 || self.pendingRowHeight - difference <= -1){
        self.pendingRowHeight = difference;
        [self.tableView reloadData];
    }
}

-(void)handlePendingRowsDuringScrolling
{
    if (self.tableView.contentOffset.y < -TOP_INSET){
        if (!self.pendingPath && self.state == RCListGestureManagerStateNone && !self.tableView.isDecelerating){
            self.state = RCListGestureManagerStateDragging;
            self.pendingRowHeight = fabsf(self.tableView.contentOffset.y+TOP_INSET);
            [self addRowToTop];
        }
    }
    if (self.pendingPath && self.state == RCListGestureManagerStateDragging){
        self.pendingRowHeight += (self.tableView.contentOffset.y+TOP_INSET) * -1;
        [self.tableView reloadData];
        [self.tableView setContentOffset:CGPointMake(0, -TOP_INSET)];
    }
}

-(void)addRowToTop
{
    self.pendingPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.delegate gestureManager:self needsNewRowAtIndexPath:self.pendingPath];
    [self.tableView reloadData];
}

-(NSIndexPath *)indexPathInMiddleOfPinch
{
    NSArray * indexPaths = [self indexPathsWithinPinch];
    if (!indexPaths || indexPaths.count < 2)
        return nil;
    NSIndexPath *firstIndexPath = [indexPaths objectAtIndex:0];
    NSIndexPath *lastIndexPath  = [indexPaths lastObject];
    NSInteger    midIndex = ((float)(firstIndexPath.row + lastIndexPath.row) / 2) + 0.5;
    NSIndexPath *midIndexPath = [NSIndexPath indexPathForRow:midIndex inSection:firstIndexPath.section];
    return midIndexPath;
}

-(NSArray *)indexPathsWithinPinch
{
    CGRect  rect = [self pinchRect];
    NSArray *indexPaths = [self.tableView indexPathsForRowsInRect:rect];
    return indexPaths;
}

-(CGRect)pinchRect
{
    CGPoint location1 = [self.pinchGesture locationOfTouch:0 inView:self.tableView];
    CGPoint location2 = [self.pinchGesture locationOfTouch:1 inView:self.tableView];
    CGRect  rect = (CGRect){location1, location2.x - location1.x, location2.y - location1.y};
    return rect;
}

-(BOOL)panGestureInAllowedDraggingArea
{
    CGPoint point = [self.panGesture translationInView:self.tableView];
    CGPoint location = [self.panGesture locationInView:self.tableView];
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:location];
    if (fabsf(point.y) > fabsf(point.x)) {
        return NO;
    } else if (!indexPath) {
        return NO;
    }
    return YES;
}


@end
