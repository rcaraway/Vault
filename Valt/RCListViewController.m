//
//  RCListViewController.m
//  Valt
//
//  Created by Rob Caraway on 12/10/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCListViewController.h"
#import "JTTableViewGestureRecognizer.h"
#import "JTTransformableTableViewCell.h"
#import "UIColor+JTGestureBasedTableViewHelper.h"
#import "RCPassword.h"
#import "RCPasswordManager.h"
#import "RCDropDownCell.h"
#import "RCTableViewCell.h"
#import "UIColor+RCColors.h"
#import "RCAppDelegate.h"
#import "RCRootViewController.h"
#import "UIImage+memoIcons.h"


#define ADDING_CELL @"Continue..."
#define DONE_CELL @"Done"
#define DUMMY_CELL @"Dummy"
#define COMMITING_CREATE_CELL_HEIGHT 60
#define NORMAL_CELL_FINISHING_HEIGHT 60

@interface RCListViewController ()<JTTableViewGestureEditingRowDelegate, JTTableViewGestureAddingRowDelegate, JTTableViewGestureMoveRowDelegate>
@property (nonatomic, strong) JTTableViewGestureRecognizer *tableViewRecognizer;
@property(nonatomic) BOOL addingNewPassword;
@property(nonatomic) NSInteger dummyCellIndex;
@property (nonatomic, strong) id grabbedObject;
@property(nonatomic, strong) UIView * fakeCellView;

@end

@implementation RCListViewController

#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}


#pragma mark - View LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = YES;
    self.addingNewPassword = NO;
    self.dummyCellIndex = NSNotFound;
    self.tableViewRecognizer = [self.tableView enableGestureTableViewWithDelegate:self];
    self.view.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    [self setupTableView];
    [self setupSearchBar];
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

-(void)setupSearchBar
{
    self.searchBar = [[UISearchBar  alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.searchBar.delegate =self;
    self.searchBar.barTintColor = [UIColor cellUnselectedForeground];
    [self setSearchBarUnselected];
    self.tableView.tableHeaderView = self.searchBar;
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self setSearchBarSelected];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self setSearchBarUnselected];
}

-(void)setSearchBarSelected
{
    UITextField *txfSearchField = [_searchBar valueForKey:@"_searchField"];
    txfSearchField.backgroundColor = [UIColor colorWithRed:234.0/255.0 green:120.0/255.0 blue:216.0/255.0 alpha:1];
    txfSearchField.textColor = [UIColor whiteColor];
    txfSearchField.attributedPlaceholder = [[NSAttributedString  alloc] initWithString:@"Search for Credentials" attributes:@{NSForegroundColorAttributeName: [UIColor cellUnselectedForeground]}];
}

-(void)setSearchBarUnselected
{
    UITextField *txfSearchField = [_searchBar valueForKey:@"_searchField"];
    txfSearchField.backgroundColor = [UIColor colorWithRed:175.0/255.0 green:112.0/255.0 blue:165.0/255.0 alpha:1];
    txfSearchField.textColor = [UIColor whiteColor];
    txfSearchField.attributedPlaceholder = [[NSAttributedString  alloc] initWithString:@"Search for Credentials" attributes:@{NSForegroundColorAttributeName: [UIColor cellUnselectedForeground]}];
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
    if (self.addingNewPassword){
        return [[RCPasswordManager defaultManager] allTitles].count+1;
    }
    return [[RCPasswordManager defaultManager] allTitles].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.addingNewPassword) {
        JTTransformableTableViewCell *cell = nil;
        if (indexPath.row == 0) {
            cell = [self pullDownCell];
            return cell;
        } else {
            cell = [self foldingCell];
            return cell;
        }
    } else {
        
        NSString *object;
        if (self.addingNewPassword)
            object =  [[RCPasswordManager defaultManager] allTitles][indexPath.row-1];
        else
            object =  [[RCPasswordManager defaultManager] allTitles][indexPath.row];
            static NSString *cellIdentifier = @"MyCell";
            RCTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            cell.textField.text = (NSString *)object;
            if ([object isEqual:DONE_CELL]) {
                cell.textLabel.textColor = [UIColor grayColor];
            } else if ([object isEqual:DUMMY_CELL]) {
                cell.textLabel.text = @"";
                cell.textField.text = @"";
            } else {
                cell.textLabel.textColor = [UIColor blackColor];
            }
            return cell;
    }
}


#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NORMAL_CELL_FINISHING_HEIGHT;
}


#pragma mark JTTableViewGestureAddingRowDelegate

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsAddRowAtIndexPath:(NSIndexPath *)indexPath
{
 
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsCommitRowAtIndexPath:(NSIndexPath *)indexPath {

    RCPassword * password = [[RCPassword alloc] init];
    [[RCPasswordManager defaultManager] addPassword:password atIndex:indexPath.row];
    [[APP rootController] launchSingleWithPassword:password];
    JTTransformableTableViewCell *cell = (id)[gestureRecognizer.tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[JTTransformableTableViewCell class]]){
        BOOL isFirstCell = indexPath.section == 0 && indexPath.row == 0;
        if (isFirstCell && cell.frame.size.height > COMMITING_CREATE_CELL_HEIGHT * 2) {
            self.addingNewPassword = NO;
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        }
        else {
            cell.finishedHeight = NORMAL_CELL_FINISHING_HEIGHT;
            cell.imageView.image = nil;
            cell.textLabel.text = @"Just Added!";
        }
    }
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsDiscardRowAtIndexPath:(NSIndexPath *)indexPath {
    [[RCPasswordManager defaultManager] removePasswordAtIndex:indexPath.row];
}

-(void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer didTapRowAtIndexPath:(NSIndexPath *)path atLocation:(CGPoint)location
{
    if ([[self.tableView cellForRowAtIndexPath:path] isMemberOfClass:[RCTableViewCell class]]){
        RCTableViewCell * cell = (RCTableViewCell *)[self.tableView cellForRowAtIndexPath:path];
        [cell setFocused];
        RCPassword * password = [[RCPasswordManager defaultManager] passwords][path.row];
        [[APP rootController] launchSingleWithPassword:password];
    }
}

-(void)gestureRecognizerDidTapOutsideRows:(JTTableViewGestureRecognizer *)gestureRecognizer
{
    RCPassword * password = [[RCPassword alloc] init];
    [[RCPasswordManager defaultManager] addPassword:password];
    [[APP rootController] launchSingleWithPassword:password];
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
                //TODO: add browser show
                break;
            default:
                [cell setRedColored];
                break;
        }
    }
}


// This is needed to be implemented to let our delegate choose whether the panning gesture should work
- (BOOL)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer commitEditingState:(JTTableViewCellEditingState)state forRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableView *tableView = gestureRecognizer.tableView;
    [tableView beginUpdates];
    if (state == JTTableViewCellEditingStateLeft) {
        [[RCPasswordManager defaultManager] removePasswordAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    } else if (state == JTTableViewCellEditingStateRight) {
        //TODO: web browser
    } else {
    }
    [tableView endUpdates];
    
    // Row color needs update after datasource changes, reload it.
    [tableView performSelector:@selector(reloadVisibleRowsExceptIndexPath:) withObject:indexPath afterDelay:JTTableViewRowAnimationDuration];
}


#pragma mark JTTableViewGestureMoveRowDelegate

- (BOOL)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsCreatePlaceholderForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.grabbedObject = [[RCPasswordManager defaultManager] allTitles][indexPath.row];
    self.dummyCellIndex = indexPath.row;
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsMoveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [[RCPasswordManager defaultManager] movePasswordAtIndex:sourceIndexPath.row toNewIndex:destinationIndexPath.row];
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsReplacePlaceholderForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.dummyCellIndex = NSNotFound;
    self.grabbedObject = nil;
}


#pragma mark - Table Convenience

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
