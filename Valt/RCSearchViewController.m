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

@interface RCSearchViewController ()

@property(nonatomic, strong) NSMutableArray * allTitles;
@property(nonatomic, strong) NSMutableArray * extraCells;
@property(nonatomic, strong) NSMutableArray * searchFilter;

@end

#define NORMAL_CELL_HEIGHT 60
#define ABOUT_NAME @"About"
#define ADD_CELL_PREFIX @"Add "
#define EMPTY_ADD_CELL @"Add \"\""
#define LOCK_NAME @"Lock your Vault"
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.extraCells = [@[ABOUT_NAME, LOCK_NAME, SPREAD_VAULT] mutableCopy];
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
    if (indexPath.row == 0){
        cell.textLabel.text = [NSString stringWithFormat:@"Add item titled \"%@\"", [APP rootController].searchBar.text];
    }
    else if (!self.searchFilter){
        cell.textLabel.text = self.extraCells[indexPath.row-1];
    }else{
        cell.textLabel.text = self.searchFilter[indexPath.row-1];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}





@end
