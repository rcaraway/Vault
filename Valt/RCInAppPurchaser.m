 //
//  RCInAppPurchaser.m
//  Vault
//
//  Created by Robert Caraway on 1/3/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCInAppPurchaser.h"
#import <StoreKit/StoreKit.h>
#import "RCNetworking.h"

#define YEARLY_ID @"year699"
#define MONTHLY_ID @"month199"
#define LOCAL_EXPIRATION @"localExpiration"

NSString * purchaserDidFail = @"purchaserDidFail";
NSString * purchaserDidBeginUpgrading = @"purchaserDidBeginUpgrading";
NSString * purchaserDidPayYearly = @"purchaserDidPayYearly";
NSString * purchaserDidPayMonthly = @"purchaserDidPayMonthly";
NSString * purchaseDidLoadProducts = @"purchaseDidLoadProducts";

static RCInAppPurchaser * sharedPurchaser;

@interface RCInAppPurchaser () <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property(nonatomic, strong) SKProduct * monthlyProduct;
@property(nonatomic, strong) SKProduct * yearlyProduct;
@property(nonatomic, strong) SKProductsRequest * request;

@end


@implementation RCInAppPurchaser


#pragma mark - Class Methods

+(void)initialize
{
    sharedPurchaser = [[RCInAppPurchaser alloc] init];
}

+(RCInAppPurchaser *)sharePurchaser
{
    return sharedPurchaser;
}


#pragma mark - Actions

-(void)loadProducts
{
    _loadingProducts = YES;
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [self requestProducts];
}

-(void)purchaseMonth
{
    if (self.monthlyProduct){
        SKPayment *payment = [SKPayment paymentWithProduct:self.monthlyProduct];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

-(void)purchaseYear
{
    if (self.yearlyProduct){
        SKPayment *payment = [SKPayment paymentWithProduct:self.yearlyProduct];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

-(void)requestProducts
{
    NSSet *productIdentifiers = [NSSet setWithArray:@[YEARLY_ID, MONTHLY_ID]];
    self.request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    self.request.delegate = self;
    [self.request start];
}

-(BOOL)productsExist
{
    return self.monthlyProduct != nil && self.yearlyProduct != nil;
}

#pragma mark - Product Delegate

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray * products = response.products;
    [self setProducts:products];
    _loadingProducts = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:purchaseDidLoadProducts object:nil];
}


#pragma mark - Payment Delegate

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                [[NSNotificationCenter defaultCenter] postNotificationName:purchaserDidBeginUpgrading object:nil];
                break;
        }
    }
}

-(void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads
{
}


#pragma mark - Setter Getters

-(BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
}

-(void)setProducts:(NSArray *)array
{
    if (array.count > 0){
        NSString * productId = [array[0] productIdentifier];
        if ([productId isEqualToString:YEARLY_ID]){
            self.yearlyProduct = array[0];
        }else{
            self.monthlyProduct = array[0];
        }
    }
    if (array.count > 1){
        NSString * productId = [array[1] productIdentifier];
        if ([productId isEqualToString:YEARLY_ID]){
            self.yearlyProduct = array[1];
        }else{
            self.monthlyProduct = array[1];
        }
    }
}

-(NSString *)localizedPriceForMonthly
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:self.monthlyProduct.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:self.monthlyProduct.price];
    return formattedString;
}

-(NSString *)localizedPriceForYearly
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:self.yearlyProduct.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:self.yearlyProduct.price];
    return formattedString;
}


#pragma mark - Convenience

//
// called when the transaction was successful
//
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction];
    [self enablePremium:transaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction.originalTransaction];
    [self enablePremium:transaction.originalTransaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // error!
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else
    {
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    NSDate * localExpire = [self dateForId:transaction.payment.productIdentifier];
    [[NSUserDefaults standardUserDefaults] setObject:localExpire forKey:LOCAL_EXPIRATION];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)enablePremium:(NSString *)productId
{
    NSDate * date = [self dateForId:productId];
    [[RCNetworking sharedNetwork] extendPremiumToDate:date];
}

-(NSDate *)dateForId:(NSString *)productID
{
    NSDate * localExpire;
    if ([productID isEqualToString:YEARLY_ID])
    {
        NSDate *today = [[NSDate alloc] init];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        [offsetComponents setYear:1];
        localExpire = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
    }else if ([productID isEqualToString:MONTHLY_ID]){
        NSDate *today = [[NSDate alloc] init];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        [offsetComponents setYear:1];
        localExpire = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
    }
    return localExpire;
}

//
// removes the transaction from the queue and posts a notification with the transaction result
//
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    if (wasSuccessful)
    {
        if ([transaction.payment.productIdentifier isEqualToString:MONTHLY_ID]){
            [[NSNotificationCenter defaultCenter] postNotificationName:purchaserDidPayMonthly object:nil];
        }else if ([transaction.payment.productIdentifier isEqualToString:YEARLY_ID]){
            [[NSNotificationCenter defaultCenter] postNotificationName:purchaserDidPayYearly object:nil];
        }
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:purchaserDidFail object:nil];
        
    }
}

@end
