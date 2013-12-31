//
//  NSIndexPath+VaultPaths.h
//  Valt
//
//  Created by Robert Caraway on 12/31/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSIndexPath (VaultPaths)

+(NSArray *)insertedIndexPathsForFetchedResults:(NSArray *)passwords;
+(NSArray *)removedIndexPathsForFetchedResults:(NSArray *)passwords;

+(NSArray *)insertedIndexPathsForMergedResults:(NSArray *)passwords;

@end
