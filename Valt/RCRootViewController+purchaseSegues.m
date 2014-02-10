//
//  RCRootViewController+purchaseSegues.m
//  Valt
//
//  Created by Robert Caraway on 2/3/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCRootViewController+purchaseSegues.h"

#import "RCListViewController.h"
#import "RCPurchaseViewController.h"

#import "UIColor+RCColors.h"

@implementation RCRootViewController (purchaseSegues)

-(void)segueToPurchaseFromList
{
    [self.listController removeFromParentViewController];
    [self addChildViewController:self.purchaseController];
    [self setNavBarAlternateWithTitle:@"Go Platinum" color:[UIColor goPlatinumColor]];
    [self.purchaseController.view setFrame:CGRectOffset(self.purchaseController.view.frame, 0, [UIScreen mainScreen].bounds.size.height)];
    [self.view addSubview:self.purchaseController.view];
    
    [UIView animateWithDuration:.4 animations:^{
        [self.purchaseController.view setFrame:CGRectOffset(self.purchaseController.view.frame, 0, -[UIScreen mainScreen].bounds.size.height)];
        self.listController.view.transform = CGAffineTransformMakeScale(.97, .97);
    }completion:^(BOOL finished) {
        [self.listController.view removeFromSuperview];
        self.listController.view.transform = CGAffineTransformIdentity;
    }];
}

@end
