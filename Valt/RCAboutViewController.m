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

@interface RCAboutViewController () <MFMailComposeViewControllerDelegate>

@property(nonatomic, strong) MFMailComposeViewController * mailController;

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
    self.descriptionView.text = @"Rob built an app that he would actually use. \n\n\n"
    @"1. Simplicity is King: No feature bloat.  Everything you need and nothing else.\n\n"
    @"2. Theatrical Design: Password management is boring.  Vault isn't.\n\n"
    @"3. Fair Pricing: 1 year's payment is less than a full meal. Pay only if you need it.\n\n"
    @"4. Legitimate Security: The standard for storing sensitivate data is Apple's Keychain.  Vault uses it.";
    self.descriptionView.editable = NO;
    [self.followRobButton addTarget:self action:@selector(followRobOnTwitter) forControlEvents:UIControlEventTouchUpInside];
    [self.feedbackButton addTarget:self action:@selector(launchMailController) forControlEvents:UIControlEventTouchUpInside];
    [self.doneButton setTarget:self];
    [self.doneButton setAction:@selector(doneTapped)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)doneTapped
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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

#pragma mark - Email

-(void)launchMailController
{
    if ([MFMailComposeViewController canSendMail]) {
        self.mailController = [[MFMailComposeViewController alloc] init];
        [self.mailController setSubject:@"Vault Feedback"];
        [self.mailController setToRecipients:@[@"rob@getvault.me"]];
        self.mailController.mailComposeDelegate = self;
        [self presentViewController:self.mailController animated:YES completion:nil];
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
