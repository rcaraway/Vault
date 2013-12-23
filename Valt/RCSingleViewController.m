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
#import "RCPassword.h"
#import "RCPasswordManager.h"
#import "RCDropDownCell.h"
#import "RCTitleViewCell.h"
#import "UIColor+RCColors.h"
#import "HTAutocompleteTextField.h"
#import "UIImage+memoIcons.h"
#import "RCAppDelegate.h"
#import "RCCredentialGestureManager.h"
#import "RCRootViewController.h"
#import "HTAutocompleteManager.h"

#define ADDING_CELL @"Continue..."
#define DONE_CELL @"Done"
#define DUMMY_CELL @"Dummy"
#define COMMITING_CREATE_CELL_HEIGHT 50
#define NORMAL_CELL_FINISHING_HEIGHT 50
#define TITLE_CELL_HEIGHT 60


@interface RCSingleViewController ()<RCCredentialGestureManagerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) RCCredentialGestureManager * gestureManager;
@property(nonatomic, strong) NSMutableArray * credentials;
@property(nonatomic, strong) NSMutableArray * textFields;
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


#pragma mark - View LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    self.gestureManager = [[RCCredentialGestureManager alloc] initWithTableView:self.tableView delegate:self];
    [self setupTableView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setAllTextFieldDelegates];
    [self launchKeyboardIfNeeded];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)willMoveToParentViewController:(UIViewController *)parent
{
    if (parent == [APP rootController]){
        RCRootViewController * rootVC = (RCRootViewController *)parent;
        [rootVC hideSearchAnimated:YES];
        [parent.view insertSubview:self.view belowSubview:rootVC.searchBar];
    }
}

-(void)didMoveToParentViewController:(UIViewController *)parent
{
    [self.view removeFromSuperview];
}

-(void)launchKeyboardIfNeeded
{
    if (self.credentials.count == 0 || (self.credentials.count > 0 && [self.credentials[0] isEqualToString:@""])){
        RCTitleViewCell * cell = (RCTitleViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [cell.textField becomeFirstResponder];
    }
}


#pragma mark - View Setup

-(void)setupTableView
{
    self.tableView.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    self.tableView.allowsSelection = NO;
    [self.tableView registerClass:[RCTitleViewCell class] forCellReuseIdentifier:@"MyCell"];
    [self.tableView registerClass:[RCDropDownCell class] forCellReuseIdentifier:@"DropDownCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = NORMAL_CELL_FINISHING_HEIGHT;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}


#pragma mark - TableView Delegate/DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = self.credentials.count;
    if (count < 5){
        count = 5;
        self.addCellIndex = 4;
    }else if (count == 6){
        self.addCellIndex = 5;
    }else{
        self.addCellIndex = NSNotFound;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger adjustedRow = indexPath.row;;
    NSString *object = [self stringForIndexPath:indexPath];
    if (adjustedRow == 0){
        static NSString *cellIdentifier = @"MyCell";
        RCTitleViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.textField.text = (NSString *)object;
        cell.textField.placeholder = @"Title";
        [cell setFocused];
        return cell;
    }else{
        static NSString * cellId = @"DropDownCell";
        RCDropDownCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
        if (indexPath.row == self.addCellIndex){
            [cell setAddMoreState];
        }else{
             [cell setTitle:object placeHolder:[self placeholderForIndexPath:indexPath]];
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
        return TITLE_CELL_HEIGHT;
    return NORMAL_CELL_FINISHING_HEIGHT;
}


#pragma mark - Gesture Manager

-(BOOL)gestureManagerShouldAllowEditingAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= 4){
        return YES;
    }
    return NO;
}

-(void)gestureManager:(RCCredentialGestureManager *)gestureManager needsNewRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.credentials addObject:@""];
}

-(void)gestureManagerDidTapOutsideRows:(RCCredentialGestureManager *)manager
{
    [self goBackToList];
}

-(BOOL)gestureManagerShouldAllowNewCellAtBottom:(RCCredentialGestureManager *)gestureManager
{
    if ([self.tableView numberOfRowsInSection:0] <= 6){
        return YES;
    }
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
        }else if (i == 3){
            self.password.urlName = field;
        }else {
            [extraFields addObject:field];
        }
    }
    self.password.extraFields = extraFields;
    [[RCPasswordManager defaultManager] commitPasswordToKeyChain:self.password];
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
            [self.textFields addObject:cell.textField];
            cell.textField.delegate = self;
        }
    }
}

-(void)goBackToList
{
    [self.view endEditing:YES];
   [self publishChangesToPassword];
    if ([self passwordContainsNoData]){
        [[APP rootController] returnToListAndRemovePassword:self.password];
    }else{
         [[APP rootController] returnToListFromSingle];
    }
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

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.textFields[0]){
         [textField setFrame:CGRectMake(12, 0, 320, 60)];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    NSInteger index = [self.textFields indexOfObject:textField];
    [self.credentials replaceObjectAtIndex:index withObject:textField.text];
}

#pragma mark - Table Convenience

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
            return [NSString stringWithFormat:@"More Notes %d", indexPath.row];
            break;
    }
}


@end
