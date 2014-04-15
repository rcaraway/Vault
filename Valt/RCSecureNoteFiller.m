//
//  RCSecureNoteFiller.m
//  Valt
//
//  Created by Robert Caraway on 4/14/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCSecureNoteFiller.h"
#import "RCPasswordManager.h"

static RCSecureNoteFiller * sharedFiller;

@interface RCSecureNoteFiller ()

@property(nonatomic, strong) NSArray * lineNotes;
@property(nonatomic, strong) NSMutableArray * nonPasswordNotes;
@property(nonatomic, strong) NSMutableDictionary * autofillPairs;

@end


@implementation RCSecureNoteFiller


#pragma mark - Class Method

+(void)initialize
{
    sharedFiller = [[RCSecureNoteFiller alloc] init];
}

+(RCSecureNoteFiller *)sharedFiller
{
    return sharedFiller;
}


-(id)init
{
    self = super.init;
    if (self){
        [self updateSecureNotesFill];
    }
    return self;
}

-(void)updateSecureNotesFill
{
    NSString * secureNotes = [[RCPasswordManager defaultManager] secureNotes];
    NSArray * lines =  [secureNotes componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    self.nonPasswordNotes = [lines mutableCopy];
}

-(NSArray *)lineNotes
{
    NSMutableArray * array = [self.nonPasswordNotes mutableCopy];
    if (self.appendedPassword){
        NSArray * lines = [self.appendedPassword.notes componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [array addObjectsFromArray:lines];
    }
    return array;
}

-(void)autoFillForString:(NSString *)string completion:(void(^)(NSArray *))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", string];
        NSArray * array = [self.lineNotes filteredArrayUsingPredicate:predicate];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(array);
        });
    });
}

-(NSString *)autoFilledTitleForLine:(NSString *)line
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", line];
    NSArray * array = [[self titleAutofills] filteredArrayUsingPredicate:predicate];
    if (array.count > 0){
        return array[0];
    }
    return nil;
}

-(NSArray *)titleAutofills
{
    return @[@"Social Security #",
             @"SSN",
             @"Bank Account",
             @"Credit Card #",
             @"Debit Card #",
             @"Email",
             @"Birthday",
             @"Savings Account #",
             @"Zip Code",
             @"Billing Address",
             @"Home Address",
             @"Address",
             @"State",
             @"Country",
             @"Age",
             @"Bank",
             @"Credit Card Expiration",
             @"Debit Card Expiration",
             @"Visa Card",
             @"Mobile Number",
             @"Phone Number"];
}

@end
