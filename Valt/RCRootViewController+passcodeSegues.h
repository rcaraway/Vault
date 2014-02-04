//
//  RCRootViewController+passcodeSegues.h
//  Valt
//
//  Created by Robert Caraway on 1/16/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCRootViewController.h"

@interface RCRootViewController (passcodeSegues)

-(void)seguePasscodeToList;
-(void)returnToPasscodeFromList;
-(void)resetToOpen;
-(void)showPasscodeHint;
-(void)movePasscodeToXOrigin:(CGFloat)xOrigin;

@end
