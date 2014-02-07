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


-(BOOL)launchCountTriggered;
-(BOOL)shouldShowRenew;
-(void)resetRenewCount;

@end
