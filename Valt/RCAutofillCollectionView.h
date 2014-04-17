//
//  RCAutofillCollectionView.h
//  Valt
//
//  Created by Rob Caraway on 4/16/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RCPassword;
@interface RCAutofillCollectionView : UICollectionView

@property(nonatomic, weak) RCPassword * password;

-(id)initWithPassword:(RCPassword *)password;

-(void)filterWithString:(NSString *)string;

@end

extern NSString * const didTapAutofillForWeb;