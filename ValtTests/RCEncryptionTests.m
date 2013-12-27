//
//  RCEncryptionTests.m
//  Valt
//
//  Created by Rob Caraway on 12/26/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+Encryption.h"
#import "RCPassword.h"
#import "RCPasswordManager.h"

@interface RCEncryptionTests : XCTestCase

@property(nonatomic, strong) RCPassword * password;

@end

@implementation RCEncryptionTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}
-(void)testBasicStringCryptographyShort
{
    NSString * string = @"shorty";
    NSString * key = [NSString randomString];
    NSString * encrypted = [string stringByEncryptingWithKey:key];
    NSString * decrypted = [encrypted stringByDecryptingWithKey:key];
    XCTAssertTrue([string isEqualToString:decrypted], @"Short Cryptography Failed not working");
}

-(void)testBasicStringCryptographyMedium
{
    NSString * string = @"mediumLengthString";
    NSString * key = [NSString randomString];
    NSString * encrypted = [string stringByEncryptingWithKey:key];
    NSString * decrypted = [encrypted stringByDecryptingWithKey:key];
    XCTAssertTrue([string isEqualToString:decrypted], @"Medium Cryptography Failed ");
}

-(void)testBasicStringCryptographyLarge
{
    NSString * string = @"reallyLongStringIsPrettyDarnLongDontYouThink.yes/TestHardForLife";
    NSString * key = [NSString randomString];
    NSString * encrypted = [string stringByEncryptingWithKey:key];
    NSString * decrypted = [encrypted stringByDecryptingWithKey:key];
    NSLog(@"ENCRYPTED %@ DECRYPTED %@", encrypted, decrypted);
    XCTAssertTrue([string isEqualToString:decrypted], @"Long Cryptography Failed");
}

-(void)testPasswordTitleNotEncrypted
{
    RCPassword * password = [[RCPassword  alloc] init];
    password.title = @"Geico";
    [password encrypt];
    XCTAssertTrue([password.title isEqualToString:@"Geico"], @"Password title should not encrypt");
}

-(void)testPasswordURLNotEncrypted
{
    RCPassword * password = [[RCPassword  alloc] init];
    password.urlName = @"www.Geico.com/login";
    [password encrypt];
    XCTAssertTrue([password.urlName isEqualToString:@"www.Geico.com/login"], @"Password URL should not encrypt");
}

-(void)testPasswordDecrypted
{
    RCPassword * password = [[RCPassword  alloc] init];
    password.username = @"demoAccount@gmail.com";
    password.password = @"youWontGuessThisOkMaybeYouWill";
    [password encrypt];
    [password decrypt];
    XCTAssertTrue([password.username isEqualToString:@"demoAccount@gmail.com"], @"username not decrypted right");
    XCTAssertTrue([password.password isEqualToString:@"youWontGuessThisOkMaybeYouWill"], @"password not decrypted right");
}

-(void)testPassPasswordSeveralDecryptions
{
    RCPassword * password = [[RCPassword  alloc] init];
    password.username = @"songBird@robcaraway.com";
    password.password = @"youWontGuessThisOkMaybeYouWill";
    [password encrypt];
    [password decrypt];
    [password encrypt];
    [password decrypt];
    [password encrypt];
    [password decrypt];
    [password encrypt];
    [password decrypt];
    XCTAssertTrue([password.username isEqualToString:@"songBird@robcaraway.com"], @"username not decrypted right");
    XCTAssertTrue([password.password isEqualToString:@"youWontGuessThisOkMaybeYouWill"], @"password not decrypted right");
}



@end
