//
//  RCSearchViewController.m
//  Valt
//
//  Created by Robert Caraway on 12/17/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

//VC
#import "RCAppDelegate.h"
#import "RCSearchViewController.h"
#import "RCRootViewController.h"

//Model
#import "RCNetworking.h"
#import "RCPassword.h"
#import "RCPasswordManager.h"

//Views
#import "RCMainCell.h"
#import "RCSearchBar.h"

//Categories
#import "RCRootViewController+passcodeSegues.h"
#import "RCRootViewController+searchSegue.h"


@interface RCSearchViewController ()<RCSearchBarDelegate>

@property(nonatomic, strong) NSMutableArray * allTitles;
@property(nonatomic, strong) NSMutableArray * searchFilter;

@end

#define NORMAL_CELL_HEIGHT 60


@implementation RCSearchViewController


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.allTitles = [[[RCPasswordManager defaultManager] allTitles] mutableCopy];
    [self setupTableView];
    [self setupSearchBar];
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
    self.searchFilter = nil;
    self.allTitles = nil;
    self.view = nil;
}

-(void)setupTableView
{
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.tableView registerClass:[RCMainCell class] forCellReuseIdentifier:@"Cell"];
    self.tableView.rowHeight = NORMAL_CELL_HEIGHT;
    self.tableView.tableFooterView = [[UIView  alloc] initWithFrame:CGRectZero];
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
        return 0;
    }
    return self.searchFilter.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RCMainCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSString * text = [self textForIndexPath:indexPath];
    cell.customLabel.text = text;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * text = [self textForIndexPath:indexPath];
    RCPassword * password = [[RCPasswordManager defaultManager] passwordForTitle:text];
    [[APP rootController] segueSearchToSingleWithPassword:password indexPath:indexPath];
}


#pragma mark - SearchBar

-(void)setupSearchBar
{
    self.searchBar = [[RCSearchBar  alloc] initWithFrame:CGRectMake(0, 20, 320, 44)];
    self.searchBar.delegate =self;
    [self.view addSubview:self.searchBar];
}

-(void)searchBarDidBeginEditing:(RCSearchBar *)searchBar
{
    
}

-(void)searchBarDidEndEditing:(RCSearchBar *)searchBar
{
    
}

-(void)searchBar:(RCSearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self filterSearchWithText:searchText];
}

-(void)searchBarCancelTapped:(RCSearchBar *)searchBar
{
    [self.view endEditing:YES];
    [[APP rootController] segueSearchToList];
}


#pragma mark - Convenience

-(NSString *)textForIndexPath:(NSIndexPath *)indexPath
{
    NSString * text;
    if (self.searchFilter && indexPath.row < self.searchFilter.count){
        text = self.searchFilter[indexPath.row];
    }
    return text;
}

-(void)filterSearchWithText:(NSString *)filterstring
{
    if (filterstring.length > 0){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSMutableArray * allTitles =  [NSMutableArray arrayWithArray:[[RCPasswordManager defaultManager] allTitles]];
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
