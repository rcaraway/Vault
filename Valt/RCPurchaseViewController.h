//
//  RCPurchaseViewController.h
//  Valt
//
//  Created by Robert Caraway on 12/19/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCPurchaseViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *monthlyButton;
@property (strong, nonatomic) IBOutlet UIButton *yearlyButton;
@property (strong, nonatomic) IBOutlet UILabel *multiDeviceLabel;
@property (strong, nonatomic) IBOutlet UILabel *cloudBackupLabel;
@property (strong, nonatomic) IBOutlet UILabel *unlimtedLabel;
@property (strong, nonatomic) IBOutlet UIButton *restorePurchaseButton;
@property (strong, nonatomic) IBOutlet UIImageView *backImageView;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;


@end
