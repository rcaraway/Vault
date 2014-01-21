//
//  RCAboutViewController.m
//  Valt
//
//  Created by Robert Caraway on 12/19/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCAboutViewController.h"
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "UIView+QuartzEffects.h"
#import "UIColor+RCColors.h"

#define RATE_APP_LINK @"itms-apps://itunes.apple.com/app/id791566527?at=10l6dK"

@interface RCAboutViewController () <UIScrollViewDelegate>


@end

@implementation RCAboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [self init];
    if (self) {
    }
    return self;
}

-(id)init
{
    self = [super initWithNibName:@"AboutController" bundle:nil];
    if (self){
        
    }
    return self;
}

-(void)viewDidLayoutSubviews
{
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width*2, self.scrollView.frame.size.height);
    self.scrollView.pagingEnabled = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.websiteButton setCornerRadius:5];
    self.scrollView.delegate =self;
    self.pageControl.pageIndicatorTintColor = [UIColor colorWithRed:230.0/255.0 green:203.0/255.0 blue:255.0/255.0 alpha:1];
    self.pageControl.numberOfPages = 2;
    [self.pageControl addTarget:self action:@selector(pageChanged) forControlEvents:UIControlEventValueChanged];
    [self.blogButton setCornerRadius:5];
    [self.licensesButton setCornerRadius:5];
    self.descriptionView.backgroundColor = [UIColor clearColor];
    [self.bannerView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"checker.jpg"]]];
    [self setupBannerButtons];
    self.descriptionView.text = @"Valt is simple. No feature bloat. Only what you need. \n\n"
    @"It's fun. Password management is boring.  Valt is not.\n\n"
    @"Pay as you go. Pay a fair price when needed.  No big fees ever. \n\n"
    @"Legit security. Valt uses best practices to secure your data.";
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:self.descriptionView.text];
    [string addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]} range:[self.descriptionView.text rangeOfString:self.descriptionView.text]];
    [string addAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:16]} range:[self.descriptionView.text rangeOfString:@"Valt is simple."]];
    [string addAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:16]} range:[self.descriptionView.text rangeOfString:@"It's fun."]];
    [string addAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:16]} range:[self.descriptionView.text rangeOfString:@"Pay as you go."]];
    [string addAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:16]} range:[self.descriptionView.text rangeOfString:@"Legit security"]];
    self.descriptionView.attributedText =string;
    self.descriptionView.editable = NO;
    [self.followRobButton addTarget:self action:@selector(followRobOnTwitter) forControlEvents:UIControlEventTouchUpInside];
    [self.doneButton setTarget:self];
    [self.feedbackButton setTitle:@"Rate Valt" forState:UIControlStateNormal];
    [self.feedbackButton addTarget:self action:@selector(rateValt) forControlEvents:UIControlEventTouchUpInside];
    [self.doneButton setAction:@selector(doneTapped)];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.scrollView.contentOffset.x == 0){
        [self.pageControl setCurrentPage:0];
    }else{
        [self.pageControl setCurrentPage:1];
    }
}

-(void)pageChanged
{
    if (self.pageControl.currentPage == 0){
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }else{
        [self.scrollView setContentOffset:CGPointMake(320, 0) animated:YES];
    }
}

-(void)setupBannerButtons
{
    [self.feedbackButton setCornerRadius:5];
    [self.followRobButton setCornerRadius:5];
    [[self.feedbackButton layer] setBorderWidth:2.0f];
    [[self.feedbackButton layer] setBorderColor:[UIColor colorWithRed:253/255.0 green:246/255.0 blue:146/255.0 alpha:1].CGColor];
    [[self.followRobButton layer] setBorderWidth:2.0f];
    [[self.followRobButton layer]setBorderColor:[UIColor colorWithRed:253/255.0 green:246/255.0 blue:146/255.0 alpha:1].CGColor];
    [self addMotionEffects];
}

-(void)addMotionEffects
{
    UIInterpolatingMotionEffect *verticalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.y"
     type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(-10);
    verticalMotionEffect.maximumRelativeValue = @(10);
    UIInterpolatingMotionEffect *horizontalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.x"
     type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(-10);
    horizontalMotionEffect.maximumRelativeValue = @(10);
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    [self.feedbackButton addMotionEffect:group];
    [self.followRobButton addMotionEffect:group];
}

-(BOOL)shouldAutorotate
{
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)doneTapped
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


-(void)rateValt
{
    NSString * url = RATE_APP_LINK;
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
}

#pragma mark - Twitter Follow

-(void)followRobOnTwitter
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if(granted) {
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            if ([accountsArray count] > 0) {
                ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
                [tempDict setValue:@"TheCaraway" forKey:@"screen_name"];
                [tempDict setValue:@"true" forKey:@"follow"];
                NSLog(@"*******tempDict %@*******",tempDict);
                SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:@"https://api.twitter.com/1/friendships/create.json"] parameters:tempDict];
                [postRequest setAccount:twitterAccount];
                [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    if (!error){
                        
                    }else{
                        NSString *output = [NSString stringWithFormat:@"HTTP response status: %i Error %d", [urlResponse statusCode],error.code];
                        NSLog(@"%@error %@", output,error.description);
                    }
                }];
            }
            
        }
    }];
}

- (IBAction)tappedWebsite:(id)sender
{
    NSString * url = @"http://getvalt.com";
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
}

- (IBAction)tappedBlog:(id)sender {
    NSString * url = @"http://robcaraway.com";
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
}

- (IBAction)tappedLicenses:(id)sender
{
    NSString * url = @"http://getvalt.com/licenses";
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
}
@end
