//
//  RCAppDelegate.h
//  Valt
//
//  Created by Rob Caraway on 12/10/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RCRootViewController;


@interface RCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(nonatomic, strong) RCRootViewController * rootController;

@property (nonatomic) BOOL secureNoteTip;
@property(nonatomic) BOOL locksOnClose;
@property (nonatomic) BOOL swipeRightHint;
@property (nonatomic) BOOL autofillHints;

-(void)trackEvent:(NSString *)event properties:(NSDictionary *)properties;
-(void)incrementEvent:(NSString *)event byAmount:(NSInteger)amount;
-(void)setPersonalObject:(NSString *)object forKey:(NSString *)key;
-(BOOL)launchCountTriggered;
-(BOOL)shouldShowRenew;

@end
