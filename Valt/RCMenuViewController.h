//
//  RCMenuViewController.h
//  Valt
//
//  Created by Rob Caraway on 1/24/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCViewController.h"

@interface RCMenuViewController : RCViewController <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) UITableView * tableView;
@property(nonatomic, strong) UIButton * feelgoodButton;
@property(nonatomic, strong) UILabel * hiddenLabel;
@property(nonatomic, strong) UISwitch * closeSwitch;
@property(nonatomic, strong) UILabel * switchLabel;

-(void)changeFeelgoodMessage;


@end
