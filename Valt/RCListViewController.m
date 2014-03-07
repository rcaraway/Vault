//
//  RCListViewController.m
//  Valt
//
//  Created by Rob Caraway on 12/10/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCListViewController.h"

//Model
#import "RCPassword.h"
#import "RCPasswordManager.h"
#import "RCAppDelegate.h"
#import "RCRootViewController.h"
#import "RCListGestureManager.h"
#import "RCNetworking.h"
#import "RCInAppPurchaser.h"
#import "HTAutocompleteManager.h"
#import "LEColorPicker.h"

//Views
#import "JTTransformableTableViewCell.h"
#import "HTAutocompleteTextField.h"
#import "LBActionSheet.h"
#import "RCSearchBar.h"
#import "RCBackupView.h"
#import "RCDropDownCell.h"
#import "RCMainCell.h"
#import "RCTableView.h"
#import "RCMessageView.h"
#import "MLAlertView.h"

//Categories
#import "UIColor+RCColors.h"
#import "UIImage+memoIcons.h"
#import "UIColor+JTGestureBasedTableViewHelper.h"
#import "RCRootViewController+passwordSegues.h"
#import "RCRootViewController+menuSegues.h"
#import "RCRootViewController+WebSegues.h"
#import "RCRootViewController+purchaseSegues.h"

#define ADDING_CELL @"Continue..."
#define DONE_CELL @"Done"
#define DUMMY_CELL @"Dummy"


@interface RCListViewController ()<RCListGestureManagerDelegate, LBActionSheetDelegate, RCBackupViewDelegate, MLAlertViewDelegate>


@property(nonatomic) NSInteger addingCellIndex;
@property(nonatomic) NSInteger dummyCellIndex;
@property(nonatomic, strong) NSIndexPath * deletionPath;
@property(nonatomic, strong) UIImageView * hintImageView;
@property(nonatomic, strong) UILabel * hintLabel;

@property (nonatomic, strong) id grabbedObject;
@property(nonatomic, strong) LBActionSheet * actionSheet;
@property(nonatomic, strong) MLAlertView * alertView;

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
        self.addingCellIndex = NSNotFound;
        self.dummyCellIndex = NSNotFound;
    }
    return self;
}


#pragma mark - View LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupTableView];
    self.gestureManager = [[RCListGestureManager alloc] initWithTableView:self.tableView delegate:self];
    self.view.backgroundColor = [UIColor listBackground];
    [self addNotifications];
    if ([RCPasswordManager defaultManager].passwords.count == 0){
        [self showPullDownViews];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setOffsetIfNeeded];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self reloadIfNeeded];
    [self showBackupViewIfNeeded];
}

-(void)showBackupViewIfNeeded
{
    static BOOL backupShown = NO;
    if ([APP launchCountTriggered] &&  [RCNetworking sharedNetwork].premiumState == RCPremiumStateNone && ![[RCPasswordManager defaultManager] canLogin] && !backupShown){
        [self setupBackupView];
        [self performSelector:@selector(showBackup) withObject:nil afterDelay:.6];
        backupShown = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    if (self.isViewLoaded && self.parentViewController == nil && !self.view.window){
        [self freeAllMemory];
    }
    [super didReceiveMemoryWarning];
}

-(void)freeAllMemory
{
    [self removeNotifications];
    self.tableView = nil;
    self.gestureManager = nil;
    self.view = nil;
}

-(void)dealloc
{
    [self freeAllMemory];
}


#pragma mark - NSNotifications Event Handling

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


#pragma mark - State Handling

-(void)showPullDownViews
{
    if ([RCPasswordManager defaultManager].passwords.count == 0){
        if (!self.hintImageView){
            [self setupPullDownView];
        }
        if (self.hintImageView.alpha == 1){
            self.hintImageView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2.0, self.view.center.y-100);
            [UIView animateWithDuration:.8 delay:.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self.hintImageView setFrame:CGRectOffset(self.hintImageView.frame, 0, 80)];
            } completion:^(BOOL finished) {
                [NSObject cancelPreviousPerformRequestsWithTarget:self];
                [self performSelector:@selector(showPullDownViews) withObject:nil afterDelay:1.4];
            }];
        }
    }else{
        [self hideHintLabels];
    }
}

-(void)showSwipeRightViews
{
    if ([APP swipeRightHint]){
        if (!self.hintImageView){
            [self setupSwipeRightViews];
        }
        [self.hintImageView setFrame:CGRectMake(12, 60, 128, 128)];
        [UIView animateWithDuration:.8 delay:.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.hintImageView setFrame:CGRectOffset(self.hintImageView.frame, 100, 0)];
        } completion:^(BOOL finished) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            [self performSelector:@selector(showSwipeRightViews) withObject:nil afterDelay:1.4];
        }];
    }else{
        [self hideHintLabels];
    }
}

-(void)hideHintLabels
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    self.hintImageView.alpha = 0;
    self.hintLabel.alpha = 0;
    [self.hintLabel removeFromSuperview];
    [self.hintImageView removeFromSuperview];
    self.hintImageView = nil;
    self.hintLabel = nil;
}

-(void)setHintsHidden
{
    [UIView animateWithDuration:.3 animations:^{
        self.hintImageView.alpha = 0;
        self.hintLabel.alpha = 0;
    }];
}

-(void)reshowHints
{
    [UIView animateWithDuration:.3 animations:^{
        self.hintImageView.alpha = 1;
        self.hintLabel.alpha = 1;
    }];
}

-(void)setOffsetIfNeeded
{
    dispatch_once(&onceToken, ^{
        self.tableView.contentOffset = CGPointMake(0, -44);
    });
}

-(void)reloadIfNeeded
{
    static BOOL firstLaunch = YES;
    if (!firstLaunch && !self.gestureManager.webPath){
        [self.tableView reloadData];
    }else{
        self.gestureManager.webPath = nil;
    }
    firstLaunch = NO;
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
    self.tableView.separatorColor = [UIColor colorWithWhite:.8 alpha:1];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = NORMAL_CELL_FINISHING_HEIGHT;
    [self.view addSubview:self.tableView];
}

-(void)setupBackupView
{
    self.backupView = [[RCBackupView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 60)];
    self.backupView.delegate = self;
    [self.view addSubview:self.backupView];
}

-(void)setupPullDownView
{
    self.hintImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"Swipe_Down"] tintedImageWithColorOverlay:[UIColor darkGrayColor]]];
    [self.hintImageView setFrame:CGRectMake(0, 0, 128, 128)];
    self.hintImageView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2.0, self.view.center.y-100);
    [self.view addSubview:self.hintImageView];
    [self setupHintLabelWithText:@"Pull down to create"];
}

-(void)setupHintLabelWithText:(NSString *)text
{
    UILabel * label = [[UILabel  alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    label.center =CGPointMake([UIScreen mainScreen].bounds.size.width/2.0, self.view.center.y+140);
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 1;
    label.text = text;
    label.font = [UIFont systemFontOfSize:17];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor lightGrayColor];
    self.hintLabel= label;
    [self.view addSubview:label];
}

-(void)setupSwipeRightViews
{
    UIImageView * imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"Swipe_Right"] tintedImageWithColorOverlay:[UIColor darkGrayColor]]];
    [imageView setFrame:CGRectMake(12, 44, 128, 128)];
    [imageView setUserInteractionEnabled:NO];
    self.hintImageView = imageView;
    [self.view addSubview:imageView];
    [self setupHintLabelWithText:@"Swipe Item Right To Login"];
}



#pragma mark - TableView Delegate/DataSource

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{

}

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
        
    } if ([indexPath isEqual:self.viewPath]){
        static NSString *cellIdentifier = @"MyCell";
        RCMainCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.customLabel.text = @"";
        [(RCMainCell *)cell setNormalColored];
        return cell;
    }
    else if ([indexPath isEqual:self.gestureManager.webPath]){
        static NSString *cellIdentifier = @"MyCell";
        RCMainCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        [cell setFinishedGreen];
        return cell;
    }
    else{
        RCPassword * password;
        NSInteger extraIndex = NSNotFound;
        if (self.addingCellIndex != NSNotFound){
            extraIndex = self.addingCellIndex;
        }else if (self.viewPath){
            extraIndex = self.viewPath.row;
        }
        if (extraIndex != NSNotFound){
            if (indexPath.row < extraIndex){
                password =[[RCPasswordManager defaultManager] passwords][indexPath.row];
            }else{
                password =[[RCPasswordManager defaultManager] passwords][indexPath.row-1];
            }
        }
        else{
            if ([[RCPasswordManager defaultManager] allTitles].count > indexPath.row){
                password =[[RCPasswordManager defaultManager] passwords][indexPath.row];
            }
        }
        
        static NSString *cellIdentifier = @"MyCell";
        RCMainCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        [cell setPassword:password];
        [cell setNormalColored];
       
        if (indexPath.row == self.dummyCellIndex){
             cell.customLabel.text = @"";
             cell.contentView.backgroundColor = [UIColor listBackground];
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
        if (isFirstCell && cell.frame.size.height > COMMITING_CREATE_CELL_HEIGHT * 3){
            if ([RCNetworking sharedNetwork].premiumState == RCPremiumStateCurrent){
                [[RCNetworking sharedNetwork] fetchFromServer];
            }else{
                [[APP rootController] segueToPurchaseFromList];
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
    } else if (state == RCListGestureManagerPanStateRight) {
        RCPassword * password = [[RCPasswordManager defaultManager] passwords][indexPath.row];
        if (password.hasValidURL){
            self.gestureManager.webPath = indexPath;
            [[APP rootController] segueToWebWithPassword:[RCPasswordManager defaultManager].passwords[indexPath.row]];
        }else{
            self.gestureManager.webPath = indexPath;
            self.alertView = [[MLAlertView alloc] initWithTextfieldWithPlaceholder:@"URL" title:@"Enter valid URL" delegate:self cancelButtonTitle:@"Cancel" confirmButtonTitle:@"Go"];
            self.alertView.passwordTextField.autocorrectionType = RCAutocompleteTypeURL;
            self.alertView.passwordTextField.secureTextEntry = NO;
            
            [self.alertView show];
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
        [[RCNetworking sharedNetwork] saveToCloud];
    }
    self.dummyCellIndex = NSNotFound;
    self.grabbedObject = nil;
}


#pragma mark - Alert View

-(void)alertView:(MLAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex withText:(NSString *)text
{
    if (buttonIndex == 1){
        RCPassword * password = [RCPasswordManager defaultManager].passwords[self.gestureManager.webPath.row];
        password.urlName = text;
        if (password.hasValidURL){
            [[RCPasswordManager defaultManager] updatePassword:password];
            if ([[RCNetworking sharedNetwork] loggedIn]){
                [[RCNetworking sharedNetwork] saveToCloud];
            }
            [self.alertView dismissWithSuccessCompletion:^{
                   [[APP rootController] segueToWebWithPassword:password];
            }];
        }else{
            [self.alertView showFailWithTitle:@"Invalid URL"];
        }
    }

}

-(void)alertViewTappedCancel:(MLAlertView *)alertView
{
    [self.gestureManager resetCellToCenterAtIndexPath:self.gestureManager.webPath];
    self.gestureManager.webPath = nil;
}

-(void)alertView:(MLAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
}

-(void)alertView:(MLAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex withEmail:(NSString *)email password:(NSString *)password
{
    
}

#pragma mark - Backup View

-(void)showBackup
{
    [UIView animateWithDuration:.8 delay:0 usingSpringWithDamping:.6 initialSpringVelocity:.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.backupView setFrame:CGRectOffset(self.backupView.frame, 0, -60)];
    } completion:^(BOOL finished) {
        
    }];
}

-(void)hideBackup
{
    [UIView animateWithDuration:.6 delay:0 usingSpringWithDamping:.7 initialSpringVelocity:.2 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.backupView setFrame:CGRectOffset(self.backupView.frame, 0, 60)];
    } completion:^(BOOL finished) {
        [self.backupView removeFromSuperview];
        self.backupView = nil;
    }];
}

-(void)backupViewDidTapNo:(RCBackupView *)backupView
{
    [self hideBackup];
}

-(void)backupViewDidTapYes:(RCBackupView *)backupView
{
    [[APP rootController] segueToPurchaseFromList];
    [self hideBackup];
}


#pragma mark - Action Sheet

-(void)actionSheet:(LBActionSheet *)actionSheet clickedButtonAtIndex:(NSUInteger)buttonIndex
{
    if (buttonIndex == 0){
        [[RCPasswordManager defaultManager] removePasswordAtIndex:self.deletionPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[self.deletionPath] withRowAnimation:UITableViewRowAnimationMiddle];
        [[RCNetworking sharedNetwork] saveToCloud];
        if (self.hintImageView){
            [self hideHintLabels];
        }
        if ([RCPasswordManager defaultManager].passwords.count == 0){
            [self showPullDownViews];
        }
    }else{
        [self reshowHints];
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
