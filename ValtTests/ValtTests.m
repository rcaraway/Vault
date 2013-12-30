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
        XCTAssertTrue([[[RCPasswordManager defaultManager] passwords] containsObject:password], @"Contained passwords not exact");
    }
    [[RCPasswordManager defaultManager] lockPasswords];
    [[RCPasswordManager defaultManager] grantPasswordAccess];
    XCTAssertTrue([[RCPasswordManager defaultManager] passwords].count == self.passwords.count, @"Adding Several didn't all work");
}

#pragma mark - addPassword:atIndex

-(void)testAddAtIndexZero
{
    [[RCPasswordManager defaultManager] addPassword:self.passwords[2] atIndex:0];
    [[RCPasswordManager defaultManager] lockPasswords];
    [[RCPasswordManager defaultManager] grantPasswordAccess];
    XCTAssertTrue([[[RCPasswordManager defaultManager] passwords][0] isEqual:self.passwords[2]], @"Passwords wereren't equal after lock and regrant");
}

-(void)testAddAtMaxIndex
{
    NSInteger maxIndex = [[RCPasswordManager defaultManager] passwords].count;
    [[RCPasswordManager defaultManager]  addPassword:self.passwords[4] atIndex:maxIndex];
    [[RCPasswordManager defaultManager] lockPasswords];
    [[RCPasswordManager defaultManager] grantPasswordAccess];
    XCTAssertTrue([[[RCPasswordManager defaultManager] passwords][maxIndex] isEqual:self.passwords[4]], @"Adding at max index failed");
}

-(void)testAddSeveralAtSameIndex
{
    NSInteger currentCount = [[RCPasswordManager defaultManager] passwords].count;
    for (RCPassword * password in self.passwords) {
        [[RCPasswordManager defaultManager] addPassword:password atIndex:0];
    }
    [[RCPasswordManager defaultManager] lockPasswords];
    [[RCPasswordManager defaultManager] grantPasswordAccess];
    XCTAssertTrue([[RCPasswordManager defaultManager] passwords].count == self.passwords.count+currentCount, @"Didn't add them all");
    XCTAssertTrue([[[RCPasswordManager defaultManager] passwords] containsObject:self.passwords[4]], @"Didn't add them all correctly");
}

-(void)testAddFalseIndex
{
    [[RCPasswordManager defaultManager] clearAllPasswordData];
    for (RCPassword * password in self.passwords) {
        [[RCPasswordManager defaultManager] addPassword:password atIndex:2];
    }
    [[RCPasswordManager defaultManager] lockPasswords];
    [[RCPasswordManager defaultManager] grantPasswordAccess];
    XCTAssertTrue([[RCPasswordManager defaultManager] passwords].count == 0, @"Didn't add them all");
    XCTAssertFalse([[[RCPasswordManager defaultManager] passwords] containsObject:self.passwords[4]], @"Didn't add them all correctly");
}


#pragma mark - addPasswords

-(void)testAddAFewPasswords
{
    NSInteger currentCount = [[RCPasswordManager defaultManager] passwords].count;
    NSArray * subArray = [self.passwords subarrayWithRange:NSMakeRange(0, 2)];
    [[RCPasswordManager defaultManager] addPasswords:subArray];
    XCTAssertTrue([[RCPasswordManager defaultManager] passwords].count == currentCount+subArray.count, @"Didn't add them all");
    XCTAssertTrue([[[RCPasswordManager defaultManager] passwords] containsObject:subArray[1]], @"Didnt add them all");
}

-(void)testAddManyPasswords
{
    NSInteger currentCount = [[RCPasswordManager defaultManager] passwords].count;
    [[RCPasswordManager defaultManager] addPasswords:self.passwords];
    XCTAssertTrue([[RCPasswordManager defaultManager] passwords].count == currentCount+self.passwords.count, @"Didn't add them all");
    XCTAssertTrue([[[RCPasswordManager defaultManager] passwords] containsObject:self.passwords[4]], @"Didnt add them all");
}

-(void)testAddingOver200Passwords
{
    NSMutableArray * allpasswords = [NSMutableArray arrayWithCapacity:200];
    NSInteger currentCount = [[RCPasswordManager defaultManager] passwords].count;
    for (int i = 0; i < 40; i++) {
        NSMutableArray * passwords = [self generatedPasswordsWithPostfix:[NSString stringWithFormat:@"MANY%d", i]];
        [allpasswords addObjectsFromArray:passwords];
    }
    [[RCPasswordManager defaultManager] addPasswords:allpasswords];
    [[RCPasswordManager defaultManager] lockPasswords];
    [[RCPasswordManager defaultManager] grantPasswordAccess];
    XCTAssertTrue([[RCPasswordManager defaultManager] passwords].count == currentCount+allpasswords.count, @"Not all passwords added");
}


#pragma mark - Replacing Passwords

-(void)testReplaceAllPasswordsWith1
{
    RCPassword * password = self.passwords[2];
    [[RCPasswordManager defaultManager] replaceAllPasswordsWithPasswords:@[password]];
    [[RCPasswordManager defaultManager] lockPasswords];
    [[RCPasswordManager defaultManager] grantPasswordAccess];
    XCTAssertTrue([[RCPasswordManager defaultManager] passwords].count == 1, @"Didn't remove all passwords");
    XCTAssertTrue([[[RCPasswordManager defaultManager] passwords] containsObject:password], @"Didn't contain right password");
}

-(void)testReplaceAllPasswordsWithAFew
{
    NSArray * subarray = [self.passwords subarrayWithRange:NSMakeRange(0, 3)];
    [[RCPasswordManager defaultManager] replaceAllPasswordsWithPasswords:subarray];
    [[RCPasswordManager defaultManager] lockPasswords];
    [[RCPasswordManager defaultManager] grantPasswordAccess];
    XCTAssertTrue([[RCPasswordManager defaultManager] passwords].count == 3, @"Didn't remove all passwords");
    XCTAssertTrue([[[RCPasswordManager defaultManager] passwords] containsObject:subarray[0]], @"Didn't contain right password");
}

-(void)testReplaceAllPasswordsWithMany
{
    [[RCPasswordManager defaultManager] replaceAllPasswordsWithPasswords:self.passwords];
    [[RCPasswordManager defaultManager] lockPasswords];
    [[RCPasswordManager defaultManager] grantPasswordAccess];
    XCTAssertTrue([[RCPasswordManager defaultManager] passwords].count == self.passwords.count, @"Didn't remove all passwords");
    XCTAssertTrue([[[RCPasswordManager defaultManager] passwords] containsObject:self.passwords[3]], @"Didn't contain right password");
}

#pragma mark - Remove Password

-(void)testRemoveSinglePassword
{
    [[RCPasswordManager defaultManager] clearAllPasswordData];
    [[RCPasswordManager defaultManager] addPassword:self.passwords[0]];
    [[RCPasswordManager defaultManager] removePassword:self.passwords[0]];
    XCTAssertTrue([[RCPasswordManager defaultManager] passwords].count == 0, @"Removal didn't work");
}

-(void)testRemoveAllPasswordsOneAtATime
{
    [[RCPasswordManager defaultManager] clearAllPasswordData];
    [[RCPasswordManager defaultManager] addPasswords:self.passwords];
    NSArray * array = [NSArray arrayWithArray:[[RCPasswordManager defaultManager] passwords]];
    for (RCPassword * password in array) {
        [[RCPasswordManager defaultManager] removePassword:password];
    }
    XCTAssertTrue([[RCPasswordManager defaultManager] passwords].count == 0, @"Removal didn't work");
}

-(void)testRemovingInvalidPassword
{
    [[RCPasswordManager defaultManager] clearAllPasswordData];
    [[RCPasswordManager defaultManager] addPassword:self.passwords[0]];
    [[RCPasswordManager defaultManager] removePassword:self.passwords[1]];
    XCTAssertTrue([[RCPasswordManager defaultManager] passwords].count == 1, @"Invalid removal didn't work");

}

#pragma mark - Remove Password At Index

-(void)testRemoveIndexZero
{
    [[RCPasswordManager defaultManager] clearAllPasswordData];
    [[RCPasswordManager defaultManager] addPassword:self.passwords[0]];
    [[RCPasswordManager defaultManager] removePasswordAtIndex:0];
    XCTAssertTrue([[RCPasswordManager defaultManager] passwords].count == 0, @"Index Removal didn't work");
}

-(void)testRemoveLastIndex
{
    [[RCPasswordManager defaultManager] clearAllPasswordData];
    [[RCPasswordManager defaultManager] addPasswords:self.passwords];
    [[RCPasswordManager defaultManager] removePasswordAtIndex:self.passwords.count-1];
    XCTAssertTrue([[RCPasswordManager defaultManager] passwords].count == self.passwords.count-1, @"Index Removal didn't work");
}

-(void)testRemoveSeveralAtSameIndex
{
    [[RCPasswordManager defaultManager] clearAllPasswordData];
    [[RCPasswordManager defaultManager] addPasswords:self.passwords];
    [[RCPasswordManager defaultManager] removePasswordAtIndex:1];
    [[RCPasswordManager defaultManager] removePasswordAtIndex:1];
    [[RCPasswordManager defaultManager] removePasswordAtIndex:1];
    XCTAssertTrue([[RCPasswordManager defaultManager] passwords].count == self.passwords.count-3, @"Index Removal didn't work");
    XCTAssertTrue([[RCPasswordManager defaultManager] passwords][1] == self.passwords[4], @"DIdnt remove correct Passwords");
}

-(void)testRemovingInvalidIndex
{
    [[RCPasswordManager defaultManager] clearAllPasswordData];
    [[RCPasswordManager defaultManager] addPasswords:self.passwords];
    [[RCPasswordManager defaultManager] removePasswordAtIndex:self.passwords.count];
    XCTAssertTrue([[RCPasswordManager defaultManager] passwords].count == self.passwords.count, @"Invalid Index Removal didn't work");
}

#pragma mark - Update Password

-(void)testUpdatingPassword
{
    [[RCPasswordManager defaultManager] clearAllPasswordData];
    RCPassword * password = self.passwords[0];
    [[RCPasswordManager defaultManager] addPassword:password];
    password.urlName = @"ReplaceURLName.com";
    password.password = @"NewPassword1";
    password.username = @"New Username";
    [[RCPasswordManager defaultManager] updatePassword:password];
    [[RCPasswordManager defaultManager] lockPasswords];
    [[RCPasswordManager defaultManager] grantPasswordAccess];
    XCTAssertTrue([[RCPasswordManager defaultManager] passwords].count == 1 , @"Updating messed with count");
    XCTAssertTrue([[[[RCPasswordManager defaultManager] passwords][0] username] isEqualToString:@"New Username"], @"Username not updated");
    XCTAssertTrue([[[[RCPasswordManager defaultManager] passwords][0] password] isEqualToString:@"NewPassword1"], @"Password not updated");
    XCTAssertTrue([[[[RCPasswordManager defaultManager] passwords][0] urlName] isEqualToString:@"ReplaceURLName.com"], @"URL not updated");
}


#pragma mark - Move Password at index to index

-(void)testMoveIndexZeroToLast
{
    [[RCPasswordManager defaultManager] clearAllPasswordData];
    [[RCPasswordManager defaultManager] addPasswords:self.passwords];
    [[RCPasswordManager defaultManager] movePasswordAtIndex:0 toNewIndex:self.passwords.count-1];
    [[RCPasswordManager defaultManager] lockPasswords];
    [[RCPasswordManager defaultManager] grantPasswordAccess];
    XCTAssertTrue([[RCPasswordManager defaultManager] passwords].count == self.passwords.count, @"Exchange didn't work right");
    XCTAssertTrue([[[RCPasswordManager defaultManager] passwords][self.passwords.count-1] isEqual:self.passwords[0]], @"Exchange didn't work right");
}

-(void)testMoveIndexLastToZero
{
    [[RCPasswordManager defaultManager] clearAllPasswordData];
    [[RCPasswordManager defaultManager] addPasswords:self.passwords];
    [[RCPasswordManager defaultManager] movePasswordAtIndex:self.passwords.count-1 toNewIndex:0];
    [[RCPasswordManager defaultManager]lockPasswords];
    [[RCPasswordManager defaultManager] grantPasswordAccess];
    XCTAssertTrue([[RCPasswordManager defaultManager] passwords].count == self.passwords.count, @"Exchange didn't work right");
    XCTAssertTrue([[[RCPasswordManager defaultManager] passwords][0] isEqual:self.passwords[self.passwords.count-1]], @"Exchange didn't work right");
}

-(void)testRandomSwap
{
    NSInteger firstIndex = rand()%self.passwords.count;
    NSInteger secondIndex = rand()%self.passwords.count;
    [[RCPasswordManager defaultManager] clearAllPasswordData];
    [[RCPasswordManager defaultManager] addPasswords:self.passwords];
    [[RCPasswordManager defaultManager] movePasswordAtIndex:firstIndex toNewIndex:secondIndex];
    [[RCPasswordManager defaultManager]lockPasswords];
    [[RCPasswordManager defaultManager] grantPasswordAccess];
    XCTAssertTrue([[RCPasswordManager defaultManager] passwords].count == self.passwords.count, @"Exchange didn't work right");
    XCTAssertTrue([[[RCPasswordManager defaultManager] passwords][secondIndex] isEqual:self.passwords[firstIndex]], @"Exchange didn't work right");
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
