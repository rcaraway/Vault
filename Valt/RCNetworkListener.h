//
//  RCNetworkQueue.h
//  Valt
//
//  Created by Robert Caraway on 12/31/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

// This class is completely REACTIVE.
// Reacts to events that should trigger
// other networking events or other management
// events

#import <Foundation/Foundation.h>

@interface RCNetworkListener : NSObject

+(void)beginListening;
+(void)stopListening;
+(void)setLoginAfterUse;
+(BOOL)isListening;

@end
