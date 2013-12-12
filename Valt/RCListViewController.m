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
#import "UIImage+memoIcons.h"


#define ADDING_CELL @"Continue..."
#define DONE_CELL @"Done"
#define DUMMY_CELL @"Dummy"
#define COMMITING_CREATE_CELL_HEIGHT 60
#define NORMAL_CELL_FINISHING_HEIGHT 60

@interface RCListViewController ()<JTTableViewGestureEditingRowDelegate, JTTableViewGestureAddingRowDelegate, JTTableViewGestureMoveRowDelegate>
@property (nonatomic, strong) NSMutableArray *rows;
@property(nonatomic, strong) NSIndexPath * dropDownPath;
@property(nonatomic, strong) NSMutableArray * dropDownRows;
@property (nonatomic, strong) JTTableViewGestureRecognizer *tableViewRecognizer;
@property (nonatomic, strong) id grabbedObject;
@property(nonatomic, strong) UIView * fakeCellView;

@end

@implementation RCListViewController


#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.rows = [NSMutableArray arrayWithObjects:
                     @"Swipe to the right to complete",
                     @"Swipe to left to delete",
                     @"Drag down to create a new cell",
                     @"Pinch two rows apart to create cell",
                     @"Long hold to start reorder cell",
                     nil];
        self.dropDownRows = [NSMutableArray new];
    }
    return self;
}


#pragma mark - View LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = YES;
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


#pragma mark - Table State handling

- (void)moveRowToBottomForIndexPath:(NSIndexPath *)indexPath {
    [self.tableView beginUpdates];
    
    id object = [self.rows objectAtIndex:indexPath.row];
    [self.rows removeObjectAtIndex:indexPath.row];
    [self.rows addObject:object];
    
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:[self.rows count] - 1 inSection:0];
    [self.tableView moveRowAtIndexPath:indexPath toIndexPath:lastIndexPath];
    
    [self.tableView endUpdates];
    
    [self.tableView performSelector:@selector(reloadVisibleRowsExceptIndexPath:) withObject:lastIndexPath afterDelay:JTTableViewRowAnimationDuration];
}

-(void)addDropDownRowsForIndexPath:(NSIndexPath *)indexPath
{
    if (self.dropDownPath != indexPath){
        [self.dropDownRows removeAllObjects];
        self.dropDownPath = indexPath;
        [self.dropDownRows addObjectsFromArray:@[@"Email@aol.com", @"schwerpty5", @"http://aol.com/login"]];
        [self.tableView reloadData];
    }
}

-(void)removeDropDownRows
{
    [self.dropDownRows removeAllObjects];
    [self.tableView reloadData];
}


#pragma mark - TableView Delegate/DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dropDownPath){
        NSInteger countTotal = self.rows.count+self.dropDownRows.count;
        return countTotal;
    }else{
        return self.rows.count;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *object = [self stringForIndexPath:indexPath];
    UIColor *backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
    if ([object isEqual:ADDING_CELL]) {
        NSString *cellIdentifier = nil;
        JTTransformableTableViewCell *cell = nil;
        
        // IndexPath.row == 0 is the case we wanted to pick the pullDown style
        if (indexPath.row == 0) {
            cellIdentifier = @"PullDownTableViewCell";
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if (cell == nil) {
                cell = [JTTransformableTableViewCell transformableTableViewCellWithStyle:JTTransformableTableViewCellStylePullDown
                                                                         reuseIdentifier:cellIdentifier];

            }
            
            cell.finishedHeight = COMMITING_CREATE_CELL_HEIGHT;
            if (cell.frame.size.height > COMMITING_CREATE_CELL_HEIGHT * 2) {
                cell.imageView.image = [UIImage imageNamed:@"reload.png"];
                cell.tintColor = [UIColor blackColor];
                cell.textLabel.text = @"Create";
            } else if (cell.frame.size.height > COMMITING_CREATE_CELL_HEIGHT) {
                cell.imageView.image = nil;
                // Setup tint color
                cell.tintColor = backgroundColor;
                cell.textLabel.text = @"Release to Create Item";
            } else {
                cell.imageView.image = nil;
                // Setup tint color
                cell.tintColor = backgroundColor;
                cell.textLabel.text = @"Pull to Create Item";
            }
            cell.contentView.backgroundColor = [UIColor clearColor];
            return cell;
            
        } else {
            // Otherwise is the case we wanted to pick the pullDown style
            cellIdentifier = @"UnfoldingTableViewCell";
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if (cell == nil) {
                cell = [JTTransformableTableViewCell transformableTableViewCellWithStyle:JTTransformableTableViewCellStyleUnfolding
                                                                         reuseIdentifier:cellIdentifier];
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
                cell.textLabel.textColor = [UIColor blackColor];
            }
            
            // Setup tint color
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
        
    } else {
        if ([self isDropDownRowAtIndexPath:indexPath]){
            static NSString * cellId = @"DropDownCell";
            RCDropDownCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
            NSInteger index = [self dropdownIndexForIndexPath:indexPath];
            NSString * placeholder = [self dropdownPlaceholderForIndex:index];
            [cell setTitle:self.dropDownRows[index] placeHolder:placeholder];
            return cell;
        }else{
            static NSString *cellIdentifier = @"MyCell";
            RCTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            cell.textField.text = (NSString *)object;
            if ([object isEqual:DONE_CELL]) {
                cell.textLabel.textColor = [UIColor grayColor];
            } else if ([object isEqual:DUMMY_CELL]) {
                cell.textLabel.text = @"";
            } else {
                cell.textLabel.textColor = [UIColor blackColor];
            }
            return cell;
        }
    }
}



#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NORMAL_CELL_FINISHING_HEIGHT;
}



#pragma mark -
#pragma mark JTTableViewGestureAddingRowDelegate

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsAddRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.rows insertObject:ADDING_CELL atIndex:indexPath.row];
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsCommitRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.rows replaceObjectAtIndex:indexPath.row withObject:@"Added!"];
    JTTransformableTableViewCell *cell = (id)[gestureRecognizer.tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[JTTransformableTableViewCell class]]){
        BOOL isFirstCell = indexPath.section == 0 && indexPath.row == 0;
        if (isFirstCell && cell.frame.size.height > COMMITING_CREATE_CELL_HEIGHT * 2) {
            [self.rows removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
            // Return to list
        }
        else {
            cell.finishedHeight = NORMAL_CELL_FINISHING_HEIGHT;
            cell.imageView.image = nil;
            cell.textLabel.text = @"Just Added!";
        }
    }
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsDiscardRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.rows removeObjectAtIndex:indexPath.row];
}

-(void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer didTapRowAtIndexPath:(NSIndexPath *)path atLocation:(CGPoint)location
{
    if ([[self.tableView cellForRowAtIndexPath:path] isMemberOfClass:[RCTableViewCell class]]){
        RCTableViewCell * cell = (RCTableViewCell *)[self.tableView cellForRowAtIndexPath:path];
        [cell setFocused];
        [self addDropDownRowsForIndexPath:path];
        NSArray * cells = [self.tableView visibleCells];
        for (UITableViewCell * subView in cells) {
            if ([subView isMemberOfClass:[RCTableViewCell class]] && subView != cell){
                [(RCTableViewCell *)subView removeFocus];
            }
        }
    }
}

-(void)gestureRecognizerDidTapOutsideRows:(JTTableViewGestureRecognizer *)gestureRecognizer
{
    [self.rows addObject:@"From Below!"];
    if (!self.fakeCellView){
        _fakeCellView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, 320, NORMAL_CELL_FINISHING_HEIGHT)];
        [self.view addSubview:_fakeCellView];
    }
    CGAffineTransform original = _fakeCellView.transform;
    _fakeCellView.transform = CGAffineTransformScale(_fakeCellView.transform, .1, .1);
    _fakeCellView.alpha = 1;
    [UIView animateWithDuration:.22 delay:0 usingSpringWithDamping:.8 initialSpringVelocity:.7 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _fakeCellView.transform = original;
    } completion:^(BOOL finished) {
        _fakeCellView.alpha = 0;
        [self.tableView reloadData];
    }];
    
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
    
    
    NSIndexPath *rowToBeMovedToBottom = nil;
    NSInteger regularIndex = [self regularIndexForIndexPath:indexPath];
    [tableView beginUpdates];
    
    if (state == JTTableViewCellEditingStateLeft) {
        // An example to discard the cell at JTTableViewCellEditingStateLeft
        [self.rows removeObjectAtIndex:regularIndex];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    } else if (state == JTTableViewCellEditingStateRight) {
        // An example to retain the cell at commiting at JTTableViewCellEditingStateRight
        [self.rows replaceObjectAtIndex:regularIndex withObject:DONE_CELL];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        rowToBeMovedToBottom = indexPath;
    } else {
        // JTTableViewCellEditingStateMiddle shouldn't really happen in
        // - [JTTableViewGestureDelegate gestureRecognizer:commitEditingState:forRowAtIndexPath:]
    }
    [tableView endUpdates];
    
    
    // Row color needs update after datasource changes, reload it.
    [tableView performSelector:@selector(reloadVisibleRowsExceptIndexPath:) withObject:indexPath afterDelay:JTTableViewRowAnimationDuration];
    
    if (rowToBeMovedToBottom) {
        [self performSelector:@selector(moveRowToBottomForIndexPath:) withObject:rowToBeMovedToBottom afterDelay:JTTableViewRowAnimationDuration * 2];
    }
}



#pragma mark JTTableViewGestureMoveRowDelegate

- (BOOL)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsCreatePlaceholderForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.grabbedObject = [self.rows objectAtIndex:indexPath.row];
    [self.rows replaceObjectAtIndex:indexPath.row withObject:DUMMY_CELL];
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsMoveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    id object = [self.rows objectAtIndex:sourceIndexPath.row];
    [self.rows removeObjectAtIndex:sourceIndexPath.row];
    [self.rows insertObject:object atIndex:destinationIndexPath.row];
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsReplacePlaceholderForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.rows replaceObjectAtIndex:indexPath.row withObject:self.grabbedObject];
    self.grabbedObject = nil;
}



#pragma mark - TableView Convenience

-(NSString *)stringForIndexPath:(NSIndexPath *)indexPath
{
    //check if dropdown path
    //add total paths together
    if (self.dropDownPath){
        NSInteger dropPathRow = self.dropDownPath.row;
        if (indexPath.row > dropPathRow && indexPath.row < dropPathRow+self.dropDownRows.count){
            NSString * string = self.dropDownRows[indexPath.row-dropPathRow];
            return string;
        }
    }else{
        return [self.rows objectAtIndex:indexPath.row];
    }
    return @"";
}

-(BOOL)isDropDownRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dropDownPath){
        NSInteger dropPathRow = self.dropDownPath.row;
        if (indexPath.row > dropPathRow && indexPath.row < dropPathRow+self.dropDownRows.count){
            return YES;
        }else{
            return NO;
        }
    }else{
        return NO;
    }
}

-(NSInteger)regularIndexForIndexPath:(NSIndexPath *)indexPath
{
    if (self.dropDownPath){
        NSInteger dropPathRow = self.dropDownPath.row;
        if (indexPath.row < dropPathRow){
            return indexPath.row;
        }else{
            if (indexPath.row > dropPathRow && indexPath.row < dropPathRow+self.dropDownRows.count){
                return NSNotFound;
            }else if (indexPath.row > dropPathRow+self.dropDownRows.count){
                return indexPath.row-_dropDownRows.count;
            }
        }
    }else{
        return indexPath.row;
    }
    return NSNotFound;
}

-(NSInteger)dropdownIndexForIndexPath:(NSIndexPath *)indexPath
{
    if (self.dropDownPath){
        NSInteger dropPathRow = self.dropDownPath.row;
        if (indexPath.row > dropPathRow && indexPath.row < dropPathRow+self.dropDownRows.count){
            NSInteger row = indexPath.row - dropPathRow;
            return row;
        }else{
            return NSNotFound;
        }
    }else{
        return NSNotFound;
    }
}

-(NSString *)dropdownPlaceholderForIndex:(NSInteger)index
{
    NSString * placeholder;
    switch (index) {
        case 0:
            placeholder = @"Username or Email";
            break;
        case 1:
            placeholder = @"Password";
            break;
        case 2:
            placeholder = @"URL";
            break;
        default:
            placeholder = [NSString stringWithFormat:@"Notes %d", index-2];
            break;
    }
    return placeholder;
}

@end
