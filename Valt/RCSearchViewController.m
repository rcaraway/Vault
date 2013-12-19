//
//  RCSearchViewController.m
//  Valt
//
//  Created by Robert Caraway on 12/17/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCSearchViewController.h"
#import "RCPasswordManager.h"
#import "RCRootViewController.h"
#import "RCAppDelegate.h"
#import "RCPassword.h"
#import "RCMainCell.h"
#import <Social/Social.h>

@interface RCSearchViewController ()

@property(nonatomic, strong) SLComposeViewController * tweetController;
@property(nonatomic, strong) NSMutableArray * allTitles;
@property(nonatomic, strong) NSMutableArray * extraCells;
@property(nonatomic, strong) NSMutableArray * searchFilter;

@end

#define NORMAL_CELL_HEIGHT 60
#define ABOUT_NAME @"About"
#define ADD_CELL_PREFIX @"Add "
#define EMPTY_ADD_CELL @"Add \"\""
#define LOCK_NAME @"Lock your Vault"
#define SYNC_TO_ICLOUD @"Sync to iCloud"
#define SPREAD_VAULT @"Tweet about Vault"

@implementation RCSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]){
        self.extraCells = [@[SYNC_TO_ICLOUD, LOCK_NAME, SPREAD_VAULT,ABOUT_NAME] mutableCopy];
    }else{
        self.extraCells = [@[SYNC_TO_ICLOUD, LOCK_NAME, ABOUT_NAME] mutableCopy];
    }
    self.allTitles = [[[RCPasswordManager defaultManager] allTitles] mutableCopy];
    [self setupTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)setupTableView
{
    self.tableView.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    [self.tableView registerClass:[RCMainCell class] forCellReuseIdentifier:@"Cell"];
    self.tableView.rowHeight = NORMAL_CELL_HEIGHT;
}



#pragma mark - Transitions

-(void)willMoveToParentViewController:(UIViewController *)parent
{
    if (parent == [APP rootController]){
        RCRootViewController * rootVc = (RCRootViewController *)parent;
        [rootVc showSearchAnimated:YES];
        [self.view setFrame:CGRectMake(0, 64, 320, [UIScreen mainScreen].bounds.size.height-64)];
        [rootVc.view insertSubview:self.view belowSubview:rootVc.searchBar];
    }
}

-(void)didMoveToParentViewController:(UIViewController *)parent
{
    [self.view removeFromSuperview];
}



#pragma mark - Tableview

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.searchFilter){
        return self.extraCells.count+1;
    }
    return self.searchFilter.count+1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RCMainCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSString * text = [self textForIndexPath:indexPath];
    if (indexPath.row == 0){
        cell.textLabel.text = [NSString stringWithFormat:@"Add item titled \"%@\"", text];
    }
    else if (!self.searchFilter){
        cell.textLabel.text = text;
    }else{
        cell.textLabel.text = text;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * text = [self textForIndexPath:indexPath];
    if (indexPath == 0){
        RCPassword * password = [[RCPassword alloc] init];
        password.title = text;
        [[APP rootController] moveFromSearchToSingleWithPassword:password];
    }else{
        if ([self.extraCells containsObject:text]){
            if ([text isEqualToString:ABOUT_NAME]){
                [[APP rootController] launchAbout];
            }else if ([text isEqualToString:SYNC_TO_ICLOUD]){
                [[APP rootController] launchPurchaseScreen];
            }else if ([text isEqualToString:SPREAD_VAULT]){
                [self launchTweetMessenger];
            }else if ([text isEqualToString:LOCK_NAME]){
                [[[APP rootController] searchBar] setShowsCancelButton:NO];
                [[APP rootController] returnToPasscode];
            }
        }else{
            RCPassword * password = [[RCPasswordManager defaultManager] passwordForTitle:text];
            [[APP rootController] moveFromSearchToSingleWithPassword:password];
        }
    }
}


#pragma mark - State Handling

-(void)launchTweetMessenger
{
    self.tweetController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [self.tweetController setInitialText:@"Securely login anywhere on the fly! @getVault"];
    [[APP rootController] presentViewController:self.tweetController animated:YES completion:nil];
}

#pragma mark - Convenience

-(NSString *)textForIndexPath:(NSIndexPath *)indexPath
{
    NSString * text;
    if (indexPath.row == 0){
        text = [APP rootController].searchBar.text;
    }
    else if (!self.searchFilter){
        text = self.extraCells[indexPath.row-1];
    }else{
        text = self.searchFilter[indexPath.row-1];
    }
    return text;
}

-(void)filterSearchWithText:(NSString *)filterstring
{
    if (filterstring.length > 0){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSMutableArray * allTitles =  [NSMutableArray arrayWithArray:[[RCPasswordManager defaultManager] allTitles]];
            [allTitles addObjectsFromArray:self.extraCells];
            NSPredicate * predicate= [NSPredicate predicateWithFormat:@"self beginswith[c] %@", filterstring];
            [allTitles filterUsingPredicate:predicate];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.searchFilter = allTitles;
                [self.tableView reloadData];
            });
        });
    }else{
        self.searchFilter = nil;
        [self.tableView reloadData];
    }
}


@end
