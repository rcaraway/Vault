//
//  RCAboutViewController.m
//  Valt
//
//  Created by Robert Caraway on 12/19/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCAboutViewController.h"

#import "RCAppDelegate.h"

//Frameworks
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

//Categories
#import "UIView+QuartzEffects.h"
#import "UIColor+RCColors.h"
#import "RCRootViewController+menuSegues.h"
#import "UIImage+memoIcons.h"

//VC
#import "RCRootViewController.h"


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
    if (IS_IPHONE){
         self = [super initWithNibName:@"AboutController" bundle:nil];
    }else{
         self = [super initWithNibName:@"AboutControllerIpad" bundle:nil];
    }
    if (self){
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64)];
    [self.websiteButton setCornerRadius:5];
   [self.blogButton setCornerRadius:5];
    [self.licensesButton setCornerRadius:5];
    [self.bannerView setBackgroundColor:[UIColor colorWithPatternImage:[[UIImage imageNamed:@"checker.jpg"] tintedImageWithColorOverlay:[UIColor colorWithRed:0 green:.4 blue:.39 alpha:1]]]];
    [self setupBannerButtons];
}

-(BOOL)shouldAutorotate
{
    return NO;
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
    self.titleLabel = nil;
    self.followRobButton = nil;
    self.feedbackButton = nil;
    self.bannerView = nil;
    self.robLabel = nil;
    self.blogButton = nil;
    self.websiteButton = nil;
    self.blogButton = nil;
    self.licensesButton = nil;
    self.thankyouButton = nil;
    self.versionLabel = nil;
    self.view = nil;
}



#pragma mark - Setup

-(void)setupBannerButtons
{
    [self.feedbackButton setCornerRadius:5];
    [self.followRobButton setCornerRadius:5];
    [[self.feedbackButton layer] setBorderWidth:2.0f];
    [[self.feedbackButton layer] setBorderColor:[UIColor colorWithRed:253/255.0 green:246/255.0 blue:146/255.0 alpha:1].CGColor];
    [[self.followRobButton layer] setBorderWidth:2.0f];
    [[self.followRobButton layer]setBorderColor:[UIColor colorWithRed:253/255.0 green:246/255.0 blue:146/255.0 alpha:1].CGColor];
    [self addMotionEffects];
    [self.followRobButton addTarget:self action:@selector(followRobOnTwitter) forControlEvents:UIControlEventTouchUpInside];
    [self.feedbackButton setTitle:@"Rate Valt" forState:UIControlStateNormal];
    [self.feedbackButton addTarget:self action:@selector(rateValt) forControlEvents:UIControlEventTouchUpInside];

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




#pragma mark - State Handling

-(void)rateValt
{
    NSString * url = RATE_APP_LINK;
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
}



#pragma mark - Event Handling

-(void)doneTapped
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didPan:(UIPanGestureRecognizer *)sender
{
    CGFloat translation =[sender translationInView:self.view].x;
    if (sender.state == UIGestureRecognizerStateBegan){
        [[APP rootController] beginDragToMenu];
    }else if (sender.state == UIGestureRecognizerStateChanged){
        
        if (translation <= 20){
             [[APP rootController] dragSideToXOrigin:translation];
        }
    }else if (sender.state == UIGestureRecognizerStateEnded){
        CGFloat velocity = [sender velocityInView:self.view].x;
        if (velocity <= -180.0 || translation <= -160.0){
            [[APP rootController] finishDragWithSegue];
        }else{
            [[APP rootController] finishDragWithClose];
        }
    }
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
                [tempDict setValue:@"GetValt" forKey:@"screen_name"];
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
@end
