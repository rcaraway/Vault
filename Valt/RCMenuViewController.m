//
//  RCMenuViewController.m
//  Valt
//
//  Created by Rob Caraway on 1/24/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCMenuViewController.h"
#import "RCAppDelegate.h"
#import "RCRootViewController.h"

@interface RCMenuViewController ()

@end

@implementation RCMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor darkGrayColor];
}

-(void)setupTableView
{
    self.tableView = [[UITableView  alloc] initWithFrame:CGRectMake(40, 40, self.view.frame.size.height-40, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationNone;
}

@end
