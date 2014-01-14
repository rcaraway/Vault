//
//  MLAlertView.h
//  MLAlertView
//
//  Copyright (c) 2013 Maximilian Litteral.
//  See LICENSE for full license agreement.
//

#import <UIKit/UIKit.h>

@class MLAlertView;
@class HTAutocompleteTextField;

typedef void (^MLAlertTapButtonBlock)(MLAlertView *alertView, NSInteger buttonIndex);

@protocol MLAlertViewDelegate <NSObject>

- (void)alertView:(MLAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)alertView:(MLAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex withEmail:(NSString *)email password:(NSString *)password;
-(void)alertView:(MLAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex withText:(NSString *)text;
-(void)alertViewTappedCancel:(MLAlertView *)alertView;

@end



@interface MLAlertView : UIView

@property (nonatomic, assign) id<MLAlertViewDelegate> delegate;
@property (nonatomic, copy) MLAlertTapButtonBlock buttonDidTappedBlock;
@property(nonatomic, strong) HTAutocompleteTextField * loginTextField;
@property(nonatomic, strong) UILabel * titleLabel;
@property(nonatomic, strong) UITextField * passwordTextField;



- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id /*<UIAlertViewDelegate>*/)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles;
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles;
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles usingBlockWhenTapButton:(MLAlertTapButtonBlock)tapButtonBlock;
-(instancetype)initWithTitle:(NSString *)title textFields:(BOOL)textFields delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle confirmButtonTitle:(NSString *)confirmButtonTitle;
-(instancetype)initWithTextfieldWithPlaceholder:(NSString *)placeholder title:(NSString *)title delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle confirmButtonTitle:(NSString *)confirmButtonTitle;

-(void)clearText;
-(void)show;
-(void)dismiss;
-(void)loadWithText:(NSString *)text;
-(void)dismissWithSuccessTitle:(NSString *)title;
-(void)showFailWithTitle:(NSString *)title;

@end
