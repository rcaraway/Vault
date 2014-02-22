//
//  RCInAppPurchaser.h
//  Vault
//
//  Created by Robert Caraway on 1/3/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCInAppPurchaser : NSObject

@property(nonatomic, readonly) BOOL canMakePurchases;
@property (nonatomic, readonly) BOOL loadingProducts;

-(NSString *)localizedPriceForMonthly;
-(NSString *)localizedPriceForYearly;
-(BOOL)productsExist;

-(void)loadProducts;
-(void)purchaseMonth;
-(void)purchaseYear;

+(RCInAppPurchaser *)sharePurchaser;

@end

extern NSString * purchaserDidBeginUpgrading;
extern NSString * purchaserDidPayYearly;
extern NSString * purchaserDidFail;
extern NSString * purchaserDidPayMonthly;
extern NSString * purchaseDidLoadProducts;
extern NSString * const purchaserDidFailToLoadProducts;


