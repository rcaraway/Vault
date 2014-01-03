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

#define RATE_APP_LINK @"itms-apps://itunes.apple.com/app/id791566527?at=10l6dK"

@interface RCAboutViewController ()

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.descriptionView.text = @"Valt is built to save you time and energy. \n\n\n"
    @"1. Simple: No feature bloat. Only what you need.\n\n"
    @"2. Fun: Password management is boring.  Valt is not.\n\n"
    @"3. Pay as needed: No massive fees. You choose to continue paying.\n\n"
    @"4. Legitimate Security: Valt uses best practices for safely storing your passwords.\n\n"
    @"Valt is NOT:\n\n"
    @"Robust: If you need advanced features, try 1Password.\n\n"
    @"Collaberative: Valt is meant for personal use.\n\n"
    @"And ALWAYS REMEMBER: No password software is uncrackable. Valt simply makes it much harder to crack.";
    self.descriptionView.editable = NO;
    [self.followRobButton addTarget:self action:@selector(followRobOnTwitter) forControlEvents:UIControlEventTouchUpInside];
    [self.doneButton setTarget:self];
    [self.feedbackButton setTitle:@"Rate Valt" forState:UIControlStateNormal];
    [self.feedbackButton addTarget:self action:@selector(rateValt) forControlEvents:UIControlEventTouchUpInside];
    [self.doneButton setAction:@selector(doneTapped)];
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

@end
