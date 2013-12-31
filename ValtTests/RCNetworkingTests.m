//
//  RCNetworkingTests.m
//  Valt
//
//  Created by Rob Caraway on 12/26/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCPasswordManager.h"
#import "RCNetworking.h"
#import "NSString+Encryption.h"

#define DEMO_ACCOUNT_USERNAME @"demo@demoaccount.ct"
#define DEMO_ACCOUNT_PASSWORD @"112989"

@interface RCNetworkingTests : XCTestCase

@property(nonatomic) BOOL shouldStop;
@property(nonatomic, strong) NSMutableArray * passwords;

@end

@implementation RCNetworkingTests

- (void)setUp
{
    [super setUp];
    self.passwords = [self generatedPasswords];
    [self addNotifications];
}

- (void)tearDown
{
    [super tearDown];
    self.passwords = nil;
    [self removeNotifications];
}


#pragma mark - Log in

-(void)testALogin
{
    self.shouldStop = NO;
    NSDate * untilDate;
    [[RCNetworking sharedNetwork] loginWithEmail:DEMO_ACCOUNT_USERNAME password:DEMO_ACCOUNT_PASSWORD];
    while (!self.shouldStop) {
        untilDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
        [[NSRunLoop currentRunLoop] runUntilDate:untilDate];
    }
    XCTAssertTrue([[RCNetworking sharedNetwork] loggedIn], @"Didn't log in");
}

-(void)testASync
{
    [[RCPasswordManager defaultManager] clearAllPasswordData];
    [[RCPasswordManager defaultManager] addPasswords:self.passwords];
    self.shouldStop = NO;
    NSDate * untilDate;
    [[RCNetworking sharedNetwork] sync];
    while (!self.shouldStop) {
        untilDate = [NSDate dateWithTimeIntervalSinceNow:0.3];
        [[NSRunLoop currentRunLoop] runUntilDate:untilDate];
    }
    XCTAssertTrue([[RCNetworking sharedNetwork] loggedIn], @"Not logged in");
}

-(void)testFetch
{
    self.shouldStop = NO;
    NSDate * untilDate;
    [[RCNetworking sharedNetwork] fetchFromServer];
    while (!self.shouldStop) {
       untilDate = [NSDate dateWithTimeIntervalSinceNow:0.3];
        [[NSRunLoop currentRunLoop] runUntilDate:untilDate];
    }
    XCTAssertTrue([[RCNetworking sharedNetwork] loggedIn], @"Didn't log in");
}



#pragma mark - Responses


-(void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin) name:networkingDidLogin object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailLogin) name:networkingDidFailToLogin object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSync) name:networkingDidSync object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailSync) name:networkingDidFailToSync object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFetch) name:networkingDidFetchCredentials object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailFetch) name:networkingDidFailToFetchCredentials object:nil];
}

-(void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)didLogin
{
    self.shouldStop = YES;
}

-(void)didFailLogin
{
    XCTAssertTrue(NO, @"Failed Login");
}

-(void)didSync
{
    self.shouldStop = YES;
}

-(void)didFailSync
{
    XCTAssertTrue(NO, @"Failed Sync");
}

-(void)didFetch
{
    self.shouldStop = YES;
}

-(void)didFailFetch
{
    XCTAssertTrue(NO, @"Failed Fetch");
}

-(void)didMerge:(NSNotification *)notification
{
    self.shouldStop = YES;
}

-(void)didFailMerge
{
    XCTAssertTrue(NO, @"Failed Merge");
}


#pragma mark - Convenience

-(NSMutableArray *)generatedPasswords
{
    NSString * postFix = [NSString randomString];
    NSInteger count = rand() % 8;
    NSMutableArray * array = [NSMutableArray new];
    for (int i = 0; i < count; i++) {
        RCPassword * password = [[RCPassword  alloc] init];
        password.title= [NSString stringWithFormat:@"Title%@%d", postFix, i];
        password.username = [NSString stringWithFormat:@"username%@%d", postFix, i];
        password.password = [NSString stringWithFormat:@"password%@%d", postFix, i];
        password.urlName = [NSString stringWithFormat:@"http://www.urlname%@%d.com", postFix, i];
        password.extraFields = [@[[NSString stringWithFormat:@"extraField%@%d", postFix, i]] mutableCopy];
        [array addObject:password];
    }
    return array;
}


@end
