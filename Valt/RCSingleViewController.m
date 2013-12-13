//
//  RCSingleViewController.m
//  Valt
//
//  Created by Rob Caraway on 12/10/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCSingleViewController.h"
#import "JTTableViewGestureRecognizer.h"
#import "JTTransformableTableViewCell.h"
#import "UIColor+JTGestureBasedTableViewHelper.h"
#import "RCPassword.h"
#import "RCPasswordManager.h"
#import "RCDropDownCell.h"
#import "RCTableViewCell.h"
#import "UIColor+RCColors.h"
#import "UIImage+memoIcons.h"
#import "RCAppDelegate.h"
#import "RCRootViewController.h"

#define ADDING_CELL @"Continue..."
#define DONE_CELL @"Done"
#define DUMMY_CELL @"Dummy"
#define COMMITING_CREATE_CELL_HEIGHT 50
#define NORMAL_CELL_FINISHING_HEIGHT 50
#define TITLE_CELL_HEIGHT 60


@interface RCSingleViewController ()<JTTableViewGestureEditingRowDelegate, JTTableViewGestureAddingRowDelegate, JTTableViewGestureMoveRowDelegate>

@property (nonatomic, strong) JTTableViewGestureRecognizer *tableViewRecognizer;
@property(nonatomic, strong) NSMutableArray * credentials;
@property(nonatomic) NSInteger addCellIndex;
@property(nonatomic) NSInteger dummyCellIndex;
@property(nonatomic, strong) RCPassword * password;
@property (nonatomic, strong) id grabbedObject;

@end

@implementation RCSingleViewController


#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return nil;
}

-(id)initWithPassword:(RCPassword *)password
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.password = password;
        self.addCellIndex = NSNotFound;
        self.dummyCellIndex = NSNotFound;
        self.credentials = [NSMutableArray arrayWithArray:[self.password allFields]];
    }
    return self;
}

-(void)publishChangesToPassword
{
    NSMutableArray * extraFields = [NSMutableArray new];
    for (int i = 0; i < self.credentials.count; i++) {
        NSString * field = self.credentials[i];
        if (i == 0){
            self.password.title = field;
        }else if (i == 1){
            self.password.username = field;
        }else if (i == 2){
            self.password.password = field;
        }else{
            [extraFields addObject:field];
        }
    }
    self.password.extraFields = extraFields;
}


#pragma mark - View LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    self.tableViewRecognizer = [self.tableView enableGestureTableViewWithDelegate:self];
    [self setupTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - View Setup

-(void)setupTableView
{
    self.tableView.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    self.tableView.allowsSelection = NO;
    [self.tableView registerClass:[RCTableViewCell class] forCellReuseIdentifier:@"MyCell"];
    [self.tableView registerClass:[RCDropDownCell class] forCellReuseIdentifier:@"DropDownCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = NORMAL_CELL_FINISHING_HEIGHT;
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}


#pragma mark - TableView Delegate/DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = self.credentials.count;
    if (count < 3){
        count = 3;
    }
    if (self.addCellIndex != NSNotFound)
        count++;
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.addCellIndex) {
        JTTransformableTableViewCell *cell = nil;
        if (indexPath.row == 0) {
            cell = [self pullDownCell];
            return cell;
        } else {
            cell = [self foldingCell];
            return cell;
        }
    } else {
        NSInteger adjustedRow = indexPath.row - (self.addCellIndex == NSNotFound?0:1);
        NSString *object = [self stringForIndexPath:indexPath];
        if (adjustedRow == 0){
            static NSString *cellIdentifier = @"MyCell";
            RCTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            cell.textField.text = (NSString *)object;
            cell.textField.placeholder = @"Email or Username";
            [cell setFocused];
            return cell;
        }else{
            static NSString * cellId = @"DropDownCell";
            RCDropDownCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
            [cell setTitle:object placeHolder:[self placeholderForIndexPath:indexPath]];
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
        return TITLE_CELL_HEIGHT;
    return NORMAL_CELL_FINISHING_HEIGHT;
}


#pragma mark Adding

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsAddRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.credentials insertObject:ADDING_CELL atIndex:indexPath.row];
    self.addCellIndex = indexPath.row;
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsCommitRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.credentials replaceObjectAtIndex:indexPath.row withObject:@"Added!"];
    JTTransformableTableViewCell *cell = (id)[gestureRecognizer.tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[JTTransformableTableViewCell class]]){
        BOOL isFirstCell = indexPath.section == 0 && indexPath.row == 0;
        if (isFirstCell && cell.frame.size.height > COMMITING_CREATE_CELL_HEIGHT * 2) {
            [self.credentials removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        }
        else {
            cell.finishedHeight = NORMAL_CELL_FINISHING_HEIGHT;
            cell.imageView.image = nil;
            cell.textLabel.text = @"Just Added!";
        }
    }
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsDiscardRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.credentials removeObjectAtIndex:indexPath.row];
    self.addCellIndex = NSNotFound;
}

-(void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer didTapRowAtIndexPath:(NSIndexPath *)path atLocation:(CGPoint)location
{
    if (path.row == 0){
        [self publishChangesToPassword];
        [[APP rootController] launchList];
    }
}

-(void)gestureRecognizerDidTapOutsideRows:(JTTableViewGestureRecognizer *)gestureRecognizer
{
    [self.credentials addObject:@""];
    [self.tableView reloadData];
}


#pragma mark JTTableViewGestureEditingRowDelegate

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer didEnterEditingState:(JTTableViewCellEditingState)state forRowAtIndexPath:(NSIndexPath *)indexPath {
    RCTableViewCell *cell = (RCTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[RCTableViewCell class]]){
        switch (state) {
            case JTTableViewCellEditingStateMiddle:
                [cell removeFocus];
                break;
            case JTTableViewCellEditingStateRight:
                break;
            default:
                [cell setRedColored];
                break;
        }
    }
}

- (BOOL)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= 3){
        return YES;
    }
    return NO;
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer commitEditingState:(JTTableViewCellEditingState)state forRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableView *tableView = gestureRecognizer.tableView;
    
    [tableView beginUpdates];
    
    if (state == JTTableViewCellEditingStateLeft) {
        // An example to discard the cell at JTTableViewCellEditingStateLeft
        [self.credentials removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    } else if (state == JTTableViewCellEditingStateRight) {
        // An example to retain the cell at commiting at JTTableViewCellEditingStateRight
    
    } else {
        // JTTableViewCellEditingStateMiddle shouldn't really happen in
        // - [JTTableViewGestureDelegate gestureRecognizer:commitEditingState:forRowAtIndexPath:]
    }
    [tableView endUpdates];
    
    // Row color needs update after datasource changes, reload it.
    [tableView performSelector:@selector(reloadVisibleRowsExceptIndexPath:) withObject:indexPath afterDelay:JTTableViewRowAnimationDuration];
}


#pragma mark JTTableViewGestureMoveRowDelegate

- (BOOL)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}
- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsCreatePlaceholderForRowAtIndexPath:(NSIndexPath *)indexPath {
}
- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsMoveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
}
- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsReplacePlaceholderForRowAtIndexPath:(NSIndexPath *)indexPath {
}



#pragma mark - Table Convenience

-(NSString *)stringForIndexPath:(NSIndexPath *)indexPath
{
    NSString * string;
    NSInteger adjustedRow = indexPath.row - (self.addCellIndex == NSNotFound?0:1);
    if (self.credentials.count > adjustedRow){
        string = self.credentials[adjustedRow];
    }else{
        string = @"";
    }
    return string;
}

-(NSString *)placeholderForIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            return @"Email or Username";
            break;
        case 1:
            return @"Password";
            break;
        case 2:
            return @"URL";
            break;
        default:
            return [NSString stringWithFormat:@"Notes %d", indexPath.row];
            break;
    }
}

-(JTTransformableTableViewCell *)pullDownCell
{
    NSString *cellIdentifier = nil;
    JTTransformableTableViewCell *cell = nil;
    UIColor *backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
    cellIdentifier = @"PullDownTableViewCell";
    if (cell == nil) {
        cell = [JTTransformableTableViewCell transformableTableViewCellWithStyle:JTTransformableTableViewCellStylePullDown
                                                                 reuseIdentifier:cellIdentifier];
    }
    cell.finishedHeight = COMMITING_CREATE_CELL_HEIGHT;
    cell.tintColor = backgroundColor;
    if (cell.frame.size.height > COMMITING_CREATE_CELL_HEIGHT) {
        cell.textLabel.text = @"Release to Create Item";
    } else {
        cell.textLabel.text = @"Pull to Create Item";
    }
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}

-(JTTransformableTableViewCell *)foldingCell
{
    NSString *cellIdentifier = nil;
    JTTransformableTableViewCell *cell = nil;
    UIColor *backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
    cellIdentifier = @"UnfoldingTableViewCell";
    if (cell == nil) {
        cell = [JTTransformableTableViewCell transformableTableViewCellWithStyle:JTTransformableTableViewCellStyleUnfolding
                                                                 reuseIdentifier:cellIdentifier];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    cell.tintColor = backgroundColor;
    cell.finishedHeight = COMMITING_CREATE_CELL_HEIGHT;
    if (cell.frame.size.height > COMMITING_CREATE_CELL_HEIGHT) {
        cell.textLabel.text = @"Release to Create Item";
    } else {
        cell.textLabel.text = @"Pinch Apart to Create Item";
    }
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}


@end
