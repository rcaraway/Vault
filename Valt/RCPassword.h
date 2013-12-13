//
//  RCPassword.h
//  Valt
//
//  Created by Rob Caraway on 12/10/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AutoCoding.h"

@interface RCPassword : NSObject

@property(nonatomic, copy) NSString * title;
@property(nonatomic, copy) NSString * username;
@property(nonatomic, copy) NSString * password;
@property(nonatomic, strong) NSMutableArray * extraFields;

-(NSArray *)allFields;

@end
