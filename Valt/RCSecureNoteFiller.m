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
    if ([[RCPasswordManager defaultManager] accessGranted]){
        NSString * secureNotes = [[RCPasswordManager defaultManager] secureNotes];
        NSMutableArray * allWords = [NSMutableArray new];
        self.autofillPairs = [NSMutableDictionary new];
        NSArray * lines =  [secureNotes componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        for (NSString * line in lines) {
            NSArray * subLines = [line componentsSeparatedByString:@":"];
            if (subLines.count == 2){
                NSString * subLineOne = [subLines[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSString * subLineTwo = [subLines[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                [self.autofillPairs setObject:subLineTwo forKey:subLineOne];
                [allWords addObject:subLineOne];
                [allWords addObject:subLineTwo];
            }else{
                [allWords addObject:line];
            }
        }
        self.lineNotes = [allWords copy];
    }else{
        self.lineNotes = nil;
        self.autofillPairs = nil;
    }
}

-(void)hideNotesFilling
{
    self.lineNotes = nil;
    self.autofillPairs = nil;
}

-(NSString *)autoFillForKey:(NSString *)key
{
    return [self.autofillPairs objectForKey:key];
}

-(void)autoFillForString:(NSString *)string completion:(void(^)(NSArray *))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray * array;
        if (string.length > 0){
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", string];
            array = [self.lineNotes filteredArrayUsingPredicate:predicate];
        }else{
            array = self.lineNotes;
        }
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
             @"Phone Number",
             @"Website",
             @"Name",
             @"Passport number",
             @"Driver's license ID",
             @"Savings Account",
             @"Checking Account",
             @"Business Account",
             @"American Express:",
             @"MasterCard",
             @""];
}

@end
