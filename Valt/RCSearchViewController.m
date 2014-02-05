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
#import "RCSearchGestureManager.h"

//Views
#import "RCMainCell.h"
#import "RCSearchBar.h"
#import "RCTableView.h"

//Categories
#import "UIColor+RCColors.h"
#import "RCRootViewController+passcodeSegues.h"
#import "RCRootViewController+searchSegue.h"
#import "RCRootViewController+WebSegues.h"


@interface RCSearchViewController ()<RCSearchBarDelegate, RCSearchGestureManagerDelegate>

@property(nonatomic, strong) NSMutableArray * allTitles;
@property(nonatomic, strong) NSMutableArray * searchFilter;

@end




@implementation RCSearchViewController


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.allTitles = [[[RCPasswordManager defaultManager] allTitles] mutableCopy];
    [self setupTableView];
    [self setupSearchBar];
    [self setupGestureManager];
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
    self.tableView = [[RCTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.tableView.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    self.tableView.allowsSelection = NO;
    [self.tableView setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.alpha = 1;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor listBackground];
    self.tableView.dataSource = self;
    [self.tableView registerClass:[RCMainCell class] forCellReuseIdentifier:@"Cell"];
    self.tableView.separatorColor = [UIColor colorWithWhite:.8 alpha:1];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setContentOffset:CGPointMake(0, -64)];
    [self.view addSubview:self.tableView];
}

-(void)setupGestureManager
{
    self.gestureManager = [[RCSearchGestureManager alloc] initWithTableView:self.tableView delegate:self];
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
    if (self.viewPath){
        return self.searchFilter.count+1;
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:self.viewPath]){
        return 188;
    }
    return NORMAL_CELL_FINISHING_HEIGHT;
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


#pragma mark - Gesture Manager

-(void)gestureManager:(RCSearchGestureManager *)manager didTapRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * text = [self textForIndexPath:indexPath];
    RCPassword * password = [[RCPasswordManager defaultManager] passwordForTitle:text];
    [[APP rootController] segueSearchToSingleWithPassword:password indexPath:indexPath];
}

-(void)gestureManager:(RCSearchGestureManager *)manager didChangeToWebState:(BOOL)webState forIndexPath:(NSIndexPath *)indexPath
{
    RCMainCell * cell = (RCMainCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (webState){
        [cell setGreenColored];
    }else{
        [cell setNormalColored];
    }
}

-(void)gestureManagerDidFinishWithWebState:(RCSearchGestureManager *)manager atIndexPath:(NSIndexPath *)indexPath
{
    NSString * text = [self textForIndexPath:indexPath];
    RCPassword * password = [[RCPasswordManager defaultManager] passwordForTitle:text];
    self.gestureManager.webPath = indexPath;
    [[APP rootController] segueToWebWithPassword:password];
}


#pragma mark - Convenience

-(NSString *)textForIndexPath:(NSIndexPath *)indexPath
{
    NSString * text;
    if (self.searchFilter && indexPath.row < self.searchFilter.count){
        if (self.viewPath){
            if (indexPath.row < self.viewPath.row){
                text = self.searchFilter[indexPath.row];
            }else if (indexPath.row > self.viewPath.row){
                text = self.searchFilter[indexPath.row-1];
            }else return nil;
        }else{
            text = self.searchFilter[indexPath.row];
        }
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
