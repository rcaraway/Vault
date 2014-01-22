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
#import "RCNetworking.h"
#import "RCPassword.h"
#import "RCMainCell.h"
#import <Social/Social.h>
#import "RCSearchBar.h"
#import "RCRootViewController+passcodeSegues.h"
#import "RCRootViewController+searchSegue.h"


@interface RCSearchViewController ()

@property(nonatomic, strong) SLComposeViewController * tweetController;
@property(nonatomic, strong) NSMutableArray * allTitles;
@property(nonatomic, strong) NSMutableArray * extraCells;
@property(nonatomic, strong) NSMutableArray * searchFilter;

@end

#define NORMAL_CELL_HEIGHT 60
#define ABOUT_NAME @"About"
#define FEEDBACK @"Contact Support"
#define LOCK_NAME @"Lock your Valt"
#define SYNC_TO_ICLOUD @"Upgrade to Platinum"
#define SPREAD_VALT @"Tweet about Valt"

@implementation RCSearchViewController


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.extraCells = [@[SYNC_TO_ICLOUD, LOCK_NAME,ABOUT_NAME] mutableCopy];
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]){
        [self.extraCells addObject:SPREAD_VALT];
    }
    if ([[APP rootController] canSendFeedback]){
        [self.extraCells addObject:FEEDBACK];
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
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.tableView registerClass:[RCMainCell class] forCellReuseIdentifier:@"Cell"];
    self.tableView.rowHeight = NORMAL_CELL_HEIGHT;
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
        cell.customLabel.text = [NSString stringWithFormat:@"Add item titled \"%@\"", text];
    }
    else if (!self.searchFilter){
        cell.customLabel.text = text;
    }else{
        cell.customLabel.text = text;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * text = [self textForIndexPath:indexPath];
    if (indexPath.row == 0){
        RCPassword * password = [[RCPassword alloc] init];
        password.title = text;
        [[[APP rootController] searchBar] resignFirstResponder];
        [[RCPasswordManager defaultManager] addPassword:password];

        //TODO: segue;
    }else{
        if ([self.extraCells containsObject:text]){
            if ([text isEqualToString:ABOUT_NAME]){
                [[APP rootController] launchAbout];
            }else if ([text isEqualToString:SYNC_TO_ICLOUD]){
                if ([[RCNetworking sharedNetwork] premiumState] == RCPremiumStateCurrent){
                    [[RCNetworking sharedNetwork] fetchFromServer];
                }else{
                    [[APP rootController] launchPurchaseScreen];
                }
            }else if ([text isEqualToString:SPREAD_VALT]){
                [self launchTweetMessenger];
            }else if ([text isEqualToString:LOCK_NAME]){
                [[[APP rootController] searchBar] setShowsCancelButton:NO];
                [[APP rootController] returnToPasscodeFromSearch];
            }else if ([text isEqualToString:FEEDBACK]){
                [[APP rootController] launchFeedback];
            }
        }else{
            RCPassword * password = [[RCPasswordManager defaultManager] passwordForTitle:text];
            //TODO: segue
        }
    }
}


#pragma mark - State Handling

-(void)launchTweetMessenger
{
    self.tweetController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [self.tweetController setInitialText:@"Found a great password keeper for iPhone. @getValt"];
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
