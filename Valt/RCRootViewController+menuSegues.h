//
//  RCRootViewController+menuSegues.h
//  Valt
//
//  Created by Rob Caraway on 1/24/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCRootViewController.h"

@interface RCRootViewController (menuSegues)

-(void)segueToMenu;
-(void)closeMenu;
-(void)goHome;
-(void)closeToNewViewController:(UIViewController *)controller title:(NSString *)title color:(UIColor *)color;

-(void)beginListDragToMenu;
-(void)beginDragToMenu;
-(void)dragSideToXOrigin:(CGFloat)xOrigin;
-(void)finishDragWithClose;
-(void)finishDragWithSegue;

@end
