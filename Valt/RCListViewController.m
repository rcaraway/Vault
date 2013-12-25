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
#import "RCTitleViewCell.h"
#import "UIColor+RCColors.h"
#import "RCAppDelegate.h"
#import "RCRootViewController.h"
#import "UIImage+memoIcons.h"
#import "RCListGestureManager.h"
#import "JTTransformableTableViewCell.h"
#import "HTAutocompleteTextField.h"
#import "RCNetworking.h"

#define ADDING_CELL @"Continue..."
#define DONE_CELL @"Done"
#define DUMMY_CELL @"Dummy"
#define COMMITING_CREATE_CELL_HEIGHT 60
#define NORMAL_CELL_FINISHING_HEIGHT 60

@interface RCListViewController ()<RCListGestureManagerDelegate>
@property(nonatomic, strong) RCListGestureManager * gestureManager;
@property(nonatomic) NSInteger addingCellIndex;
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
    self.addingCellIndex = NSNotFound;
    self.dummyCellIndex = NSNotFound;
    self.gestureManager = [[RCListGestureManager alloc] initWithTableView:self.tableView delegate:self];
    self.view.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    [self setupTableView];
    [self setupSyncButtonIfNeeded];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.tableView.alpha = 0.0;
        CGAffineTransform scale = CGAffineTransformMakeScale(.3, .3);
        self.tableView.transform = scale;
        [UIView animateWithDuration:0.2  animations:^{
            self.tableView.alpha = 1.0;
            CGAffineTransform scale = CGAffineTransformMakeScale(1.1, 1.1);
            self.tableView.transform = scale;
        } completion:^(BOOL finished) {
            [self showSyncButton];
            [UIView animateWithDuration:.2 animations:^{
                self.tableView.transform = CGAffineTransformIdentity;
            }completion:^(BOOL finished) {
            }];
        }];
        
    });
    [self.tableView reloadData];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)willMoveToParentViewController:(UIViewController *)parent
{
    if (parent == [APP rootController]){
        RCRootViewController * rootVC = (RCRootViewController *)parent;
        [rootVC showSearchAnimated:YES];
        [self.view setFrame:CGRectMake(0, 64, 320, [UIScreen mainScreen].bounds.size.height-64)];
        [rootVC.view insertSubview:self.view belowSubview:rootVC.searchBar];
    }
}

-(void)didMoveToParentViewController:(UIViewController *)parent
{
    [self.view removeFromSuperview];
}

#pragma mark - View Setup

-(void)setupTableView
{
    self.tableView.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    self.tableView.allowsSelection = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.alpha = 0;
    [self.tableView registerClass:[RCTitleViewCell class] forCellReuseIdentifier:@"MyCell"];
    [self.tableView registerClass:[JTPullDownTableViewCell class] forCellReuseIdentifier:@"PullDownTableViewCell"];
    [self.tableView registerClass:[JTUnfoldingTableViewCell class] forCellReuseIdentifier:@"UnfoldingTableViewCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = NORMAL_CELL_FINISHING_HEIGHT;
}



-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma mark - Sync Button

-(void)setupSyncButtonIfNeeded
{
    if (![[RCNetworking sharedNetwork] loggedIn]){
        self.syncButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.syncButton setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, 320, 50)];
        [self.syncButton addTarget:self action:@selector(didTapSync) forControlEvents:UIControlEventTouchUpInside];
        [self.syncButton setBackgroundColor:[UIColor whiteColor]];
        [self.syncButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.syncButton setTitle:@"Sync Data to Cloud" forState:UIControlStateNormal];
        [[APP rootController].view addSubview:self.syncButton];
    }
}

-(void)showSyncButton
{
    [UIView animateWithDuration:2 delay:0 usingSpringWithDamping:.7 initialSpringVelocity:.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.syncButton setFrame:CGRectMake(0, [APP rootController].view.frame.size.height-50, 320, 50)];
    } completion:nil];
}

-(void)didTapSync
{
    [[APP rootController] launchPurchaseScreen];
}



#pragma mark - TableView Delegate/DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.addingCellIndex != NSNotFound){
        return [[RCPasswordManager defaultManager] allTitles].count+1;
    }
    return [[RCPasswordManager defaultManager] allTitles].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.addingCellIndex) {
        JTTransformableTableViewCell *cell = nil;
        if (indexPath.row == 0) {
            cell = [self pullDownCellForIndexPath:indexPath];
            return cell;
        } else {
            cell = [self foldingCellForIndexPath:indexPath];
            return cell;
        }
    } else{
        NSString *object;
        if (self.addingCellIndex != NSNotFound){
            if (indexPath.row < self.addingCellIndex){
                object =  [[RCPasswordManager defaultManager] allTitles][indexPath.row];
            }else{
                object =  [[RCPasswordManager defaultManager] allTitles][indexPath.row-1];
            }
        }
        else
            object =  [[RCPasswordManager defaultManager] allTitles][indexPath.row];
        static NSString *cellIdentifier = @"MyCell";
        RCTitleViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.textField.text = (NSString *)object;
        if (indexPath.row == self.dummyCellIndex){
            cell.textField.text = @"";
            cell.textLabel.text = @"";
            cell.textField.placeholder = @"";
        }
        return cell;
    }
}


#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NORMAL_CELL_FINISHING_HEIGHT;
}


#pragma mark Gesture Management

-(void)gestureManager:(RCListGestureManager *)manager needsNewRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.addingCellIndex = indexPath.row;
}

-(void)gestureManager:(RCListGestureManager *)manager needsFinishedNewRowAtIndexPath:(NSIndexPath *)indexPath
{
    JTTransformableTableViewCell * cell = (JTTransformableTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[JTTransformableTableViewCell class]]){
        BOOL isFirstCell = indexPath.section == 0 && indexPath.row == 0;
        if (isFirstCell && cell.frame.size.height > COMMITING_CREATE_CELL_HEIGHT * 2){
            self.addingCellIndex = NSNotFound;
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        }else if (cell.frame.size.height > COMMITING_CREATE_CELL_HEIGHT)
        {
            RCPassword * password = [[RCPassword alloc] init];
            [[RCPasswordManager defaultManager] addPassword:password atIndex:indexPath.row];
            self.addingCellIndex = NSNotFound;
            cell.finishedHeight = NORMAL_CELL_FINISHING_HEIGHT;
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [[APP rootController] launchSingleWithPassword:password];
        }
    }
}

-(void)gestureManager:(RCListGestureManager *)manager needsRemovalOfRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.addingCellIndex = NSNotFound;
}

-(void)gestureManager:(RCListGestureManager *)manager didTapRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.tableView cellForRowAtIndexPath:indexPath] isMemberOfClass:[RCTitleViewCell class]]){
        RCTitleViewCell * cell = (RCTitleViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell setFocused];
        RCPassword * password = [[RCPasswordManager defaultManager] passwords][indexPath.row];
        [[APP rootController] launchSingleWithPassword:password];
    }
}

-(void)gestureManagerDidTapBelowCells:(RCListGestureManager *)manager
{
    RCPassword * password = [[RCPassword alloc] init];
    [[RCPasswordManager defaultManager] addPassword:password];
    [[APP rootController] launchSingleWithPassword:password];
}


-(void)gestureManager:(RCListGestureManager *)manager didChangeToState:(RCListGestureManagerPanState)state forIndexPath:(NSIndexPath *)indexPath
{
    RCTitleViewCell *cell = (RCTitleViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[RCTitleViewCell class]]){
        switch (state) {
            case RCListGestureManagerPanStateMiddle:
                [cell removeFocus];
                break;
            case RCListGestureManagerPanStateRight:
                //TODO: add browser show
                break;
            default:
                [cell setRedColored];
                break;
        }
    }
}

-(void)gestureManager:(RCListGestureManager *)manager didFinishWithState:(RCListGestureManagerPanState)state forIndexPath:(NSIndexPath *)indexPath
{
    UITableView *tableView = self.gestureManager.tableView;
    [tableView beginUpdates];
    if (state == RCListGestureManagerPanStateLeft) {
        [[RCPasswordManager defaultManager] removePasswordAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    } else if (state == JTTableViewCellEditingStateRight) {
        RCPassword * password = [[RCPasswordManager defaultManager] passwords][indexPath.row];
        if (password.hasValidURL){
            [[APP rootController] launchBrowserWithPassword:password];
        }else{
            //pop up, ask for a url to go to
            //save it
            //then go
        }
        
    } else {
        
    }
    [tableView endUpdates];
    [self.gestureManager resetCellToCenterAtIndexPath:indexPath];
    [self.gestureManager reloadAllRowsExceptIndexPath:indexPath];
}

-(void)removePassword:(RCPassword *)password
{
    NSIndexPath * path = [NSIndexPath indexPathForRow:[[[RCPasswordManager defaultManager] passwords] indexOfObject:password] inSection:0];
    [[RCPasswordManager defaultManager] removePasswordAtIndex:path.row];
    [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
    [[RCPasswordManager defaultManager] saveAllToKeychain];
}

-(void)gestureManager:(RCListGestureManager *)manager needsPlaceholderRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.grabbedObject = [[RCPasswordManager defaultManager] allTitles][indexPath.row];
    self.dummyCellIndex = indexPath.row;
}

-(void)gestureManager:(RCListGestureManager *)manager needsRowMovedAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)updatedPath
{
    [[RCPasswordManager defaultManager] movePasswordAtIndex:indexPath.row toNewIndex:updatedPath.row];
}

-(void)gestureManager:(RCListGestureManager *)manager needsReplacePlaceholderForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.dummyCellIndex = NSNotFound;
    self.grabbedObject = nil;
    [[RCPasswordManager defaultManager] saveAllToKeychain];
}



#pragma mark - Table Convenience

-(JTTransformableTableViewCell *)pullDownCellForIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = nil;
    UIColor *backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
    cellIdentifier = @"PullDownTableViewCell";
    JTPullDownTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
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

-(JTTransformableTableViewCell *)foldingCellForIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = nil;
    UIColor *backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
    cellIdentifier = @"UnfoldingTableViewCell";
    JTUnfoldingTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.textColor = [UIColor blackColor];
    
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
