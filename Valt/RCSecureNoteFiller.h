//
//  RCSecureNoteFiller.h
//  Valt
//
//  Created by Robert Caraway on 4/14/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import <Foundation/Foundation.h>


@class RCPassword;
@interface RCSecureNoteFiller : NSObject

@property(nonatomic, strong) RCPassword * appendedPassword;

+(RCSecureNoteFiller *)sharedFiller;

-(void)updateSecureNotesFill;
-(void)autoFillForString:(NSString *)string completion:(void(^)(NSArray *))completion;
-(NSString *)autoFilledTitleForLine:(NSString *)line;


@end
