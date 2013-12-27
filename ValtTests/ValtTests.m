//
//  ValtTests.m
//  ValtTests
//
//  Created by Rob Caraway on 12/10/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCPasswordManager.h"

@interface ValtTests : XCTestCase

@property(nonatomic, strong) NSMutableArray * passwords;

@end

@implementation ValtTests

- (void)setUp
{
    [super setUp];
    self.passwords = [self generatedPasswordsWithPostfix:@"START"];
    [[RCPasswordManager defaultManager] grantPasswordAccess];
}


- (void)tearDown
{
    [[RCPasswordManager defaultManager] lockPasswords];
    self.passwords = nil;
    [super tearDown];
}

-(void)testLockPassword
{
    [[RCPasswordManager defaultManager] lockPasswords];
    XCTAssertNil([[RCPasswordManager defaultManager] passwords], @"Passwords still existed");
}

-(void)testReGrantAccess
{
    [[RCPasswordManager defaultManager] lockPasswords];
    [[RCPasswordManager defaultManager] grantPasswordAccess];
    XCTAssertNotNil([[RCPasswordManager defaultManager] passwords], @"Passwords didn't exist");
}


#pragma mark - Clear All Passwords

-(void)testAllPasswordsCleared
{
    [[RCPasswordManager defaultManager] addPasswords:self.passwords];
    [[RCPasswordManager defaultManager] clearAllPasswordData];
    XCTAssertTrue([[RCPasswordManager defaultManager] passwords].count == 0, @"Data uncleared");
}

#pragma mark - addPassword

-(void)testAddPassword
{
    [[RCPasswordManager defaultManager] clearAllPasswordData];
    [[RCPasswordManager defaultManager] addPassword:self.passwords[2]];
    XCTAssertTrue([[RCPasswordManager defaultManager] passwords].count == 1, @"Didn't Add Password");
    XCTAssertTrue([[[RCPasswordManager defaultManager] passwords][0] isEqual:self.passwords[2]], @"Didn't Add Right Password");
}

-(void)testManyPasswords
{
    [[RCPasswordManager defaultManager] clearAllPasswordData];
    for (RCPassword * password in self.passwords) {
        [[RCPasswordManager defaultManager] addPassword:password];
    }
    
}

#pragma mark - addPassword:atIndex

-(void)testAddAtIndexZero
{
    
}

-(void)testAddAtMaxIndex
{
    
}

-(void)testAddSeveralAtSameIndex
{
    
}


#pragma mark - addPasswords

-(void)testAddAFewPasswords
{
    
}

-(void)testAddManyPasswords
{
    
}

-(void)testAddingOver200Passwords
{
    
}


#pragma mark - Replacing Passwords

-(void)testReplaceAllPasswordsWith1
{
    
}

-(void)testReplaceAllPasswordsWithAFew
{
    
}

-(void)testReplaceAllPasswordsWithMany
{
    
}

#pragma mark - Remove Password

-(void)testRemoveSinglePassword
{
    
}

-(void)testRemoveAllPasswordsOneAtATime
{
    
}

-(void)testGracefulFailureOfRemovingInvalidPassword
{
    
}

#pragma mark - Remove Password At Index

-(void)testRemoveIndexZero
{
    
}

-(void)testRemoveLastIndex
{
    
}

-(void)testRemoveSeveralAtSameIndex
{
    
}

-(void)testRemovingInvalidIndex
{
    
}

#pragma mark - Move Password at index to index

-(void)testMoveIndexZeroToLast
{
    
}

-(void)testMoveIndexLastToZero
{
    
}

-(void)testRandomSwap
{
    
}

-(void)testSeveralRandomSwaps
{
    
}

#pragma mark - Password Saving

-(void)testMultipleSavesToKeychain
{
    
}

-(void)testRandomMutationSaves
{
    
}

#pragma mark - Convenience

-(NSMutableArray *)generatedPasswordsWithPostfix:(NSString *)postFix
{
    NSInteger count = 5;
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
