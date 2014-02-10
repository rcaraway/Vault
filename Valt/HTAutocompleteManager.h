//
//  HTAutocompleteManager.h
//  HotelTonight
//
//  Created by Jonathan Sibley on 12/6/12.
//  Copyright (c) 2012 Hotel Tonight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTAutocompleteTextField.h"

typedef enum {
    RCAutocompleteTypeUsername, // Default
    RCAutoCompleteTypeEmailOnly,
    RCAutocompleteTypeTitle,
    RCAutocompleteTypePassword,
    RCAutocompleteTypeURL,
    RCAutoCompleteTypeNone
} RCAutoCompleteType;

@interface HTAutocompleteManager : NSObject <HTAutocompleteDataSource>

+ (HTAutocompleteManager *)sharedManager;
-(NSDictionary *)titleUrlPairs;

@end
