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
#import "RCMainCell.h"
#import "UIColor+RCColors.h"
#import "RCAppDelegate.h"
#import "RCRootViewController.h"
#import "UIImage+memoIcons.h"
#import "RCListGestureManager.h"
#import "JTTransformableTableViewCell.h"
#import "HTAutocompleteTextField.h"
#import "RCNetworking.h"
#import "RCInAppPurchaser.h"
#import "LBActionSheet.h"
#import "RCRootViewController+passwordSegues.h"
#import "RCSearchBar.h"
#import "RCRootViewController+menuSegues.h"
#import "RCRootViewController+WebSegues.h"

#define ADDING_CELL @"Continue..."
#define DONE_CELL @"Done"
#define DUMMY_CELL @"Dummy"



@implementation RCTableView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        self.shouldAllowMovement = YES;
    }
    return self;
}

-(void)setContentOffset:(CGPoint)contentOffset
{
    if (self.shouldAllowMovement){
        [super setContentOffset:contentOffset];
    }
}

-(void)setContentSize:(CGSize)contentSize
{
    if (self.shouldAllowMovement){
        [super setContentSize:contentSize];
    }
}



@end




@interface RCListViewController ()<RCListGestureManagerDelegate, LBActionSheetDelegate>


@property(nonatomic) NSInteger addingCellIndex;
@property(nonatomic) NSInteger dummyCellIndex;
@property(nonatomic, strong) NSIndexPath * deletionPath;

@property (nonatomic, strong) id grabbedObject;
@property(nonatomic, strong) LBActionSheet * actionSheet;

@end

@implementation RCListViewController
{
    dispatch_once_t onceToken;
}

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
    self.addingCellIndex = NSNotFound;
    self.dummyCellIndex = NSNotFound;
    [self setupTableView];
    self.gestureManager = [[RCListGestureManager alloc] initWithTableView:self.tableView delegate:self];
    self.view.backgroundColor = [UIColor listBackground];
    
    [self addNotifications];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([[RCNetworking sharedNetwork] premiumState] == RCPremiumStateExpired){
        //TODO:Launch Alert View for renewing
    }
    [self.tableView reloadData];

}

- (void)didReceiveMemoryWarning
{
    if (self.isViewLoaded && !self.view.window){
        [self removeNotifications];
    }
    [super didReceiveMemoryWarning];
}

#pragma mark - Status Bar

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationFade;
}


#pragma mark - NSNotifications

-(void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPurchaseSubscription) name:purchaserDidPayMonthly object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPurchaseSubscription) name:purchaserDidPayYearly object:nil];
}

-(void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:purchaserDidPayYearly object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:purchaserDidPayMonthly object:nil];
}

-(void)didPurchaseSubscription
{
}


#pragma mark - View Setup

-(void)setupTableView
{
    self.tableView = [[RCTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.tableView.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    self.tableView.allowsSelection = NO;
    [self.tableView setContentInset:UIEdgeInsetsMake(44, 0, 0, 0)];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.alpha = 1;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor listBackground];
    self.tableView.dataSource = self;
    [self.tableView registerClass:[RCMainCell class] forCellReuseIdentifier:@"MyCell"];
    [self.tableView registerClass:[JTPullDownTableViewCell class] forCellReuseIdentifier:@"PullDownTableViewCell"];
    [self.tableView registerClass:[JTUnfoldingTableViewCell class] forCellReuseIdentifier:@"UnfoldingTableViewCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    NSLog(@"CONTENT OFFSET %f", self.tableView.contentOffset.y);
    self.tableView.rowHeight = NORMAL_CELL_FINISHING_HEIGHT;
    [self.view addSubview:self.tableView];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([[[[APP rootController] searchBar] searchField] isFirstResponder]){
         [self.view endEditing:YES];
    }
}



#pragma mark - TableView Delegate/DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.addingCellIndex != NSNotFound || self.viewPath){
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
        
    } if ([indexPath isEqual:self.viewPath] || [indexPath isEqual:self.webPath]){
        static NSString *cellIdentifier = @"MyCell";
        RCMainCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.customLabel.text = @"";
        if ([indexPath isEqual:self.webPath]){
            [cell setCompletelyGreen];
        }
        return cell;
    }
    else{
        NSString *object;
        if (self.addingCellIndex != NSNotFound){
            if (indexPath.row < self.addingCellIndex){
                object =  [[RCPasswordManager defaultManager] allTitles][indexPath.row];
            }else{
                object =  [[RCPasswordManager defaultManager] allTitles][indexPath.row-1];
            }
        }
        else{
            if ([[RCPasswordManager defaultManager] allTitles].count > indexPath.row){
                 object =  [[RCPasswordManager defaultManager] allTitles][indexPath.row];   
            }
        }
        
        static NSString *cellIdentifier = @"MyCell";
        RCMainCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.customLabel.text = (NSString *)object;
        if (indexPath.row == self.dummyCellIndex){
                cell.customLabel.text = @"";
        }
        return cell;
    }
}


#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:self.viewPath]){
        return 188;
    }
    if ([indexPath isEqual:self.webPath]){
        return self.view.frame.size.height;
    }
    return NORMAL_CELL_FINISHING_HEIGHT;
}


#pragma mark Gesture Management

-(void)gestureManagerDidTapInMenuMode:(RCListGestureManager *)manager
{
    [[APP rootController] closeMenu];
}

-(BOOL)gestureManagerShouldAllowCellCreation:(RCListGestureManager *)manager
{
    if ([[[APP rootController] childViewControllers] containsObject:[[APP rootController] singleController]]){
        return NO;
    }
    return YES;
}

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
            if ([[RCNetworking sharedNetwork] loggedIn]){
                [[RCNetworking sharedNetwork] fetchFromServer];
            }else{
                //TODO: Transition From list to Purchase
            }
            self.addingCellIndex = NSNotFound;
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        }else if (cell.frame.size.height > COMMITING_CREATE_CELL_HEIGHT)
        {
            self.gestureManager.didAddCell = YES;
            RCPassword * password = [[RCPassword alloc] init];
            [[RCPasswordManager defaultManager] addPassword:password atIndex:indexPath.row];
            self.addingCellIndex = NSNotFound;
            cell.finishedHeight = NORMAL_CELL_FINISHING_HEIGHT;
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

-(void)gestureManager:(RCListGestureManager *)manager didFinishAnimatingNewRowAtIndexPath:(NSIndexPath *)indexPath
{
    RCPassword * password = [[RCPasswordManager defaultManager] passwords][indexPath.row];
    [[APP rootController] segueToSingleWithPassword:password];
}

-(void)gestureManager:(RCListGestureManager *)manager needsRemovalOfRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath * copy = [NSIndexPath indexPathForRow:self.addingCellIndex inSection:0];
    self.addingCellIndex = NSNotFound;
    [self.tableView deleteRowsAtIndexPaths:@[copy] withRowAnimation:UITableViewRowAnimationTop];
}

-(void)gestureManager:(RCListGestureManager *)manager didTapRowAtIndexPath:(NSIndexPath *)indexPath atLocation:(CGPoint)location
{
    if ([[self.tableView cellForRowAtIndexPath:indexPath] isMemberOfClass:[RCMainCell class]]){
        RCPassword * password = [[RCPasswordManager defaultManager] passwords][indexPath.row];
        [[APP rootController] segueToSingleWithPassword:password];
    }
}

-(void)gestureManagerDidTapBelowCells:(RCListGestureManager *)manager atLocation:(CGPoint)location
{
    [[APP rootController] segueToSingleWithNewPasswordAtLocation:location];
}


-(void)gestureManager:(RCListGestureManager *)manager didChangeToState:(RCListGestureManagerPanState)state forIndexPath:(NSIndexPath *)indexPath
{
    RCMainCell *cell = (RCMainCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[RCMainCell class]]){
        switch (state) {
            case RCListGestureManagerPanStateMiddle:
                [cell removeFocus];
                break;
            case RCListGestureManagerPanStateRight:
                [cell setGreenColored];
                break;
            default:
                [cell setRedColored];
                break;
        }
    }
}

-(void)gestureManager:(RCListGestureManager *)manager didFinishWithState:(RCListGestureManagerPanState)state forIndexPath:(NSIndexPath *)indexPath
{
    if (state == RCListGestureManagerPanStateLeft) {
        self.actionSheet = [[LBActionSheet alloc] initWithTitle:[[[RCPasswordManager defaultManager] passwords][indexPath.row] title] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Entry" otherButtonTitles:nil];
        self.deletionPath = indexPath;
        [self.actionSheet showInView:self.view];
    } else if (state == JTTableViewCellEditingStateRight) {
        RCPassword * password = [[RCPasswordManager defaultManager] passwords][indexPath.row];
        if (password.hasValidURL){
            [[APP rootController] segueToWebFromIndexPath:indexPath];
        }else{
            //pop up, ask for a url to go to
            //save it
            //then go
        }
        
    } else {
        [self.gestureManager resetCellToCenterAtIndexPath:indexPath];
        [self.gestureManager reloadAllRowsExceptIndexPath:indexPath];
    }
}



-(void)removePassword:(RCPassword *)password
{
    NSIndexPath * path = [NSIndexPath indexPathForRow:[[[RCPasswordManager defaultManager] passwords] indexOfObject:password] inSection:0];
    [[RCPasswordManager defaultManager] removePasswordAtIndex:path.row];
    [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
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
    if (self.dummyCellIndex != indexPath.row){
        [[RCNetworking sharedNetwork] sync];
    }
    self.dummyCellIndex = NSNotFound;
    self.grabbedObject = nil;
}


#pragma mark - Action Sheet

-(void)actionSheet:(LBActionSheet *)actionSheet clickedButtonAtIndex:(NSUInteger)buttonIndex
{
    if (buttonIndex == 0){
        [[RCPasswordManager defaultManager] removePasswordAtIndex:self.deletionPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[self.deletionPath] withRowAnimation:UITableViewRowAnimationMiddle];
        [[RCNetworking sharedNetwork] sync];
    }else{
        [self.gestureManager resetCellToCenterAtIndexPath:self.deletionPath];
    }
    self.deletionPath = nil;
}

-(void)actionSheetCancel:(LBActionSheet *)actionSheet
{

    self.deletionPath = nil;
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
    return cell;
}

-(JTTransformableTableViewCell *)foldingCellForIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = nil;
    UIColor *backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
    cellIdentifier = @"UnfoldingTableViewCell";
    JTUnfoldingTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.tintColor = backgroundColor;
    cell.finishedHeight = COMMITING_CREATE_CELL_HEIGHT;
    return cell;
}

@end
