//
//  RCMenuViewController.m
//  Valt
//
//  Created by Rob Caraway on 1/24/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCAppDelegate.h"

#import "RCMenuViewController.h"
#import "RCRootViewController.h"
#import "RCAboutViewController.h"
#import "RCPurchaseViewController.h"


#import "RCRootViewController+passcodeSegues.h"
#import "RCRootViewController+menuSegues.h"
#import "UIImage+memoIcons.h"
#import "UIColor+RCColors.h"

#import "RCSearchBar.h"
#import "MLAlertView.h"

#import "RCNetworking.h"

#import <Social/Social.h>


#define CELL_HEIGHT 44;
#define HOME @"My Valt"
#define ABOUT_NAME @"About"
#define FEEDBACK @"Contact Support"
#define UPGRADE @"Go Platinum"
#define RENEW @"Renew Platinum"
#define SPREAD_VALT @"Tweet about Valt"



@interface RCMenuCell : UITableViewCell
@end

@implementation RCMenuCell


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (highlighted){
        UIColor * color;
        if ([self.textLabel.text isEqualToString:HOME]){
            color = [UIColor myValtColor];
        }else if ([self.textLabel.text isEqualToString:ABOUT_NAME]){
            color = [UIColor aboutColor];
        }else if ([self.textLabel.text isEqualToString:FEEDBACK]){
            color = [UIColor contactSupportColor];
        }else if ([self.textLabel.text isEqualToString:UPGRADE] || [self.textLabel.text isEqualToString:RENEW]){
            color = [UIColor goPlatinumColor];
        }else{
            color = [UIColor tweetColor];
        }
        [self highlightImageWithColor:color];
    }else{
        if ([self.textLabel.text isEqualToString:HOME]){
            self.imageView.image = [[UIImage imageNamed:@"valtSmall"] tintedIconWithColor:[UIColor myValtColor]];
        }else if ([self.textLabel.text isEqualToString:ABOUT_NAME]){
            self.imageView.image = [[UIImage imageNamed:@"about"] tintedIconWithColor:[UIColor aboutColor]];
        }else if ([self.textLabel.text isEqualToString:FEEDBACK]){
            self.imageView.image = [[UIImage imageNamed:@"support1"] tintedIconWithColor:[UIColor contactSupportColor]];
        }else if ([self.textLabel.text isEqualToString:UPGRADE] || [self.textLabel.text isEqualToString:RENEW]){
            self.imageView.image = [[UIImage imageNamed:@"up"] tintedIconWithColor:[UIColor goPlatinumColor]];
        }else{
            self.imageView.image = [[UIImage imageNamed:@"tweet"] tintedIconWithColor:[UIColor tweetColor]];
        }
    }
}

-(void)highlightImageWithColor:(UIColor *)color
{
    CGFloat red =0, blue = 0, green = 0, alpha = 0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    CGFloat hRed = fminf(red+.3, 1.0);
    CGFloat hGreen = fminf(green+.3, 1.0);
    CGFloat hBlue = fminf(blue+.3, 1.0);
    UIColor * highlight = [UIColor colorWithRed:hRed green:hGreen blue:hBlue alpha:1];
    self.imageView.image = [self.imageView.image tintedIconWithColor:highlight];
}

@end




@interface RCMenuViewController ()

@property(nonatomic, strong) SLComposeViewController * tweetController;
@property(nonatomic, strong) NSMutableArray * cellNames;
@property(nonatomic, strong) NSMutableArray * cellImages;

@end



@implementation RCMenuViewController

#pragma mark - View LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:.298 alpha:1];
    [self setupCellNames];
    [self setupCellImages];
    [self setupTableView];
    [self setupFeelgoodButton];
    [self setupSwitchLabel];
    [self setupCloseSwitch];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([RCNetworking sharedNetwork].premiumState == RCPremiumStateCurrent){
        NSInteger index = [self.cellNames indexOfObject:RENEW];
        if (index == NSNotFound){
            index = [self.cellNames indexOfObject:UPGRADE];
        }
        if (index != NSNotFound){
            [self.cellNames removeObjectAtIndex:index];
            [self.cellImages removeObjectAtIndex:index];
            [self.tableView reloadData];
        }
    }
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
    self.feelgoodButton = nil;
    self.cellImages = nil;
    self.cellNames = nil;
    self.tweetController = nil;
    self.view = nil;
}


#pragma mark - Table View Datasource Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cellNames.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = self.cellNames[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self handleTapForIndexPath:indexPath];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = self.view.backgroundColor;
    cell.imageView.image = self.cellImages[indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    if ([self.cellNames[indexPath.row] isEqualToString:UPGRADE] || [self.cellNames[indexPath.row] isEqualToString:RENEW]){
            UIInterpolatingMotionEffect *verticalMotionEffect =
            [[UIInterpolatingMotionEffect alloc]
             initWithKeyPath:@"center.y"
             type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
            verticalMotionEffect.minimumRelativeValue = @(-5);
            verticalMotionEffect.maximumRelativeValue = @(5);
            UIInterpolatingMotionEffect *horizontalMotionEffect =
            [[UIInterpolatingMotionEffect alloc]
             initWithKeyPath:@"center.x"
             type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
            horizontalMotionEffect.minimumRelativeValue = @(-5);
            horizontalMotionEffect.maximumRelativeValue = @(5);
            UIMotionEffectGroup *group = [UIMotionEffectGroup new];
            group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
            [cell.imageView addMotionEffect:group];
    }
}


#pragma mark - State Handling

-(void)launchTweetMessenger
{
    self.tweetController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [self.tweetController setInitialText:@"Check out this pasword keeper @getValt"];
    [[APP rootController] presentViewController:self.tweetController animated:YES completion:nil];
}

-(void)changeFeelgoodMessage
{
    NSString * string = [self randomizedFeelGoodMessage];
    [self.feelgoodButton setTitle:string forState:UIControlStateNormal];
}


#pragma mark - Event Handling

-(void)didTapFeelGood
{
    
}

-(void)handleTapForIndexPath:(NSIndexPath * )indexPath
{
    NSString * text = self.cellNames[indexPath.row];
    if ([text isEqualToString:HOME]){
        [[APP rootController] closeMenu];
    }
    else if ([text isEqualToString:ABOUT_NAME]){
        [[APP rootController] closeToNewViewController:[[APP rootController] aboutController] title:@"About" color:[UIColor aboutColor]];
    }else if ([text isEqualToString:UPGRADE]){
        [[APP rootController] closeToNewViewController:[[APP rootController] purchaseController] title:@"Go Platinum" color:[UIColor goPlatinumColor]];
    }else if ([text isEqualToString:RENEW]){
        [[APP rootController] closeToNewViewController:[[APP rootController] purchaseController] title:@"Renew Platinum" color:[UIColor goPlatinumColor]];
    }else if ([text isEqualToString:SPREAD_VALT]){
        [self launchTweetMessenger];
    }else if ([text isEqualToString:FEEDBACK]){
        [[APP rootController] launchFeedback];
    }
}


#pragma mark - Setup

-(void)setupCellNames
{
    self.cellNames = [@[HOME,ABOUT_NAME] mutableCopy];
    if ([RCNetworking sharedNetwork].premiumState == RCPremiumStateNone){
        [self.cellNames insertObject:UPGRADE atIndex:1];
    }else if ([RCNetworking sharedNetwork].premiumState == RCPremiumStateExpired){
        [self.cellNames insertObject:RENEW atIndex:1];
    }
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]){
        [self.cellNames addObject:SPREAD_VALT];
    }
    if ([[APP rootController] canSendFeedback]){
        [self.cellNames addObject:FEEDBACK];
    }
}

-(void)setupCellImages
{
    self.cellImages = [@[[[UIImage imageNamed:@"valtSmall"] tintedImageWithColorOverlay:[UIColor myValtColor]], [[UIImage imageNamed:@"about"] tintedIconWithColor:[UIColor aboutColor]]] mutableCopy];
    if ([RCNetworking sharedNetwork].premiumState != RCPremiumStateCurrent){
        [self.cellImages insertObject:[[UIImage imageNamed:@"up"] tintedIconWithColor:[UIColor goPlatinumColor]] atIndex:1];
    }
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]){
        [self.cellImages addObject:[[UIImage imageNamed:@"tweet"] tintedIconWithColor:[UIColor tweetColor]]];
    }
    if ([[APP rootController] canSendFeedback]){
        [self.cellImages addObject:[[UIImage imageNamed:@"support1"] tintedIconWithColor:[UIColor contactSupportColor]]];
    }
}

-(void)setupTableView
{
    self.tableView = [[UITableView  alloc] initWithFrame:CGRectMake(self.view.frame.size.width-280, 0, 280, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    [self.tableView setContentInset:UIEdgeInsetsMake(20, 0, 0, 0)];
    self.tableView.delegate = self;
    self.tableView.backgroundColor = self.view.backgroundColor;
    [self.tableView registerClass:[RCMenuCell class] forCellReuseIdentifier:@"Cell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableView];
}

-(void)setupFeelgoodButton
{
    self.feelgoodButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.feelgoodButton setFrame:CGRectMake(40, self.view.frame.size.height-30, self.view.frame.size.width-40, 30)];
    [self.feelgoodButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.feelgoodButton setTitle:[self randomizedFeelGoodMessage] forState:UIControlStateNormal];
    [self.feelgoodButton addTarget:self action:@selector(didTapFeelGood) forControlEvents:UIControlEventTouchUpInside];
    [self.feelgoodButton.titleLabel setFont:[UIFont fontWithName:@"Verdana" size:13]];
    [self.view addSubview:self.feelgoodButton];
}

-(void)setupCloseSwitch
{
    self.closeSwitch = [[UISwitch  alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.switchLabel.frame)+12, CGRectGetMinY(self.switchLabel.frame)-7, 100, 44)];
    [self.closeSwitch addTarget:self action:@selector(didSwitch) forControlEvents:UIControlEventValueChanged];
    [self.closeSwitch setOn:[APP locksOnClose] animated:NO];
    self.closeSwitch.onTintColor = [UIColor colorWithRed:.5 green:.7 blue:.5 alpha:1];
    [self.view addSubview:self.closeSwitch];
}

-(void)setupSwitchLabel
{
    UILabel * label = [[UILabel  alloc] initWithFrame:CGRectMake(90, self.view.frame.size.height-60, 120, 20)];
    [label setFont:[UIFont systemFontOfSize:18]];
    [label setNumberOfLines:1];
    [label setText:@"Lock on close:"];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor colorWithWhite:.5 alpha:1]];
    self.switchLabel = label;
    [self.view addSubview:self.switchLabel];
}

-(void)didSwitch
{
    if (!self.closeSwitch.isOn){
        [[[MLAlertView  alloc] initWithTitle:@"Be Careful" message:@"Keeping Valt open after leaving sacrifices security for convenience.  We recommend keeping a lock on your phone to reduce risk." cancelButtonTitle:@"Proceed" otherButtonTitles:nil] show];
    }
    [APP setLocksOnClose:self.closeSwitch.isOn];
}


#pragma mark - Convenience


-(NSString *)randomizedFeelGoodMessage
{
    NSArray * messages = @[@"Work with Purpose",
                           @"Good Software is Art",
                           @"Never Give Up",
                           @"You're excellent"];
    NSString * selection = messages[rand()%messages.count];
    return selection;
}



@end
