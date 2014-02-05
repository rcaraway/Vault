//
//  RCSingleViewController.m
//  Valt
//
//  Created by Rob Caraway on 12/10/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCSingleViewController.h"
#import "RCRootViewController.h"
#import "RCListViewController.h"
#import "RCSearchViewController.h"

#import "RCAppDelegate.h"

#import "RCCredentialGestureManager.h"
#import "HTAutocompleteManager.h"
#import "RCNetworking.h"
#import "RCPassword.h"
#import "RCPasswordManager.h"
#import "JTTableViewGestureRecognizer.h"

#import "JTTransformableTableViewCell.h"
#import "HTAutocompleteTextField.h"
#import "RCDropDownCell.h"
#import "RCTitleViewCell.h"
#import "RCTableView.h"

#import "UIImage+memoIcons.h"
#import "UIColor+RCColors.h"
#import "RCRootViewController+passwordSegues.h"
#import "RCRootViewController+searchSegue.h"

#define ADDING_CELL @"Continue..."
#define DONE_CELL @"Done"
#define DUMMY_CELL @"Dummy"
#define COMMIT_SINGLE_CELL_HEIGHT 47
#define NORMAL_SINGLE_FINISHING_HEIGHT 47
#define TITLE_CELL_HEIGHT NORMAL_CELL_FINISHING_HEIGHT


@interface RCSingleViewController ()<RCCredentialGestureManagerDelegate, UITextFieldDelegate>
{
    CGPoint listOffset;
    CGPoint singleOffset;
    BOOL dataChanged;
}

@property (nonatomic, strong) RCCredentialGestureManager * gestureManager;
@property(nonatomic, strong) NSMutableArray * credentials;
@property(nonatomic, strong) NSMutableArray * textFields;
@property(nonatomic) NSInteger dummyCellIndex;

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
        self.isTransitioningTo = YES;
        self.dummyCellIndex = NSNotFound;
        self.credentials = [NSMutableArray arrayWithArray:[self.password allFields]];
    }
    return self;
}


#pragma mark - View LifeCycle

-(void)loadView
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    view.backgroundColor = [UIColor clearColor];
    self.view = view;
    [self setupTableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:.1 alpha:.4];
    self.gestureManager = [[RCCredentialGestureManager alloc] initWithTableView:self.tableView delegate:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setAllTextFieldDelegates];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (!self.parentViewController && self.isViewLoaded && !self.view.window){
        [self freeAllMemory];
    }
}

-(void)freeAllMemory
{
    self.tableView = nil;
    self.gestureManager = nil;
    self.view = nil;
}



#pragma mark - View Setup

-(void)setupTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height)];
    self.tableView.delegate  = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.dataSource = self;
    self.tableView.allowsSelection = NO;
    [self.tableView registerClass:[RCTitleViewCell class] forCellReuseIdentifier:@"MyCell"];
    [self.tableView registerClass:[RCDropDownCell class] forCellReuseIdentifier:@"DropDownCell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = NORMAL_SINGLE_FINISHING_HEIGHT;
    [self.view addSubview:self.tableView];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (!self.cameFromSearch){
         listOffset = [APP rootController].listController.tableView.contentOffset;
    }else{
        listOffset = [APP rootController].searchController.tableView.contentOffset;
    }
    singleOffset = scrollView.contentOffset;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
    if (!self.isTransitioningTo && !self.cameFromSearch){
        [self scrollListView:scrollView];
    }else if (!self.isTransitioningTo && self.cameFromSearch){
        [self scrollSearchView:scrollView];
    }
}

-(void)scrollListView:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 0){
        CGFloat magnitude = fabsf(scrollView.contentOffset.y / 60.0) ;
        if (magnitude > 1)
            magnitude = 1;
        self.view.backgroundColor = [UIColor colorWithWhite:.1 alpha:(1- magnitude)*.75];
    }else{
    }
    [[APP rootController].listController.tableView setShouldAllowMovement:YES];
    CGPoint difPoint = CGPointMake(singleOffset.x-scrollView.contentOffset.x, singleOffset.y-scrollView.contentOffset.y);
    [[APP rootController].listController.tableView setContentOffset:CGPointMake(listOffset.x-difPoint.x, listOffset.y-difPoint.y)];
    listOffset = [APP rootController].listController.tableView.contentOffset;
    singleOffset = scrollView.contentOffset;

}

-(void)scrollSearchView:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 0){
        CGFloat magnitude = fabsf(scrollView.contentOffset.y / 60.0) ;
        if (magnitude > 1)
            magnitude = 1;
        self.view.backgroundColor = [UIColor colorWithWhite:.1 alpha:(1- magnitude)*.75];
    }else{
    }
    [[APP rootController].searchController.tableView setShouldAllowMovement:YES];
    CGPoint difPoint = CGPointMake(singleOffset.x-scrollView.contentOffset.x, singleOffset.y-scrollView.contentOffset.y);
    [[APP rootController].searchController.tableView setContentOffset:CGPointMake(listOffset.x-difPoint.x, listOffset.y-difPoint.y)];
    listOffset = [APP rootController].searchController.tableView.contentOffset;
    singleOffset = scrollView.contentOffset;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y <= - 60){
        if (!self.cameFromSearch){
          [[APP rootController] segueSingleToList];
        }else{
            [[APP rootController] segueSingleToSearch];
        }
    }
}


#pragma mark - TableView Delegate/DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isTransitioningTo){
        return 1;
    }
    NSInteger count = self.credentials.count;
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger adjustedRow = indexPath.row;
    NSString *object = [self stringForIndexPath:indexPath];
    if (adjustedRow == 0){
        static NSString *cellIdentifier = @"MyCell";
        RCTitleViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.textField.text = (NSString *)object;
        cell.textField.placeholder = @"Title";
        return cell;
    }else{
        static NSString * cellId = @"DropDownCell";
        RCDropDownCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
         [cell setTitle:object placeHolder:[self placeholderForIndexPath:indexPath]];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
        return TITLE_CELL_HEIGHT;
    return NORMAL_SINGLE_FINISHING_HEIGHT;
}


#pragma mark - Gesture Manager

-(BOOL)gestureManagerShouldAllowEditingAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

-(void)gestureManager:(RCCredentialGestureManager *)gestureManager needsNewRowAtIndexPath:(NSIndexPath *)indexPath
{
   
}

-(void)gestureManagerDidTapOutsideRows:(RCCredentialGestureManager *)manager
{
    if (!self.cameFromSearch){
        [self goBackToList];
    }
    else{
        [self goBackToSearch];
    }
}

-(BOOL)gestureManagerShouldAllowNewCellAtBottom:(RCCredentialGestureManager *)gestureManager
{
    return NO;
}

-(void)gestureManager:(RCCredentialGestureManager *)gestureManager didMoveToDeletionState:(BOOL)deletionState atIndexPath:(NSIndexPath *)indexPath
{
    if (deletionState){
        //deletionState
    }else{
        //no deletion state
    }
}

-(void)gestureManager:(RCCredentialGestureManager *)gestureManager needsDeletionAtIndexPath:(NSIndexPath *)indexPath
{
    
}


#pragma mark - State Updating/Handling

-(void)launchKeyboardIfNeeded
{
    if (self.credentials.count == 0 || (self.credentials.count > 0 && [self.credentials[0] isEqualToString:@""])){
        RCTitleViewCell * cell = (RCTitleViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [cell.textField becomeFirstResponder];
    }
}

-(void)publishChangesToPassword
{
    for (int i = 0; i < self.credentials.count; i++) {
        NSString * field = self.credentials[i];
        if (i == 0){
            self.password.title = field;
        }else if (i == 1){
            self.password.username = field;
        }else if (i == 2){
            self.password.password = field;
        }else if (i == 3){
            self.password.urlName = field;
        }else {
            self.password.notes = field;
        }
    }
    [[RCPasswordManager defaultManager] updatePassword:self.password];
    if (dataChanged && ![self textfieldsEmpty]){
        [[RCNetworking sharedNetwork] sync];
    }
}

-(void)setAllTextFieldDelegates
{
    NSInteger count = [self.tableView numberOfRowsInSection:0];
    self.textFields = [NSMutableArray new];
    for (int i = 0; i < count; i++) {
        NSIndexPath * path = [NSIndexPath indexPathForRow:i inSection:0];
        if (i == 0){
            RCTitleViewCell * cell = (RCTitleViewCell *)[self.tableView cellForRowAtIndexPath:path];
            [self.textFields addObject:cell.textField];
            cell.textField.delegate = self;
        }else{
            RCDropDownCell * cell= (RCDropDownCell *)[self.tableView cellForRowAtIndexPath:path];
            if (cell){
                [self.textFields addObject:cell.textField];
                cell.textField.delegate = self;
            }
        }
    }
}

-(void)goBackToList
{
    [self.view endEditing:YES];
    [self publishChangesToPassword];
    [[APP rootController] segueSingleToList];
}

-(void)goBackToSearch
{
    [self.view endEditing:YES];
    [self publishChangesToPassword];
    self.cameFromSearch = NO;
    [[APP rootController] segueSingleToSearch];
}

-(BOOL)passwordContainsNoData
{
    for (NSString * credential in self.credentials) {
        if (credential.length > 0)
            return NO;
    }
    return YES;
}


#pragma mark - Text Field Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger index = [self.textFields indexOfObject:textField];
     HTAutocompleteTextField * acTextfield = (HTAutocompleteTextField *)textField;
    if (index <= 2){
        if (index == 0){
            [self attemptToAutofillURLBasedOnTitleForTextField:acTextfield];
        }
        [self.textFields[index+1] becomeFirstResponder];
    }else{
        if (index == 3){
            [self appendURLSchemeIfNeededForTextField:acTextfield];
        }
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)attemptToAutofillURLBasedOnTitleForTextField:(HTAutocompleteTextField *)acTextField
{
    if ([self.credentials[3] length] == 0){
        NSString * typedText = [acTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString * actext = [acTextField.autocompleteLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString * finalText;
        if (actext.length >0){
            finalText = [NSString stringWithFormat:@"%@%@", typedText, actext];
        }else{
            finalText = typedText;
        }
        NSString * urlValue = [[[HTAutocompleteManager sharedManager] titleUrlPairs] objectForKey:finalText];
        if (urlValue && self.textFields.count > 3){
            [self.textFields[3] setText:urlValue];
            self.credentials[3] = urlValue;
        }
    }
}

- (void)appendURLSchemeIfNeededForTextField:(HTAutocompleteTextField *)textField
{
    NSString* urlString = textField.text;
    NSURL* url = [NSURL URLWithString:self.password.urlName];
    if(!url.scheme)
    {
        NSString* modifiedURLString = [NSString stringWithFormat:@"http://%@", urlString];
        self.password.urlName = modifiedURLString;
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    dataChanged = YES;
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.textFields[0]){
         [textField setFrame:CGRectMake(12, 0, 320, 60)];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    NSInteger index = [self.textFields indexOfObject:textField];
    if (index >= 0 && index < self.credentials.count){
         [self.credentials replaceObjectAtIndex:index withObject:textField.text];
    }
}


#pragma mark - Convenience

-(BOOL)textfieldsEmpty
{
    BOOL empty = YES;
    for (UITextField * tf in self.textFields) {
        if (tf.text.length > 0){
            empty = NO;
            break;
        }
    }
    return empty;
}

-(NSString *)stringForIndexPath:(NSIndexPath *)indexPath
{
    NSString * string;
    NSInteger adjustedRow = indexPath.row;
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
        case 1:
            return @"Email or Username";
            break;
        case 2:
            return @"Password";
            break;
        case 3:
            return @"URL";
            break;
        default:
            return [NSString stringWithFormat:@"Notes %d", indexPath.row];
            break;
    }
}


@end
