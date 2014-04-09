//
//  RCNotesViewController.m
//  Valt
//
//  Created by Robert Caraway on 4/9/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCNotesViewController.h"

@interface RCNotesViewController ()

@end

@implementation RCNotesViewController


-(id)init
{
    self = [super initWithNibName:@"RCNotesViewController" bundle:nil];
    if (self){
        
    }
    return self;
}


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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)infoTapped:(UIButton *)sender {
}

- (IBAction)autoFillTapped:(UIButton *)sender {
}
@end
